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
import model.Course;

public class CourseDAO {

    public List<Course> getList(String keyword, long categoryId,
            String pricingType) throws SQLException {

        List<Course> list = new ArrayList<>();

        String sql = "SELECT c.CourseId, c.Title, c.ThumbnailUrl, "
                + "c.PricingType, c.ListPriceVnd, c.SalePriceVnd, "
                + "c.EstimatedHours, u.FullName AS InstructorName, "
                + "ca.Name AS CategoryName, "
                + "COALESCE(rv.AverageRating, 0) AS AverageRating, "
                + "COALESCE(rv.ReviewCount, 0) AS ReviewCount, "
                + "(SELECT COUNT(*) FROM Lessons l "
                + "WHERE l.CourseId = c.CourseId) AS LessonCount "
                + "FROM Courses c "
                + "JOIN Users u ON c.InstructorId = u.UserId "
                + "JOIN Categories ca ON c.CategoryId = ca.CategoryId "
                + "LEFT JOIN (SELECT e.CourseId, "
                + "AVG(CAST(r.Rating AS decimal(10, 4))) AS AverageRating, "
                + "COUNT_BIG(*) AS ReviewCount "
                + "FROM dbo.CourseReviews r "
                + "JOIN dbo.Enrollments e ON e.EnrollmentId = r.EnrollmentId "
                + "WHERE r.IsHidden = 0 "
                + "GROUP BY e.CourseId) rv ON rv.CourseId = c.CourseId "
                + "WHERE c.Status = 'PUBLISHED' "
                + "AND ca.IsActive = 1 "
                + "AND c.Title LIKE ? "
                + "AND (? = 0 OR c.CategoryId = ?) "
                + "AND (? = '' OR c.PricingType = ?) "
                + "ORDER BY c.PublishedAt DESC, c.CourseId DESC";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, "%" + keyword + "%");
            statement.setLong(2, categoryId);
            statement.setLong(3, categoryId);
            statement.setString(4, pricingType);
            statement.setString(5, pricingType);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Course course = new Course();

                    course.setId(result.getLong("CourseId"));
                    course.setTitle(result.getString("Title"));
                    course.setThumbnailUrl(result.getString("ThumbnailUrl"));
                    course.setInstructorName(result.getString("InstructorName"));
                    course.setCategoryName(result.getString("CategoryName"));
                    course.setPricingType(result.getString("PricingType"));
                    course.setListPrice(result.getBigDecimal("ListPriceVnd"));
                    course.setSalePrice(result.getBigDecimal("SalePriceVnd"));
                    course.setEstimatedHours(result.getBigDecimal("EstimatedHours"));
                    course.setLessonCount(result.getInt("LessonCount"));

                    course.setAverageRating(result.getDouble("AverageRating"));
                    course.setReviewCount(result.getLong("ReviewCount"));

                    list.add(course);
                }
            }
        }

        return list;
    }
}