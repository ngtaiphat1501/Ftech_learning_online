package dao;

import config.DBContext;
import model.CourseReview;
import model.DiscussionPost;

import java.sql.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class ModerationDAO {

    public List<DiscussionPost> getDiscussionsForAdmin(String filter, String searchKeyword) throws SQLException {
        List<DiscussionPost> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT dp.PostId, dp.LessonId, l.Title AS LessonTitle, ")
           .append("c.CourseId, c.Title AS CourseTitle, ")
           .append("dp.AuthorId, u.FullName AS AuthorName, u.Email AS AuthorEmail, u.AvatarUrl AS AuthorAvatar, ")
           .append("dp.ParentPostId, dp.Body, dp.IsHidden, dp.IsDeleted, dp.CreatedAt ")
           .append("FROM dbo.DiscussionPosts dp ")
           .append("INNER JOIN dbo.Lessons l ON dp.LessonId = l.LessonId ")
           .append("INNER JOIN dbo.Courses c ON l.CourseId = c.CourseId ")
           .append("INNER JOIN dbo.Users u ON dp.AuthorId = u.UserId ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if ("HIDDEN".equalsIgnoreCase(filter)) {
            conditions.add("dp.IsHidden = 1");
        } else if ("VISIBLE".equalsIgnoreCase(filter)) {
            conditions.add("dp.IsHidden = 0");
        }

        if (searchKeyword != null && !searchKeyword.isBlank()) {
            conditions.add("(dp.Body LIKE ? OR u.FullName LIKE ? OR c.Title LIKE ?)");
            String kw = "%" + searchKeyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY dp.CreatedAt DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DiscussionPost post = new DiscussionPost();
                    post.setId(rs.getLong("PostId"));
                    post.setLessonId(rs.getLong("LessonId"));
                    post.setLessonTitle(rs.getString("LessonTitle"));
                    post.setCourseId(rs.getLong("CourseId"));
                    post.setCourseTitle(rs.getString("CourseTitle"));
                    post.setAuthorId(rs.getLong("AuthorId"));
                    post.setAuthorName(rs.getString("AuthorName"));
                    post.setAuthorEmail(rs.getString("AuthorEmail"));
                    post.setAuthorAvatar(rs.getString("AuthorAvatar"));
                    post.setParentId(rs.getLong("ParentPostId"));
                    post.setBody(rs.getString("Body"));
                    post.setHidden(rs.getBoolean("IsHidden"));
                    post.setDeleted(rs.getBoolean("IsDeleted"));
                    Timestamp cat = rs.getTimestamp("CreatedAt");
                    if (cat != null) {
                        post.setCreatedAt(cat.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
                    }
                    list.add(post);
                }
            }
        }
        return list;
    }

    public List<CourseReview> getReviewsForAdmin(String filter, String searchKeyword) throws SQLException {
        List<CourseReview> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cr.EnrollmentId, c.CourseId, c.Title AS CourseTitle, ")
           .append("e.StudentId, u.FullName AS StudentName, u.Email AS StudentEmail, u.AvatarUrl AS StudentAvatar, ")
           .append("cr.Rating, cr.Comment, cr.IsHidden, cr.CreatedAt ")
           .append("FROM dbo.CourseReviews cr ")
           .append("INNER JOIN dbo.Enrollments e ON cr.EnrollmentId = e.EnrollmentId ")
           .append("INNER JOIN dbo.Courses c ON e.CourseId = c.CourseId ")
           .append("INNER JOIN dbo.Users u ON e.StudentId = u.UserId ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if ("HIDDEN".equalsIgnoreCase(filter)) {
            conditions.add("cr.IsHidden = 1");
        } else if ("VISIBLE".equalsIgnoreCase(filter)) {
            conditions.add("cr.IsHidden = 0");
        }

        if (searchKeyword != null && !searchKeyword.isBlank()) {
            conditions.add("(cr.Comment LIKE ? OR u.FullName LIKE ? OR c.Title LIKE ?)");
            String kw = "%" + searchKeyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY cr.CreatedAt DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourseReview review = new CourseReview();
                    review.setEnrollmentId(rs.getLong("EnrollmentId"));
                    review.setCourseId(rs.getLong("CourseId"));
                    review.setCourseTitle(rs.getString("CourseTitle"));
                    review.setStudentName(rs.getString("StudentName"));
                    review.setStudentEmail(rs.getString("StudentEmail"));
                    review.setStudentAvatar(rs.getString("StudentAvatar"));
                    review.setRating(rs.getInt("Rating"));
                    review.setComment(rs.getString("Comment"));
                    review.setHidden(rs.getBoolean("IsHidden"));
                    review.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(review);
                }
            }
        }
        return list;
    }

    public boolean setDiscussionHidden(long postId, boolean isHidden) throws SQLException {
        String sql = "UPDATE dbo.DiscussionPosts SET IsHidden = ?, UpdatedAt = SYSUTCDATETIME() WHERE PostId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isHidden);
            ps.setLong(2, postId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean setReviewHidden(long enrollmentId, boolean isHidden) throws SQLException {
        String sql = "UPDATE dbo.CourseReviews SET IsHidden = ?, UpdatedAt = SYSUTCDATETIME() WHERE EnrollmentId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isHidden);
            ps.setLong(2, enrollmentId);
            return ps.executeUpdate() > 0;
        }
    }
}
