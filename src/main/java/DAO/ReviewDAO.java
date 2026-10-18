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
        throw new SecurityException("Bạn không có quyền đánh giá khóa này.");
    }

    private boolean hasActivity(Connection c,long enrollmentId) throws SQLException {
        String sql="SELECT CASE WHEN EXISTS (SELECT 1 FROM LessonProgress WHERE EnrollmentId=?) "
                + "OR EXISTS (SELECT 1 FROM QuizAttempts WHERE EnrollmentId=?) THEN 1 ELSE 0 END";
        try(PreparedStatement p=c.prepareStatement(sql)) {
            p.setLong(1,enrollmentId);p.setLong(2,enrollmentId);
            try(ResultSet rs=p.executeQuery()) {rs.next();return rs.getBoolean(1);}
        }
    }

    public CourseReview getOwnReview(long userId,long courseId) throws SQLException {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                long id=enrollment(c,userId,courseId);
                CourseReview review=new CourseReview();review.setEligible(hasActivity(c,id));
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

    public void save(long userId,long courseId,int rating,String comment) throws SQLException {
        if(rating<1 || rating>5) throw new IllegalArgumentException("Điểm đánh giá phải từ 1 đến 5.");
        String content=comment==null?"":comment.trim();
        if(content.length()>2000) throw new IllegalArgumentException("Nhận xét tối đa 2000 ký tự.");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                long id=enrollment(c,userId,courseId);
                if(!hasActivity(c,id)) throw new SecurityException("Hãy học và lưu tiến độ ít nhất một bài trước khi đánh giá.");
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
