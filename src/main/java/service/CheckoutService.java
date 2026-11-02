package service;

import config.DBContext;
import dao.CartDAO;
import dao.OrderDAO;
import dao.UserDAO;
import model.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CheckoutService {

    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    public static class CheckoutQuote {
        public List<CartItem> cartItems = new ArrayList<>();
        public BigDecimal subtotalVnd = BigDecimal.ZERO;
        public BigDecimal discountVnd = BigDecimal.ZERO;
        public BigDecimal totalVnd = BigDecimal.ZERO;
        public Coupon appliedCoupon;
        public String couponMessage;
        public BigDecimal userBalance = BigDecimal.ZERO;
        public BigDecimal missingVnd = BigDecimal.ZERO;
        public BigDecimal remainingBalanceAfterPay = BigDecimal.ZERO;
        public boolean isSufficient = false;
    }

    public static class PaymentResult {
        public boolean success;
        public String message;
        public String orderCode;
        public BigDecimal missingVnd = BigDecimal.ZERO;

        public static PaymentResult ok(String orderCode, String message) {
            PaymentResult r = new PaymentResult();
            r.success = true;
            r.orderCode = orderCode;
            r.message = message;
            return r;
        }

        public static PaymentResult fail(String message, BigDecimal missingVnd) {
            PaymentResult r = new PaymentResult();
            r.success = false;
            r.message = message;
            r.missingVnd = missingVnd != null ? missingVnd : BigDecimal.ZERO;
            return r;
        }
    }

    public CheckoutQuote getCheckoutQuote(long studentId, String couponCode) throws SQLException {
        return getCheckoutQuote(studentId, couponCode, null);
    }

    public CheckoutQuote getCheckoutQuote(long studentId, String couponCode, List<Long> selectedCourseIds) throws SQLException {
        CheckoutQuote quote = new CheckoutQuote();

        try (Connection conn = DBContext.getConnection()) {
            List<CartItem> allItems = cartDAO.getCartItems(conn, studentId);
            if (selectedCourseIds != null && !selectedCourseIds.isEmpty()) {
                List<CartItem> filtered = new ArrayList<>();
                for (CartItem item : allItems) {
                    if (selectedCourseIds.contains(item.getCourseId())) {
                        filtered.add(item);
                    }
                }
                quote.cartItems = filtered;
            } else {
                quote.cartItems = allItems;
            }

            quote.userBalance = userDAO.getUserBalance(conn, studentId);

            BigDecimal subtotal = BigDecimal.ZERO;
            for (CartItem item : quote.cartItems) {
                BigDecimal p = item.getCurrentPriceVnd();
                if (p != null) {
                    subtotal = subtotal.add(p);
                }
            }
            quote.subtotalVnd = subtotal;

            BigDecimal discount = BigDecimal.ZERO;
            if (couponCode != null && !couponCode.isBlank() && subtotal.compareTo(BigDecimal.ZERO) > 0) {
                Coupon coupon = orderDAO.findCouponByCode(conn, couponCode);
                if (coupon == null || !coupon.isUsable()) {
                    quote.couponMessage = "Mã giảm giá không tồn tại hoặc đã hết hạn.";
                } else if (subtotal.compareTo(coupon.getMinOrderVnd()) < 0) {
                    quote.couponMessage = "Mã giảm giá yêu cầu đơn hàng tối thiểu " + formatMoney(coupon.getMinOrderVnd()) + "đ.";
                } else {
                    discount = subtotal.multiply(BigDecimal.valueOf(coupon.getDiscountPercent()))
                            .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                    if (coupon.getMaxDiscountVnd() != null && discount.compareTo(coupon.getMaxDiscountVnd()) > 0) {
                        discount = coupon.getMaxDiscountVnd();
                    }
                    if (discount.compareTo(subtotal) > 0) {
                        discount = subtotal;
                    }
                    quote.appliedCoupon = coupon;
                    quote.couponMessage = "Áp dụng thành công mã " + coupon.getCode() + " (-" + coupon.getDiscountPercent() + "%).";
                }
            }

            quote.discountVnd = discount;
            quote.totalVnd = subtotal.subtract(discount).max(BigDecimal.ZERO);

            if (quote.userBalance.compareTo(quote.totalVnd) >= 0) {
                quote.isSufficient = true;
                quote.missingVnd = BigDecimal.ZERO;
                quote.remainingBalanceAfterPay = quote.userBalance.subtract(quote.totalVnd);
            } else {
                quote.isSufficient = false;
                quote.missingVnd = quote.totalVnd.subtract(quote.userBalance);
                quote.remainingBalanceAfterPay = BigDecimal.ZERO;
            }
        }
        return quote;
    }

    public PaymentResult payWithBalance(long studentId, String couponCode) throws SQLException {
        return payWithBalance(studentId, couponCode, null);
    }

    public PaymentResult payWithBalance(long studentId, String couponCode, List<Long> selectedCourseIds) throws SQLException {
        try (Connection conn = DBContext.beginTransaction()) {
            try {
                List<CartItem> allItems = cartDAO.getCartItems(conn, studentId);
                List<CartItem> cartItems = new ArrayList<>();
                if (selectedCourseIds != null && !selectedCourseIds.isEmpty()) {
                    for (CartItem ci : allItems) {
                        if (selectedCourseIds.contains(ci.getCourseId())) {
                            cartItems.add(ci);
                        }
                    }
                } else {
                    cartItems = allItems;
                }

                if (cartItems.isEmpty()) {
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Vui lòng chọn ít nhất một khóa học để thanh toán.", BigDecimal.ZERO);
                }

                BigDecimal subtotal = BigDecimal.ZERO;
                List<OrderItem> orderItems = new ArrayList<>();
                for (CartItem ci : cartItems) {
                    BigDecimal p = ci.getCurrentPriceVnd() != null ? ci.getCurrentPriceVnd() : BigDecimal.ZERO;
                    subtotal = subtotal.add(p);
                    OrderItem oi = new OrderItem(null, ci.getCourseId(), ci.getTitle(), p, BigDecimal.ZERO, p);
                    orderItems.add(oi);
                }

                BigDecimal discount = BigDecimal.ZERO;
                String appliedCouponCode = null;
                if (couponCode != null && !couponCode.isBlank() && subtotal.compareTo(BigDecimal.ZERO) > 0) {
                    Coupon coupon = orderDAO.findCouponByCode(conn, couponCode);
                    if (coupon != null && coupon.isUsable() && subtotal.compareTo(coupon.getMinOrderVnd()) >= 0) {
                        discount = subtotal.multiply(BigDecimal.valueOf(coupon.getDiscountPercent()))
                                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                        if (coupon.getMaxDiscountVnd() != null && discount.compareTo(coupon.getMaxDiscountVnd()) > 0) {
                            discount = coupon.getMaxDiscountVnd();
                        }
                        appliedCouponCode = coupon.getCode();
                    }
                }

                BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

                BigDecimal currentBalance = userDAO.getUserBalance(conn, studentId);
                if (currentBalance.compareTo(total) < 0) {
                    BigDecimal missing = total.subtract(currentBalance);
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Số dư tài khoản không đủ để thanh toán.", missing);
                }

                String orderCode = generateOrderCode();
                String idempotencyKey = "idem-" + studentId + "-" + UUID.randomUUID().toString().substring(0, 18);
                String merchantRef = "TXN-" + orderCode + "-BAL";

                Order order = new Order();
                order.setOrderCode(orderCode);
                order.setStudentId(studentId);
                order.setSubtotalVnd(subtotal);
                order.setDiscountVnd(discount);
                order.setTotalVnd(total);
                order.setCouponCode(appliedCouponCode);
                order.setIdempotencyKey(idempotencyKey);

                orderDAO.createOrderWithItemsAndAttempt(conn, order, orderItems, merchantRef);

                boolean paid = orderDAO.completeOrderPayment(conn, order.getOrderId(), studentId, total, appliedCouponCode);
                if (!paid) {
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Không thể thực hiện trừ số dư tài khoản.", total);
                }

                conn.commit();
                return PaymentResult.ok(orderCode, "Thanh toán đơn hàng thành công!");

            } catch (SQLException ex) {
                DBContext.rollbackQuietly(conn);
                throw ex;
            }
        }
    }

    public PaymentResult topUpAndPay(long studentId, BigDecimal topUpAmount, String couponCode) throws SQLException {
        return topUpAndPay(studentId, topUpAmount, couponCode, null);
    }

    public PaymentResult topUpAndPay(long studentId, BigDecimal topUpAmount, String couponCode, List<Long> selectedCourseIds) throws SQLException {
        if (topUpAmount == null || topUpAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return PaymentResult.fail("Số tiền nạp không hợp lệ.", BigDecimal.ZERO);
        }

        try (Connection conn = DBContext.beginTransaction()) {
            try {
                // 1. Top up user balance
                boolean toppedUp = userDAO.topUpUserBalance(conn, studentId, topUpAmount);
                if (!toppedUp) {
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Không thể nạp tiền vào tài khoản.", BigDecimal.ZERO);
                }

                // 2. Prepare order items
                List<CartItem> allItems = cartDAO.getCartItems(conn, studentId);
                List<CartItem> cartItems = new ArrayList<>();
                if (selectedCourseIds != null && !selectedCourseIds.isEmpty()) {
                    for (CartItem ci : allItems) {
                        if (selectedCourseIds.contains(ci.getCourseId())) {
                            cartItems.add(ci);
                        }
                    }
                } else {
                    cartItems = allItems;
                }

                if (cartItems.isEmpty()) {
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Vui lòng chọn ít nhất một khóa học để thanh toán.", BigDecimal.ZERO);
                }

                BigDecimal subtotal = BigDecimal.ZERO;
                List<OrderItem> orderItems = new ArrayList<>();
                for (CartItem ci : cartItems) {
                    BigDecimal p = ci.getCurrentPriceVnd() != null ? ci.getCurrentPriceVnd() : BigDecimal.ZERO;
                    subtotal = subtotal.add(p);
                    OrderItem oi = new OrderItem(null, ci.getCourseId(), ci.getTitle(), p, BigDecimal.ZERO, p);
                    orderItems.add(oi);
                }

                BigDecimal discount = BigDecimal.ZERO;
                String appliedCouponCode = null;
                if (couponCode != null && !couponCode.isBlank() && subtotal.compareTo(BigDecimal.ZERO) > 0) {
                    Coupon coupon = orderDAO.findCouponByCode(conn, couponCode);
                    if (coupon != null && coupon.isUsable() && subtotal.compareTo(coupon.getMinOrderVnd()) >= 0) {
                        discount = subtotal.multiply(BigDecimal.valueOf(coupon.getDiscountPercent()))
                                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                        if (coupon.getMaxDiscountVnd() != null && discount.compareTo(coupon.getMaxDiscountVnd()) > 0) {
                            discount = coupon.getMaxDiscountVnd();
                        }
                        appliedCouponCode = coupon.getCode();
                    }
                }

                BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

                String orderCode = generateOrderCode();
                String idempotencyKey = "idem-" + studentId + "-" + UUID.randomUUID().toString().substring(0, 18);
                String merchantRef = "TXN-" + orderCode + "-TOPUP";

                Order order = new Order();
                order.setOrderCode(orderCode);
                order.setStudentId(studentId);
                order.setSubtotalVnd(subtotal);
                order.setDiscountVnd(discount);
                order.setTotalVnd(total);
                order.setCouponCode(appliedCouponCode);
                order.setIdempotencyKey(idempotencyKey);

                orderDAO.createOrderWithItemsAndAttempt(conn, order, orderItems, merchantRef);

                boolean paid = orderDAO.completeOrderPayment(conn, order.getOrderId(), studentId, total, appliedCouponCode);
                if (!paid) {
                    DBContext.rollbackQuietly(conn);
                    return PaymentResult.fail("Thanh toán thất bại sau khi nạp tiền.", total);
                }

                conn.commit();
                return PaymentResult.ok(orderCode, "Nạp tiền và kích hoạt khóa học thành công!");

            } catch (SQLException ex) {
                DBContext.rollbackQuietly(conn);
                throw ex;
            }
        }
    }

    public int getRemainingCartCount(long studentId) {
        try (Connection conn = DBContext.getConnection()) {
            return cartDAO.getCartCount(conn, studentId);
        } catch (SQLException ex) {
            return 0;
        }
    }

    public Order getOrderDetails(String orderCode, long studentId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return orderDAO.findOrderByCode(conn, orderCode, studentId);
        }
    }

    private String generateOrderCode() {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rand = String.format("%04d", (int) (Math.random() * 10000));
        return "ORD-" + dateStr + "-" + rand;
    }

    private String formatMoney(BigDecimal amount) {
        if (amount == null) return "0";
        return java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi-VN")).format(amount);
    }
}
