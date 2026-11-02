package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PaymentAttempt implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long paymentAttemptId;
    private Long orderId;
    private String merchantReference;
    private String provider = "ACCOUNT_BALANCE"; // 'ACCOUNT_BALANCE', 'VNPAY_SANDBOX'
    private String providerTransactionId;
    private BigDecimal amountVnd = BigDecimal.ZERO;
    private String currency = "VND";
    private String status = "CREATED"; // 'CREATED', 'PENDING', 'SUCCEEDED', 'FAILED', 'CANCELLED'
    private LocalDateTime createdAt;
    private LocalDateTime lastVerifiedAt;

    public PaymentAttempt() {
    }

    public Long getPaymentAttemptId() {
        return paymentAttemptId;
    }

    public void setPaymentAttemptId(Long paymentAttemptId) {
        this.paymentAttemptId = paymentAttemptId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getMerchantReference() {
        return merchantReference;
    }

    public void setMerchantReference(String merchantReference) {
        this.merchantReference = merchantReference;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderTransactionId() {
        return providerTransactionId;
    }

    public void setProviderTransactionId(String providerTransactionId) {
        this.providerTransactionId = providerTransactionId;
    }

    public BigDecimal getAmountVnd() {
        return amountVnd != null ? amountVnd : BigDecimal.ZERO;
    }

    public void setAmountVnd(BigDecimal amountVnd) {
        this.amountVnd = amountVnd;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastVerifiedAt() {
        return lastVerifiedAt;
    }

    public void setLastVerifiedAt(LocalDateTime lastVerifiedAt) {
        this.lastVerifiedAt = lastVerifiedAt;
    }
}
