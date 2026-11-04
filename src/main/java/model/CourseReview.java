package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class CourseReview implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long enrollmentId;
    private int rating;
    private String comment;
    private Timestamp createdAt;
    private String studentName;
    private String studentAvatar;

    // Flags used by student review flow
    private boolean eligible;
    private boolean existing;

    public CourseReview() {
    }

    public CourseReview(Long enrollmentId, int rating, String comment, Timestamp createdAt,
                        String studentName, String studentAvatar) {
        this.enrollmentId = enrollmentId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
        this.studentName = studentName;
        this.studentAvatar = studentAvatar;
    }

    public Long getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(Long enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentAvatar() {
        return studentAvatar;
    }

    public void setStudentAvatar(String studentAvatar) {
        this.studentAvatar = studentAvatar;
    }

    public boolean isEligible() {
        return eligible;
    }

    public void setEligible(boolean eligible) {
        this.eligible = eligible;
    }

    public boolean isExisting() {
        return existing;
    }

    public void setExisting(boolean existing) {
        this.existing = existing;
    }
}
