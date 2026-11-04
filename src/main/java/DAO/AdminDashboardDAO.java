package dao;

import model.Course;
import model.Order;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminDashboardDAO {

    public Map<String, Object> getDashboardStats(Connection conn) throws SQLException {
        Map<String, Object> stats = new HashMap<>();

        // 1. Total students
        String studentSql = "SELECT COUNT(DISTINCT u.UserId) AS Total "
                          + "FROM dbo.Users u "
                          + "JOIN dbo.UserRoles ur ON u.UserId = ur.UserId "
                          + "WHERE ur.RoleCode = 'STUDENT'";
        try (PreparedStatement ps = conn.prepareStatement(studentSql);
             ResultSet rs = ps.executeQuery()) {
            stats.put("totalStudents", rs.next() ? rs.getInt("Total") : 0);
        }

        // 2. Total instructors
        String instructorSql = "SELECT COUNT(DISTINCT u.UserId) AS Total "
                             + "FROM dbo.Users u "
                             + "JOIN dbo.UserRoles ur ON u.UserId = ur.UserId "
                             + "WHERE ur.RoleCode = 'INSTRUCTOR'";
        try (PreparedStatement ps = conn.prepareStatement(instructorSql);
             ResultSet rs = ps.executeQuery()) {
            stats.put("totalInstructors", rs.next() ? rs.getInt("Total") : 0);
        }

        // 3. Courses stats (published & pending)
        String courseSql = "SELECT "
                         + "  SUM(CASE WHEN Status = 'PUBLISHED' THEN 1 ELSE 0 END) AS PublishedCount, "
                         + "  SUM(CASE WHEN Status = 'PENDING_APPROVAL' THEN 1 ELSE 0 END) AS PendingCount, "
                         + "  COUNT(*) AS TotalCount "
                         + "FROM dbo.Courses";
        try (PreparedStatement ps = conn.prepareStatement(courseSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("publishedCourses", rs.getInt("PublishedCount"));
                stats.put("pendingCourses", rs.getInt("PendingCount"));
                stats.put("totalCourses", rs.getInt("TotalCount"));
            } else {
                stats.put("publishedCourses", 0);
                stats.put("pendingCourses", 0);
                stats.put("totalCourses", 0);
            }
        }

        // 4. Financial & Orders stats
        String revenueSql = "SELECT "
                          + "  COALESCE(SUM(CASE WHEN Status = 'PAID' THEN TotalVnd ELSE 0 END), 0) AS TotalRevenue, "
                          + "  SUM(CASE WHEN Status = 'PAID' THEN 1 ELSE 0 END) AS PaidOrders, "
                          + "  SUM(CASE WHEN Status = 'PENDING_PAYMENT' THEN 1 ELSE 0 END) AS PendingOrders, "
                          + "  SUM(CASE WHEN Status = 'PAYMENT_REVIEW' THEN 1 ELSE 0 END) AS ReviewOrders, "
                          + "  COUNT(*) AS TotalOrders "
                          + "FROM dbo.Orders";
        try (PreparedStatement ps = conn.prepareStatement(revenueSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                stats.put("paidOrders", rs.getInt("PaidOrders"));
                stats.put("pendingOrders", rs.getInt("PendingOrders"));
                stats.put("reviewOrders", rs.getInt("ReviewOrders"));
                stats.put("totalOrders", rs.getInt("TotalOrders"));
            } else {
                stats.put("totalRevenue", BigDecimal.ZERO);
                stats.put("paidOrders", 0);
                stats.put("pendingOrders", 0);
                stats.put("reviewOrders", 0);
                stats.put("totalOrders", 0);
            }
        }

        // 5. Total active enrollments
        String enrollSql = "SELECT COUNT(*) AS Total FROM dbo.Enrollments WHERE AccessStatus = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(enrollSql);
             ResultSet rs = ps.executeQuery()) {
            stats.put("totalEnrollments", rs.next() ? rs.getInt("Total") : 0);
        }

        return stats;
    }

    public List<Order> getRecentOrders(Connection conn, int limit) throws SQLException {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP (?) o.OrderId, o.OrderCode, o.StudentId, o.Status, o.TotalVnd, o.CreatedAt, "
                   + "       u.FullName AS StudentName, u.Email AS StudentEmail "
                   + "FROM dbo.Orders o "
                   + "JOIN dbo.Users u ON o.StudentId = u.UserId "
                   + "ORDER BY o.CreatedAt DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getLong("OrderId"));
                    o.setOrderCode(rs.getString("OrderCode"));
                    o.setStudentId(rs.getLong("StudentId"));
                    o.setStudentName(rs.getString("StudentName"));
                    o.setStudentEmail(rs.getString("StudentEmail"));
                    o.setStatus(rs.getString("Status"));
                    o.setTotalVnd(rs.getBigDecimal("TotalVnd"));

                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        o.setCreatedAt(ts.toLocalDateTime());
                    }
                    list.add(o);
                }
            }
        }
        return list;
    }

    public List<Course> getTopEnrolledCourses(Connection conn, int limit) throws SQLException {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT TOP (?) c.CourseId, c.Title, c.ThumbnailUrl, c.SalePriceVnd, c.PricingType, "
                   + "       u.FullName AS InstructorName, "
                   + "       COUNT(e.EnrollmentId) AS EnrollmentCount "
                   + "FROM dbo.Courses c "
                   + "JOIN dbo.Users u ON c.InstructorId = u.UserId "
                   + "LEFT JOIN dbo.Enrollments e ON c.CourseId = e.CourseId AND e.AccessStatus = 'ACTIVE' "
                   + "WHERE c.Status = 'PUBLISHED' "
                   + "GROUP BY c.CourseId, c.Title, c.ThumbnailUrl, c.SalePriceVnd, c.PricingType, u.FullName "
                   + "ORDER BY EnrollmentCount DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course c = new Course();
                    c.setCourseId(rs.getLong("CourseId"));
                    c.setTitle(rs.getString("Title"));
                    c.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                    c.setSalePriceVnd(rs.getBigDecimal("SalePriceVnd"));
                    c.setPricingType(rs.getString("PricingType"));
                    c.setInstructorName(rs.getString("InstructorName"));
                    c.setReviewCount(rs.getInt("EnrollmentCount")); // Reused as enrollment count
                    list.add(c);
                }
            }
        }
        return list;
    }
}
