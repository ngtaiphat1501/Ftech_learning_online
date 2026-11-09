<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.List"%>
<%@page import="model.Order"%>
<%@page import="model.OrderItem"%>

<%
    request.setAttribute("pageTitle", "Lịch sử đơn hàng - Ftech");
    request.setAttribute("activeMenu", "");

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String currentStatus = (String) request.getAttribute("currentStatus");
    if (currentStatus == null) currentStatus = "ALL";
    String orderMessage = (String) request.getAttribute("orderMessage");
    String csrfToken = (String) request.getAttribute("csrfToken");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .orders-container {
        max-width: 960px;
        margin: 0 auto;
        padding-top: 2.5rem;
        padding-bottom: 5rem;
    }
    .order-card {
        background-color: var(--ftech-card-bg, var(--bs-card-bg)) !important;
        border: 1px solid var(--ftech-card-border, var(--bs-border-color)) !important;
        border-radius: 1.25rem !important;
        overflow: hidden;
        transition: transform 0.15s ease, border-color 0.15s ease;
    }
    .order-card:hover {
        border-color: var(--bs-primary) !important;
    }
    .order-card-header {
        background-color: var(--ftech-social-bg, var(--bs-tertiary-bg));
        border-bottom: 1px solid var(--ftech-card-border, var(--bs-border-color));
        padding: 1.15rem 1.5rem;
    }
    .order-card-body {
        padding: 1.25rem 1.5rem;
    }
    .order-card-footer {
        background-color: var(--ftech-social-bg, var(--bs-tertiary-bg));
        border-top: 1px solid var(--ftech-card-border, var(--bs-border-color));
        padding: 1rem 1.5rem;
    }
    .order-course-thumb {
        width: 64px;
        height: 64px;
        object-fit: cover;
        border-radius: 0.65rem;
        background-color: #0d0f15;
        flex-shrink: 0;
    }
    .nav-order-tabs .nav-link {
        color: #94a3b8;
        border: none;
        padding: 0.65rem 1.25rem;
        border-radius: 999px;
        font-weight: 500;
        font-size: 0.9rem;
        transition: all 0.2s ease;
    }
    .nav-order-tabs .nav-link.active {
        color: #ffffff !important;
        background-color: #4f46e5 !important;
        box-shadow: 0 4px 14px rgba(79, 70, 229, 0.35);
    }
    .nav-order-tabs .nav-link:hover:not(.active) {
        color: #ffffff;
        background-color: rgba(255, 255, 255, 0.06);
    }
</style>

