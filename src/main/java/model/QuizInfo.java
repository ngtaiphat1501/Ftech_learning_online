package model;

import java.math.BigDecimal;

public class QuizInfo {
    private long quizId;
    private long courseId;
    private String title;
    private String description;
    private int durationMinutes;
    private int maxAttempts;
    private BigDecimal passingScore;
    private boolean required;
    private int questionCount;
    private int usedAttempts;
    private long activeAttemptId;
    private boolean activeExpired;
    private boolean passed;
    private int totalRequiredLessons;
    private int completedRequiredLessons;

    public QuizInfo() {
    }

    public long getQuizId() {
        return quizId;
    }

    public void setQuizId(long quizId) {
        this.quizId = quizId;
    }

    public long getCourseId() {
        return courseId;
    }

    public void setCourseId(long courseId) {
        this.courseId = courseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public int getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(int maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public BigDecimal getPassingScore() {
        return passingScore;
    }

    public void setPassingScore(BigDecimal passingScore) {
        this.passingScore = passingScore;
    }

    public boolean isRequired() {
        return required;
    }

    public void setRequired(boolean required) {
        this.required = required;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public int getUsedAttempts() {
        return usedAttempts;
    }

    public void setUsedAttempts(int usedAttempts) {
        this.usedAttempts = usedAttempts;
    }

    public long getActiveAttemptId() {
        return activeAttemptId;
    }

    public void setActiveAttemptId(long activeAttemptId) {
        this.activeAttemptId = activeAttemptId;
    }

    public boolean isActiveExpired() {
        return activeExpired;
    }

    public void setActiveExpired(boolean activeExpired) {
        this.activeExpired = activeExpired;
    }

    public boolean isPassed() {
        return passed;
    }

    public void setPassed(boolean passed) {
        this.passed = passed;
    }
    public int getTotalRequiredLessons() {
        return totalRequiredLessons;
    }

    public void setTotalRequiredLessons(int totalRequiredLessons) {
        this.totalRequiredLessons = totalRequiredLessons;
    }

    public int getCompletedRequiredLessons() {
        return completedRequiredLessons;
    }

    public void setCompletedRequiredLessons(int completedRequiredLessons) {
        this.completedRequiredLessons = completedRequiredLessons;
    }

    public boolean isLessonsCompleted() {
        return totalRequiredLessons > 0 && completedRequiredLessons >= totalRequiredLessons;
    }
}
