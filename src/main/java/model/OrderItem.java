package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class OrderItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long orderItemId;
    private Long orderId;
    private Long courseId;
    private String courseTitleSnapshot;
    private BigDecimal unitPriceVnd = BigDecimal.ZERO;
    private BigDecimal discountVnd = BigDecimal.ZERO;
    private BigDecimal payableVnd = BigDecimal.ZERO;

    // Optional display helpers
    private String thumbnailUrl;
    private String instructorName;

    public OrderItem() {
    }

    public OrderItem(Long orderId, Long courseId, String courseTitleSnapshot,
                     BigDecimal unitPriceVnd, BigDecimal discountVnd, BigDecimal payableVnd) {
        this.orderId = orderId;
        this.courseId = courseId;
        this.courseTitleSnapshot = courseTitleSnapshot;
        this.unitPriceVnd = unitPriceVnd;
        this.discountVnd = discountVnd;
        this.payableVnd = payableVnd;
    }

    public Long getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(Long orderItemId) {
        this.orderItemId = orderItemId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }

    public String getCourseTitleSnapshot() {
        return courseTitleSnapshot;
    }

    public void setCourseTitleSnapshot(String courseTitleSnapshot) {
        this.courseTitleSnapshot = courseTitleSnapshot;
    }

    public BigDecimal getUnitPriceVnd() {
        return unitPriceVnd != null ? unitPriceVnd : BigDecimal.ZERO;
    }

    public void setUnitPriceVnd(BigDecimal unitPriceVnd) {
        this.unitPriceVnd = unitPriceVnd;
    }

    public BigDecimal getDiscountVnd() {
        return discountVnd != null ? discountVnd : BigDecimal.ZERO;
    }

    public void setDiscountVnd(BigDecimal discountVnd) {
        this.discountVnd = discountVnd;
    }

    public BigDecimal getPayableVnd() {
        return payableVnd != null ? payableVnd : BigDecimal.ZERO;
    }

    public void setPayableVnd(BigDecimal payableVnd) {
        this.payableVnd = payableVnd;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }
}