<main class="container orders-container">

    <!-- Header Title -->
    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">Lịch sử đơn hàng</h1>
            <p class="text-secondary small mb-0">Theo dõi thông tin thanh toán và các khóa học bạn đã mua</p>
        </div>
        <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline-primary btn-sm rounded-pill px-3 py-2 fw-medium">
            <i class="bi bi-grid me-1"></i> Khám phá khóa học
        </a>
    </div>

    <!-- Alert notification if any -->
    <% if (orderMessage != null && !orderMessage.isBlank()) { %>
        <div class="alert alert-info py-2.5 small mb-4 border-0 d-flex align-items-center gap-2 rounded-3">
            <i class="bi bi-info-circle-fill flex-shrink-0"></i>
            <span><%= orderMessage %></span>
        </div>
    <% } %>

    <!-- Filter Tabs -->
    <ul class="nav nav-order-tabs gap-2 mb-4">
        <li class="nav-item">
            <a class="nav-link <%= "ALL".equals(currentStatus) ? "active" : "" %>" 
               href="${pageContext.request.contextPath}/student/orders?status=ALL">
                Tất cả
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= "PAID".equals(currentStatus) ? "active" : "" %>" 
               href="${pageContext.request.contextPath}/student/orders?status=PAID">
                <i class="bi bi-patch-check-fill text-success me-1"></i> Đã thanh toán
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= "PENDING_PAYMENT".equals(currentStatus) ? "active" : "" %>" 
               href="${pageContext.request.contextPath}/student/orders?status=PENDING_PAYMENT">
                <i class="bi bi-clock-history text-warning me-1"></i> Chờ thanh toán
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= "CANCELLED".equals(currentStatus) ? "active" : "" %>" 
               href="${pageContext.request.contextPath}/student/orders?status=CANCELLED">
                <i class="bi bi-x-circle text-secondary me-1"></i> Đã hủy
            </a>
        </li>
    </ul>

    <!-- Orders List -->
    <% if (orders == null || orders.isEmpty()) { %>
        <!-- Empty State -->
        <div class="text-center py-5 rounded-4 border border-secondary border-opacity-25 bg-body-tertiary">
            <div class="rounded-circle bg-dark d-inline-flex align-items-center justify-content-center mb-3"
                 style="width: 76px; height: 76px; border: 1px solid rgba(255,255,255,0.1);">
                <i class="bi bi-receipt-cutoff fs-1 text-secondary"></i>
            </div>
            <h5 class="fw-bold mb-1 text-body">Chưa có đơn hàng nào</h5>
            <p class="text-secondary small mb-4" style="max-width: 420px; margin: 0 auto;">
                Bạn chưa thực hiện giao dịch nào ở mục này. Hãy lựa chọn khóa học yêu thích và bắt đầu hành trình nâng cao kỹ năng!
            </p>
            <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary rounded-pill px-4 py-2 fw-semibold">
                Xem danh sách khóa học
            </a>
        </div>
    <% } else { %>
        <div class="d-flex flex-column gap-4">
            <% for (Order order : orders) {
                String status = order.getStatus();
                boolean isPaid = "PAID".equalsIgnoreCase(status);
                boolean isPending = "PENDING_PAYMENT".equalsIgnoreCase(status);
                boolean isCancelled = "CANCELLED".equalsIgnoreCase(status);
            %>
                <div class="order-card shadow-sm">
                    
                    <!-- Order Header -->
                    <div class="order-card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <div class="d-flex align-items-center gap-3">
                            <div>
                                <span class="text-secondary small d-block">Mã đơn hàng:</span>
                                <span class="fw-bold text-info font-monospace fs-6">#<%= order.getOrderCode() %></span>
                            </div>
                            <div class="border-start border-secondary border-opacity-25 ps-3 d-none d-sm-block">
                                <span class="text-secondary small d-block">Thời gian:</span>
                                <span class="text-body small">
                                    <%= order.getCreatedAt() != null ? order.getCreatedAt().format(dtf) : "Vừa xong" %>
                                </span>
                            </div>
                        </div>

                        <!-- Status Badge -->
                        <div>
                            <% if (isPaid) { %>
                                <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">
                                    <i class="bi bi-patch-check-fill me-1"></i> Đã thanh toán
                                </span>
                            <% } else if (isPending) { %>
                                <span class="badge bg-warning bg-opacity-25 text-warning border border-warning border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">
                                    <i class="bi bi-clock-history me-1"></i> Chờ thanh toán
                                </span>
                            <% } else if (isCancelled) { %>
                                <span class="badge bg-secondary bg-opacity-25 text-secondary border border-secondary border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">
                                    <i class="bi bi-x-circle me-1"></i> Đã hủy
                                </span>
                            <% } else { %>
                                <span class="badge bg-info bg-opacity-25 text-info border border-info border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">
                                    <%= status %>
                                </span>
                            <% } %>
                        </div>
                    </div>

                    <!-- Order Items Body -->
                    <div class="order-card-body">
                        <div class="d-flex flex-column gap-3">
                            <% for (OrderItem item : order.getItems()) { %>
                                <div class="d-flex align-items-center justify-content-between gap-3 flex-wrap">
                                    <div class="d-flex align-items-center gap-3 flex-grow-1 min-w-0">
                                        <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                                            <img src="<%= item.getThumbnailUrl() %>" alt="<%= item.getCourseTitleSnapshot() %>" class="order-course-thumb">
                                        <% } else { %>
                                            <div class="order-course-thumb d-flex align-items-center justify-content-center text-primary">
                                                <i class="bi bi-journal-code fs-4"></i>
                                            </div>
                                        <% } %>
                                        <div class="flex-grow-1 min-w-0">
                                            <h6 class="fw-semibold mb-1 text-truncate text-body" title="<%= item.getCourseTitleSnapshot() %>">
                                                <a href="${pageContext.request.contextPath}/course?id=<%= item.getCourseId() %>" class="text-body text-decoration-none hover-primary">
                                                    <%= item.getCourseTitleSnapshot() %>
                                                </a>
                                            </h6>
                                            <div class="text-secondary small d-flex align-items-center gap-2">
                                                <% if (item.getInstructorName() != null && !item.getInstructorName().isBlank()) { %>
                                                    <span><i class="bi bi-person me-1"></i><%= item.getInstructorName() %></span>
                                                    <span>•</span>
                                                <% } %>
                                                <span class="text-white-50"><%= currency.format(item.getPayableVnd()) %>đ</span>
                                            </div>
                                        </div>
                                    </div>

                                    <% if (isPaid) { %>
                                        <a href="${pageContext.request.contextPath}/student/learn?courseId=<%= item.getCourseId() %>" 
                                           class="btn btn-outline-primary btn-sm rounded-pill px-3 py-1.5 fw-medium text-nowrap">
                                            <i class="bi bi-play-circle-fill me-1"></i> Vào học
                                        </a>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Order Footer with Totals & Actions -->
                    <div class="order-card-footer d-flex align-items-center justify-content-between flex-wrap gap-3">
                        <div class="d-flex align-items-baseline gap-2">
                            <span class="text-secondary small">Tổng thanh toán:</span>
                            <span class="fw-bold text-body fs-5"><%= currency.format(order.getTotalVnd()) %>đ</span>
                            <% if (order.getDiscountVnd().compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                                <span class="badge bg-success bg-opacity-25 text-success small ms-1">
                                    Đã giảm <%= currency.format(order.getDiscountVnd()) %>đ
                                </span>
                            <% } %>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <!-- View Detail Button -->
                            <a href="${pageContext.request.contextPath}/student/order?id=<%= order.getOrderId() %>" 
                               class="btn btn-outline-secondary text-white btn-sm px-3 py-1.5 rounded-pill border-secondary border-opacity-50">
                                <i class="bi bi-eye me-1"></i> Chi tiết
                            </a>

                            <!-- Actions for PENDING_PAYMENT -->
                            <% if (isPending) { %>
                                <button type="button" 
                                        class="btn btn-primary btn-sm px-3 py-1.5 rounded-pill fw-medium"
                                        onclick="openCheckoutModal()">
                                    <i class="bi bi-credit-card me-1"></i> Thanh toán
                                </button>

                                <form action="${pageContext.request.contextPath}/student/order/cancel" method="post" class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                    <button type="submit" class="btn btn-link text-danger btn-sm p-1 text-decoration-none">
                                        Hủy đơn
                                    </button>
                                </form>
                            <% } %>
                        </div>
                    </div>

                </div>
            <% } %>
        </div>
    <% } %>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>

