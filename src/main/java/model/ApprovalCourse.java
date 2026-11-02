package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ApprovalCourse {

    private long courseId;
    private long instructorId;

    private String title;

    private String instructorName;
    private String instructorEmail;

    private String pricingType;

    private BigDecimal listPriceVnd;
    private BigDecimal salePriceVnd;
    private BigDecimal proposedPriceVnd;

    private String status;

    private Timestamp submittedAt;
    private Timestamp updatedAt;

    public ApprovalCourse() {
    }

    public long getCourseId() {
        return courseId;
    }

    public void setCourseId(long courseId) {
        this.courseId = courseId;
    }

    public long getInstructorId() {
        return instructorId;
    }

    public void setInstructorId(long instructorId) {
        this.instructorId = instructorId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(
            String instructorName
    ) {
        this.instructorName
                = instructorName;
    }

    public String getInstructorEmail() {
        return instructorEmail;
    }

    public void setInstructorEmail(
            String instructorEmail
    ) {
        this.instructorEmail
                = instructorEmail;
    }

    public String getPricingType() {
        return pricingType;
    }

    public void setPricingType(
            String pricingType
    ) {
        this.pricingType
                = pricingType;
    }

    public BigDecimal getListPriceVnd() {
        return listPriceVnd;
    }

    public void setListPriceVnd(
            BigDecimal listPriceVnd
    ) {
        this.listPriceVnd
                = listPriceVnd;
    }

    public BigDecimal getSalePriceVnd() {
        return salePriceVnd;
    }

    public void setSalePriceVnd(
            BigDecimal salePriceVnd
    ) {
        this.salePriceVnd
                = salePriceVnd;
    }

    public BigDecimal getProposedPriceVnd() {
        return proposedPriceVnd;
    }

    public void setProposedPriceVnd(
            BigDecimal proposedPriceVnd
    ) {
        this.proposedPriceVnd
                = proposedPriceVnd;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(
            Timestamp submittedAt
    ) {
        this.submittedAt
                = submittedAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(
            Timestamp updatedAt
    ) {
        this.updatedAt
                = updatedAt;
    }
}