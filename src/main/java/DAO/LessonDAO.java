package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CurriculumLesson;

public class LessonDAO {

    public boolean createLesson(
            long chapterId,
            long courseId,
            long instructorId,
            String title,
            String content,
            String videoUrl,
            Integer durationSeconds,
            boolean preview,
            boolean required
    ) throws SQLException {

        String sql
                = "INSERT INTO dbo.Lessons "
                + "(ChapterId, CourseId, Title, Content, VideoUrl, "
                + "DurationSeconds, SortOrder, IsPreview, IsRequired) "
                + "SELECT ch.ChapterId, ch.CourseId, ?, ?, ?, ?, "
                + "ISNULL(MAX(l.SortOrder), 0) + 1, ?, ? "
                + "FROM dbo.Chapters ch "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = ch.CourseId "
                + "LEFT JOIN dbo.Lessons l "
                + "ON l.ChapterId = ch.ChapterId "
                + "AND l.CourseId = ch.CourseId "
                + "WHERE ch.ChapterId = ? "
                + "AND ch.CourseId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT' "
                + "GROUP BY ch.ChapterId, ch.CourseId";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, title);
            statement.setString(2, content);
            statement.setString(3, videoUrl);

            if (durationSeconds == null) {
                statement.setNull(
                        4,
                        java.sql.Types.INTEGER
                );
            } else {
                statement.setInt(
                        4,
                        durationSeconds
                );
            }

            statement.setBoolean(5, preview);
            statement.setBoolean(6, required);
            statement.setLong(7, chapterId);
            statement.setLong(8, courseId);
            statement.setLong(9, instructorId);

