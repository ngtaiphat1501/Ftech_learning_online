<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.Course"%>
<%@page import="model.Chapter"%>
<%@page import="model.Lesson"%>
<%@page import="model.CourseApprovalEvent"%>

<%
    Course course = (Course) request.getAttribute("course");
    List<Chapter> chapters = (List<Chapter>) request.getAttribute("chapters");
    List<CourseApprovalEvent> history = (List<CourseApprovalEvent>) request.getAttribute("history");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    String thumb = (course != null && course.getThumbnailUrl() != null && !course.getThumbnailUrl().isBlank())
            ? course.getThumbnailUrl()
            : request.getContextPath() + "/assets/images/default-course.jpg";
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <!-- Top Back & Action Bar -->
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <a href="${pageContext.request.contextPath}/admin/approvals" class="btn btn-sm btn-outline-secondary rounded-pill mb-2">
                <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách chờ duyệt
            </a>
            <h1 class="h3 fw-bold text-white mb-1">
                Kiểm duyệt: <%= course != null ? course.getTitle() : "Khóa học" %>
            </h1>
            <div class="d-flex align-items-center gap-2 small text-secondary">
                <span>Giảng viên: <strong class="text-white"><%= course != null ? course.getInstructorName() : "N/A" %></strong></span>
                <span>•</span>
                <span>Trạng thái hiện tại: 
                    <% String stDetail = course != null ? course.getStatus() : ""; %>
                    <% if ("PENDING_APPROVAL".equalsIgnoreCase(stDetail)) { %>
                        <span class="badge bg-warning text-dark">Chờ duyệt</span>
                    <% } else if ("DRAFT".equalsIgnoreCase(stDetail)) { %>
                        <span class="badge bg-secondary-subtle text-light border border-secondary">Bản nháp (DRAFT)</span>
                    <% } else if ("PUBLISHED".equalsIgnoreCase(stDetail)) { %>
                        <span class="badge bg-success">Đã xuất bản (PUBLISHED)</span>
                    <% } else { %>
                        <span class="badge bg-dark-subtle text-light"><%= stDetail %></span>
                    <% } %>
                </span>
            </div>
        </div>

        <div class="d-flex align-items-center gap-2">
            <% if ("PENDING_APPROVAL".equalsIgnoreCase(course != null ? course.getStatus() : "")) { %>
                <!-- Reject Button -->
                <button type="button" class="btn btn-outline-danger rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#rejectModal">
                    <i class="bi bi-x-circle me-1"></i>Từ chối duyệt
                </button>

                <!-- Approve Button -->
                <button type="button" class="btn btn-success rounded-pill px-4 fw-semibold" data-bs-toggle="modal" data-bs-target="#approveModal">
                    <i class="bi bi-check-circle me-1"></i>Phê duyệt & Xuất bản
                </button>
            <% } else if ("DRAFT".equalsIgnoreCase(course != null ? course.getStatus() : "")) { %>
                <span class="badge bg-secondary-subtle text-secondary border border-secondary px-3 py-2 rounded-pill">
                    <i class="bi bi-info-circle me-1"></i>Khóa học đang ở trạng thái Bản nháp (Giảng viên chưa gửi duyệt)
                </span>
            <% } else if ("PUBLISHED".equalsIgnoreCase(course != null ? course.getStatus() : "")) { %>
                <span class="badge bg-success-subtle text-success border border-success px-3 py-2 rounded-pill">
                    <i class="bi bi-check-circle me-1"></i>Khóa học đã xuất bản hoạt động
                </span>
            <% } %>
        </div>
    </div>

    <% if (course != null) { %>
    <div class="row g-4">
        <!-- Left: Course Overview & Curriculum -->
        <div class="col-12 col-lg-8">
            <!-- Course Card Overview -->
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 mb-4 shadow-sm">
                <div class="row g-4">
                    <div class="col-12 col-md-5">
                        <img src="<%= thumb %>" alt="Thumbnail" class="img-fluid rounded-3 border border-secondary border-opacity-25 w-100 object-fit-cover shadow-sm"
                             onerror="this.src='https://placehold.co/400x250/212529/ced4da?text=Course'">
                    </div>
                    <div class="col-12 col-md-7">
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill mb-2">
                            <%= course.getCategoryName() != null ? course.getCategoryName() : "Danh mục" %>
                        </span>
                        <h4 class="fw-bold text-white mb-2"><%= course.getTitle() %></h4>
                        <p class="text-secondary small mb-3"><%= course.getHeadline() != null ? course.getHeadline() : "" %></p>

                        <div class="row g-2 small text-secondary">
                            <div class="col-6">
                                <i class="bi bi-bar-chart me-1"></i>Cấp độ: <strong class="text-white"><%= course.getLevel() != null ? course.getLevel() : "Mọi cấp độ" %></strong>
                            </div>
                            <div class="col-6">
                                <i class="bi bi-cash-stack me-1"></i>Học phí: 
                                <strong class="text-success font-monospace">
                                    <% if ("FREE".equalsIgnoreCase(course.getPricingType()) || (course.getSalePriceVnd() != null && course.getSalePriceVnd().doubleValue() == 0)) { %>
                                        Miễn phí
                                    <% } else { %>
                                        <%= currency.format(course.getSalePriceVnd() != null ? course.getSalePriceVnd() : course.getListPriceVnd()) %> đ
                                    <% } %>
                                </strong>
                            </div>
                        </div>
                    </div>
                </div>

                <% if (course.getDescription() != null && !course.getDescription().isBlank()) { %>
                    <hr class="border-secondary border-opacity-25 my-4">
                    <h6 class="fw-bold text-white mb-2">Mô tả chi tiết nội dung:</h6>
                    <div class="text-secondary small" style="white-space: pre-line;">
                        <%= course.getDescription() %>
                    </div>
                <% } %>
            </div>

            <!-- Curriculum Outline -->
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 shadow-sm">
                <h5 class="fw-bold text-white mb-3">
                    <i class="bi bi-journal-text text-primary me-2"></i>Giáo trình khóa học (<%= chapters != null ? chapters.size() : 0 %> chương)
                </h5>

                <% if (chapters == null || chapters.isEmpty()) { %>
                    <div class="alert alert-warning border-0 rounded-3 mb-0 small">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i>Khóa học này chưa có chương mục bài học nào. Cần lưu ý trước khi phê duyệt!
                    </div>
                <% } else { %>
                    <div class="accordion accordion-flush" id="curriculumAccordion">
                        <% for (int i = 0; i < chapters.size(); i++) {
                            Chapter ch = chapters.get(i);
                            List<Lesson> lessons = ch.getLessons();
                        %>
                            <div class="accordion-item bg-transparent border-bottom border-secondary border-opacity-25">
                                <h2 class="accordion-header" id="heading<%= ch.getChapterId() %>">
                                    <button class="accordion-button <%= i > 0 ? "collapsed" : "" %> bg-transparent text-white px-0"
                                            type="button" data-bs-toggle="collapse" data-bs-target="#collapse<%= ch.getChapterId() %>">
                                        <span class="fw-semibold me-2">Chương <%= ch.getSortOrder() %>: <%= ch.getTitle() %></span>
                                        <span class="badge bg-secondary-subtle text-secondary small rounded-pill ms-auto me-3">
                                            <%= lessons != null ? lessons.size() : 0 %> bài học
                                        </span>
                                    </button>
                                </h2>
                                <div id="collapse<%= ch.getChapterId() %>" class="accordion-collapse collapse <%= i == 0 ? "show" : "" %>"
                                     data-bs-parent="#curriculumAccordion">
                                    <div class="accordion-body px-0 pt-2 pb-3">
                                        <% if (lessons == null || lessons.isEmpty()) { %>
                                            <span class="text-secondary small fst-italic">Chương này chưa có bài học.</span>
                                        <% } else { %>
                                            <div class="list-group list-group-flush rounded-3 border border-secondary border-opacity-25">
                                                <% for (Lesson l : lessons) { %>
                                                    <div class="list-group-item bg-dark-subtle text-white d-flex align-items-center justify-content-between py-2 border-secondary border-opacity-25">
                                                        <div class="d-flex align-items-center gap-2">
                                                            <i class="bi bi-play-circle text-primary"></i>
                                                            <span class="small fw-medium"><%= l.getTitle() %></span>
                                                            <% if (l.isPreview()) { %>
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill small" style="font-size: 0.7rem;">Học thử</span>
                                                            <% } %>
                                                        </div>
                                                        <div class="small text-secondary font-monospace">
                                                            <%= l.getDurationSeconds() / 60 %> phút
                                                        </div>
                                                    </div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Right: Instructor Profile & Approval History -->
        <div class="col-12 col-lg-4">
            <!-- Instructor Info Card -->
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 mb-4 shadow-sm">
                <h6 class="fw-bold text-secondary text-uppercase small mb-3">Thông tin Giảng viên</h6>
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-5" style="width: 48px; height: 48px;">
                        <%= (course.getInstructorName() != null && !course.getInstructorName().isBlank()) ? course.getInstructorName().substring(0, 1).toUpperCase() : "U" %>
                    </div>
                    <div>
                        <div class="fw-bold text-white"><%= course.getInstructorName() %></div>
                        <div class="small text-secondary">User ID: #<%= course.getInstructorId() %></div>
                    </div>
                </div>
            </div>

            <!-- Approval Timeline History -->
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 shadow-sm">
                <h6 class="fw-bold text-white mb-3">
                    <i class="bi bi-clock-history text-secondary me-2"></i>Lịch sử kiểm duyệt
                </h6>

                <% if (history == null || history.isEmpty()) { %>
                    <p class="text-secondary small mb-0 fst-italic">Chưa có bản ghi duyệt nào trước đây.</p>
                <% } else { %>
                    <ul class="list-unstyled mb-0 position-relative">
                        <% for (CourseApprovalEvent evt : history) {
                            String badgeColor = "bg-secondary";
                            if ("APPROVE".equalsIgnoreCase(evt.getAction())) badgeColor = "bg-success";
                            else if ("REJECT".equalsIgnoreCase(evt.getAction())) badgeColor = "bg-danger";
                            else if ("SUBMIT".equalsIgnoreCase(evt.getAction())) badgeColor = "bg-warning text-dark";
                        %>
                            <li class="mb-3 pb-3 border-bottom border-secondary border-opacity-25">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="badge <%= badgeColor %> rounded-pill small"><%= evt.getAction() %></span>
                                    <span class="small text-secondary"><%= evt.getCreatedAt() != null ? evt.getCreatedAt().format(dtf) : "" %></span>
                                </div>
                                <div class="small text-white">Thực hiện bởi: <strong><%= evt.getActorName() != null ? evt.getActorName() : ("ID #" + evt.getActorId()) %></strong></div>
                                <div class="small text-secondary mt-1">
                                    <%= evt.getFromStatus() %> <i class="bi bi-arrow-right"></i> <%= evt.getToStatus() %>
                                </div>
                                <% if (evt.getNote() != null && !evt.getNote().isBlank()) { %>
                                    <div class="alert alert-secondary bg-opacity-25 border-0 rounded-3 p-2 mt-2 mb-0 small text-white">
                                        "<%= evt.getNote() %>"
                                    </div>
                                <% } %>
                            </li>
                        <% } %>
                    </ul>
                <% } %>
            </div>
        </div>
    </div>
    <% } %>
</main>

<!-- Modal Approve -->
<div class="modal fade" id="approveModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/admin/course/approve" method="POST">
                <input type="hidden" name="courseId" value="<%= course != null ? course.getCourseId() : "" %>">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold text-success">
                        <i class="bi bi-check-circle-fill me-2"></i>Xác nhận Phê duyệt Khóa học
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <p class="text-secondary small mb-3">
                        Bạn đang chuẩn bị duyệt xuất bản khóa học <strong class="text-white">"<%= course != null ? course.getTitle() : "" %>"</strong>. 
                        Sau khi duyệt, khóa học sẽ ngay lập tức chuyển sang trạng thái <strong class="text-success">PUBLISHED</strong> và học viên toàn hệ thống có thể đăng ký / mua học.
                    </p>

                    <div class="mb-2">
                        <label class="form-label text-secondary small fw-medium">Ghi chú phê duyệt (Tùy chọn)</label>
                        <textarea name="note" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" rows="2"
                                  placeholder="Nhập lời chúc mừng hoặc ghi chú lưu vết nội bộ..."></textarea>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-success rounded-pill px-4 fw-semibold">
                        <i class="bi bi-check2-circle me-1"></i>Xác nhận Xuất bản
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Reject -->
<div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/admin/course/reject" method="POST">
                <input type="hidden" name="courseId" value="<%= course != null ? course.getCourseId() : "" %>">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold text-danger">
                        <i class="bi bi-x-circle-fill me-2"></i>Từ chối Phê duyệt Khóa học
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <p class="text-secondary small mb-3">
                        Khóa học sẽ được chuyển ngược về trạng thái <strong class="text-warning">DRAFT</strong> để Giảng viên bổ sung hoặc chỉnh sửa theo yêu cầu.
                    </p>

                    <div class="mb-2">
                        <label class="form-label text-secondary small fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                        <textarea name="reason" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" rows="3"
                                  placeholder="Nêu rõ nội dung chưa đạt: video mờ, thiếu bài tập, vi phạm bản quyền hoặc tiêu đề chưa phù hợp..." required></textarea>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 fw-semibold">
                        <i class="bi bi-x-circle me-1"></i>Xác nhận Từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
