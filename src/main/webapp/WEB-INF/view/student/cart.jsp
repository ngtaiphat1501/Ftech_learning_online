<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.CartItem"%>

<%
    request.setAttribute("pageTitle", "Cart - Ftech");
    request.setAttribute("activeMenu", "");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");
    BigDecimal listTotal = (BigDecimal) request.getAttribute("listTotal");
    BigDecimal totalSavings = (BigDecimal) request.getAttribute("totalSavings");
    Integer totalDiscountPercent = (Integer) request.getAttribute("totalDiscountPercent");
    String message = (String) request.getAttribute("message");
    String csrfToken = (String) request.getAttribute("csrfToken");

    if (cartTotal == null) cartTotal = BigDecimal.ZERO;
    if (listTotal == null) listTotal = cartTotal;
    if (totalSavings == null) totalSavings = BigDecimal.ZERO;
    if (totalDiscountPercent == null) totalDiscountPercent = 0;

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
%>

<style>
    .cart-page-container {
        max-width: 820px;
        margin: 0 auto;
        padding-top: 3rem;
        padding-bottom: 5rem;
    }
    .cart-item-card {
        background-color: #151821 !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        border-radius: 1.25rem !important;
        padding: 1.25rem 1.5rem !important;
        transition: transform 0.15s ease, border-color 0.15s ease;
    }
    .cart-item-card:hover {
        border-color: rgba(255, 255, 255, 0.2) !important;
    }
    .cart-checkout-btn {
        background-color: #4f46e5 !important;
        border: none !important;
        transition: all 0.2s ease;
    }
    .cart-checkout-btn:hover {
        background-color: #4338ca !important;
        transform: translateY(-1px);
        box-shadow: 0 10px 25px rgba(79, 70, 229, 0.35) !important;
    }
</style>

