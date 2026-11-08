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

public class ProgressDAO {

    public boolean saveProgress(long studentId, long courseId,
            long lessonId, int position, boolean complete)
            throws SQLException {

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                long enrollmentId = 0;

                String checkSql = "SELECT e.EnrollmentId "
                        + "FROM Enrollments e WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Courses c ON e.CourseId = c.CourseId "
                        + "JOIN Users u ON e.StudentId = u.UserId "
                        + "JOIN Lessons l ON l.CourseId = e.CourseId "
                        + "WHERE e.StudentId = ? "
                        + "AND e.CourseId = ? "
                        + "AND l.LessonId = ? "
                        + "AND e.AccessStatus = 'ACTIVE' "
                        + "AND u.Status = 'ACTIVE' "
                        + "AND c.Status IN ('PUBLISHED', 'ARCHIVED')";

                try (PreparedStatement statement
                        = connection.prepareStatement(checkSql)) {

                    statement.setLong(1, studentId);
                    statement.setLong(2, courseId);
                    statement.setLong(3, lessonId);

                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            enrollmentId = result.getLong("EnrollmentId");
                        }
                    }
                }

                if (enrollmentId == 0) {
                    connection.rollback();
                    return false;
                }

                String updateSql = "UPDATE LessonProgress "
                        + "SET LastPositionSeconds = ?, "
                        + "LastAccessedAt = SYSUTCDATETIME(), "
                        + "CompletedAt = CASE "
                        + "WHEN ? = 1 AND CompletedAt IS NULL "
                        + "THEN SYSUTCDATETIME() "
                        + "ELSE CompletedAt END "
                        + "WHERE EnrollmentId = ? AND LessonId = ?";

                int updated;

                try (PreparedStatement statement
                        = connection.prepareStatement(updateSql)) {

                    statement.setInt(1, position);
                    statement.setBoolean(2, complete);
                    statement.setLong(3, enrollmentId);
                    statement.setLong(4, lessonId);

                    updated = statement.executeUpdate();
                }

                if (updated == 0) {
                    String insertSql = "INSERT INTO LessonProgress "
                            + "(EnrollmentId, LessonId, CourseId, "
                            + "LastPositionSeconds, LastAccessedAt, CompletedAt) "
                            + "VALUES (?, ?, ?, ?, SYSUTCDATETIME(), "
                            + "CASE WHEN ? = 1 "
                            + "THEN SYSUTCDATETIME() ELSE NULL END)";

                    try (PreparedStatement statement
                            = connection.prepareStatement(insertSql)) {

                        statement.setLong(1, enrollmentId);
                        statement.setLong(2, lessonId);
                        statement.setLong(3, courseId);
                        statement.setInt(4, position);
                        statement.setBoolean(5, complete);

                        statement.executeUpdate();
                    }
                }

                String accessSql = "UPDATE Enrollments "
                        + "SET LastAccessedLessonId = ?, "
                        + "LastAccessedAt = SYSUTCDATETIME() "
                        + "WHERE EnrollmentId = ?";

                try (PreparedStatement statement
                        = connection.prepareStatement(accessSql)) {

                    statement.setLong(1, lessonId);
                    statement.setLong(2, enrollmentId);

                    statement.executeUpdate();
                }

                String completionSql = "UPDATE Enrollments "
                        + "SET CompletedAt = SYSUTCDATETIME() "
                        + "WHERE EnrollmentId = ? "
                        + "AND CompletedAt IS NULL "
                        + "AND EXISTS ("
                        + "SELECT 1 FROM vEnrollmentProgress p "
                        + "WHERE p.EnrollmentId = Enrollments.EnrollmentId "
                        + "AND p.IsEligibleForCompletion = 1)";

                try (PreparedStatement statement
                        = connection.prepareStatement(completionSql)) {

                    statement.setLong(1, enrollmentId);

                    statement.executeUpdate();
                }

                connection.commit();
                return true;

            } catch (SQLException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }
}