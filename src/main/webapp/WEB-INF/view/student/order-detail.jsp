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
    request.setAttribute("pageTitle", "Chi tiết đơn hàng #" + orderCode + " - Ftech");
    request.setAttribute("activeMenu", "");

    String csrfToken = (String) request.getAttribute("csrfToken");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .order-detail-container {
        max-width: 860px;
        margin: 0 auto;
        padding-top: 2.5rem;
        padding-bottom: 5rem;
    }
    .detail-card {
        background-color: #151821 !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        border-radius: 1.25rem !important;
        padding: 2rem !important;
    }
    .detail-meta-box {
        background-color: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 1rem;
        padding: 1.25rem 1.5rem;
    }
    .course-detail-row {
        background-color: rgba(255, 255, 255, 0.015);
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 0.85rem;
        padding: 1rem 1.25rem;
        transition: all 0.2s ease;
    }
    .course-detail-row:hover {
        background-color: rgba(255, 255, 255, 0.03);
        border-color: rgba(99, 102, 241, 0.35);
    }
    .detail-thumb {
        width: 80px;
        height: 80px;
        border-radius: 0.65rem;
        object-fit: cover;
        background-color: #0d0f15;
        flex-shrink: 0;
    }
</style>

<main class="container order-detail-container">

    <!-- Top Navigation -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/student/orders" 
           class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1.5 text-white border-secondary border-opacity-50">
            <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách đơn hàng
        </a>
    </div>

    <% if (order == null) { %>
        <div class="detail-card text-center text-white">
            <i class="bi bi-exclamation-triangle-fill text-warning fs-1 mb-2"></i>
            <h4 class="fw-bold mb-1">Không tìm thấy thông tin đơn hàng</h4>
            <p class="text-secondary small mb-3">Đơn hàng không tồn tại hoặc bạn không có quyền xem đơn hàng này.</p>
            <a href="${pageContext.request.contextPath}/student/orders" class="btn btn-primary rounded-pill px-4">
                Về danh sách đơn hàng
            </a>
        </div>
    <% } else {
        String status = order.getStatus();
        boolean isPaid = "PAID".equalsIgnoreCase(status);
        boolean isPending = "PENDING_PAYMENT".equalsIgnoreCase(status);
        boolean isCancelled = "CANCELLED".equalsIgnoreCase(status);
    %>
        <div class="detail-card text-white shadow-lg">

            <!-- Title & Status -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
                <div>
                    <span class="text-secondary small text-uppercase fw-semibold">Chi tiết đơn hàng</span>
                    <h3 class="fw-bold text-white mb-0 font-monospace">#<%= order.getOrderCode() %></h3>
                </div>
                <div>
                    <% if (isPaid) { %>
                        <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 rounded-pill px-3 py-2 fs-6 fw-medium">
                            <i class="bi bi-patch-check-fill me-1"></i> Đã thanh toán
                        </span>
                    <% } else if (isPending) { %>
                        <span class="badge bg-warning bg-opacity-25 text-warning border border-warning border-opacity-25 rounded-pill px-3 py-2 fs-6 fw-medium">
                            <i class="bi bi-clock-history me-1"></i> Chờ thanh toán
                        </span>
                    <% } else if (isCancelled) { %>
                        <span class="badge bg-secondary bg-opacity-25 text-secondary border border-secondary border-opacity-25 rounded-pill px-3 py-2 fs-6 fw-medium">
                            <i class="bi bi-x-circle me-1"></i> Đã hủy
                        </span>
                    <% } else { %>
                        <span class="badge bg-info bg-opacity-25 text-info border border-info border-opacity-25 rounded-pill px-3 py-2 fs-6 fw-medium">
                            <%= status %>
                        </span>
                    <% } %>
                </div>
            </div>

            <!-- Metadata Box -->
            <div class="detail-meta-box mb-4">
                <div class="row g-3 text-sm">
                    <div class="col-6 col-md-3">
                        <div class="text-secondary small mb-1">Thời gian đặt:</div>
                        <div class="fw-semibold text-white">
                            <%= order.getCreatedAt() != null ? order.getCreatedAt().format(dtf) : "N/A" %>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-secondary small mb-1">Thời gian thanh toán:</div>
                        <div class="fw-semibold text-white">
                            <%= order.getPaidAt() != null ? order.getPaidAt().format(dtf) : (isPaid ? "Đã xác nhận" : "Chưa thanh toán") %>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-secondary small mb-1">Phương thức:</div>
                        <div class="fw-semibold text-white">
                            <i class="bi bi-wallet2 text-warning me-1"></i>
                            <%= order.getPaymentProvider() != null ? order.getPaymentProvider() : "Ví tài khoản Ftech" %>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-secondary small mb-1">Mã giảm giá:</div>
                        <div class="fw-semibold text-white font-monospace">
                            <%= order.getCouponCode() != null && !order.getCouponCode().isBlank() ? order.getCouponCode() : "Không áp dụng" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Items Section -->
            <div class="mb-4">
                <h5 class="fw-bold text-white mb-3 d-flex align-items-center gap-2">
                    <i class="bi bi-journal-code text-primary"></i>
                    <span>Khóa học trong đơn hàng (<%= order.getItems().size() %>)</span>
                </h5>

                <div class="d-flex flex-column gap-3">
                    <% for (OrderItem item : order.getItems()) { %>
                        <div class="course-detail-row d-flex align-items-center justify-content-between gap-3 flex-wrap">
                            <div class="d-flex align-items-center gap-3 flex-grow-1 min-w-0">
                                <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                                    <img src="<%= item.getThumbnailUrl() %>" alt="<%= item.getCourseTitleSnapshot() %>" class="detail-thumb">
                                <% } else { %>
                                    <div class="detail-thumb d-flex align-items-center justify-content-center text-primary">
                                        <i class="bi bi-journal-code fs-3"></i>
                                    </div>
                                <% } %>

                                <div class="flex-grow-1 min-w-0">
                                    <h6 class="text-white fw-bold mb-1 text-truncate" title="<%= item.getCourseTitleSnapshot() %>">
                                        <a href="${pageContext.request.contextPath}/course?id=<%= item.getCourseId() %>" class="text-white text-decoration-none hover-primary">
                                            <%= item.getCourseTitleSnapshot() %>
                                        </a>
                                    </h6>
                                    <div class="text-secondary small d-flex align-items-center gap-2 mb-1">
                                        <% if (item.getInstructorName() != null && !item.getInstructorName().isBlank()) { %>
                                            <span><i class="bi bi-person me-1"></i><%= item.getInstructorName() %></span>
                                            <span>•</span>
                                        <% } %>
                                        <span class="text-success"><i class="bi bi-shield-check me-1"></i>Quyền học vĩnh viễn</span>
                                    </div>
                                    <div class="d-flex align-items-baseline gap-2">
                                        <span class="fw-bold text-white"><%= currency.format(item.getPayableVnd()) %>đ</span>
                                        <% if (item.getDiscountVnd().compareTo(BigDecimal.ZERO) > 0) { %>
                                            <del class="text-secondary small"><%= currency.format(item.getUnitPriceVnd()) %>đ</del>
                                        <% } %>
                                    </div>
                                </div>
                            </div>

                            <% if (isPaid) { %>
                                <a href="${pageContext.request.contextPath}/student/learn?courseId=<%= item.getCourseId() %>" 
                                   class="btn btn-primary btn-sm px-3 py-2 rounded-pill fw-medium text-nowrap">
                                    <i class="bi bi-play-circle-fill me-1"></i> Vào học ngay
                                </a>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Cost Breakdown -->
            <div class="detail-meta-box mb-4">
                <div class="d-flex justify-content-between align-items-center py-1 text-secondary small">
                    <span>Tạm tính:</span>
                    <span class="text-white fw-medium"><%= currency.format(order.getSubtotalVnd()) %>đ</span>
                </div>
                <% if (order.getDiscountVnd().compareTo(BigDecimal.ZERO) > 0) { %>
                    <div class="d-flex justify-content-between align-items-center py-1 text-success small">
                        <span>Giảm giá khuyến mãi:</span>
                        <span class="fw-medium">-<%= currency.format(order.getDiscountVnd()) %>đ</span>
                    </div>
                <% } %>
                <hr class="border-secondary border-opacity-25 my-2">
                <div class="d-flex justify-content-between align-items-baseline pt-1">
                    <span class="fw-bold text-white fs-6">Tổng tiền thanh toán:</span>
                    <span class="fw-bold text-primary fs-4"><%= currency.format(order.getTotalVnd()) %>đ</span>
                </div>
            </div>

            <!-- Actions footer -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 pt-2">
                <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline-secondary text-white rounded-pill px-4 py-2 border-secondary border-opacity-50">
                    <i class="bi bi-grid me-1"></i> Xem thêm khóa học
                </a>

                <div class="d-flex align-items-center gap-2">
                    <% if (isPending) { %>
                        <button type="button" class="btn btn-primary rounded-pill px-4 py-2 fw-medium" onclick="openCheckoutModal()">
                            <i class="bi bi-credit-card me-1"></i> Thanh toán đơn này
                        </button>
                        <form action="${pageContext.request.contextPath}/student/order/cancel" method="post" class="d-inline"
                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                            <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <button type="submit" class="btn btn-outline-danger rounded-pill px-3 py-2">
                                Hủy đơn
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>

        </div>
    <% } %>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
