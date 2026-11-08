<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.CourseReview"%>
<%@page import="model.DiscussionPost"%>

<%
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "reviews";
    String filter = (String) request.getAttribute("filter");
    String search = (String) request.getAttribute("search");

    List<CourseReview> reviews = (List<CourseReview>) request.getAttribute("reviews");
    List<DiscussionPost> discussions = (List<DiscussionPost>) request.getAttribute("discussions");
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-shield-check text-primary me-2"></i>Kiểm duyệt Nội dung (Đánh giá & Thảo luận)
            </h1>
            <p class="text-secondary small mb-0">
                Theo dõi, phát hiện vi phạm và thực hiện Ẩn/Hiện đánh giá hoặc bài thảo luận (sử dụng cờ IsHidden).
            </p>
        </div>

        <ul class="nav nav-pills bg-body-tertiary p-1 rounded-pill border border-secondary border-opacity-25">
            <li class="nav-item">
                <a class="nav-link rounded-pill px-4 fw-semibold <%= "reviews".equals(activeTab) ? "active bg-primary" : "text-light" %>"
                   href="${pageContext.request.contextPath}/admin/moderation?tab=reviews">
                    <i class="bi bi-star-fill text-warning me-1"></i>Đánh giá khóa học
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link rounded-pill px-4 fw-semibold <%= "discussions".equals(activeTab) ? "active bg-primary" : "text-light" %>"
                   href="${pageContext.request.contextPath}/admin/moderation?tab=discussions">
                    <i class="bi bi-chat-left-dots-fill text-info me-1"></i>Thảo luận bài học
                </a>
            </li>
        </ul>
    </div>

    <!-- Filter Bar -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 mb-4 shadow-sm">
        <form action="${pageContext.request.contextPath}/admin/moderation" method="GET" class="row g-3 align-items-center">
            <input type="hidden" name="tab" value="<%= activeTab %>">
            <div class="col-12 col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-body-tertiary border-secondary border-opacity-25 text-secondary"><i class="bi bi-search"></i></span>
                    <input type="text" name="q" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                           placeholder="<%= "reviews".equals(activeTab) ? "Tìm kiếm theo nhận xét hoặc tên học viên..." : "Tìm kiếm theo nội dung thảo luận hoặc tên tác giả..." %>"
                           value="<%= search != null ? search : "" %>">
                </div>
            </div>

            <div class="col-6 col-md-4">
                <select name="filter" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white">
                    <option value="ALL" <%= filter == null || "ALL".equalsIgnoreCase(filter) ? "selected" : "" %>>-- Tất cả trạng thái --</option>
                    <option value="VISIBLE" <%= "VISIBLE".equalsIgnoreCase(filter) ? "selected" : "" %>>Đang hiển thị công khai</option>
                    <option value="HIDDEN" <%= "HIDDEN".equalsIgnoreCase(filter) ? "selected" : "" %>>Đang bị ẩn (Vi phạm)</option>
                </select>
            </div>

            <div class="col-6 col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary rounded-pill px-3 w-100 fw-semibold">
                    <i class="bi bi-funnel me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/moderation?tab=<%= activeTab %>" class="btn btn-outline-secondary rounded-pill px-3">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>

    <% if ("reviews".equals(activeTab)) { %>
    <!-- REVIEWS TABLE -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead>
                    <tr class="text-secondary small border-bottom border-secondary border-opacity-25">
                        <th class="ps-4 py-3" style="width: 240px;">Khóa học</th>
                        <th class="py-3">Học viên</th>
                        <th class="py-3 text-center" style="width: 100px;">Đánh giá</th>
                        <th class="py-3">Nội dung nhận xét</th>
                        <th class="py-3 text-center" style="width: 120px;">Trạng thái</th>
                        <th class="pe-4 py-3 text-end" style="width: 140px;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (reviews != null && !reviews.isEmpty()) {
                        for (CourseReview r : reviews) {
                    %>
                    <tr class="border-bottom border-secondary border-opacity-10 <%= r.isHidden() ? "bg-danger bg-opacity-10" : "" %>">
                        <td class="ps-4">
                            <a href="${pageContext.request.contextPath}/course?id=<%= r.getCourseId() %>"
                               class="fw-semibold text-white text-decoration-none text-truncate d-block" style="max-width: 220px;" target="_blank">
                                <%= r.getCourseTitle() %>
                            </a>
                        </td>
                        <td>
                            <div class="fw-medium text-light"><%= r.getStudentName() %></div>
                            <div class="text-secondary small"><%= r.getStudentEmail() != null ? r.getStudentEmail() : "" %></div>
                        </td>
                        <td class="text-center">
                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-2 py-1">
                                <i class="bi bi-star-fill me-1"></i><%= r.getRating() %>/5
                            </span>
                        </td>
                        <td>
                            <div class="text-light small text-break"><%= r.getComment() != null ? r.getComment() : "<em class='text-secondary'>Không có lời nhắn</em>" %></div>
                        </td>
                        <td class="text-center">
                            <% if (r.isHidden()) { %>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2.5 py-1">Đã bị ẩn</span>
                            <% } else { %>
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2.5 py-1">Công khai</span>
                            <% } %>
                        </td>
                        <td class="pe-4 text-end">
                            <form action="${pageContext.request.contextPath}/admin/moderation" method="POST" class="d-inline">
                                <input type="hidden" name="tab" value="reviews">
                                <input type="hidden" name="type" value="review">
                                <input type="hidden" name="id" value="<%= r.getEnrollmentId() %>">
                                <% if (r.isHidden()) { %>
                                    <input type="hidden" name="action" value="restore">
                                    <button type="submit" class="btn btn-outline-success btn-sm rounded-3 px-3 fw-medium">
                                        <i class="bi bi-eye"></i> Hiện lại
                                    </button>
                                <% } else { %>
                                    <input type="hidden" name="action" value="hide">
                                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-3 px-3 fw-medium">
                                        <i class="bi bi-eye-slash"></i> Ẩn đánh giá
                                    </button>
                                <% } %>
                            </form>
                        </td>
                    </tr>
                    <%  }
                       } else { %>
                    <tr>
                        <td colspan="6" class="text-center py-5 text-secondary">Không tìm thấy đánh giá nào.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <% } else { %>
    <!-- DISCUSSIONS TABLE -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead>
                    <tr class="text-secondary small border-bottom border-secondary border-opacity-25">
                        <th class="ps-4 py-3" style="width: 240px;">Bài học / Khóa học</th>
                        <th class="py-3">Tác giả</th>
                        <th class="py-3">Nội dung thảo luận</th>
                        <th class="py-3 text-center" style="width: 140px;">Thời gian</th>
                        <th class="py-3 text-center" style="width: 120px;">Trạng thái</th>
                        <th class="pe-4 py-3 text-end" style="width: 140px;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (discussions != null && !discussions.isEmpty()) {
                        for (DiscussionPost p : discussions) {
                    %>
                    <tr class="border-bottom border-secondary border-opacity-10 <%= p.isHidden() ? "bg-danger bg-opacity-10" : "" %>">
                        <td class="ps-4">
                            <div class="fw-semibold text-white text-truncate" style="max-width: 220px;"><%= p.getLessonTitle() %></div>
                            <div class="text-secondary small text-truncate" style="max-width: 220px;"><%= p.getCourseTitle() %></div>
                        </td>
                        <td>
                            <div class="fw-medium text-light"><%= p.getAuthorName() %></div>
                            <div class="text-secondary small"><%= p.getAuthorEmail() != null ? p.getAuthorEmail() : "" %></div>
                        </td>
                        <td>
                            <div class="text-light small text-break"><%= p.getBody() %></div>
                        </td>
                        <td class="text-center text-secondary small">
                            <%= p.getCreatedAt() != null ? p.getCreatedAt() : "" %>
                        </td>
                        <td class="text-center">
                            <% if (p.isHidden()) { %>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2.5 py-1">Đã bị ẩn</span>
                            <% } else { %>
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2.5 py-1">Công khai</span>
                            <% } %>
                        </td>
                        <td class="pe-4 text-end">
                            <form action="${pageContext.request.contextPath}/admin/moderation" method="POST" class="d-inline">
                                <input type="hidden" name="tab" value="discussions">
                                <input type="hidden" name="type" value="discussion">
                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                <% if (p.isHidden()) { %>
                                    <input type="hidden" name="action" value="restore">
                                    <button type="submit" class="btn btn-outline-success btn-sm rounded-3 px-3 fw-medium">
                                        <i class="bi bi-eye"></i> Hiện lại
                                    </button>
                                <% } else { %>
                                    <input type="hidden" name="action" value="hide">
                                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-3 px-3 fw-medium">
                                        <i class="bi bi-eye-slash"></i> Ẩn bài viết
                                    </button>
                                <% } %>
                            </form>
                        </td>
                    </tr>
                    <%  }
                       } else { %>
                    <tr>
                        <td colspan="6" class="text-center py-5 text-secondary">Không tìm thấy bài thảo luận nào.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
