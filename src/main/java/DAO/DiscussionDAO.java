/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import config.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.DiscussionPost;

public class DiscussionDAO {
    private long checkAccess(Connection c, long userId, long lessonId) throws SQLException {
        String sql = "SELECT l.CourseId FROM Lessons l JOIN Courses co ON co.CourseId=l.CourseId "
                + "JOIN Users u ON u.UserId=? AND u.Status='ACTIVE' "
                + "WHERE l.LessonId=? AND co.Status IN ('PUBLISHED','ARCHIVED') "
                + "AND (co.InstructorId=? OR EXISTS (SELECT 1 FROM Enrollments e "
                + "WHERE e.CourseId=co.CourseId AND e.StudentId=? AND e.AccessStatus='ACTIVE'))";
        try (PreparedStatement p=c.prepareStatement(sql)) {
            p.setLong(1,userId); p.setLong(2,lessonId); p.setLong(3,userId); p.setLong(4,userId);
            try (ResultSet rs=p.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SecurityException("Bạn không có quyền thảo luận bài học này.");
    }

    public long getCourseId(long userId, long lessonId) throws SQLException {
        try (Connection c=DBContext.getConnection()) { return checkAccess(c,userId,lessonId); }
    }

    public List<DiscussionPost> getPosts(long userId,long lessonId) throws SQLException {
        try (Connection c=DBContext.getConnection()) {
            checkAccess(c,userId,lessonId);
            List<DiscussionPost> posts=new ArrayList<>();
            String sql="SELECT p.PostId,p.ParentPostId,p.AuthorId,u.FullName,p.IsDeleted,p.IsHidden, CASE WHEN co.InstructorId=p.AuthorId THEN 1 ELSE 0 END AS IsInstructor, "
                    + "CASE WHEN p.IsDeleted=1 OR p.IsHidden=1 THEN NULL ELSE p.Body END AS Body, "
                    + "CONVERT(varchar(19),DATEADD(HOUR,7,p.CreatedAt),120) AS CreatedText "
                    + "FROM DiscussionPosts p JOIN Users u ON u.UserId=p.AuthorId JOIN Lessons l ON l.LessonId=p.LessonId JOIN Courses co ON co.CourseId=l.CourseId "
                    + "WHERE p.LessonId=? ORDER BY p.CreatedAt,p.PostId";
            try (PreparedStatement p=c.prepareStatement(sql)) {
                p.setLong(1,lessonId);
                try (ResultSet rs=p.executeQuery()) {
                    while(rs.next()) {
                        DiscussionPost post=new DiscussionPost();
                        post.setInstructor(rs.getBoolean("IsInstructor"));
                        post.setId(rs.getLong("PostId"));post.setParentId(rs.getLong("ParentPostId"));
                        post.setAuthorId(rs.getLong("AuthorId"));post.setAuthorName(rs.getString("FullName"));
                        post.setDeleted(rs.getBoolean("IsDeleted"));post.setHidden(rs.getBoolean("IsHidden"));
                        post.setBody(rs.getString("Body"));post.setCreatedAt(rs.getString("CreatedText"));
                        posts.add(post);
                    }
                }
            }
            java.util.Map<Long,DiscussionPost> byId=new java.util.HashMap<>();
            for(DiscussionPost post:posts) byId.put(post.getId(),post);
            List<DiscussionPost> roots=new ArrayList<>();
            for(DiscussionPost post:posts) {
                if(post.getParentId()==0) {
                    roots.add(post);
                } else {
                    DiscussionPost parent=byId.get(post.getParentId());
                    if(parent==null) continue;
                    post.setReplyToName(parent.getAuthorName());
                    DiscussionPost root=parent;
                    java.util.Set<Long> visited=new java.util.HashSet<>();
                    while(root.getParentId()!=0 && visited.add(root.getId())) {
                        DiscussionPost ancestor=byId.get(root.getParentId());
                        if(ancestor==null) break;
                        root=ancestor;
                    }
                    if(root.getParentId()==0) root.getReplies().add(post);
                }
            }
            return roots;
        }
    }

    public void create(long userId,long lessonId,long parentId,String body) throws SQLException {
        if(body==null || body.trim().isEmpty() || body.trim().length()>4000)
            throw new IllegalArgumentException("Nội dung phải có từ 1 đến 4000 ký tự.");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                checkAccess(c,userId,lessonId);
                if(parentId>0) {
                    try(PreparedStatement p=c.prepareStatement("SELECT PostId FROM DiscussionPosts WITH (UPDLOCK,HOLDLOCK) WHERE PostId=? AND LessonId=? AND IsDeleted=0 AND IsHidden=0")) {
                        p.setLong(1,parentId);p.setLong(2,lessonId);
                        try(ResultSet rs=p.executeQuery()) {
                            if(!rs.next()) throw new IllegalArgumentException("Bài được trả lời không còn hiển thị hoặc không thuộc bài học này.");
                        }
                    }
                }
                try(PreparedStatement p=c.prepareStatement("INSERT INTO DiscussionPosts(LessonId,AuthorId,ParentPostId,Body) VALUES (?,?,?,?)")) {
                    p.setLong(1,lessonId);p.setLong(2,userId);
                    if(parentId==0) p.setNull(3,Types.BIGINT);else p.setLong(3,parentId);
                    p.setNString(4,body.trim());p.executeUpdate();
                }
                c.commit();
            } catch(SQLException | RuntimeException ex) { c.rollback();throw ex; }
        }
    }

    public void delete(long userId,long lessonId,long postId) throws SQLException {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                checkAccess(c,userId,lessonId);
                try(PreparedStatement p=c.prepareStatement("UPDATE DiscussionPosts SET IsDeleted=1,UpdatedAt=SYSUTCDATETIME() WHERE PostId=? AND LessonId=? AND AuthorId=?")) {
                    p.setLong(1,postId);p.setLong(2,lessonId);p.setLong(3,userId);
                    if(p.executeUpdate()!=1) throw new SecurityException("Bạn chỉ được xóa bài viết của mình.");
                }
                c.commit();
            } catch(SQLException | RuntimeException ex) {c.rollback();throw ex;}
        }
    }
}

