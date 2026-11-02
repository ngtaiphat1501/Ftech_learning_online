package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Order implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long orderId;
    private String orderCode;
    private Long studentId;
    private String status; // 'PENDING_PAYMENT', 'PAYMENT_REVIEW', 'PAID', 'CANCELLED', 'EXPIRED', 'REFUNDED'
    private String currency = "VND";
    private BigDecimal subtotalVnd = BigDecimal.ZERO;
    private BigDecimal discountVnd = BigDecimal.ZERO;
    private BigDecimal totalVnd = BigDecimal.ZERO;
    private String couponCode;
    private String policyVersion = "v2026.1";
    private String idempotencyKey;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private LocalDateTime paidAt;

    private String paymentProvider;
    private String paymentMerchantRef;

    private List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public BigDecimal getSubtotalVnd() {
        return subtotalVnd != null ? subtotalVnd : BigDecimal.ZERO;
    }

    public void setSubtotalVnd(BigDecimal subtotalVnd) {
        this.subtotalVnd = subtotalVnd;
    }

    public BigDecimal getDiscountVnd() {
        return discountVnd != null ? discountVnd : BigDecimal.ZERO;
    }

    public void setDiscountVnd(BigDecimal discountVnd) {
        this.discountVnd = discountVnd;
    }

    public BigDecimal getTotalVnd() {
        return totalVnd != null ? totalVnd : BigDecimal.ZERO;
    }

    public void setTotalVnd(BigDecimal totalVnd) {
        this.totalVnd = totalVnd;
    }

    public String getCouponCode() {
        return couponCode;
    }

    public void setCouponCode(String couponCode) {
        this.couponCode = couponCode;
    }

    public String getPolicyVersion() {
        return policyVersion;
    }

    public void setPolicyVersion(String policyVersion) {
        this.policyVersion = policyVersion;
    }

    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public void addItem(OrderItem item) {
        if (item != null) {
            this.items.add(item);
        }
    }

    public String getPaymentProvider() {
        return paymentProvider;
    }

    public void setPaymentProvider(String paymentProvider) {
        this.paymentProvider = paymentProvider;
    }

    public String getPaymentMerchantRef() {
        return paymentMerchantRef;
    }

    public void setPaymentMerchantRef(String paymentMerchantRef) {
        this.paymentMerchantRef = paymentMerchantRef;
    }

    public int getItemCount() {
        return items != null ? items.size() : 0;
    }

    public String getFirstCourseTitle() {
        return (items != null && !items.isEmpty()) ? items.get(0).getCourseTitleSnapshot() : "";
    }

    public String getFirstCourseThumbnail() {
        return (items != null && !items.isEmpty()) ? items.get(0).getThumbnailUrl() : "";
    }
}
