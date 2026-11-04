package dao;

import model.QuizInfo;
import model.QuizOption;
import model.QuizQuestion;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class InstructorQuizDAO {

    public boolean checkCourseOwnership(Connection conn, long courseId, long instructorId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.Courses WHERE CourseId = ? AND InstructorId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, courseId);
            ps.setLong(2, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean checkQuizOwnership(Connection conn, long quizId, long instructorId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.Quizzes q "
                   + "JOIN dbo.Courses c ON q.CourseId = c.CourseId "
                   + "WHERE q.QuizId = ? AND c.InstructorId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, quizId);
            ps.setLong(2, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean checkQuestionOwnership(Connection conn, long questionId, long instructorId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.Questions qn "
                   + "JOIN dbo.Quizzes q ON qn.QuizId = q.QuizId "
                   + "JOIN dbo.Courses c ON q.CourseId = c.CourseId "
                   + "WHERE qn.QuestionId = ? AND c.InstructorId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, questionId);
            ps.setLong(2, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean hasQuizAttempts(Connection conn, long quizId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.QuizAttempts WHERE QuizId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public boolean hasQuestionAttempts(Connection conn, long questionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.QuizAttempts qa "
                   + "JOIN dbo.Questions q ON qa.QuizId = q.QuizId "
                   + "WHERE q.QuestionId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<QuizInfo> getQuizzesByCourseId(Connection conn, long courseId, long instructorId) throws SQLException {
        List<QuizInfo> list = new ArrayList<>();
        if (!checkCourseOwnership(conn, courseId, instructorId)) {
            return list;
        }

        String sql = "SELECT q.QuizId, q.CourseId, q.Title, q.Description, q.DurationMinutes, "
                   + "       q.MaxAttempts, q.PassingScore, q.IsRequired, q.SortOrder, "
                   + "       (SELECT COUNT(*) FROM dbo.Questions qn WHERE qn.QuizId = q.QuizId) AS QuestionCount, "
                   + "       (SELECT COUNT(*) FROM dbo.QuizAttempts qa WHERE qa.QuizId = q.QuizId) AS AttemptCount "
                   + "FROM dbo.Quizzes q "
                   + "WHERE q.CourseId = ? "
                   + "ORDER BY q.SortOrder ASC, q.QuizId ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuizInfo quiz = new QuizInfo();
                    quiz.setQuizId(rs.getLong("QuizId"));
                    quiz.setCourseId(rs.getLong("CourseId"));
                    quiz.setTitle(rs.getString("Title"));
                    quiz.setDescription(rs.getString("Description"));
                    quiz.setDurationMinutes(rs.getInt("DurationMinutes"));
                    quiz.setMaxAttempts(rs.getInt("MaxAttempts"));
                    quiz.setPassingScore(rs.getBigDecimal("PassingScore"));
                    quiz.setRequired(rs.getBoolean("IsRequired"));
                    quiz.setSortOrder(rs.getInt("SortOrder"));
                    quiz.setQuestionCount(rs.getInt("QuestionCount"));
                    quiz.setAttemptCount(rs.getInt("AttemptCount"));
                    list.add(quiz);
                }
            }
        }
        return list;
    }

    public QuizInfo getQuizById(Connection conn, long quizId, long instructorId) throws SQLException {
        if (!checkQuizOwnership(conn, quizId, instructorId)) {
            return null;
        }

        String sql = "SELECT q.QuizId, q.CourseId, q.Title, q.Description, q.DurationMinutes, "
                   + "       q.MaxAttempts, q.PassingScore, q.IsRequired, q.SortOrder, "
                   + "       (SELECT COUNT(*) FROM dbo.Questions qn WHERE qn.QuizId = q.QuizId) AS QuestionCount, "
                   + "       (SELECT COUNT(*) FROM dbo.QuizAttempts qa WHERE qa.QuizId = q.QuizId) AS AttemptCount "
                   + "FROM dbo.Quizzes q "
                   + "WHERE q.QuizId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    QuizInfo quiz = new QuizInfo();
                    quiz.setQuizId(rs.getLong("QuizId"));
                    quiz.setCourseId(rs.getLong("CourseId"));
                    quiz.setTitle(rs.getString("Title"));
                    quiz.setDescription(rs.getString("Description"));
                    quiz.setDurationMinutes(rs.getInt("DurationMinutes"));
                    quiz.setMaxAttempts(rs.getInt("MaxAttempts"));
                    quiz.setPassingScore(rs.getBigDecimal("PassingScore"));
                    quiz.setRequired(rs.getBoolean("IsRequired"));
                    quiz.setSortOrder(rs.getInt("SortOrder"));
                    quiz.setQuestionCount(rs.getInt("QuestionCount"));
                    quiz.setAttemptCount(rs.getInt("AttemptCount"));
                    return quiz;
                }
            }
        }
        return null;
    }

    public boolean createQuiz(Connection conn, long courseId, long instructorId, String title, String description,
                              int duration, int maxAttempts, BigDecimal passingScore, boolean isRequired, int sortOrder) throws SQLException {
        if (!checkCourseOwnership(conn, courseId, instructorId)) {
            return false;
        }

        String sql = "INSERT INTO dbo.Quizzes (CourseId, Title, Description, DurationMinutes, MaxAttempts, PassingScore, IsRequired, SortOrder) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, courseId);
            ps.setString(2, title.trim());
            ps.setString(3, description != null ? description.trim() : null);
            ps.setInt(4, duration > 0 ? duration : 20);
            ps.setInt(5, maxAttempts > 0 ? maxAttempts : 3);
            ps.setBigDecimal(6, passingScore != null ? passingScore : new BigDecimal("70.00"));
            ps.setBoolean(7, isRequired);
            ps.setInt(8, sortOrder > 0 ? sortOrder : 1);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateQuiz(Connection conn, long quizId, long instructorId, String title, String description,
                              int duration, int maxAttempts, BigDecimal passingScore, boolean isRequired, int sortOrder) throws SQLException {
        if (!checkQuizOwnership(conn, quizId, instructorId)) {
            return false;
        }
        if (hasQuizAttempts(conn, quizId)) {
            throw new IllegalStateException("Đề kiểm tra này đã có học viên làm bài thi, không được phép thay đổi nội dung.");
        }

        String sql = "UPDATE dbo.Quizzes "
                   + "SET Title = ?, Description = ?, DurationMinutes = ?, MaxAttempts = ?, PassingScore = ?, IsRequired = ?, SortOrder = ? "
                   + "WHERE QuizId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title.trim());
            ps.setString(2, description != null ? description.trim() : null);
            ps.setInt(3, duration > 0 ? duration : 20);
            ps.setInt(4, maxAttempts > 0 ? maxAttempts : 3);
            ps.setBigDecimal(5, passingScore != null ? passingScore : new BigDecimal("70.00"));
            ps.setBoolean(6, isRequired);
            ps.setInt(7, sortOrder > 0 ? sortOrder : 1);
            ps.setLong(8, quizId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteQuiz(Connection conn, long quizId, long instructorId) throws SQLException {
        if (!checkQuizOwnership(conn, quizId, instructorId)) {
            return false;
        }
        if (hasQuizAttempts(conn, quizId)) {
            throw new IllegalStateException("Đề kiểm tra này đã có học viên làm bài thi, không được phép xóa.");
        }

        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Delete answer options
            String delOptionsSql = "DELETE ao FROM dbo.AnswerOptions ao "
                                 + "JOIN dbo.Questions qn ON ao.QuestionId = qn.QuestionId "
                                 + "WHERE qn.QuizId = ?";
            try (PreparedStatement ps = conn.prepareStatement(delOptionsSql)) {
                ps.setLong(1, quizId);
                ps.executeUpdate();
            }

            // 2. Delete questions
            String delQuestionsSql = "DELETE FROM dbo.Questions WHERE QuizId = ?";
            try (PreparedStatement ps = conn.prepareStatement(delQuestionsSql)) {
                ps.setLong(1, quizId);
                ps.executeUpdate();
            }

            // 3. Delete quiz
            String delQuizSql = "DELETE FROM dbo.Quizzes WHERE QuizId = ?";
            int rows;
            try (PreparedStatement ps = conn.prepareStatement(delQuizSql)) {
                ps.setLong(1, quizId);
                rows = ps.executeUpdate();
            }

            conn.commit();
            return rows > 0;
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(autoCommit);
        }
    }

    // Question & Answer Options Methods
    public List<QuizQuestion> getQuestionsByQuizId(Connection conn, long quizId, long instructorId) throws SQLException {
        List<QuizQuestion> list = new ArrayList<>();
        if (!checkQuizOwnership(conn, quizId, instructorId)) {
            return list;
        }

        String sqlQuestions = "SELECT QuestionId, QuizId, Content, Explanation, Points, SortOrder "
                            + "FROM dbo.Questions "
                            + "WHERE QuizId = ? "
                            + "ORDER BY SortOrder ASC, QuestionId ASC";

        try (PreparedStatement ps = conn.prepareStatement(sqlQuestions)) {
            ps.setLong(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuizQuestion qn = new QuizQuestion();
                    qn.setId(rs.getLong("QuestionId"));
                    qn.setQuizId(rs.getLong("QuizId"));
                    qn.setContent(rs.getString("Content"));
                    qn.setExplanation(rs.getString("Explanation"));
                    qn.setPoints(rs.getBigDecimal("Points"));
                    qn.setSortOrder(rs.getInt("SortOrder"));

                    // Fetch options
                    String sqlOptions = "SELECT OptionId, QuestionId, Content, IsCorrect, SortOrder "
                                      + "FROM dbo.AnswerOptions "
                                      + "WHERE QuestionId = ? "
                                      + "ORDER BY SortOrder ASC, OptionId ASC";
                    try (PreparedStatement psOpt = conn.prepareStatement(sqlOptions)) {
                        psOpt.setLong(1, qn.getId());
                        try (ResultSet rsOpt = psOpt.executeQuery()) {
                            List<QuizOption> options = new ArrayList<>();
                            while (rsOpt.next()) {
                                QuizOption opt = new QuizOption();
                                opt.setId(rsOpt.getLong("OptionId"));
                                opt.setContent(rsOpt.getString("Content"));
                                opt.setCorrect(rsOpt.getBoolean("IsCorrect"));
                                opt.setSortOrder(rsOpt.getInt("SortOrder"));
                                options.add(opt);
                            }
                            qn.setOptions(options);
                        }
                    }

                    list.add(qn);
                }
            }
        }
        return list;
    }

    public boolean createQuestionWithOptions(Connection conn, long quizId, long instructorId,
                                             String content, String explanation, BigDecimal points, int sortOrder,
                                             List<String> optionContents, int correctIndex) throws SQLException {
        if (!checkQuizOwnership(conn, quizId, instructorId)) {
            return false;
        }
        if (hasQuizAttempts(conn, quizId)) {
            throw new IllegalStateException("Đề kiểm tra này đã có học viên làm bài thi, không được thêm câu hỏi mới.");
        }
        if (optionContents == null || optionContents.size() < 2) {
            throw new IllegalArgumentException("Mỗi câu hỏi phải có ít nhất 2 phương án lựa chọn.");
        }
        if (correctIndex < 0 || correctIndex >= optionContents.size()) {
            throw new IllegalArgumentException("Phải chỉ định chính xác 1 phương án đáp án đúng.");
        }

        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Insert question
            String insQnSql = "INSERT INTO dbo.Questions (QuizId, Content, Explanation, Points, SortOrder) "
                            + "VALUES (?, ?, ?, ?, ?)";
            long newQuestionId = 0;
            try (PreparedStatement ps = conn.prepareStatement(insQnSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, quizId);
                ps.setString(2, content.trim());
                ps.setString(3, explanation != null ? explanation.trim() : null);
                ps.setBigDecimal(4, points != null ? points : BigDecimal.ONE);
                ps.setInt(5, sortOrder > 0 ? sortOrder : 1);
                ps.executeUpdate();

                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) {
                        newQuestionId = gk.getLong(1);
                    }
                }
            }

            if (newQuestionId <= 0) {
                conn.rollback();
                return false;
            }

            // 2. Insert answer options
            String insOptSql = "INSERT INTO dbo.AnswerOptions (QuestionId, Content, IsCorrect, SortOrder) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psOpt = conn.prepareStatement(insOptSql)) {
                for (int i = 0; i < optionContents.size(); i++) {
                    psOpt.setLong(1, newQuestionId);
                    psOpt.setString(2, optionContents.get(i).trim());
                    psOpt.setBoolean(3, i == correctIndex);
                    psOpt.setInt(4, i + 1);
                    psOpt.addBatch();
                }
                psOpt.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(autoCommit);
        }
    }

    public boolean updateQuestionWithOptions(Connection conn, long questionId, long instructorId,
                                             String content, String explanation, BigDecimal points, int sortOrder,
                                             List<String> optionContents, int correctIndex) throws SQLException {
        if (!checkQuestionOwnership(conn, questionId, instructorId)) {
            return false;
        }
        if (hasQuestionAttempts(conn, questionId)) {
            throw new IllegalStateException("Câu hỏi này thuộc đề đã có học viên làm bài thi, không được sửa.");
        }
        if (optionContents == null || optionContents.size() < 2) {
            throw new IllegalArgumentException("Mỗi câu hỏi phải có ít nhất 2 phương án lựa chọn.");
        }
        if (correctIndex < 0 || correctIndex >= optionContents.size()) {
            throw new IllegalArgumentException("Phải chỉ định chính xác 1 phương án đáp án đúng.");
        }

        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Update question
            String updQnSql = "UPDATE dbo.Questions SET Content = ?, Explanation = ?, Points = ?, SortOrder = ? WHERE QuestionId = ?";
            try (PreparedStatement ps = conn.prepareStatement(updQnSql)) {
                ps.setString(1, content.trim());
                ps.setString(2, explanation != null ? explanation.trim() : null);
                ps.setBigDecimal(3, points != null ? points : BigDecimal.ONE);
                ps.setInt(4, sortOrder > 0 ? sortOrder : 1);
                ps.setLong(5, questionId);
                ps.executeUpdate();
            }

            // 2. Delete old answer options
            String delOptsSql = "DELETE FROM dbo.AnswerOptions WHERE QuestionId = ?";
            try (PreparedStatement ps = conn.prepareStatement(delOptsSql)) {
                ps.setLong(1, questionId);
                ps.executeUpdate();
            }

            // 3. Insert new answer options
            String insOptSql = "INSERT INTO dbo.AnswerOptions (QuestionId, Content, IsCorrect, SortOrder) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psOpt = conn.prepareStatement(insOptSql)) {
                for (int i = 0; i < optionContents.size(); i++) {
                    psOpt.setLong(1, questionId);
                    psOpt.setString(2, optionContents.get(i).trim());
                    psOpt.setBoolean(3, i == correctIndex);
                    psOpt.setInt(4, i + 1);
                    psOpt.addBatch();
                }
                psOpt.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(autoCommit);
        }
    }

    public boolean deleteQuestion(Connection conn, long questionId, long instructorId) throws SQLException {
        if (!checkQuestionOwnership(conn, questionId, instructorId)) {
            return false;
        }
        if (hasQuestionAttempts(conn, questionId)) {
            throw new IllegalStateException("Câu hỏi này thuộc đề đã có học viên làm bài thi, không được xóa.");
        }

        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Delete options
            String delOptSql = "DELETE FROM dbo.AnswerOptions WHERE QuestionId = ?";
            try (PreparedStatement ps = conn.prepareStatement(delOptSql)) {
                ps.setLong(1, questionId);
                ps.executeUpdate();
            }

            // 2. Delete question
            String delQnSql = "DELETE FROM dbo.Questions WHERE QuestionId = ?";
            int rows;
            try (PreparedStatement ps = conn.prepareStatement(delQnSql)) {
                ps.setLong(1, questionId);
                rows = ps.executeUpdate();
            }

            conn.commit();
            return rows > 0;
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(autoCommit);
        }
    }
}
