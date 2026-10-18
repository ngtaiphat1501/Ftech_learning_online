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
import model.StudentCourse;

public class StudentCourseDAO {

    public List<StudentCourse> getList(long studentId) throws SQLException {
        List<StudentCourse> list = new ArrayList<>();

        String sql = "SELECT c.CourseId, c.Title, c.ThumbnailUrl, "
                + "u.FullName AS InstructorName, "
                + "e.AccessStatus, e.CompletedAt, "
                + "p.ProgressPercent, p.CompletedRequiredLessons, "
                + "p.TotalRequiredLessons "
                + "FROM Enrollments e "
                + "JOIN Courses c ON e.CourseId = c.CourseId "
                + "JOIN Users u ON c.InstructorId = u.UserId "
                + "JOIN vEnrollmentProgress p "
                + "ON e.EnrollmentId = p.EnrollmentId "
                + "WHERE e.StudentId = ? "
                + "ORDER BY e.EnrolledAt DESC, e.EnrollmentId DESC";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, studentId);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    StudentCourse course = new StudentCourse();

                    course.setCourseId(result.getLong("CourseId"));
                    course.setTitle(result.getString("Title"));
                    course.setThumbnailUrl(result.getString("ThumbnailUrl"));
                    course.setInstructorName(result.getString("InstructorName"));
                    course.setAccessStatus(result.getString("AccessStatus"));
                    course.setProgressPercent(
                            result.getBigDecimal("ProgressPercent")
                    );
                    course.setCompletedLessons(
                            result.getInt("CompletedRequiredLessons")
                    );
                    course.setTotalLessons(
                            result.getInt("TotalRequiredLessons")
                    );
                    course.setCompleted(
                            result.getTimestamp("CompletedAt") != null
                    );

                    list.add(course);
                }
            }
        }

        return list;
    }

    public boolean isActiveStudent(long userId) throws SQLException {
        String sql = "SELECT u.UserId "
                + "FROM Users u "
                + "JOIN UserRoles ur ON u.UserId = ur.UserId "
                + "WHERE u.UserId = ? "
                + "AND u.Status = 'ACTIVE' "
                + "AND ur.RoleCode = 'STUDENT'";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        }
    }
}