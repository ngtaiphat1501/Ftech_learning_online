package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.CurriculumChapter;
import model.CurriculumLesson;

public class ChapterDAO {

    public List<CurriculumChapter> getCurriculum(long courseId)
            throws SQLException {

        Map<Long, CurriculumChapter> chapterMap
                = new LinkedHashMap<>();

        String sql
                = "SELECT "
                + "ch.ChapterId, "
                + "ch.CourseId, "
                + "ch.Title AS ChapterTitle, "
                + "ch.Description AS ChapterDescription, "
                + "ch.SortOrder AS ChapterSortOrder, "
                + "l.LessonId, "
                + "l.Title AS LessonTitle, "
                + "l.DurationSeconds, "
                + "l.SortOrder AS LessonSortOrder, "
                + "l.IsPreview, "
                + "l.IsRequired "
                + "FROM dbo.Chapters ch "
                + "LEFT JOIN dbo.Lessons l "
                + "ON l.ChapterId = ch.ChapterId "
                + "AND l.CourseId = ch.CourseId "
                + "WHERE ch.CourseId = ? "
                + "ORDER BY "
                + "ch.SortOrder, "
                + "ch.ChapterId, "
                + "l.SortOrder, "
                + "l.LessonId";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    long chapterId
                            = result.getLong("ChapterId");

                    CurriculumChapter chapter
                            = chapterMap.get(chapterId);

                    if (chapter == null) {

                        chapter = new CurriculumChapter();

                        chapter.setChapterId(chapterId);
                        chapter.setCourseId(
                                result.getLong("CourseId")
                        );
                        chapter.setTitle(
                                result.getString("ChapterTitle")
                        );
                        chapter.setDescription(
                                result.getString(
                                        "ChapterDescription"
                                )
                        );
                        chapter.setSortOrder(
                                result.getInt(
                                        "ChapterSortOrder"
                                )
                        );

                        chapterMap.put(
                                chapterId,
                                chapter
                        );
                    }

                    Object lessonIdObject
                            = result.getObject("LessonId");

                    if (lessonIdObject != null) {

                        CurriculumLesson lesson
                                = new CurriculumLesson();

                        lesson.setLessonId(
                                result.getLong("LessonId")
                        );

                        lesson.setChapterId(chapterId);

                        lesson.setCourseId(
                                result.getLong("CourseId")
                        );

                        lesson.setTitle(
                                result.getString("LessonTitle")
                        );

                        Object duration
                                = result.getObject(
                                        "DurationSeconds"
                                );

                        if (duration != null) {

                            lesson.setDurationSeconds(
                                    ((Number) duration)
                                            .intValue()
                            );
                        }

                        lesson.setSortOrder(
                                result.getInt(
                                        "LessonSortOrder"
                                )
                        );

                        lesson.setPreview(
                                result.getBoolean("IsPreview")
                        );

                        lesson.setRequired(
                                result.getBoolean("IsRequired")
                        );

                        chapter.getLessons().add(lesson);
                    }
                }
            }
        }

        return new ArrayList<>(
                chapterMap.values()
        );
    }

    public boolean createChapter(
            long courseId,
            String title,
            String description
    ) throws SQLException {

        String sql
                = "INSERT INTO dbo.Chapters "
                + "(CourseId, Title, Description, SortOrder) "
                + "SELECT ?, ?, ?, "
                + "ISNULL(MAX(SortOrder), 0) + 1 "
                + "FROM dbo.Chapters "
                + "WHERE CourseId = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);
            statement.setString(2, title);
            statement.setString(3, description);
            statement.setLong(4, courseId);

            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateChapter(
            long chapterId,
            long courseId,
            long instructorId,
            String title,
            String description,
            int newSortOrder
    ) throws SQLException {

        String checkSql
                = "SELECT ch.ChapterId "
                + "FROM dbo.Chapters ch "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = ch.CourseId "
                + "WHERE ch.ChapterId = ? "
                + "AND ch.CourseId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        String listSql
                = "SELECT ChapterId "
                + "FROM dbo.Chapters "
                + "WHERE CourseId = ? "
                + "ORDER BY SortOrder, ChapterId";

        String updateInfoSql
                = "UPDATE dbo.Chapters "
                + "SET Title = ?, Description = ? "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ?";

        String updateOrderSql
                = "UPDATE dbo.Chapters "
                + "SET SortOrder = ? "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ?";

        try (Connection connection = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                try (PreparedStatement check
                        = connection.prepareStatement(checkSql)) {

                    check.setLong(1, chapterId);
                    check.setLong(2, courseId);
                    check.setLong(3, instructorId);

                    try (ResultSet result = check.executeQuery()) {

                        if (!result.next()) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                List<Long> chapterIds = new ArrayList<>();

                try (PreparedStatement statement
                        = connection.prepareStatement(listSql)) {

                    statement.setLong(1, courseId);

                    try (ResultSet result = statement.executeQuery()) {

                        while (result.next()) {

                            chapterIds.add(
                                    result.getLong("ChapterId")
                            );
                        }
                    }
                }

                chapterIds.remove(chapterId);

                if (newSortOrder < 1) {
                    newSortOrder = 1;
                }

                if (newSortOrder > chapterIds.size() + 1) {
                    newSortOrder = chapterIds.size() + 1;
                }

                chapterIds.add(
                        newSortOrder - 1,
                        chapterId
                );

                try (PreparedStatement statement
                        = connection.prepareStatement(updateInfoSql)) {

                    statement.setString(1, title);
                    statement.setString(2, description);
                    statement.setLong(3, chapterId);
                    statement.setLong(4, courseId);

                    statement.executeUpdate();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(updateOrderSql)) {

                    for (int i = 0; i < chapterIds.size(); i++) {

                        statement.setInt(
                                1,
                                1000000 + i
                        );

                        statement.setLong(
                                2,
                                chapterIds.get(i)
                        );

                        statement.setLong(
                                3,
                                courseId
                        );

                        statement.addBatch();
                    }

                    statement.executeBatch();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(updateOrderSql)) {

                    for (int i = 0; i < chapterIds.size(); i++) {

                        statement.setInt(
                                1,
                                i + 1
                        );

                        statement.setLong(
                                2,
                                chapterIds.get(i)
                        );

                        statement.setLong(
                                3,
                                courseId
                        );

                        statement.addBatch();
                    }

                    statement.executeBatch();
                }

                connection.commit();
                return true;

            } catch (SQLException ex) {

                connection.rollback();
                throw ex;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    public boolean deleteChapter(
            long chapterId,
            long courseId,
            long instructorId
    ) throws SQLException {

        String checkSql
                = "SELECT ch.ChapterId "
                + "FROM dbo.Chapters ch "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = ch.CourseId "
                + "WHERE ch.ChapterId = ? "
                + "AND ch.CourseId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        String relatedDataSql
                = "SELECT TOP 1 l.LessonId "
                + "FROM dbo.Lessons l "
                + "WHERE l.ChapterId = ? "
                + "AND l.CourseId = ? "
                + "AND ("
                + "EXISTS ("
                + "SELECT 1 FROM dbo.LessonProgress lp "
                + "WHERE lp.LessonId = l.LessonId "
                + "AND lp.CourseId = l.CourseId"
                + ") "
                + "OR EXISTS ("
                + "SELECT 1 FROM dbo.DiscussionPosts dp "
                + "WHERE dp.LessonId = l.LessonId"
                + ")"
                + ")";

        String deleteResourcesSql
                = "DELETE lr "
                + "FROM dbo.LessonResources lr "
                + "JOIN dbo.Lessons l "
                + "ON l.LessonId = lr.LessonId "
                + "WHERE l.ChapterId = ? "
                + "AND l.CourseId = ?";

        String deleteLessonsSql
                = "DELETE FROM dbo.Lessons "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ?";

        String deleteChapterSql
                = "DELETE FROM dbo.Chapters "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ?";

        String listSql
                = "SELECT ChapterId "
                + "FROM dbo.Chapters "
                + "WHERE CourseId = ? "
                + "ORDER BY SortOrder, ChapterId";

        String updateOrderSql
                = "UPDATE dbo.Chapters "
                + "SET SortOrder = ? "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ?";

        try (Connection connection = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                try (PreparedStatement statement
                        = connection.prepareStatement(checkSql)) {

                    statement.setLong(1, chapterId);
                    statement.setLong(2, courseId);
                    statement.setLong(3, instructorId);

                    try (ResultSet result = statement.executeQuery()) {

                        if (!result.next()) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(relatedDataSql)) {

                    statement.setLong(1, chapterId);
                    statement.setLong(2, courseId);

                    try (ResultSet result = statement.executeQuery()) {

                        if (result.next()) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(deleteResourcesSql)) {

                    statement.setLong(1, chapterId);
                    statement.setLong(2, courseId);

                    statement.executeUpdate();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(deleteLessonsSql)) {

                    statement.setLong(1, chapterId);
                    statement.setLong(2, courseId);

                    statement.executeUpdate();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(deleteChapterSql)) {

                    statement.setLong(1, chapterId);
                    statement.setLong(2, courseId);

                    if (statement.executeUpdate() == 0) {
                        connection.rollback();
                        return false;
                    }
                }

                List<Long> chapterIds = new ArrayList<>();

                try (PreparedStatement statement
                        = connection.prepareStatement(listSql)) {

                    statement.setLong(1, courseId);

                    try (ResultSet result = statement.executeQuery()) {

                        while (result.next()) {
                            chapterIds.add(
                                    result.getLong("ChapterId")
                            );
                        }
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(updateOrderSql)) {

                    for (int i = 0; i < chapterIds.size(); i++) {

                        statement.setInt(1, 1000000 + i);
                        statement.setLong(2, chapterIds.get(i));
                        statement.setLong(3, courseId);

                        statement.addBatch();
                    }

                    statement.executeBatch();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(updateOrderSql)) {

                    for (int i = 0; i < chapterIds.size(); i++) {

                        statement.setInt(1, i + 1);
                        statement.setLong(2, chapterIds.get(i));
                        statement.setLong(3, courseId);

                        statement.addBatch();
                    }

                    statement.executeBatch();
                }

                connection.commit();
                return true;

            } catch (SQLException ex) {

                connection.rollback();
                throw ex;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }
}
