package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Coupon implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long couponId;
    private String code;
    private String description;
    private int discountPercent;
    private BigDecimal maxDiscountVnd;
    private BigDecimal minOrderVnd = BigDecimal.ZERO;
    private int usageLimit = 100;
    private int usedCount = 0;
    private boolean active = true;
    private LocalDateTime expiresAt;
    private LocalDateTime createdAt;

    public Coupon() {
    }

    public boolean isUsable() {
        if (!active) {
            return false;
        }
        if (usageLimit > 0 && usedCount >= usageLimit) {
            return false;
        }
        if (expiresAt != null && expiresAt.isBefore(LocalDateTime.now())) {
            return false;
        }
        return true;
    }

    public Long getCouponId() {
        return couponId;
    }

    public void setCouponId(Long couponId) {
        this.couponId = couponId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public BigDecimal getMaxDiscountVnd() {
        return maxDiscountVnd;
    }

    public void setMaxDiscountVnd(BigDecimal maxDiscountVnd) {
        this.maxDiscountVnd = maxDiscountVnd;
    }

    public BigDecimal getMinOrderVnd() {
        return minOrderVnd != null ? minOrderVnd : BigDecimal.ZERO;
    }

    public void setMinOrderVnd(BigDecimal minOrderVnd) {
        this.minOrderVnd = minOrderVnd;
    }

    public int getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(int usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
