<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.Course"%>

<%
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null || selectedStatus.isBlank()) {
        selectedStatus = "PENDING_APPROVAL";
    }

    Map<String, Integer> statusCounts = (Map<String, Integer>) request.getAttribute("statusCounts");
    int countPending = (statusCounts != null && statusCounts.get("PENDING_APPROVAL") != null) ? statusCounts.get("PENDING_APPROVAL") : 0;
    int countDraft = (statusCounts != null && statusCounts.get("DRAFT") != null) ? statusCounts.get("DRAFT") : 0;
    int countPublished = (statusCounts != null && statusCounts.get("PUBLISHED") != null) ? statusCounts.get("PUBLISHED") : 0;
    int countAll = (statusCounts != null && statusCounts.get("ALL") != null) ? statusCounts.get("ALL") : 0;

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    int currentCount = courses != null ? courses.size() : 0;
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-patch-check text-warning me-2"></i>Duyệt & Quản Lý Khóa Học
            </h1>
            <p class="text-secondary small mb-0">
                Xem xét nội dung khóa học, bài học do Giảng viên khởi tạo và gửi lên trước khi phê duyệt hiển thị trên sàn Ftech.
            </p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-semibold">
                <i class="bi bi-hourglass-split me-1"></i><%= countPending %> khóa chờ duyệt
            </span>
            <span class="badge bg-secondary-subtle text-light border border-secondary px-3 py-2 rounded-pill fw-semibold">
                <i class="bi bi-pencil-square me-1"></i><%= countDraft %> bản nháp mới
            </span>
        </div>
    </div>

    <!-- Status Tabs / Filter -->
    <div class="d-flex flex-wrap gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/admin/approvals?status=PENDING_APPROVAL"
           class="btn btn-sm rounded-pill px-3 py-2 <%= "PENDING_APPROVAL".equalsIgnoreCase(selectedStatus) ? "btn-warning text-dark fw-bold" : "btn-outline-secondary text-light" %>">
            <i class="bi bi-hourglass-split me-1"></i>Chờ duyệt
            <span class="badge <%= "PENDING_APPROVAL".equalsIgnoreCase(selectedStatus) ? "bg-dark text-warning" : "bg-warning text-dark" %> ms-1"><%= countPending %></span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/approvals?status=DRAFT"
           class="btn btn-sm rounded-pill px-3 py-2 <%= "DRAFT".equalsIgnoreCase(selectedStatus) ? "btn-info text-dark fw-bold" : "btn-outline-secondary text-light" %>">
            <i class="bi bi-pencil-square me-1"></i>Bản nháp (Mới tạo)
            <span class="badge <%= "DRAFT".equalsIgnoreCase(selectedStatus) ? "bg-dark text-info" : "bg-secondary text-light" %> ms-1"><%= countDraft %></span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/approvals?status=PUBLISHED"
           class="btn btn-sm rounded-pill px-3 py-2 <%= "PUBLISHED".equalsIgnoreCase(selectedStatus) ? "btn-success fw-bold" : "btn-outline-secondary text-light" %>">
            <i class="bi bi-check-circle me-1"></i>Đã xuất bản
            <span class="badge bg-dark ms-1"><%= countPublished %></span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/approvals?status=ALL"
           class="btn btn-sm rounded-pill px-3 py-2 <%= "ALL".equalsIgnoreCase(selectedStatus) ? "btn-light fw-bold" : "btn-outline-secondary text-light" %>">
            <i class="bi bi-collection me-1"></i>Tất cả
            <span class="badge bg-dark ms-1"><%= countAll %></span>
        </a>
    </div>

    <!-- Table of Courses -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                    <tr>
                        <th class="ps-4">Khóa học</th>
                        <th>Giảng viên</th>
                        <th>Trạng thái</th>
                        <th>Danh mục</th>
                        <th class="text-center">Số bài học</th>
                        <th class="text-end">Học phí</th>
                        <th class="text-center">Ngày tạo</th>
                        <th class="text-end pe-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (courses == null || courses.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-secondary">
                                <% if ("PENDING_APPROVAL".equalsIgnoreCase(selectedStatus)) { %>
                                    <i class="bi bi-check2-circle fs-1 text-success opacity-75 d-block mb-2"></i>
                                    <div class="fw-semibold text-white mb-1">Hiện không có khóa học nào đang ở hàng đợi duyệt!</div>
                                    <div class="small text-secondary mb-3">
                                        Khóa học mới tạo bởi Giảng viên sẽ ở trạng thái <strong>Bản nháp (DRAFT)</strong>. 
                                        Sau khi Giảng viên thêm chương, bài học và bấm nút <em>"Gửi duyệt"</em>, khóa học sẽ xuất hiện tại đây.
                                    </div>
                                    <a href="${pageContext.request.contextPath}/admin/approvals?status=DRAFT" class="btn btn-sm btn-outline-info rounded-pill px-3">
                                        <i class="bi bi-pencil-square me-1"></i>Xem các khóa học Bản nháp vừa tạo (<%= countDraft %> khóa) →
                                    </a>
                                <% } else { %>
                                    <i class="bi bi-inbox fs-1 text-secondary opacity-50 d-block mb-2"></i>
                                    Không có khóa học nào thuộc bộ lọc này.
                                <% } %>
                            </td>
                        </tr>
                    <% } else {
                        for (Course c : courses) {
                            String thumb = (c.getThumbnailUrl() != null && !c.getThumbnailUrl().isBlank())
                                    ? c.getThumbnailUrl()
                                    : request.getContextPath() + "/assets/images/default-course.jpg";
                            String st = c.getStatus() != null ? c.getStatus().toUpperCase() : "DRAFT";
                    %>
                        <tr>
                            <td class="ps-4">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="<%= thumb %>" alt="Thumbnail" class="rounded-3 object-fit-cover border border-secondary border-opacity-25"
                                         style="width: 72px; height: 44px;"
                                         onerror="this.src='https://placehold.co/120x80/212529/ced4da?text=Course'">
                                    <div>
                                        <a href="${pageContext.request.contextPath}/admin/approval?courseId=<%= c.getCourseId() %>"
                                           class="fw-semibold text-white text-decoration-none text-hover-primary">
                                            <%= c.getTitle() %>
                                        </a>
                                        <div class="small text-secondary text-truncate" style="max-width: 260px;">
                                            <%= c.getHeadline() != null ? c.getHeadline() : "Chưa có tóm tắt" %>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="fw-medium text-white"><%= c.getInstructorName() != null ? c.getInstructorName() : "N/A" %></div>
                                <div class="small text-secondary">ID #<%= c.getInstructorId() %></div>
                            </td>
                            <td>
                                <% if ("PENDING_APPROVAL".equals(st)) { %>
                                    <span class="badge bg-warning text-dark border border-warning-subtle rounded-pill">
                                        <i class="bi bi-hourglass-split me-1"></i>Chờ duyệt
                                    </span>
                                <% } else if ("DRAFT".equals(st)) { %>
                                    <span class="badge bg-secondary-subtle text-secondary border border-secondary rounded-pill">
                                        <i class="bi bi-pencil-square me-1"></i>Bản nháp
                                    </span>
                                <% } else if ("PUBLISHED".equals(st)) { %>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                                        <i class="bi bi-check-circle me-1"></i>Đã xuất bản
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-dark-subtle text-light border border-secondary rounded-pill">
                                        <%= st %>
                                    </span>
                                <% } %>
                            </td>
                            <td>
                                <div><span class="badge bg-secondary-subtle text-light border border-secondary border-opacity-25"><%= c.getCategoryName() != null ? c.getCategoryName() : "Chưa phân loại" %></span></div>
                                <span class="small text-secondary mt-1 d-inline-block"><%= c.getLevel() != null ? c.getLevel() : "All Levels" %></span>
                            </td>
                            <td class="text-center">
                                <span class="badge bg-info-subtle text-info border border-info-subtle rounded-pill">
                                    <i class="bi bi-play-circle me-1"></i><%= c.getLessonCount() %> bài
                                </span>
                            </td>
                            <td class="text-end font-monospace fw-bold">
                                <% if ("FREE".equalsIgnoreCase(c.getPricingType()) || (c.getSalePriceVnd() != null && c.getSalePriceVnd().doubleValue() == 0)) { %>
                                    <span class="text-success">Miễn phí</span>
                                <% } else { %>
                                    <span class="text-primary"><%= currency.format(c.getSalePriceVnd() != null ? c.getSalePriceVnd() : c.getListPriceVnd()) %> đ</span>
                                <% } %>
                            </td>
                            <td class="text-center small text-secondary">
                                <%= c.getCreatedAt() != null ? c.getCreatedAt().format(dtf) : "N/A" %>
                            </td>
                            <td class="text-end pe-4">
                                <% if ("PENDING_APPROVAL".equals(st)) { %>
                                    <a href="${pageContext.request.contextPath}/admin/approval?courseId=<%= c.getCourseId() %>"
                                       class="btn btn-sm btn-warning text-dark fw-semibold rounded-pill px-3 shadow-sm">
                                        <i class="bi bi-shield-check me-1"></i>Kiểm duyệt
                                    </a>
                                <% } else { %>
                                    <a href="${pageContext.request.contextPath}/admin/approval?courseId=<%= c.getCourseId() %>"
                                       class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                                        <i class="bi bi-eye me-1"></i>Chi tiết
                                    </a>
                                <% } %>
                            </td>
                        </tr>
                    <% }
                    } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
