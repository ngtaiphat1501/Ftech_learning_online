package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class InstructorStudentProgress {

    private long enrollmentId;
    private long studentId;
    private long courseId;

    private String fullName;
    private String email;
    private String accessStatus;

    private Timestamp enrolledAt;
    private Timestamp completedAt;

    private int totalRequiredLessons;
    private int completedRequiredLessons;

    private int totalRequiredQuizzes;
    private int passedRequiredQuizzes;

    private BigDecimal progressPercent;

    private boolean eligibleForCompletion;

    public InstructorStudentProgress() {
    }

    public long getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(long enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public long getStudentId() {
        return studentId;
    }

    public void setStudentId(long studentId) {
        this.studentId = studentId;
    }

    public long getCourseId() {
        return courseId;
    }

    public void setCourseId(long courseId) {
        this.courseId = courseId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAccessStatus() {
        return accessStatus;
    }

    public void setAccessStatus(String accessStatus) {
        this.accessStatus = accessStatus;
    }

    public Timestamp getEnrolledAt() {
        return enrolledAt;
    }

    public void setEnrolledAt(Timestamp enrolledAt) {
        this.enrolledAt = enrolledAt;
    }

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }

    public int getTotalRequiredLessons() {
        return totalRequiredLessons;
    }

    public void setTotalRequiredLessons(
            int totalRequiredLessons
    ) {
        this.totalRequiredLessons
                = totalRequiredLessons;
    }

    public int getCompletedRequiredLessons() {
        return completedRequiredLessons;
    }

    public void setCompletedRequiredLessons(
            int completedRequiredLessons
    ) {
        this.completedRequiredLessons
                = completedRequiredLessons;
    }

    public int getTotalRequiredQuizzes() {
        return totalRequiredQuizzes;
    }

    public void setTotalRequiredQuizzes(
            int totalRequiredQuizzes
    ) {
        this.totalRequiredQuizzes
                = totalRequiredQuizzes;
    }

    public int getPassedRequiredQuizzes() {
        return passedRequiredQuizzes;
    }

    public void setPassedRequiredQuizzes(
            int passedRequiredQuizzes
    ) {
        this.passedRequiredQuizzes
                = passedRequiredQuizzes;
    }

    public BigDecimal getProgressPercent() {
        return progressPercent;
    }

    public void setProgressPercent(
            BigDecimal progressPercent
    ) {
        this.progressPercent
                = progressPercent;
    }

    public boolean isEligibleForCompletion() {
        return eligibleForCompletion;
    }

    public void setEligibleForCompletion(
            boolean eligibleForCompletion
    ) {
        this.eligibleForCompletion
                = eligibleForCompletion;
    }
}