            return statement.executeUpdate() > 0;
        }
    }

    public CurriculumLesson getByIdForInstructor(
            long lessonId,
            long instructorId
    ) throws SQLException {

        String sql
                = "SELECT "
                + "l.LessonId, "
                + "l.ChapterId, "
                + "l.CourseId, "
                + "l.Title, "
                + "l.Content, "
                + "l.VideoUrl, "
                + "l.DurationSeconds, "
                + "l.SortOrder, "
                + "l.IsPreview, "
                + "l.IsRequired "
                + "FROM dbo.Lessons l "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE l.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(1, lessonId);
            statement.setLong(2, instructorId);

            try (ResultSet result
                    = statement.executeQuery()) {

                if (!result.next()) {
                    return null;
                }

                CurriculumLesson lesson
                        = new CurriculumLesson();

                lesson.setLessonId(
                        result.getLong("LessonId")
                );

                lesson.setChapterId(
                        result.getLong("ChapterId")
                );

                lesson.setCourseId(
                        result.getLong("CourseId")
                );

                lesson.setTitle(
                        result.getString("Title")
                );

                lesson.setContent(
                        result.getString("Content")
                );

                lesson.setVideoUrl(
                        result.getString("VideoUrl")
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
                        result.getInt("SortOrder")
                );

                lesson.setPreview(
                        result.getBoolean("IsPreview")
                );

                lesson.setRequired(
                        result.getBoolean("IsRequired")
                );

                return lesson;
            }
        }
    }

    public boolean updateLesson(
            long lessonId,
            long instructorId,
            String title,
            String content,
            String videoUrl,
            Integer durationSeconds,
            boolean preview,
            boolean required,
            int newSortOrder
    ) throws SQLException {

        String checkSql
                = "SELECT l.ChapterId, l.CourseId "
                + "FROM dbo.Lessons l "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE l.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        String listSql
                = "SELECT LessonId "
                + "FROM dbo.Lessons "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ? "
                + "ORDER BY SortOrder, LessonId";

        String updateInfoSql
                = "UPDATE dbo.Lessons "
                + "SET Title = ?, "
                + "Content = ?, "
                + "VideoUrl = ?, "
                + "DurationSeconds = ?, "
                + "IsPreview = ?, "
                + "IsRequired = ? "
                + "WHERE LessonId = ? "
                + "AND CourseId = ?";

        String updateOrderSql
                = "UPDATE dbo.Lessons "
                + "SET SortOrder = ? "
                + "WHERE LessonId = ? "
                + "AND CourseId = ?";

        try (Connection connection
                = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                long chapterId;
                long courseId;

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                checkSql
                        )) {

                    statement.setLong(
                            1,
                            lessonId
                    );

                    statement.setLong(
                            2,
                            instructorId
                    );

                    try (ResultSet result
                            = statement.executeQuery()) {

                        if (!result.next()) {

                            connection.rollback();
                            return false;
                        }

                        chapterId
                                = result.getLong(
                                        "ChapterId"
                                );

                        courseId
                                = result.getLong(
                                        "CourseId"
                                );
                    }
                }

                List<Long> lessonIds
                        = new ArrayList<>();

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                listSql
                        )) {

                    statement.setLong(
                            1,
                            chapterId
                    );

                    statement.setLong(
                            2,
                            courseId
                    );

                    try (ResultSet result
                            = statement.executeQuery()) {

                        while (result.next()) {

                            lessonIds.add(
                                    result.getLong(
                                            "LessonId"
                                    )
                            );
                        }
                    }
                }

                lessonIds.remove(
                        Long.valueOf(lessonId)
                );

                if (newSortOrder < 1) {
                    newSortOrder = 1;
                }

                if (newSortOrder
                        > lessonIds.size() + 1) {

                    newSortOrder
                            = lessonIds.size() + 1;
                }

                lessonIds.add(
                        newSortOrder - 1,
                        lessonId
                );

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                updateInfoSql
                        )) {

                    statement.setString(
                            1,
                            title
                    );

                    statement.setString(
                            2,
                            content
                    );

                    statement.setString(
                            3,
                            videoUrl
                    );

                    if (durationSeconds == null) {

                        statement.setNull(
                                4,
                                java.sql.Types.INTEGER
                        );

                    } else {

                        statement.setInt(
                                4,
                                durationSeconds
                        );
                    }

                    statement.setBoolean(
                            5,
                            preview
                    );

                    statement.setBoolean(
                            6,
                            required
                    );

                    statement.setLong(
                            7,
                            lessonId
                    );

                    statement.setLong(
                            8,
                            courseId
                    );

                    statement.executeUpdate();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                updateOrderSql
                        )) {

                    for (int i = 0;
                            i < lessonIds.size();
                            i++) {

                        statement.setInt(
                                1,
                                1000000 + i
                        );

                        statement.setLong(
                                2,
                                lessonIds.get(i)
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
                        = connection.prepareStatement(
                                updateOrderSql
                        )) {

                    for (int i = 0;
                            i < lessonIds.size();
                            i++) {

                        statement.setInt(
                                1,
                                i + 1
                        );

                        statement.setLong(
                                2,
                                lessonIds.get(i)
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

    public boolean deleteLesson(
            long lessonId,
            long instructorId
    ) throws SQLException {

        String checkSql
                = "SELECT l.ChapterId, l.CourseId "
                + "FROM dbo.Lessons l "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE l.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        String historySql
                = "SELECT 1 "
                + "WHERE EXISTS ("
                + "SELECT 1 "
                + "FROM dbo.LessonProgress "
                + "WHERE LessonId = ?"
                + ") "
                + "OR EXISTS ("
                + "SELECT 1 "
                + "FROM dbo.DiscussionPosts "
                + "WHERE LessonId = ?"
                + ")";

        String deleteResourcesSql
                = "DELETE FROM dbo.LessonResources "
                + "WHERE LessonId = ?";

        String deleteSql
                = "DELETE FROM dbo.Lessons "
                + "WHERE LessonId = ? "
                + "AND CourseId = ?";

        String listSql
                = "SELECT LessonId "
                + "FROM dbo.Lessons "
                + "WHERE ChapterId = ? "
                + "AND CourseId = ? "
                + "ORDER BY SortOrder, LessonId";

        String updateOrderSql
                = "UPDATE dbo.Lessons "
                + "SET SortOrder = ? "
                + "WHERE LessonId = ? "
                + "AND CourseId = ?";

        try (Connection connection
                = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                long chapterId;
                long courseId;

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                checkSql
                        )) {

                    statement.setLong(
                            1,
                            lessonId
                    );

                    statement.setLong(
                            2,
                            instructorId
                    );

                    try (ResultSet result
                            = statement.executeQuery()) {

                        if (!result.next()) {

                            connection.rollback();
                            return false;
                        }

                        chapterId
                                = result.getLong(
                                        "ChapterId"
                                );

                        courseId
                                = result.getLong(
                                        "CourseId"
                                );
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                historySql
                        )) {

                    statement.setLong(
                            1,
                            lessonId
                    );

                    statement.setLong(
                            2,
                            lessonId
                    );

                    try (ResultSet result
                            = statement.executeQuery()) {

                        if (result.next()) {

                            connection.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                deleteResourcesSql
                        )) {

                    statement.setLong(
                            1,
                            lessonId
                    );

                    statement.executeUpdate();
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                deleteSql
                        )) {

                    statement.setLong(
                            1,
                            lessonId
                    );

                    statement.setLong(
                            2,
                            courseId
                    );

                    if (statement.executeUpdate()
                            == 0) {

                        connection.rollback();
                        return false;
                    }
                }

                List<Long> lessonIds
                        = new ArrayList<>();

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                listSql
                        )) {

                    statement.setLong(
                            1,
                            chapterId
                    );

                    statement.setLong(
                            2,
                            courseId
                    );

                    try (ResultSet result
                            = statement.executeQuery()) {

                        while (result.next()) {

                            lessonIds.add(
                                    result.getLong(
                                            "LessonId"
                                    )
                            );
                        }
                    }
                }

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                updateOrderSql
                        )) {

                    for (int i = 0;
                            i < lessonIds.size();
                            i++) {

                        statement.setInt(
                                1,
                                1000000 + i
                        );

                        statement.setLong(
                                2,
                                lessonIds.get(i)
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
                        = connection.prepareStatement(
                                updateOrderSql
                        )) {

                    for (int i = 0;
                            i < lessonIds.size();
                            i++) {

                        statement.setInt(
                                1,
                                i + 1
                        );

                        statement.setLong(
                                2,
                                lessonIds.get(i)
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
}