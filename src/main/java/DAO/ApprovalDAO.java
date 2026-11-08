package dao;

import model.Course;
import model.CourseApprovalEvent;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class ApprovalDAO {

    public List<Course> getPendingCourses(Connection conn) throws SQLException {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.CourseId, c.Title, c.Slug, c.Subtitle AS Headline, c.ThumbnailUrl, c.PricingType, "
                   + "       c.ListPriceVnd, c.SalePriceVnd, c.Status, c.Level, c.CreatedAt, "
                   + "       u.UserId AS InstructorId, u.FullName AS InstructorName, u.Email AS InstructorEmail, "
                   + "       cat.Name AS CategoryName, "
                   + "       (SELECT COUNT(*) FROM dbo.Chapters ch WHERE ch.CourseId = c.CourseId) AS ChapterCount, "
                   + "       (SELECT COUNT(*) FROM dbo.Lessons l JOIN dbo.Chapters ch ON l.ChapterId = ch.ChapterId WHERE ch.CourseId = c.CourseId) AS LessonCount "
                   + "FROM dbo.Courses c "
                   + "JOIN dbo.Users u ON c.InstructorId = u.UserId "
                   + "LEFT JOIN dbo.Categories cat ON c.CategoryId = cat.CategoryId "
                   + "WHERE c.Status = 'PENDING_APPROVAL' "
                   + "ORDER BY c.CourseId DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Course c = new Course();
                c.setCourseId(rs.getLong("CourseId"));
                c.setTitle(rs.getString("Title"));
                c.setSlug(rs.getString("Slug"));
                c.setHeadline(rs.getString("Headline"));
                c.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                c.setPricingType(rs.getString("PricingType"));
                c.setListPriceVnd(rs.getBigDecimal("ListPriceVnd"));
                c.setSalePriceVnd(rs.getBigDecimal("SalePriceVnd"));
                c.setStatus(rs.getString("Status"));
                c.setLevel(rs.getString("Level"));
                c.setInstructorId(rs.getLong("InstructorId"));
                c.setInstructorName(rs.getString("InstructorName"));
                c.setCategoryName(rs.getString("CategoryName"));
                c.setLessonCount(rs.getInt("LessonCount"));

                Timestamp ts = rs.getTimestamp("CreatedAt");
                if (ts != null) {
                    c.setCreatedAt(ts.toLocalDateTime());
                }
                list.add(c);
            }
        }
        return list;
    }

    public List<Course> getCoursesByStatus(Connection conn, String status) throws SQLException {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.CourseId, c.Title, c.Slug, c.Subtitle AS Headline, c.ThumbnailUrl, c.PricingType, "
          + "       c.ListPriceVnd, c.SalePriceVnd, c.Status, c.Level, c.CreatedAt, "
          + "       u.UserId AS InstructorId, u.FullName AS InstructorName, u.Email AS InstructorEmail, "
          + "       cat.Name AS CategoryName, "
          + "       (SELECT COUNT(*) FROM dbo.Chapters ch WHERE ch.CourseId = c.CourseId) AS ChapterCount, "
          + "       (SELECT COUNT(*) FROM dbo.Lessons l JOIN dbo.Chapters ch ON l.ChapterId = ch.ChapterId WHERE ch.CourseId = c.CourseId) AS LessonCount "
          + "FROM dbo.Courses c "
          + "JOIN dbo.Users u ON c.InstructorId = u.UserId "
          + "LEFT JOIN dbo.Categories cat ON c.CategoryId = cat.CategoryId "
        );

        boolean filterStatus = (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status));
        if (filterStatus) {
            sql.append("WHERE c.Status = ? ");
        }
        sql.append("ORDER BY c.CourseId DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (filterStatus) {
                ps.setString(1, status.trim().toUpperCase());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course c = new Course();
                    c.setCourseId(rs.getLong("CourseId"));
                    c.setTitle(rs.getString("Title"));
                    c.setSlug(rs.getString("Slug"));
                    c.setHeadline(rs.getString("Headline"));
                    c.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                    c.setPricingType(rs.getString("PricingType"));
                    c.setListPriceVnd(rs.getBigDecimal("ListPriceVnd"));
                    c.setSalePriceVnd(rs.getBigDecimal("SalePriceVnd"));
                    c.setStatus(rs.getString("Status"));
                    c.setLevel(rs.getString("Level"));
                    c.setInstructorId(rs.getLong("InstructorId"));
                    c.setInstructorName(rs.getString("InstructorName"));
                    c.setCategoryName(rs.getString("CategoryName"));
                    c.setLessonCount(rs.getInt("LessonCount"));

                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        c.setCreatedAt(ts.toLocalDateTime());
                    }
                    list.add(c);
                }
            }
        }
        return list;
    }

    public Map<String, Integer> getCourseStatusCounts(Connection conn) throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("PENDING_APPROVAL", 0);
        counts.put("DRAFT", 0);
        counts.put("PUBLISHED", 0);
        counts.put("ALL", 0);

        String sql = "SELECT Status, COUNT(*) AS Total FROM dbo.Courses GROUP BY Status";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int all = 0;
            while (rs.next()) {
                String s = rs.getString("Status");
                int total = rs.getInt("Total");
                counts.put(s, total);
                all += total;
            }
            counts.put("ALL", all);
        }
        return counts;
    }

    public List<CourseApprovalEvent> getApprovalHistory(Connection conn, long courseId) throws SQLException {
        List<CourseApprovalEvent> events = new ArrayList<>();
        String sql = "SELECT e.EventId, e.CourseId, e.ActorId, e.Action, e.FromStatus, e.ToStatus, e.Note, e.CreatedAt, "
                   + "       u.FullName AS ActorName, u.Email AS ActorEmail "
                   + "FROM dbo.CourseApprovalEvents e "
                   + "JOIN dbo.Users u ON e.ActorId = u.UserId "
                   + "WHERE e.CourseId = ? "
                   + "ORDER BY e.CreatedAt DESC, e.EventId DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourseApprovalEvent evt = new CourseApprovalEvent();
                    evt.setEventId(rs.getLong("EventId"));
                    evt.setCourseId(rs.getLong("CourseId"));
                    evt.setActorId(rs.getLong("ActorId"));
                    evt.setAction(rs.getString("Action"));
                    evt.setFromStatus(rs.getString("FromStatus"));
                    evt.setToStatus(rs.getString("ToStatus"));
                    evt.setNote(rs.getString("Note"));
                    evt.setActorName(rs.getString("ActorName"));
                    evt.setActorEmail(rs.getString("ActorEmail"));

                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        evt.setCreatedAt(ts.toLocalDateTime());
                    }
                    events.add(evt);
                }
            }
        }
        return events;
    }

    public boolean approveCourse(Connection conn, long courseId, long adminId, String note) throws SQLException {
        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Update course status
            String updateSql = "UPDATE dbo.Courses "
                             + "SET Status = 'PUBLISHED', PublishedAt = SYSUTCDATETIME() "
                             + "WHERE CourseId = ? AND Status = 'PENDING_APPROVAL'";
            int updated;
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setLong(1, courseId);
                updated = ps.executeUpdate();
            }

            if (updated <= 0) {
                conn.rollback();
                return false;
            }

            // 2. Insert event log
            String eventSql = "INSERT INTO dbo.CourseApprovalEvents (CourseId, ActorId, Action, FromStatus, ToStatus, Note) "
                            + "VALUES (?, ?, 'APPROVE', 'PENDING_APPROVAL', 'PUBLISHED', ?)";
            try (PreparedStatement ps = conn.prepareStatement(eventSql)) {
                ps.setLong(1, courseId);
                ps.setLong(2, adminId);
                ps.setString(3, (note != null && !note.isBlank()) ? note.trim() : "Khóa học đã được duyệt xuất bản.");
                ps.executeUpdate();
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

    public boolean rejectCourse(Connection conn, long courseId, long adminId, String reason) throws SQLException {
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Lý do từ chối khóa học là bắt buộc.");
        }

        boolean autoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 1. Update course status to DRAFT
            String updateSql = "UPDATE dbo.Courses "
                             + "SET Status = 'DRAFT' "
                             + "WHERE CourseId = ? AND Status = 'PENDING_APPROVAL'";
            int updated;
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setLong(1, courseId);
                updated = ps.executeUpdate();
            }

            if (updated <= 0) {
                conn.rollback();
                return false;
            }

            // 2. Insert event log
            String eventSql = "INSERT INTO dbo.CourseApprovalEvents (CourseId, ActorId, Action, FromStatus, ToStatus, Note) "
                            + "VALUES (?, ?, 'REJECT', 'PENDING_APPROVAL', 'DRAFT', ?)";
            try (PreparedStatement ps = conn.prepareStatement(eventSql)) {
                ps.setLong(1, courseId);
                ps.setLong(2, adminId);
                ps.setString(3, reason.trim());
                ps.executeUpdate();
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
}
