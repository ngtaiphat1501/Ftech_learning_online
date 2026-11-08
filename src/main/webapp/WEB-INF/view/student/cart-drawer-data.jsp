<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.CartItem"%>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");
    BigDecimal listTotal = (BigDecimal) request.getAttribute("listTotal");
    BigDecimal totalSavings = (BigDecimal) request.getAttribute("totalSavings");
    Integer totalDiscountPercent = (Integer) request.getAttribute("totalDiscountPercent");
    String csrfToken = (String) request.getAttribute("csrfToken");

    if (cartTotal == null) cartTotal = BigDecimal.ZERO;
    if (listTotal == null) listTotal = cartTotal;
    if (totalSavings == null) totalSavings = BigDecimal.ZERO;
    if (totalDiscountPercent == null) totalDiscountPercent = 0;

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
%>

<div id="cartResponse"
     data-count="<%= (cartItems != null) ? cartItems.size() : 0 %>"
     data-total="<%= currency.format(cartTotal) %>đ"
     data-list-total="<%= currency.format(listTotal) %>đ"
     data-savings="<%= currency.format(totalSavings) %>đ"
     data-has-savings="<%= totalSavings.compareTo(BigDecimal.ZERO) > 0 ? "true" : "false" %>"
     data-discount-percent="-<%= totalDiscountPercent %>%"
     data-csrf="<%= csrfToken != null ? csrfToken : "" %>">

    <% if (cartItems == null || cartItems.isEmpty()) { %>
        <div class="text-center py-5">
            <div class="rounded-circle bg-dark d-inline-flex align-items-center justify-content-center mb-3" style="width: 70px; height: 70px; border: 1px solid rgba(255,255,255,0.1);">
                <i class="bi bi-cart-x fs-2 text-secondary"></i>
            </div>
            <h6 class="text-body fw-bold">Giỏ hàng của bạn đang trống</h6>
            <p class="text-secondary small mt-1 mb-3">Hãy chọn những khóa học phù hợp với định hướng của bạn.</p>
            <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary btn-sm rounded-pill px-3 py-1.5 fw-medium">
                Khám phá khóa học
            </a>
        </div>
    <% } else { %>
        <div class="d-flex flex-column gap-2">
            <% for (CartItem item : cartItems) {
                BigDecimal price = item.getCurrentPriceVnd();
                if (price == null) price = BigDecimal.ZERO;
                BigDecimal savings = item.getSavingsVnd();
                int discountPercent = item.getDiscountPercentage();
            %>
                <div class="card bg-body-tertiary border border-secondary border-opacity-25 rounded-3 shadow-sm" style="transition: transform 0.15s ease;">
                    <div class="card-body p-2.5 d-flex align-items-center gap-3">
                        <%-- Thumbnail --%>
                        <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                            <img src="<%= escapeHtml(item.getThumbnailUrl()) %>"
                                 class="rounded-2 flex-shrink-0"
                                 style="width: 54px; height: 54px; object-fit: cover;"
                                 alt="<%= escapeHtml(item.getTitle()) %>">
                        <% } else { %>
                            <div class="rounded-2 bg-body-tertiary flex-shrink-0 d-flex align-items-center justify-content-center"
                                 style="width: 54px; height: 54px; border: 1px solid rgba(255,255,255,0.1);">
                                <i class="bi bi-book fs-4 text-primary"></i>
                            </div>
                        <% } %>

                        <%-- Course Info & Pricing --%>
                        <div class="flex-grow-1" style="min-width: 0;">
                            <h6 class="text-body fw-semibold mb-1 text-truncate" style="font-size: 0.88rem;" title="<%= escapeHtml(item.getTitle()) %>">
                                <%= escapeHtml(item.getTitle()) %>
                            </h6>
                            <div class="d-flex align-items-center flex-wrap gap-2">
                                <span class="fw-bold text-body" style="font-size: 0.92rem;">
                                    <%= currency.format(price) %>đ
                                </span>
                                <% if (discountPercent > 0) { %>
                                    <del class="text-secondary small" style="font-size: 0.78rem;">
                                        <%= currency.format(item.getListPriceVnd()) %>đ
                                    </del>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle" style="font-size: 0.7rem; padding: 0.15rem 0.35rem;">
                                        -<%= discountPercent %>%
                                    </span>
                                <% } %>
                            </div>
                            <% if (savings.compareTo(BigDecimal.ZERO) > 0) { %>
                                <div class="text-success small fw-medium mt-0.5" style="font-size: 0.76rem;">
                                    Save <%= currency.format(savings) %>đ
                                </div>
                            <% } %>
                        </div>

                        <%-- Delete Button --%>
                        <button type="button"
                                class="btn btn-link text-secondary p-1 flex-shrink-0 text-decoration-none"
                                onclick="removeCartItem(<%= item.getCourseId() %>)"
                                title="Xóa khỏi giỏ hàng"
                                aria-label="Xóa">
                            <i class="bi bi-trash3 fs-5"></i>
                        </button>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>
</div>
