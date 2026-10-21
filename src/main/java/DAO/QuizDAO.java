/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import config.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import model.QuizInfo;
import model.QuizAttemptData;
import model.QuizQuestion;
import model.QuizOption;

public class QuizDAO {

    private long lockEnrollment(Connection connection, long studentId,
            long quizId) throws SQLException {

        String sql = "SELECT e.EnrollmentId FROM Enrollments e WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN Users u ON u.UserId = e.StudentId "
                + "JOIN Courses c ON c.CourseId = e.CourseId "
                + "JOIN Quizzes q ON q.CourseId = e.CourseId "
                + "WHERE e.StudentId = ? AND q.QuizId = ? "
                + "AND e.AccessStatus = 'ACTIVE' AND u.Status = 'ACTIVE' "
                + "AND c.Status IN ('PUBLISHED', 'ARCHIVED')";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, studentId);
            statement.setLong(2, quizId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("EnrollmentId");
                }
            }
        }
        throw new SecurityException("Bạn không có quyền làm bài kiểm tra này.");
    }

    private long findQuizId(Connection connection, long studentId,
            long attemptId) throws SQLException {

        String sql = "SELECT a.QuizId FROM QuizAttempts a "
                + "JOIN Enrollments e ON e.EnrollmentId = a.EnrollmentId "
                + "WHERE a.AttemptId = ? AND e.StudentId = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, attemptId);
            statement.setLong(2, studentId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("QuizId");
                }
            }
        }
        throw new SecurityException("Không tìm thấy lượt thi thuộc tài khoản của bạn.");
    }

    private QuizAttemptData readAttempt(Connection connection,
            long attemptId, long enrollmentId) throws SQLException {

        String sql = "SELECT a.*, q.Title, "
                + "DATEDIFF_BIG(SECOND, SYSUTCDATETIME(), a.ExpiresAt) AS RemainingSeconds "
                + "FROM QuizAttempts a WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN Quizzes q ON q.QuizId = a.QuizId "
                + "WHERE a.AttemptId = ? AND a.EnrollmentId = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, attemptId);
            statement.setLong(2, enrollmentId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    QuizAttemptData attempt = new QuizAttemptData();
                    attempt.setAttemptId(attemptId);
                    attempt.setQuizId(result.getLong("QuizId"));
                    attempt.setCourseId(result.getLong("CourseId"));
                    attempt.setEnrollmentId(enrollmentId);
                    attempt.setTitle(result.getString("Title"));
                    attempt.setStatus(result.getString("Status"));
                    attempt.setFinishReason(result.getString("FinishReason"));
                    attempt.setAttemptNumber(result.getInt("AttemptNumber"));
                    attempt.setRemainingSeconds(result.getLong("RemainingSeconds"));
                    attempt.setTotalPoints(result.getBigDecimal("TotalPoints"));
                    attempt.setEarnedPoints(result.getBigDecimal("EarnedPoints"));
                    attempt.setScore(result.getBigDecimal("Score"));
                    attempt.setPassingScore(result.getBigDecimal("PassingScoreSnapshot"));
                    return attempt;
                }
            }
        }
        throw new SecurityException("Không tìm thấy lượt thi hợp lệ.");
    }

    private void finish(Connection connection, QuizAttemptData attempt,
            String reason) throws SQLException {

        String scoreSql = "UPDATE aa SET AwardedPoints = "
                + "CASE WHEN ao.IsCorrect = 1 THEN aa.QuestionPoints ELSE 0 END "
                + "FROM AttemptAnswers aa LEFT JOIN AnswerOptions ao "
                + "ON ao.OptionId = aa.SelectedOptionId AND ao.QuestionId = aa.QuestionId "
                + "WHERE aa.AttemptId = ?";

        try (PreparedStatement statement = connection.prepareStatement(scoreSql)) {
            statement.setLong(1, attempt.getAttemptId());
            statement.executeUpdate();
        }

        String finishSql = "UPDATE QuizAttempts SET Status = 'FINISHED', "
                + "FinalizedAt = SYSUTCDATETIME(), FinishReason = ?, "
                + "EarnedPoints = (SELECT ISNULL(SUM(AwardedPoints), 0) "
                + "FROM AttemptAnswers WHERE AttemptId = ?) "
                + "WHERE AttemptId = ? AND Status = 'IN_PROGRESS'";

        try (PreparedStatement statement = connection.prepareStatement(finishSql)) {
            statement.setString(1, reason);
            statement.setLong(2, attempt.getAttemptId());
            statement.setLong(3, attempt.getAttemptId());
            statement.executeUpdate();
        }

        String completeSql = "UPDATE Enrollments SET CompletedAt = SYSUTCDATETIME() "
                + "WHERE EnrollmentId = ? AND CompletedAt IS NULL "
                + "AND EXISTS (SELECT 1 FROM vEnrollmentProgress p "
                + "WHERE p.EnrollmentId = Enrollments.EnrollmentId "
                + "AND p.IsEligibleForCompletion = 1)";

        try (PreparedStatement statement = connection.prepareStatement(completeSql)) {
            statement.setLong(1, attempt.getEnrollmentId());
            statement.executeUpdate();
        }
    }

    private void loadLessonProgress(Connection connection, long enrollmentId,
            QuizInfo quiz) throws SQLException {
        String sql = "SELECT COUNT(l.LessonId) AS TotalLessons, "
                + "COUNT(lp.CompletedAt) AS CompletedLessons "
                + "FROM Enrollments e JOIN Lessons l ON l.CourseId = e.CourseId "
                + "AND l.IsRequired = 1 LEFT JOIN LessonProgress lp "
                + "ON lp.EnrollmentId = e.EnrollmentId AND lp.LessonId = l.LessonId "
                + "AND lp.CourseId = e.CourseId WHERE e.EnrollmentId = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, enrollmentId);
            try (ResultSet result = statement.executeQuery()) {
                result.next();
                quiz.setTotalRequiredLessons(result.getInt("TotalLessons"));
                quiz.setCompletedRequiredLessons(result.getInt("CompletedLessons"));
            }
        }
    }

    public QuizInfo getInfo(long studentId, long quizId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long enrollmentId = lockEnrollment(connection, studentId, quizId);
                String sql = "SELECT q.*, "
                        + "(SELECT COUNT(*) FROM Questions qu WHERE qu.QuizId = q.QuizId) AS QuestionCount, "
                        + "(SELECT COUNT(*) FROM QuizAttempts a WHERE a.EnrollmentId = ? AND a.QuizId = q.QuizId) AS UsedAttempts, "
                        + "CASE WHEN EXISTS (SELECT 1 FROM QuizAttempts a WHERE a.EnrollmentId = ? "
                        + "AND a.QuizId = q.QuizId AND a.Status = 'FINISHED' "
                        + "AND a.Score >= a.PassingScoreSnapshot) THEN 1 ELSE 0 END AS Passed "
                        + "FROM Quizzes q WHERE q.QuizId = ?";

                QuizInfo quiz = new QuizInfo();
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setLong(1, enrollmentId);
                    statement.setLong(2, enrollmentId);
                    statement.setLong(3, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new SecurityException("Không tìm thấy đề kiểm tra.");
                        }
                        quiz.setQuizId(quizId);
                        quiz.setCourseId(result.getLong("CourseId"));
                        quiz.setTitle(result.getString("Title"));
                        quiz.setDescription(result.getString("Description"));
                        quiz.setDurationMinutes(result.getInt("DurationMinutes"));
                        quiz.setMaxAttempts(result.getInt("MaxAttempts"));
                        quiz.setPassingScore(result.getBigDecimal("PassingScore"));
                        quiz.setRequired(result.getBoolean("IsRequired"));
                        quiz.setQuestionCount(result.getInt("QuestionCount"));
                        quiz.setUsedAttempts(result.getInt("UsedAttempts"));
                        quiz.setPassed(result.getBoolean("Passed"));
                    }
                }

                loadLessonProgress(connection, enrollmentId, quiz);

                String activeSql = "SELECT AttemptId, CASE WHEN ExpiresAt <= SYSUTCDATETIME() "
                        + "THEN 1 ELSE 0 END AS Expired FROM QuizAttempts "
                        + "WHERE EnrollmentId = ? AND QuizId = ? AND Status = 'IN_PROGRESS'";
                try (PreparedStatement statement = connection.prepareStatement(activeSql)) {
                    statement.setLong(1, enrollmentId);
                    statement.setLong(2, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            quiz.setActiveAttemptId(result.getLong("AttemptId"));
                            quiz.setActiveExpired(result.getBoolean("Expired"));
                        }
                    }
                }
                connection.commit();
                return quiz;
            } catch (SQLException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    public long start(long studentId, long quizId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long enrollmentId = lockEnrollment(connection, studentId, quizId);
                long activeId = 0;
                String activeSql = "SELECT AttemptId FROM QuizAttempts "
                        + "WHERE EnrollmentId = ? AND QuizId = ? AND Status = 'IN_PROGRESS'";
                try (PreparedStatement statement = connection.prepareStatement(activeSql)) {
                    statement.setLong(1, enrollmentId);
                    statement.setLong(2, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            activeId = result.getLong("AttemptId");
                        }
                    }
                }
                if (activeId != 0) {
                    QuizAttemptData active = readAttempt(connection, activeId, enrollmentId);
                    if (active.getRemainingSeconds() <= 0) {
                        finish(connection, active, "TIMEOUT");
                    }
                    connection.commit();
                    return activeId;
                }

                QuizInfo eligibility = new QuizInfo();
                loadLessonProgress(connection, enrollmentId, eligibility);
                if (!eligibility.isLessonsCompleted()) {
                    throw new IllegalArgumentException(
                            "Bạn cần hoàn thành tất cả bài học bắt buộc trước khi làm kiểm tra.");
                }

                int used = 0;
                int lastNumber = 0;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT COUNT(*) AS Used, ISNULL(MAX(AttemptNumber), 0) AS LastNumber "
                        + "FROM QuizAttempts WHERE EnrollmentId = ? AND QuizId = ?")) {
                    statement.setLong(1, enrollmentId);
                    statement.setLong(2, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        result.next();
                        used = result.getInt("Used");
                        lastNumber = result.getInt("LastNumber");
                    }
                }

                int duration;
                int maxAttempts;
                long courseId;
                BigDecimal passingScore;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT DurationMinutes, MaxAttempts, CourseId, PassingScore "
                        + "FROM Quizzes WITH (HOLDLOCK) WHERE QuizId = ?")) {
                    statement.setLong(1, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException("Không tìm thấy đề.");
                        }
                        duration = result.getInt("DurationMinutes");
                        maxAttempts = result.getInt("MaxAttempts");
                        courseId = result.getLong("CourseId");
                        passingScore = result.getBigDecimal("PassingScore");
                    }
                }
                if (used >= maxAttempts) {
                    throw new IllegalArgumentException("Bạn đã hết lượt làm bài.");
                }

                BigDecimal total = BigDecimal.ZERO;
                int questions = 0;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT q.Points, COUNT(o.OptionId) AS OptionsCount, "
                        + "SUM(CASE WHEN o.IsCorrect = 1 THEN 1 ELSE 0 END) AS CorrectCount "
                        + "FROM Questions q WITH (HOLDLOCK) "
                        + "LEFT JOIN AnswerOptions o WITH (HOLDLOCK) ON o.QuestionId = q.QuestionId "
                        + "WHERE q.QuizId = ? GROUP BY q.QuestionId, q.Points")) {
                    statement.setLong(1, quizId);
                    try (ResultSet result = statement.executeQuery()) {
                        while (result.next()) {
                            if (result.getInt("OptionsCount") < 2 || result.getInt("CorrectCount") != 1) {
                                throw new IllegalArgumentException("Đề có câu hỏi chưa đủ lựa chọn hoặc đáp án đúng.");
                            }
                            questions++;
                            total = total.add(result.getBigDecimal("Points"));
                        }
                    }
                }
                if (questions == 0 || total.signum() <= 0) {
                    throw new IllegalArgumentException("Đề chưa có câu hỏi hợp lệ.");
                }

                long attemptId;
                String insertSql = "INSERT INTO QuizAttempts (EnrollmentId, QuizId, CourseId, "
                        + "AttemptNumber, StartedAt, ExpiresAt, Status, PassingScoreSnapshot, TotalPoints) "
                        + "VALUES (?, ?, ?, ?, SYSUTCDATETIME(), "
                        + "DATEADD(MINUTE, ?, SYSUTCDATETIME()), 'IN_PROGRESS', ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(
                        insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setLong(1, enrollmentId);
                    statement.setLong(2, quizId);
                    statement.setLong(3, courseId);
                    statement.setInt(4, lastNumber + 1);
                    statement.setInt(5, duration);
                    statement.setBigDecimal(6, passingScore);
                    statement.setBigDecimal(7, total);
                    statement.executeUpdate();
                    try (ResultSet result = statement.getGeneratedKeys()) {
                        if (!result.next()) {
                            throw new SQLException("Không lấy được mã lượt thi.");
                        }
                        attemptId = result.getLong(1);
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(
                        "INSERT INTO AttemptAnswers (AttemptId, QuizId, QuestionId, QuestionPoints) "
                        + "SELECT ?, QuizId, QuestionId, Points FROM Questions WHERE QuizId = ?")) {
                    statement.setLong(1, attemptId);
                    statement.setLong(2, quizId);
                    statement.executeUpdate();
                }
                connection.commit();
                return attemptId;
            } catch (SQLException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    public QuizAttemptData getAttempt(long studentId, long attemptId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long quizId = findQuizId(connection, studentId, attemptId);
                long enrollmentId = lockEnrollment(connection, studentId, quizId);
                QuizAttemptData attempt = readAttempt(connection, attemptId, enrollmentId);
                if ("IN_PROGRESS".equals(attempt.getStatus()) && attempt.getRemainingSeconds() <= 0) {
                    finish(connection, attempt, "TIMEOUT");
                    attempt = readAttempt(connection, attemptId, enrollmentId);
                }
                if ("IN_PROGRESS".equals(attempt.getStatus())) {
                    List<QuizQuestion> questions = new ArrayList<>();
                    String sql = "SELECT q.QuestionId, q.Content, aa.QuestionPoints, aa.SelectedOptionId "
                            + "FROM AttemptAnswers aa JOIN Questions q ON q.QuestionId = aa.QuestionId "
                            + "AND q.QuizId = aa.QuizId WHERE aa.AttemptId = ? ORDER BY q.SortOrder, q.QuestionId";
                    try (PreparedStatement statement = connection.prepareStatement(sql)) {
                        statement.setLong(1, attemptId);
                        try (ResultSet result = statement.executeQuery()) {
                            while (result.next()) {
                                QuizQuestion question = new QuizQuestion();
                                question.setId(result.getLong("QuestionId"));
                                question.setContent(result.getString("Content"));
                                question.setPoints(result.getBigDecimal("QuestionPoints"));
                                question.setSelectedOptionId(result.getLong("SelectedOptionId"));
                                questions.add(question);
                            }
                        }
                    }
                    for (QuizQuestion question : questions) {
                        List<QuizOption> options = new ArrayList<>();
                        try (PreparedStatement statement = connection.prepareStatement(
                                "SELECT OptionId, Content FROM AnswerOptions "
                                + "WHERE QuestionId = ? ORDER BY SortOrder, OptionId")) {
                            statement.setLong(1, question.getId());
                            try (ResultSet result = statement.executeQuery()) {
                                while (result.next()) {
                                    QuizOption option = new QuizOption();
                                    option.setId(result.getLong("OptionId"));
                                    option.setContent(result.getString("Content"));
                                    options.add(option);
                                }
                            }
                        }
                        question.setOptions(options);
                    }
                    attempt.setQuestions(questions);
                }
                connection.commit();
                return attempt;
            } catch (SQLException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    public boolean save(long studentId, long attemptId,
            Map<Long, Long> answers, boolean submit) throws SQLException {

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long quizId = findQuizId(connection, studentId, attemptId);
                long enrollmentId = lockEnrollment(connection, studentId, quizId);
                QuizAttemptData attempt = readAttempt(connection, attemptId, enrollmentId);
                if ("FINISHED".equals(attempt.getStatus())) {
                    connection.commit();
                    return true;
                }
                if (attempt.getRemainingSeconds() <= 0) {
                    finish(connection, attempt, "TIMEOUT");
                    connection.commit();
                    return true;
                }

                String updateSql = "UPDATE aa SET SelectedOptionId = ?, SavedAt = SYSUTCDATETIME() "
                        + "FROM AttemptAnswers aa WHERE aa.AttemptId = ? AND aa.QuestionId = ? "
                        + "AND EXISTS (SELECT 1 FROM AnswerOptions o "
                        + "WHERE o.OptionId = ? AND o.QuestionId = aa.QuestionId)";
                for (Map.Entry<Long, Long> answer : answers.entrySet()) {
                    try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                        statement.setLong(1, answer.getValue());
                        statement.setLong(2, attemptId);
                        statement.setLong(3, answer.getKey());
                        statement.setLong(4, answer.getValue());
                        if (statement.executeUpdate() != 1) {
                            throw new IllegalArgumentException("Đáp án hoặc câu hỏi không thuộc lượt thi.");
                        }
                    }
                }

                if (submit) {
                    String reason = "SUBMITTED";
                    try (PreparedStatement statement = connection.prepareStatement(
                            "SELECT CASE WHEN ExpiresAt <= SYSUTCDATETIME() THEN 1 ELSE 0 END "
                            + "FROM QuizAttempts WHERE AttemptId = ?")) {
                        statement.setLong(1, attemptId);
                        try (ResultSet result = statement.executeQuery()) {
                            result.next();
                            if (result.getInt(1) == 1) {
                                throw new IllegalStateException("EXPIRED_DURING_SAVE");
                            }
                        }
                    }
                    finish(connection, attempt, reason);
                } else {
                    try (PreparedStatement statement = connection.prepareStatement(
                            "SELECT CASE WHEN ExpiresAt <= SYSUTCDATETIME() THEN 1 ELSE 0 END "
                            + "FROM QuizAttempts WHERE AttemptId = ?")) {
                        statement.setLong(1, attemptId);
                        try (ResultSet result = statement.executeQuery()) {
                            result.next();
                            if (result.getInt(1) == 1) {
                                throw new IllegalStateException("EXPIRED_DURING_SAVE");
                            }
                        }
                    }
                }
                connection.commit();
                return submit;
            } catch (IllegalStateException ex) {
                connection.rollback();
                if (!"EXPIRED_DURING_SAVE".equals(ex.getMessage())) {
                    throw ex;
                }
                long quizId = findQuizId(connection, studentId, attemptId);
                long enrollmentId = lockEnrollment(connection, studentId, quizId);
                QuizAttemptData attempt = readAttempt(connection, attemptId, enrollmentId);
                if ("IN_PROGRESS".equals(attempt.getStatus())) {
                    finish(connection, attempt, "TIMEOUT");
                }
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    public List<QuizInfo> getCourseQuizzes(long studentId, long courseId) throws SQLException {
        List<QuizInfo> result = new ArrayList<>();
        for (QuizInfo quiz : getQuizList(courseId)) {
            result.add(getInfo(studentId, quiz.getQuizId()));
        }
        return result;
    }

    public List<QuizInfo> getQuizList(long courseId) throws SQLException {
        List<QuizInfo> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT QuizId, Title FROM Quizzes WHERE CourseId = ? ORDER BY SortOrder, QuizId")) {
            statement.setLong(1, courseId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    QuizInfo quiz = new QuizInfo();
                    quiz.setQuizId(result.getLong("QuizId"));
                    quiz.setTitle(result.getString("Title"));
                    quiz.setCourseId(courseId);
                    list.add(quiz);
                }
            }
        }
        return list;
    }
}
