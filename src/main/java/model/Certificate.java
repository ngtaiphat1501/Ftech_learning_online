package model;

import java.time.LocalDateTime;

public class Certificate {
    private long certificateId;
    private long enrollmentId;
    private String certificateCode;
    private String studentName;
    private String courseTitle;
    private String instructorName;
    private String status;
    private LocalDateTime issuedAt;
    private String verificationUrl;

    public Certificate() {
    }

    public Certificate(long certificateId, long enrollmentId, String certificateCode,
                       String studentName, String courseTitle, String instructorName,
                       String status, LocalDateTime issuedAt, String verificationUrl) {
        this.certificateId = certificateId;
        this.enrollmentId = enrollmentId;
        this.certificateCode = certificateCode;
        this.studentName = studentName;
        this.courseTitle = courseTitle;
        this.instructorName = instructorName;
        this.status = status;
        this.issuedAt = issuedAt;
        this.verificationUrl = verificationUrl;
    }

    public long getCertificateId() {
        return certificateId;
    }

    public void setCertificateId(long certificateId) {
        this.certificateId = certificateId;
    }

    public long getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(long enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public String getCertificateCode() {
        return certificateCode;
    }

    public void setCertificateCode(String certificateCode) {
        this.certificateCode = certificateCode;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getCourseTitle() {
        return courseTitle;
    }

    public void setCourseTitle(String courseTitle) {
        this.courseTitle = courseTitle;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(LocalDateTime issuedAt) {
        this.issuedAt = issuedAt;
    }

    public String getVerificationUrl() {
        return verificationUrl;
    }

    public void setVerificationUrl(String verificationUrl) {
        this.verificationUrl = verificationUrl;
    }
}
