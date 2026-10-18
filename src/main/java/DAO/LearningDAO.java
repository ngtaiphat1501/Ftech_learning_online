/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.LearningLesson;

public class LearningDAO {

    public long getEnrollmentId(long studentId, long courseId)
            throws SQLException {

        String sql = "SELECT e.EnrollmentId "
                + "FROM Enrollments e "
                + "JOIN Courses c ON e.CourseId = c.CourseId "
                + "JOIN Users u ON e.StudentId = u.UserId "
                + "WHERE e.StudentId = ? "
                + "AND e.CourseId = ? "
                + "AND e.AccessStatus = 'ACTIVE' "
                + "AND u.Status = 'ACTIVE' "
                + "AND c.Status IN ('PUBLISHED', 'ARCHIVED')";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, studentId);
            statement.setLong(2, courseId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("EnrollmentId");
                }
            }
        }

        return 0;
    }

    public String getCourseTitle(long courseId) throws SQLException {
        String sql = "SELECT Title FROM Courses WHERE CourseId = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getString("Title");
                }
            }
        }

        return "";
    }

    public List<LearningLesson> getLessons(long courseId, long enrollmentId)
            throws SQLException {

        List<LearningLesson> list = new ArrayList<>();

        String sql = "SELECT l.LessonId, l.ChapterId, "
                + "ch.Title AS ChapterTitle, "
                + "l.Title, l.Content, l.VideoUrl, lp.CompletedAt, "
                + "ISNULL(lp.LastPositionSeconds, 0) AS LastPositionSeconds "
                + "FROM Lessons l "
                + "JOIN Chapters ch "
                + "ON l.ChapterId = ch.ChapterId "
                + "AND l.CourseId = ch.CourseId "
                + "LEFT JOIN LessonProgress lp "
                + "ON lp.LessonId = l.LessonId "
                + "AND lp.CourseId = l.CourseId "
                + "AND lp.EnrollmentId = ? "
                + "WHERE l.CourseId = ? "
                + "ORDER BY ch.SortOrder, l.SortOrder, l.LessonId";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, enrollmentId);
            statement.setLong(2, courseId);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    LearningLesson lesson = new LearningLesson();

                    lesson.setId(result.getLong("LessonId"));
                    lesson.setChapterId(result.getLong("ChapterId"));
                    lesson.setChapterTitle(result.getString("ChapterTitle"));
                    lesson.setTitle(result.getString("Title"));
                    lesson.setContent(result.getString("Content"));
                    lesson.setVideoUrl(result.getString("VideoUrl"));
                    lesson.setCompleted(
                            result.getTimestamp("CompletedAt") != null
                    );
                    lesson.setLastPositionSeconds(
                            result.getInt("LastPositionSeconds")
                    );
                    list.add(lesson);
                }
            }
        }

        return list;
    }
}