<main class="container cart-page-container">

    <!-- Title: Cart -->
    <div class="d-flex align-items-center gap-2 mb-4">
        <i class="bi bi-cart3 text-primary fs-3"></i>
        <h1 class="h3 fw-bold text-white mb-0">Cart</h1>
    </div>

    <!-- Alert Message -->
    <% if (message != null && !message.isBlank()) { %>
        <div class="alert alert-info py-2.5 small mb-4 border-0 d-flex align-items-center gap-2 rounded-3">
            <i class="bi bi-info-circle-fill flex-shrink-0"></i>
            <span><%= message %></span>
        </div>
    <% } %>

    <% if (cartItems == null || cartItems.isEmpty()) { %>
        <!-- Empty Cart -->
        <div class="text-center py-5 rounded-4 border border-secondary border-opacity-25" style="background-color: #151821;">
            <div class="rounded-circle bg-dark d-inline-flex align-items-center justify-content-center mb-3"
                 style="width: 76px; height: 76px; border: 1px solid rgba(255,255,255,0.1);">
                <i class="bi bi-cart-x fs-1 text-secondary"></i>
            </div>
            <h4 class="text-white fw-bold mb-2">Giỏ hàng của bạn đang trống</h4>
            <p class="text-secondary small mb-4" style="max-width: 420px; margin: 0 auto;">
                Hãy khám phá các khóa học phù hợp với mục tiêu và lộ trình phát triển kỹ năng của bạn.
            </p>
            <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary rounded-pill px-4 py-2 fw-semibold">
                Khám phá khóa học ngay
            </a>
        </div>
    <% } else { %>
        <!-- Cart Items List (matching uploaded design) -->
        <div class="d-flex flex-column gap-3 mb-4" id="cartItemsList">
            <% for (CartItem item : cartItems) {
                BigDecimal price = item.getCurrentPriceVnd();
                if (price == null) price = BigDecimal.ZERO;
                BigDecimal savings = item.getSavingsVnd();
                int discountPercent = item.getDiscountPercentage();
            %>
                <div class="cart-item-card shadow-sm d-flex align-items-center gap-3">
                    <!-- Thumbnail -->
                    <div class="flex-shrink-0">
                        <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                            <img src="<%= item.getThumbnailUrl() %>"
                                 alt="<%= item.getTitle() %>"
                                 class="rounded-3"
                                 style="width: 72px; height: 72px; object-fit: cover;">
                        <% } else { %>
                            <div class="rounded-3 bg-dark d-flex align-items-center justify-content-center"
                                 style="width: 72px; height: 72px; border: 1px solid rgba(255,255,255,0.1);">
                                <i class="bi bi-journal-code fs-3 text-primary"></i>
                            </div>
                        <% } %>
                    </div>

                    <!-- Course Title & Pricing -->
                    <div class="flex-grow-1 min-w-0">
                        <h6 class="text-white fw-semibold mb-1 text-truncate fs-6" title="<%= item.getTitle() %>">
                            <a href="${pageContext.request.contextPath}/course?id=<%= item.getCourseId() %>" class="text-white text-decoration-none">
                                <%= item.getTitle() %>
                            </a>
                        </h6>
                        <div class="d-flex align-items-baseline flex-wrap gap-2">
                            <span class="fw-bold text-white fs-6">
                                <%= currency.format(price) %>đ
                            </span>
                            <% if (discountPercent > 0) { %>
                                <del class="text-secondary small">
                                    <%= currency.format(item.getListPriceVnd()) %>đ
                                </del>
                                <span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-1.5" style="font-size: 0.72rem;">
                                    -<%= discountPercent %>%
                                </span>
                            <% } %>
                        </div>
                        <% if (savings.compareTo(BigDecimal.ZERO) > 0) { %>
                            <div class="text-success small fw-medium mt-1">
                                Save <%= currency.format(savings) %>đ
                            </div>
                        <% } %>
                    </div>

                    <!-- Delete Button -->
                    <button type="button"
                            class="btn btn-link text-secondary p-2 flex-shrink-0 text-decoration-none"
                            onclick="removeCartItemFullPage(<%= item.getCourseId() %>)"
                            title="Xóa khỏi giỏ hàng"
                            aria-label="Xóa">
                        <i class="bi bi-trash3 fs-5"></i>
                    </button>
                </div>
            <% } %>
        </div>

        <!-- Total Section -->
        <div class="d-flex justify-content-between align-items-baseline mb-1">
            <span class="fw-bold text-white fs-5">Total</span>
            <div class="d-flex align-items-baseline gap-2">
                <span class="fw-bold text-white fs-3"><%= currency.format(cartTotal) %>đ</span>
                <% if (totalSavings.compareTo(BigDecimal.ZERO) > 0) { %>
                    <del class="text-secondary small fs-6"><%= currency.format(listTotal) %>đ</del>
                    <span class="badge bg-success-subtle text-success border border-success-subtle fw-bold" style="font-size: 0.8rem;">
                        -<%= totalDiscountPercent %>%
                    </span>
                <% } %>
            </div>
        </div>

        <!-- Savings text -->
        <% if (totalSavings.compareTo(BigDecimal.ZERO) > 0) { %>
            <div class="text-success fw-medium small mb-4">
                You save <%= currency.format(totalSavings) %>đ
            </div>
        <% } else { %>
            <div class="mb-4"></div>
        <% } %>

        <!-- Checkout Button -->
        <a href="${pageContext.request.contextPath}/student/checkout"
           class="btn btn-primary cart-checkout-btn w-100 py-3 rounded-pill fw-semibold shadow-sm fs-6 text-center text-white d-block text-decoration-none">
            Checkout
        </a>
    <% } %>

</main>

<!-- Scripts: Bootstrap bundle (no footer included as requested) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    async function removeCartItemFullPage(courseId) {
        if (!courseId) return;

        try {
            const formData = new URLSearchParams();
            formData.append("action", "remove");
            formData.append("courseId", courseId);
            formData.append("csrfToken", "<%= csrfToken != null ? csrfToken : "" %>");

            const response = await fetch("${pageContext.request.contextPath}/student/cart", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: formData.toString()
            });

            // Reload page to reflect updated total and items
            window.location.reload();

        } catch (err) {
            console.error("Remove cart error:", err);
            alert("Lỗi khi xóa khóa học khỏi giỏ hàng.");
        }
    }
</script>
</body>
</html>
