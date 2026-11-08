/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import config.DBContext;
import java.sql.*;
import model.CourseReview;

public class ReviewDAO {
    private long enrollment(Connection c,long userId,long courseId) throws SQLException {
        String sql="SELECT e.EnrollmentId FROM Enrollments e WITH (UPDLOCK,HOLDLOCK) "
                + "JOIN Users u ON u.UserId=e.StudentId JOIN Courses co ON co.CourseId=e.CourseId "
                + "WHERE e.StudentId=? AND e.CourseId=? AND e.AccessStatus='ACTIVE' "
                + "AND u.Status='ACTIVE' AND co.Status IN ('PUBLISHED','ARCHIVED')";
        try(PreparedStatement p=c.prepareStatement(sql)) {
            p.setLong(1,userId);p.setLong(2,courseId);
            try(ResultSet rs=p.executeQuery()) {if(rs.next()) return rs.getLong(1);}
        }
        throw new SecurityException("Chỉ học viên đã tham gia khóa học này mới có thể gửi đánh giá.");
    }

    public CourseReview getOwnReview(long userId,long courseId) throws SQLException {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                long id=enrollment(c,userId,courseId);
                CourseReview review=new CourseReview();review.setEligible(true);
                try(PreparedStatement p=c.prepareStatement("SELECT Rating,Comment FROM CourseReviews WHERE EnrollmentId=?")) {
                    p.setLong(1,id);
                    try(ResultSet rs=p.executeQuery()) {
                        if(rs.next()) {review.setExisting(true);review.setRating(rs.getInt(1));review.setComment(rs.getNString(2));}
                    }
                }
                c.commit();return review;
            } catch(SQLException | RuntimeException ex) {c.rollback();throw ex;}
        }
    }

    public java.util.Map<Long, CourseReview> getOwnReviews(long userId) throws SQLException {
        java.util.Map<Long, CourseReview> reviews = new java.util.HashMap<>();
        String sql = "SELECT e.CourseId, r.Rating, r.Comment FROM Enrollments e "
                + "JOIN Users u ON u.UserId=e.StudentId JOIN Courses c ON c.CourseId=e.CourseId "
                + "LEFT JOIN CourseReviews r ON r.EnrollmentId=e.EnrollmentId "
                + "WHERE e.StudentId=? AND e.AccessStatus='ACTIVE' AND e.CompletedAt IS NOT NULL "
                + "AND u.Status='ACTIVE' AND c.Status IN ('PUBLISHED','ARCHIVED')";
        try (Connection c=DBContext.getConnection(); PreparedStatement p=c.prepareStatement(sql)) {
            p.setLong(1,userId);
            try (ResultSet rs=p.executeQuery()) {
                while (rs.next()) {
                    CourseReview review=new CourseReview();
                    review.setEligible(true);
                    int rating=rs.getInt("Rating");
                    review.setExisting(!rs.wasNull());
                    review.setRating(rating);
                    review.setComment(rs.getNString("Comment"));
                    reviews.put(rs.getLong("CourseId"),review);
                }
            }
        }
        return reviews;
    }

    public void save(long userId,long courseId,int rating,String comment) throws SQLException {
        if(rating<1 || rating>5) throw new IllegalArgumentException("Điểm đánh giá phải từ 1 đến 5.");
        String content=comment==null?"":comment.trim();
        if(content.length()>2000) throw new IllegalArgumentException("Nhận xét tối đa 2000 ký tự.");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                long id=enrollment(c,userId,courseId);
                int updated;
                try(PreparedStatement p=c.prepareStatement("UPDATE CourseReviews SET Rating=?,Comment=?,UpdatedAt=SYSUTCDATETIME() WHERE EnrollmentId=?")) {
                    p.setInt(1,rating);p.setNString(2,content);p.setLong(3,id);updated=p.executeUpdate();
                }
                if(updated==0) {
                    try(PreparedStatement p=c.prepareStatement("INSERT INTO CourseReviews(EnrollmentId,Rating,Comment) VALUES (?,?,?)")) {
                        p.setLong(1,id);p.setInt(2,rating);p.setNString(3,content);p.executeUpdate();
                    }
                }
                c.commit();
            } catch(SQLException | RuntimeException ex) {c.rollback();throw ex;}
        }
    }
}
