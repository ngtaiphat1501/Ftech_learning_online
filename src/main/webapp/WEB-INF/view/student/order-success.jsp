<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Order"%>
<%@page import="model.OrderItem"%>

<%
    Order order = (Order) request.getAttribute("order");
    String orderCode = order != null ? order.getOrderCode() : "";
    request.setAttribute("pageTitle", "Thanh toán thành công - " + orderCode);
    request.setAttribute("activeMenu", "");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .order-success-container {
        max-width: 860px;
        margin: 0 auto;
        padding-top: 3rem;
        padding-bottom: 5rem;
    }
    .success-card {
        background-color: var(--ftech-card-bg, #151821) !important;
        border: 1px solid var(--ftech-card-border, rgba(255, 255, 255, 0.1)) !important;
        border-radius: 1.25rem !important;
        padding: 2.5rem !important;
        color: var(--ftech-text-main, #ffffff);
    }
    [data-bs-theme="light"] .success-card {
        background-color: #ffffff !important;
        border-color: rgba(0, 0, 0, 0.08) !important;
        color: #0f172a !important;
    }
    .detail-box {
        background-color: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 1rem;
        padding: 1.25rem 1.5rem;
    }
    [data-bs-theme="light"] .detail-box {
        background-color: #f8fafc;
        border-color: rgba(0, 0, 0, 0.06);
    }
    .course-item-card {
        background-color: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 0.85rem;
        padding: 1rem;
        transition: all 0.2s ease;
    }
    [data-bs-theme="light"] .course-item-card {
        background-color: #ffffff;
        border-color: rgba(0, 0, 0, 0.08);
    }
    .course-item-card:hover {
        border-color: rgba(99, 102, 241, 0.4);
        background-color: rgba(255, 255, 255, 0.04);
    }
    [data-bs-theme="light"] .course-item-card:hover {
        border-color: rgba(99, 102, 241, 0.4);
        background-color: #f1f5f9;
    }
    .course-thumb {
        width: 100px;
        height: 64px;
        object-fit: cover;
        border-radius: 0.5rem;
        background-color: #0d0f15;
    }
    .success-icon-wrapper {
        width: 80px;
        height: 80px;
        margin: 0 auto 1.5rem auto;
        background: linear-gradient(135deg, rgba(34, 197, 94, 0.2), rgba(16, 185, 129, 0.05));
        border: 2px solid rgba(34, 197, 94, 0.4);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 30px rgba(34, 197, 94, 0.2);
    }
</style>

<main class="main-content">
    <div class="container order-success-container">

        <% if (order == null) { %>
            <div class="success-card text-center">
                <i class="bi bi-exclamation-triangle-fill text-warning fs-1 mb-3"></i>
                <h3 class="fw-bold mb-2">Không tìm thấy thông tin đơn hàng</h3>
                <p class="text-secondary mb-4">Vui lòng kiểm tra lại mã đơn hàng hoặc quay lại trang danh sách khóa học.</p>
                <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary px-4 py-2 rounded-pill">
                    <i class="bi bi-journal-code me-2"></i>Xem khóa học
                </a>
            </div>
        <% } else { %>

            <div class="success-card shadow-lg">

                <!-- Header Icon & Status -->
                <div class="text-center mb-4">
                    <div class="success-icon-wrapper">
                        <i class="bi bi-check-lg text-success fs-1"></i>
                    </div>
                    <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 px-3 py-2 rounded-pill fw-medium mb-3">
                        <i class="bi bi-patch-check-fill me-1"></i> Giao dịch thành công
                    </span>
                    <h2 class="fw-bold mb-2">Thanh toán hoàn tất!</h2>
                    <p class="text-secondary mb-0" style="max-width: 550px; margin: 0 auto;">
                        Cảm ơn bạn đã tin tưởng lựa chọn Ftech. Khóa học đã được tự động kích hoạt vào tài khoản của bạn và sẵn sàng để học.
                    </p>
                </div>

                <!-- Order Meta Info Box -->
                <div class="detail-box mb-4">
                    <div class="row g-3 text-sm">
                        <div class="col-6 col-md-3">
                            <div class="text-secondary small mb-1">Mã đơn hàng</div>
                            <div class="fw-semibold text-primary font-monospace">#<%= order.getOrderCode() %></div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="text-secondary small mb-1">Thời gian</div>
                            <div class="fw-semibold">
                                <%= order.getPaidAt() != null ? order.getPaidAt().format(dtf) : (order.getCreatedAt() != null ? order.getCreatedAt().format(dtf) : "Vừa xong") %>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="text-secondary small mb-1">Phương thức</div>
                            <div class="fw-semibold">
                                <i class="bi bi-wallet2 text-warning me-1"></i> Số dư tài khoản Ftech
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="text-secondary small mb-1">Tổng thanh toán</div>
                            <div class="fw-bold text-success fs-6">
                                <%= currency.format(order.getTotalVnd()) %>đ
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Purchased Courses Section -->
                <div class="mb-4">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h5 class="fw-bold mb-0">
                            <i class="bi bi-collection-play me-2 text-primary"></i>Khóa học đã đăng ký (<%= order.getItems().size() %>)
                        </h5>
                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill">
                            Quyền truy cập: Vĩnh viễn
                        </span>
                    </div>

                    <div class="d-flex flex-column gap-3">
                        <% for (OrderItem item : order.getItems()) { %>
                            <div class="course-item-card d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                                        <img src="<%= item.getThumbnailUrl() %>" alt="<%= item.getCourseTitleSnapshot() %>" class="course-thumb">
                                    <% } else { %>
                                        <div class="course-thumb d-flex align-items-center justify-content-center text-secondary">
                                            <i class="bi bi-journal-code fs-3"></i>
                                        </div>
                                    <% } %>
                                    <div>
                                        <h6 class="fw-semibold mb-1"><%= item.getCourseTitleSnapshot() %></h6>
                                        <div class="text-secondary small d-flex align-items-center gap-2">
                                            <% if (item.getInstructorName() != null && !item.getInstructorName().isBlank()) { %>
                                                <span><i class="bi bi-person me-1"></i><%= item.getInstructorName() %></span>
                                                <span>•</span>
                                            <% } %>
                                            <span class="text-success"><i class="bi bi-check2-circle me-1"></i>Đã kích hoạt</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center gap-3 justify-content-between justify-content-sm-end">
                                    <div class="text-end">
                                        <div class="fw-bold"><%= currency.format(item.getPayableVnd()) %>đ</div>
                                        <% if (item.getDiscountVnd() != null && item.getDiscountVnd().compareTo(BigDecimal.ZERO) > 0) { %>
                                            <div class="text-secondary small text-decoration-line-through">
                                                <%= currency.format(item.getUnitPriceVnd()) %>đ
                                            </div>
                                        <% } %>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/student/learn?courseId=<%= item.getCourseId() %>" 
                                       class="btn btn-primary btn-sm px-3 py-2 rounded-pill fw-medium text-nowrap">
                                        <i class="bi bi-play-circle-fill me-1"></i> Vào học ngay
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Price Breakdown Accordion / Box -->
                <div class="detail-box mb-4">
                    <div class="d-flex justify-content-between align-items-center py-1">
                        <span class="text-secondary">Tạm tính:</span>
                        <span class="fw-medium"><%= currency.format(order.getSubtotalVnd()) %>đ</span>
                    </div>
                    <% if (order.getDiscountVnd() != null && order.getDiscountVnd().compareTo(BigDecimal.ZERO) > 0) { %>
                        <div class="d-flex justify-content-between align-items-center py-1">
                            <span class="text-secondary">
                                Giảm giá voucher 
                                <% if (order.getCouponCode() != null && !order.getCouponCode().isBlank()) { %>
                                    <span class="badge bg-warning text-dark font-monospace ms-1"><%= order.getCouponCode() %></span>
                                <% } %>:
                            </span>
                            <span class="text-success">-<%= currency.format(order.getDiscountVnd()) %>đ</span>
                        </div>
                    <% } %>
                    <hr class="border-secondary border-opacity-25 my-2">
                    <div class="d-flex justify-content-between align-items-center pt-1">
                        <span class="fw-bold fs-6">Tổng tiền thanh toán:</span>
                        <span class="fw-bold text-success fs-5"><%= currency.format(order.getTotalVnd()) %>đ</span>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="d-flex flex-column flex-sm-row align-items-center justify-content-center gap-3 pt-2">
                    <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline-secondary rounded-pill px-4 py-2 w-100 w-sm-auto">
                        <i class="bi bi-grid me-2"></i>Xem thêm khóa học
                    </a>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-secondary rounded-pill px-4 py-2 w-100 w-sm-auto">
                        <i class="bi bi-house-door me-2"></i>Trang chủ
                    </a>
                </div>

            </div>

        <% } %>

    </div>
</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
