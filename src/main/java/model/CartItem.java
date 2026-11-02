package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;

public class CartItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private long cartItemId;
    private long courseId;
    private String title;
    private String thumbnailUrl;
    private String status;
    private BigDecimal currentPriceVnd;
    private BigDecimal listPriceVnd;

    public CartItem() {
    }

    public CartItem(long cartItemId, long courseId,
                    String title, String thumbnailUrl,
                    String status, BigDecimal currentPriceVnd,
                    BigDecimal listPriceVnd) {
        this.cartItemId = cartItemId;
        this.courseId = courseId;
        this.title = title;
        this.thumbnailUrl = thumbnailUrl;
        this.status = status;
        this.currentPriceVnd = currentPriceVnd;
        this.listPriceVnd = listPriceVnd;
    }

    public long getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(long cartItemId) {
        this.cartItemId = cartItemId;
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

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getCurrentPriceVnd() {
        return currentPriceVnd;
    }

    public void setCurrentPriceVnd(BigDecimal currentPriceVnd) {
        this.currentPriceVnd = currentPriceVnd;
    }

    public BigDecimal getListPriceVnd() {
        return listPriceVnd;
    }

    public void setListPriceVnd(BigDecimal listPriceVnd) {
        this.listPriceVnd = listPriceVnd;
    }

    /**
     * Calculates the savings amount (listPrice - currentPrice).
     */
    public BigDecimal getSavingsVnd() {
        if (listPriceVnd != null && currentPriceVnd != null
                && listPriceVnd.compareTo(currentPriceVnd) > 0) {
            return listPriceVnd.subtract(currentPriceVnd);
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculates discount percentage: (savings / listPrice) * 100
     */
    public int getDiscountPercentage() {
        BigDecimal savings = getSavingsVnd();
        if (savings.compareTo(BigDecimal.ZERO) > 0 && listPriceVnd != null && listPriceVnd.compareTo(BigDecimal.ZERO) > 0) {
            return savings.multiply(BigDecimal.valueOf(100))
                    .divide(listPriceVnd, 0, RoundingMode.HALF_UP)
                    .intValue();
        }
        return 0;
    }
}
