<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.User"%>

<%
    User userProfile = (User) request.getAttribute("userProfile");
    Integer enrolledCount = (Integer) request.getAttribute("enrolledCount");
    Integer completedCount = (Integer) request.getAttribute("completedCount");

    if (enrolledCount == null) enrolledCount = 0;
    if (completedCount == null) completedCount = 0;

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);

    String msg = request.getParameter("msg");
    String err = request.getParameter("error");

    String avatar = (userProfile != null && userProfile.getAvatarUrl() != null && !userProfile.getAvatarUrl().isBlank())
            ? userProfile.getAvatarUrl()
            : null;
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container my-5" style="min-height: 65vh;">
    <!-- Alert notifications -->
    <% if (msg != null && !msg.isBlank()) { %>
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>
    <% if (err != null && !err.isBlank()) { %>
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= err %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <% if (userProfile != null) { %>
    <!-- Profile Banner & Summary Card -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 mb-4 shadow-sm">
        <div class="row align-items-center g-4">
            <div class="col-12 col-md-auto text-center">
                <% if (avatar != null) { %>
                    <img src="<%= avatar %>" alt="Avatar" class="rounded-circle border border-primary border-3 shadow object-fit-cover"
                         style="width: 100px; height: 100px;"
                         onerror="this.src='https://placehold.co/120x120/212529/ced4da?text=User'">
                <% } else { %>
                    <div class="avatar bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-1 mx-auto shadow"
                         style="width: 100px; height: 100px;">
                        <%= (userProfile.getFullName() != null && !userProfile.getFullName().isBlank()) ? userProfile.getFullName().substring(0, 1).toUpperCase() : "U" %>
                    </div>
                <% } %>
            </div>

            <div class="col-12 col-md">
                <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                    <h2 class="h4 fw-bold text-body mb-0"><%= userProfile.getFullName() %></h2>
                    <% if (userProfile.isAdmin()) { %>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill small">Quản trị viên</span>
                    <% } %>
                    <% if (userProfile.isInstructor()) { %>
                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill small">Giảng viên</span>
                    <% } %>
                    <% if (userProfile.isStudent()) { %>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill small">Học viên</span>
                    <% } %>
                </div>
                <div class="text-secondary small mb-2"><i class="bi bi-envelope me-1"></i><%= userProfile.getEmail() %></div>
                <div class="text-body-secondary small"><%= userProfile.getHeadline() != null ? userProfile.getHeadline() : "Thành viên nền tảng học tập Learnora" %></div>
            </div>

            <div class="col-12 col-md-auto text-md-end border-top border-md-top-0 border-secondary border-opacity-25 pt-3 pt-md-0">
                <div class="d-flex flex-row flex-md-column gap-3 justify-content-around">
                    <div>
                        <span class="text-secondary small d-block">Số dư ví</span>
                        <span class="fw-bold text-success font-monospace fs-5">
                            <%= currency.format(userProfile.getBalanceVnd()) %> đ
                        </span>
                    </div>
                    <div>
                        <span class="text-secondary small d-block">Khóa học ghi danh</span>
                        <span class="fw-bold text-body fs-5">
                            <i class="bi bi-journal-check text-primary me-1"></i><%= enrolledCount %> khóa
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="card bg-body-tertiary border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="card-header bg-body-secondary border-bottom border-secondary border-opacity-25 px-4 pt-3 pb-0">
            <ul class="nav nav-tabs card-header-tabs border-bottom-0" id="profileTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active bg-transparent text-body border-0 border-bottom border-primary border-3 fw-medium pb-3"
                            id="info-tab" data-bs-toggle="tab" data-bs-target="#info-pane" type="button" role="tab">
                        <i class="bi bi-person me-2"></i>Thông tin tài khoản
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link bg-transparent text-body-secondary border-0 fw-medium pb-3"
                            id="password-tab" data-bs-toggle="tab" data-bs-target="#password-pane" type="button" role="tab">
                        <i class="bi bi-shield-lock me-2"></i>Đổi mật khẩu
                    </button>
                </li>
            </ul>
        </div>

        <div class="card-body p-4">
            <div class="tab-content" id="profileTabContent">
                <!-- Tab 1: Update Profile Info -->
                <div class="tab-pane fade show active" id="info-pane" role="tabpanel">
                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="row g-3">
                        <input type="hidden" name="action" value="update_profile">

                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary small fw-medium">Email đăng nhập</label>
                            <input type="email" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-secondary"
                                   value="<%= userProfile.getEmail() %>" disabled>
                            <div class="form-text text-secondary small">Email đăng nhập dùng để xác thực và không thể chỉnh sửa.</div>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary small fw-medium">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   value="<%= userProfile.getFullName() != null ? userProfile.getFullName() : "" %>" required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Tiêu đề chuyên môn / Nghề nghiệp</label>
                            <input type="text" name="headline" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="VD: Sinh viên ngành Kỹ thuật phần mềm | Lập trình viên Java Fullstack"
                                   value="<%= userProfile.getHeadline() != null ? userProfile.getHeadline() : "" %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Đường dẫn ảnh đại diện (Avatar URL)</label>
                            <input type="url" name="avatarUrl" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="https://example.com/avatar.jpg"
                                   value="<%= userProfile.getAvatarUrl() != null ? userProfile.getAvatarUrl() : "" %>">
                            <div class="form-text text-secondary small">Nhập URL hình ảnh công khai (.jpg, .png) để cập nhật ảnh đại diện.</div>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Giới thiệu bản thân (Bio)</label>
                            <textarea name="bio" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                      rows="4" placeholder="Chia sẻ kinh nghiệm, sở thích hoặc định hướng học tập của bạn..."><%= userProfile.getBio() != null ? userProfile.getBio() : "" %></textarea>
                        </div>

                        <div class="col-12 text-end pt-3 border-top border-secondary border-opacity-25 mt-4">
                            <button type="submit" class="btn btn-primary rounded-pill px-4">
                                <i class="bi bi-save me-1"></i>Lưu Thay Đổi
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Tab 2: Change Password -->
                <div class="tab-pane fade" id="password-pane" role="tabpanel">
                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="row g-3" style="max-width: 600px;">
                        <input type="hidden" name="action" value="change_password">

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                            <input type="password" name="currentPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Nhập mật khẩu bạn đang sử dụng..." required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Mật khẩu mới <span class="text-danger">*</span></label>
                            <input type="password" name="newPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Tối thiểu 6 ký tự..." minlength="6" required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                            <input type="password" name="confirmPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Nhập lại mật khẩu mới..." minlength="6" required>
                        </div>

                        <div class="col-12 pt-3">
                            <button type="submit" class="btn btn-warning rounded-pill px-4 fw-medium">
                                <i class="bi bi-key me-1"></i>Cập Nhật Mật Khẩu
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</main>

<script>
document.querySelectorAll('#profileTab button').forEach(function(triggerEl) {
    triggerEl.addEventListener('click', function(event) {
        event.preventDefault();
        document.querySelectorAll('#profileTab button').forEach(function(btn) {
            btn.classList.remove('active', 'text-white', 'border-bottom', 'border-primary', 'border-3');
            btn.classList.add('text-secondary');
        });
        triggerEl.classList.add('active', 'text-white', 'border-bottom', 'border-primary', 'border-3');
        triggerEl.classList.remove('text-secondary');
    });
});
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
