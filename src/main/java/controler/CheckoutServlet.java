package controler;

import dao.WalletDAO;
import model.CartItem;
import model.User;
import service.CheckoutService;
import service.CheckoutService.CheckoutQuote;
import service.CheckoutService.PaymentResult;
import util.CartCsrf;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/student/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final CheckoutService checkoutService = new CheckoutService();
    private final WalletDAO walletDAO = new WalletDAO();

    private Long getStudentId(HttpSession session) {
        if (session == null) return null;
        Object val = session.getAttribute("userId");
        if (val instanceof Number) {
            long id = ((Number) val).longValue();
            return id > 0 ? id : null;
        }
        return null;
    }

    private boolean isJsonRequest(HttpServletRequest request) {
        String format = request.getParameter("format");
        if ("json".equalsIgnoreCase(format)) return true;
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) return true;
        String xrw = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(xrw);
    }

    private void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (ch < ' ') {
                        String t = "000" + Integer.toHexString(ch);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(ch);
                    }
            }
        }
        return sb.toString();
    }

    private String quoteToJson(CheckoutQuote quote) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"userBalance\":").append(quote.userBalance.longValue()).append(",");
        sb.append("\"subtotal\":").append(quote.subtotalVnd.longValue()).append(",");
        sb.append("\"discount\":").append(quote.discountVnd.longValue()).append(",");
        sb.append("\"total\":").append(quote.totalVnd.longValue()).append(",");
        sb.append("\"isSufficient\":").append(quote.isSufficient).append(",");
        sb.append("\"missing\":").append(quote.missingVnd.longValue()).append(",");
        sb.append("\"remaining\":").append(quote.remainingBalanceAfterPay.longValue()).append(",");
        sb.append("\"couponCode\":\"").append(quote.appliedCoupon != null ? escapeJson(quote.appliedCoupon.getCode()) : "").append("\",");
        sb.append("\"couponMessage\":\"").append(escapeJson(quote.couponMessage)).append("\",");
        sb.append("\"items\":[");
        for (int i = 0; i < quote.cartItems.size(); i++) {
            CartItem item = quote.cartItems.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"courseId\":").append(item.getCourseId()).append(",");
            sb.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
            sb.append("\"thumbnailUrl\":\"").append(escapeJson(item.getThumbnailUrl())).append("\",");
            sb.append("\"price\":").append(item.getCurrentPriceVnd() != null ? item.getCurrentPriceVnd().longValue() : 0).append(",");
            sb.append("\"listPrice\":").append(item.getListPriceVnd() != null ? item.getListPriceVnd().longValue() : 0).append(",");
            sb.append("\"discountPercent\":").append(item.getDiscountPercentage());
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        if (studentId == null) {
            if (isJsonRequest(request)) {
                sendJson(response, "{\"success\":false,\"error\":\"UNAUTHENTICATED\",\"message\":\"Vui lòng đăng nhập để tiếp tục.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            }
            return;
        }

        String couponCode = request.getParameter("coupon");
        String checkoutError = (String) session.getAttribute("checkoutError");
        session.removeAttribute("checkoutError");

        String coursesParam = request.getParameter("courses");
        List<Long> selectedCourseIds = null;
        if (coursesParam != null && !coursesParam.isBlank()) {
            selectedCourseIds = new ArrayList<>();
            for (String s : coursesParam.split(",")) {
                try {
                    long cid = Long.parseLong(s.trim());
                    if (cid > 0) selectedCourseIds.add(cid);
                } catch (NumberFormatException ignored) {}
            }
        }

        try {
            CheckoutQuote quote = checkoutService.getCheckoutQuote(studentId, couponCode, selectedCourseIds);

            if (isJsonRequest(request)) {
                sendJson(response, quoteToJson(quote));
                return;
            }

            if (quote.cartItems.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/cart");
                return;
            }

            request.setAttribute("quote", quote);
            request.setAttribute("checkoutError", checkoutError);
            request.setAttribute("couponCode", couponCode != null ? couponCode.trim() : "");
            request.setAttribute("csrfToken", CartCsrf.getOrCreate(session));
            request.setAttribute("pageTitle", "Xác nhận thanh toán - Ftech");

            request.getRequestDispatcher("/WEB-INF/view/student/checkout.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("Checkout doGet error", ex);
            if (isJsonRequest(request)) {
                sendJson(response, "{\"success\":false,\"error\":\"SERVER_ERROR\",\"message\":\"Lỗi hệ thống khi tải thông tin thanh toán.\"}");
            } else {
                throw new ServletException("Lỗi hệ thống khi tải thông tin thanh toán.", ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        boolean isJson = isJsonRequest(request);

        if (studentId == null) {
            if (isJson) {
                sendJson(response, "{\"success\":false,\"error\":\"UNAUTHENTICATED\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            }
            return;
        }

        if (!CartCsrf.isValid(session, request.getParameter("csrfToken"))) {
            if (isJson) {
                sendJson(response, "{\"success\":false,\"error\":\"INVALID_CSRF\",\"message\":\"Phiên làm việc đã hết hạn. Vui lòng tải lại trang.\"}");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token không hợp lệ.");
            }
            return;
        }

        String action = request.getParameter("action");
        String couponCode = request.getParameter("couponCode");

        String[] courseIdStrings = request.getParameterValues("selectedCourseIds");
        List<Long> selectedCourseIds = new ArrayList<>();
        if (courseIdStrings != null) {
            for (String s : courseIdStrings) {
                try {
                    long cid = Long.parseLong(s.trim());
                    if (cid > 0) selectedCourseIds.add(cid);
                } catch (NumberFormatException ignored) {}
            }
        }

        try {
            if ("apply_coupon".equals(action)) {
                CheckoutQuote quote = checkoutService.getCheckoutQuote(studentId, couponCode, selectedCourseIds);
                if (isJson) {
                    sendJson(response, quoteToJson(quote));
                    return;
                }
                StringBuilder target = new StringBuilder(request.getContextPath() + "/student/checkout");
                boolean hasParam = false;
                if (couponCode != null && !couponCode.isBlank()) {
                    target.append("?coupon=").append(java.net.URLEncoder.encode(couponCode.trim(), "UTF-8"));
                    hasParam = true;
                }
                if (!selectedCourseIds.isEmpty()) {
                    target.append(hasParam ? "&courses=" : "?courses=");
                    for (int i = 0; i < selectedCourseIds.size(); i++) {
                        if (i > 0) target.append(",");
                        target.append(selectedCourseIds.get(i));
                    }
                }
                response.sendRedirect(target.toString());
                return;
            }

            if (selectedCourseIds.isEmpty()) {
                if (isJson) {
                    sendJson(response, "{\"success\":false,\"message\":\"Vui lòng chọn ít nhất một khóa học để thanh toán.\"}");
                } else {
                    session.setAttribute("checkoutError", "Vui lòng chọn ít nhất một khóa học để thanh toán.");
                    response.sendRedirect(request.getContextPath() + "/student/checkout");
                }
                return;
            }

            if ("topup_and_pay".equals(action)) {
                String topUpStr = request.getParameter("topUpAmount");
                BigDecimal topUpAmount = BigDecimal.ZERO;
                if (topUpStr != null && !topUpStr.isBlank()) {
                    try {
                        topUpAmount = new BigDecimal(topUpStr.trim());
                    } catch (NumberFormatException ignored) {}
                }

                String topUpMethod = request.getParameter("topUpMethod");
                if (topUpMethod == null || topUpMethod.isBlank()) {
                    topUpMethod = "VIETQR";
                }

                PaymentResult result = checkoutService.topUpAndPay(studentId, topUpAmount, couponCode, selectedCourseIds);
                if (result.success) {
                    // Record deposit in WalletTransactions history
                    try {
                        walletDAO.logTransaction(
                                studentId,
                                "TOPUP",
                                topUpAmount,
                                topUpMethod.toUpperCase(),
                                "SUCCESS",
                                "Nạp tiền bù đơn hàng #" + result.orderCode
                        );
                    } catch (Exception ignored) {}

                    int remainingCount = checkoutService.getRemainingCartCount(studentId);
                    session.setAttribute("cartCount", remainingCount);
                    if (isJson) {
                        sendJson(response, "{\"success\":true,\"orderCode\":\"" + escapeJson(result.orderCode) + "\",\"remainingCartCount\":" + remainingCount + ",\"message\":\"" + escapeJson(result.message) + "\"}");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/student/order-success?orderCode=" + result.orderCode);
                    }
                } else {
                    if (isJson) {
                        sendJson(response, "{\"success\":false,\"message\":\"" + escapeJson(result.message) + "\",\"missing\":" + result.missingVnd.longValue() + "}");
                    } else {
                        session.setAttribute("checkoutError", result.message);
                        String redirectUrl = request.getContextPath() + "/student/checkout";
                        if (couponCode != null && !couponCode.isBlank()) {
                            redirectUrl += "?coupon=" + java.net.URLEncoder.encode(couponCode.trim(), "UTF-8");
                        }
                        response.sendRedirect(redirectUrl);
                    }
                }
                return;
            }

            // Default: "pay" with current balance
            PaymentResult result = checkoutService.payWithBalance(studentId, couponCode, selectedCourseIds);
            if (result.success) {
                int remainingCount = checkoutService.getRemainingCartCount(studentId);
                session.setAttribute("cartCount", remainingCount);
                if (isJson) {
                    sendJson(response, "{\"success\":true,\"orderCode\":\"" + escapeJson(result.orderCode) + "\",\"remainingCartCount\":" + remainingCount + ",\"message\":\"" + escapeJson(result.message) + "\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/student/order-success?orderCode=" + result.orderCode);
                }
            } else {
                if (isJson) {
                    sendJson(response, "{\"success\":false,\"message\":\"" + escapeJson(result.message) + "\",\"missing\":" + result.missingVnd.longValue() + "}");
                } else {
                    session.setAttribute("checkoutError", result.message);
                    String redirectUrl = request.getContextPath() + "/student/checkout";
                    if (couponCode != null && !couponCode.isBlank()) {
                        redirectUrl += "?coupon=" + java.net.URLEncoder.encode(couponCode.trim(), "UTF-8");
                    }
                    response.sendRedirect(redirectUrl);
                }
            }

        } catch (SQLException ex) {
            getServletContext().log("Checkout doPost error", ex);
            if (isJson) {
                sendJson(response, "{\"success\":false,\"message\":\"Lỗi trong quá trình xử lý đơn hàng. Vui lòng thử lại.\"}");
            } else {
                session.setAttribute("checkoutError", "Lỗi trong quá trình xử lý đơn hàng. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/student/checkout");
            }
        }
    }
}
