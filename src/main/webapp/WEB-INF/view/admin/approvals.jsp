<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.Course"%>

<%
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    int count = courses != null ? courses.size() : 0;
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-patch-check text-warning me-2"></i>Duyệt Khóa Học Chờ Xuất Bản
            </h1>
            <p class="text-secondary small mb-0">
                Xem xét nội dung khóa học, video, giáo trình do Giảng viên gửi lên trước khi phê duyệt hiển thị trên sàn Learnora.
            </p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-semibold">
                <i class="bi bi-hourglass-split me-1"></i><%= count %> khóa đang chờ duyệt
            </span>
        </div>
    </div>

    <!-- Table of Pending Courses -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                    <tr>
                        <th class="ps-4">Khóa học</th>
                        <th>Giảng viên</th>
                        <th>Danh mục / Cấp độ</th>
                        <th class="text-center">Số bài học</th>
                        <th class="text-end">Học phí</th>
                        <th class="text-center">Ngày gửi</th>
                        <th class="text-end pe-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (courses == null || courses.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center py-5 text-secondary">
                                <i class="bi bi-check2-circle fs-1 text-success opacity-75 d-block mb-2"></i>
                                Hiện tại không có khóa học nào đang chờ duyệt. Mọi yêu cầu đã được xử lý xong!
                            </td>
                        </tr>
                    <% } else {
                        for (Course c : courses) {
                            String thumb = (c.getThumbnailUrl() != null && !c.getThumbnailUrl().isBlank())
                                    ? c.getThumbnailUrl()
                                    : request.getContextPath() + "/assets/images/default-course.jpg";
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
                                        <div class="small text-secondary text-truncate" style="max-width: 280px;">
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
                                <a href="${pageContext.request.contextPath}/admin/approval?courseId=<%= c.getCourseId() %>"
                                   class="btn btn-sm btn-outline-warning rounded-pill px-3">
                                    <i class="bi bi-eye me-1"></i>Kiểm duyệt
                                </a>
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
