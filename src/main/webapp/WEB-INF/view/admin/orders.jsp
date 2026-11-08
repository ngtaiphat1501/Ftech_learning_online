<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Order"%>
<%@page import="model.OrderItem"%>

<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String search = (String) request.getAttribute("search");
    String statusFilter = (String) request.getAttribute("statusFilter");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    int totalOrdersCount = orders != null ? orders.size() : 0;
    long paidCount = 0;
    long pendingCount = 0;
    long reviewCount = 0;
    BigDecimal totalPaidAmount = BigDecimal.ZERO;

    if (orders != null) {
        for (Order o : orders) {
            if ("PAID".equalsIgnoreCase(o.getStatus())) {
                paidCount++;
                if (o.getTotalVnd() != null) {
                    totalPaidAmount = totalPaidAmount.add(o.getTotalVnd());
                }
            } else if ("PENDING_PAYMENT".equalsIgnoreCase(o.getStatus())) {
                pendingCount++;
            } else if ("PAYMENT_REVIEW".equalsIgnoreCase(o.getStatus())) {
                reviewCount++;
            }
        }
    }
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-receipt text-primary me-2"></i>Quản lý Đơn hàng & Đối soát Thanh toán
            </h1>
            <p class="text-secondary small mb-0">
                Theo dõi giao dịch, xử lý thanh toán bất thường, đối soát và tự động mở quyền học cho học viên khi chuyển sang PAID.
            </p>
        </div>
    </div>

    <!-- Overview Stats Cards -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm">
                <span class="text-secondary small fw-medium">Tổng đơn hiển thị</span>
                <div class="h4 fw-bold text-white mt-1 mb-0"><%= totalOrdersCount %></div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm">
                <span class="text-success small fw-medium"><i class="bi bi-check-circle me-1"></i>Đã thanh toán (PAID)</span>
                <div class="h4 fw-bold text-success mt-1 mb-0"><%= paidCount %></div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm">
                <span class="text-warning small fw-medium"><i class="bi bi-clock-history me-1"></i>Chờ thanh toán (PENDING)</span>
                <div class="h4 fw-bold text-warning mt-1 mb-0"><%= pendingCount %></div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm">
                <span class="text-info small fw-medium"><i class="bi bi-exclamation-diamond me-1"></i>Cần đối soát (REVIEW)</span>
                <div class="h4 fw-bold text-info mt-1 mb-0"><%= reviewCount %></div>
            </div>
        </div>
    </div>

    <!-- Search & Filter Bar -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 mb-4 shadow-sm">
        <form action="${pageContext.request.contextPath}/admin/orders" method="GET" class="row g-3 align-items-center">
            <div class="col-12 col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-body-tertiary border-secondary border-opacity-25 text-secondary"><i class="bi bi-search"></i></span>
                    <input type="text" name="q" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                           placeholder="Tìm theo mã đơn, học viên, email hoặc Ref..." value="<%= search != null ? search : "" %>">
                </div>
            </div>

            <div class="col-8 col-md-4">
                <select name="status" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white">
                    <option value="ALL" <%= statusFilter == null || "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>-- Tất cả trạng thái --</option>
                    <option value="PAID" <%= "PAID".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Đã thanh toán (PAID)</option>
                    <option value="PENDING_PAYMENT" <%= "PENDING_PAYMENT".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Chờ thanh toán (PENDING)</option>
                    <option value="PAYMENT_REVIEW" <%= "PAYMENT_REVIEW".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Cần đối soát (PAYMENT_REVIEW)</option>
                    <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Đã hủy (CANCELLED)</option>
                    <option value="REFUNDED" <%= "REFUNDED".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Đã hoàn tiền (REFUNDED)</option>
                </select>
            </div>

            <div class="col-4 col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary w-100 rounded-pill">
                    <i class="bi bi-funnel me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary rounded-pill" title="Đặt lại bộ lọc">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>

    <!-- Orders Table -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                    <tr>
                        <th class="ps-4">Mã đơn & Thời gian</th>
                        <th>Học viên</th>
                        <th>Cổng TT / Mã GD</th>
                        <th>Khóa học</th>
                        <th class="text-end">Tổng tiền</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-end pe-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (orders == null || orders.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center py-5 text-secondary">
                                <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary opacity-50"></i>
                                Không tìm thấy đơn hàng nào phù hợp với bộ lọc.
                            </td>
                        </tr>
                    <% } else {
                        for (Order ord : orders) {
                            String st = ord.getStatus() != null ? ord.getStatus().toUpperCase() : "UNKNOWN";
                            String badgeClass = "bg-secondary";
                            String statusLabel = st;
                            if ("PAID".equals(st)) {
                                badgeClass = "bg-success";
                                statusLabel = "ĐÃ THANH TOÁN";
                            } else if ("PENDING_PAYMENT".equals(st)) {
                                badgeClass = "bg-warning text-dark";
                                statusLabel = "CHỜ THANH TOÁN";
                            } else if ("PAYMENT_REVIEW".equals(st)) {
                                badgeClass = "bg-info text-dark";
                                statusLabel = "CẦN ĐỐI SOÁT";
                            } else if ("CANCELLED".equals(st)) {
                                badgeClass = "bg-secondary";
                                statusLabel = "ĐÃ HỦY";
                            } else if ("REFUNDED".equals(st)) {
                                badgeClass = "bg-danger";
                                statusLabel = "HOÀN TIỀN";
                            }
                    %>
                        <tr>
                            <td class="ps-4">
                                <div class="fw-semibold text-white font-monospace">#<%= ord.getOrderCode() %></div>
                                <div class="small text-secondary">
                                    <%= ord.getCreatedAt() != null ? ord.getCreatedAt().format(dtf) : "N/A" %>
                                </div>
                            </td>
                            <td>
                                <div class="fw-medium text-white"><%= ord.getStudentName() != null ? ord.getStudentName() : ("ID #" + ord.getStudentId()) %></div>
                                <div class="small text-secondary"><%= ord.getStudentEmail() != null ? ord.getStudentEmail() : "" %></div>
                            </td>
                            <td>
                                <span class="badge bg-body-tertiary text-light border border-secondary border-opacity-25">
                                    <%= ord.getPaymentProvider() != null ? ord.getPaymentProvider() : "MOMO / VNPAY" %>
                                </span>
                                <% if (ord.getPaymentMerchantRef() != null && !ord.getPaymentMerchantRef().isBlank()) { %>
                                    <div class="small text-secondary font-monospace mt-1" title="Merchant Ref">
                                        <i class="bi bi-hash"></i><%= ord.getPaymentMerchantRef() %>
                                    </div>
                                <% } %>
                            </td>
                            <td>
                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill">
                                    <i class="bi bi-journal-bookmark me-1"></i><%= ord.getItems() != null ? ord.getItems().size() : 0 %> môn
                                </span>
                                <% if (ord.getItems() != null && !ord.getItems().isEmpty()) { %>
                                    <div class="small text-secondary text-truncate mt-1" style="max-width: 220px;" title="<%= ord.getItems().get(0).getCourseTitleSnapshot() %>">
                                        <%= ord.getItems().get(0).getCourseTitleSnapshot() %>
                                        <% if (ord.getItems().size() > 1) { %>
                                            <span class="text-primary">(+<%= ord.getItems().size() - 1 %>)</span>
                                        <% } %>
                                    </div>
                                <% } %>
                            </td>
                            <td class="text-end font-monospace fw-bold text-success">
                                <%= ord.getTotalVnd() != null ? currency.format(ord.getTotalVnd()) : "0" %> đ
                            </td>
                            <td class="text-center">
                                <span class="badge <%= badgeClass %> px-2 py-1 rounded-pill"><%= statusLabel %></span>
                                <% if (ord.getReconcileNote() != null && !ord.getReconcileNote().isBlank()) { %>
                                    <div class="small text-warning mt-1 text-truncate" style="max-width: 150px;" title="<%= ord.getReconcileNote() %>">
                                        <i class="bi bi-info-circle me-1"></i><%= ord.getReconcileNote() %>
                                    </div>
                                <% } %>
                            </td>
                            <td class="text-end pe-4">
                                <div class="d-inline-flex gap-2">
                                    <!-- Reconcile Button -->
                                    <button type="button" class="btn btn-sm btn-outline-warning rounded-pill px-3"
                                            onclick="openReconcileModal(<%= ord.getOrderId() %>, '<%= ord.getOrderCode() %>', '<%= st %>', '<%= ord.getReconcileNote() != null ? ord.getReconcileNote().replace("'", "\\'") : "" %>')">
                                        <i class="bi bi-arrow-repeat me-1"></i>Đối soát
                                    </button>

                                    <!-- Detail Modal Trigger -->
                                    <button type="button" class="btn btn-sm btn-outline-light rounded-pill px-2.5"
                                            data-bs-toggle="modal" data-bs-target="#orderDetailModal<%= ord.getOrderId() %>" title="Xem chi tiết đơn">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>

                                <!-- Order Detail Modal -->
                                <div class="modal fade text-start" id="orderDetailModal<%= ord.getOrderId() %>" tabindex="-1" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered modal-lg">
                                        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
                                            <div class="modal-header border-secondary border-opacity-25">
                                                <h5 class="modal-title fw-bold">
                                                    <i class="bi bi-receipt text-primary me-2"></i>Chi tiết đơn hàng #<%= ord.getOrderCode() %>
                                                </h5>
                                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body p-4">
                                                <div class="row g-3 mb-4">
                                                    <div class="col-sm-6">
                                                        <span class="text-secondary small d-block">Học viên</span>
                                                        <strong><%= ord.getStudentName() != null ? ord.getStudentName() : "N/A" %></strong>
                                                        <div class="small text-secondary"><%= ord.getStudentEmail() != null ? ord.getStudentEmail() : "" %></div>
                                                    </div>
                                                    <div class="col-sm-6 text-sm-end">
                                                        <span class="text-secondary small d-block">Thời gian tạo</span>
                                                        <div><%= ord.getCreatedAt() != null ? ord.getCreatedAt().format(dtf) : "N/A" %></div>
                                                        <span class="badge <%= badgeClass %> mt-1"><%= statusLabel %></span>
                                                    </div>
                                                </div>

                                                <h6 class="fw-semibold text-secondary text-uppercase small mb-3">Danh sách khóa học</h6>
                                                <div class="list-group list-group-flush border border-secondary border-opacity-25 rounded-3 mb-4">
                                                    <% if (ord.getItems() != null && !ord.getItems().isEmpty()) {
                                                        for (OrderItem item : ord.getItems()) { %>
                                                            <div class="list-group-item bg-dark text-white d-flex justify-content-between align-items-center border-secondary border-opacity-25 py-2.5">
                                                                <div>
                                                                    <div class="fw-medium"><%= item.getCourseTitleSnapshot() != null ? item.getCourseTitleSnapshot() : ("Khóa học #" + item.getCourseId()) %></div>
                                                                    <div class="small text-secondary">Course ID: #<%= item.getCourseId() %></div>
                                                                </div>
                                                                <div class="text-end font-monospace text-primary fw-semibold">
                                                                    <%= item.getPayableVnd() != null ? currency.format(item.getPayableVnd()) : "0" %> đ
                                                                </div>
                                                            </div>
                                                        <% }
                                                    } else { %>
                                                        <div class="list-group-item bg-dark text-secondary py-3 text-center">Không có chi tiết mặt hàng</div>
                                                    <% } %>
                                                </div>

                                                <div class="card bg-body-tertiary border-0 rounded-3 p-3">
                                                    <div class="d-flex justify-content-between mb-1">
                                                        <span class="text-secondary">Tạm tính:</span>
                                                        <span class="font-monospace"><%= ord.getSubtotalVnd() != null ? currency.format(ord.getSubtotalVnd()) : "0" %> đ</span>
                                                    </div>
                                                    <div class="d-flex justify-content-between mb-1">
                                                        <span class="text-secondary">Giảm giá voucher:</span>
                                                        <span class="font-monospace text-danger">-<%= ord.getDiscountVnd() != null ? currency.format(ord.getDiscountVnd()) : "0" %> đ</span>
                                                    </div>
                                                    <div class="d-flex justify-content-between border-top border-secondary border-opacity-25 pt-2 mt-2">
                                                        <span class="fw-bold">Tổng thanh toán:</span>
                                                        <span class="font-monospace fw-bold text-success fs-5"><%= ord.getTotalVnd() != null ? currency.format(ord.getTotalVnd()) : "0" %> đ</span>
                                                    </div>
                                                </div>

                                                <% if (ord.getReconcileNote() != null && !ord.getReconcileNote().isBlank()) { %>
                                                    <div class="alert alert-warning border-0 rounded-3 mt-3 mb-0 small">
                                                        <i class="bi bi-info-circle-fill me-1"></i><strong>Ghi chú đối soát:</strong> <%= ord.getReconcileNote() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="modal-footer border-secondary border-opacity-25">
                                                <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    <% }
                    } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Modal Reconcile Payment -->
<div class="modal fade" id="reconcileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/admin/payment/reconcile" method="POST">
                <input type="hidden" name="action" value="reconcile">
                <input type="hidden" name="orderId" id="reconcileOrderId">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold">
                        <i class="bi bi-arrow-repeat text-warning me-2"></i>Đối soát & Cập nhật Trạng thái Đơn
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <p class="text-secondary small mb-3">
                        Thực hiện đối soát thanh toán thủ công cho đơn hàng <strong class="text-white" id="reconcileOrderCodeText">#ORDER</strong>. 
                        Khi chuyển sang <strong class="text-success">PAID</strong>, hệ thống sẽ tự động kích hoạt quyền truy cập khóa học cho học viên.
                    </p>

                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Chuyển trạng thái sang <span class="text-danger">*</span></label>
                        <select name="targetStatus" id="reconcileTargetStatus" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white" required>
                            <option value="PAID">ĐÃ THANH TOÁN (PAID) - Kích hoạt quyền học</option>
                            <option value="PAYMENT_REVIEW">CẦN ĐỐI SOÁT (PAYMENT_REVIEW) - Giao dịch nghi vấn</option>
                            <option value="CANCELLED">HỦY ĐƠN (CANCELLED) - Giao dịch thất bại</option>
                            <option value="REFUNDED">HOÀN TIỀN (REFUNDED) - Đã hoàn tiền cho khách</option>
                        </select>
                    </div>

                    <div class="mb-2">
                        <label class="form-label text-secondary small fw-medium">Ghi chú đối soát / Lý do</label>
                        <textarea name="note" id="reconcileNote" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                  rows="3" placeholder="Nhập mã giao dịch ngân hàng, biên lai chuyển khoản hoặc lý do đối soát..."></textarea>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning rounded-pill px-4 fw-medium">
                        <i class="bi bi-check-circle me-1"></i>Xác nhận Cập nhật
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openReconcileModal(orderId, orderCode, currentStatus, currentNote) {
    document.getElementById('reconcileOrderId').value = orderId;
    document.getElementById('reconcileOrderCodeText').innerText = '#' + orderCode;
    
    var select = document.getElementById('reconcileTargetStatus');
    if (currentStatus === 'PENDING_PAYMENT') {
        select.value = 'PAID';
    } else if (currentStatus === 'PAID') {
        select.value = 'PAYMENT_REVIEW';
    } else {
        select.value = currentStatus;
    }
    
    document.getElementById('reconcileNote').value = currentNote || '';

    var modal = new bootstrap.Modal(document.getElementById('reconcileModal'));
    modal.show();
}
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
