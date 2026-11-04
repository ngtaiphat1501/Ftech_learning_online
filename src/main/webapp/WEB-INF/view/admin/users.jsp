<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.User"%>

<%
    List<User> users = (List<User>) request.getAttribute("users");
    String search = (String) request.getAttribute("search");
    String roleFilter = (String) request.getAttribute("roleFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-people text-primary me-2"></i>Quản lý Người dùng & Phân quyền
            </h1>
            <p class="text-secondary small mb-0">
                Tra cứu người dùng, phân bổ nhiều vai trò (Student, Instructor, Admin) và quản lý trạng thái tài khoản.
            </p>
        </div>
    </div>

    <!-- Search & Filter Bar -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 mb-4 shadow-sm">
        <form action="${pageContext.request.contextPath}/admin/users" method="GET" class="row g-3 align-items-center">
            <div class="col-12 col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-body-tertiary border-secondary border-opacity-25 text-secondary"><i class="bi bi-search"></i></span>
                    <input type="text" name="q" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                           placeholder="Tìm theo tên hoặc email..." value="<%= search != null ? search : "" %>">
                </div>
            </div>

            <div class="col-6 col-md-3">
                <select name="role" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white">
                    <option value="ALL" <%= roleFilter == null || "ALL".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>-- Tất cả vai trò --</option>
                    <option value="STUDENT" <%= "STUDENT".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>Học viên (Student)</option>
                    <option value="INSTRUCTOR" <%= "INSTRUCTOR".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>Giảng viên (Instructor)</option>
                    <option value="ADMIN" <%= "ADMIN".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>Quản trị viên (Admin)</option>
                </select>
            </div>

            <div class="col-6 col-md-2">
                <select name="status" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white">
                    <option value="ALL" <%= statusFilter == null || "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>-- Trạng thái --</option>
                    <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Hoạt động (Active)</option>
                    <option value="LOCKED" <%= "LOCKED".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Đã khóa (Locked)</option>
                </select>
            </div>

            <div class="col-12 col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary rounded-pill px-3 w-100 fw-semibold">
                    <i class="bi bi-funnel me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary rounded-pill px-3">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>

    <!-- Table of Users -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead>
                    <tr class="text-secondary small border-bottom border-secondary border-opacity-25">
                        <th class="ps-4 py-3" style="width: 70px;">ID</th>
                        <th class="py-3">Học viên / Người dùng</th>
                        <th class="py-3">Email</th>
                        <th class="py-3 text-end">Số dư ví</th>
                        <th class="py-3">Vai trò hệ thống</th>
                        <th class="py-3 text-center">Trạng thái</th>
                        <th class="pe-4 py-3 text-end" style="width: 220px;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (users != null && !users.isEmpty()) {
                        for (User u : users) {
                    %>
                    <tr class="border-bottom border-secondary border-opacity-10">
                        <td class="ps-4 text-secondary small fw-medium">#<%= u.getUserId() %></td>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <div class="rounded-circle bg-primary-subtle text-primary fw-bold d-flex align-items-center justify-content-center flex-shrink-0"
                                     style="width: 36px; height: 36px;">
                                    <%= u.getFullName() != null && !u.getFullName().isBlank() ? u.getFullName().substring(0, 1).toUpperCase() : "U" %>
                                </div>
                                <div>
                                    <div class="fw-semibold text-white"><%= u.getFullName() %></div>
                                    <% if (u.getHeadline() != null && !u.getHeadline().isBlank()) { %>
                                        <div class="text-secondary small text-truncate" style="max-width: 220px;"><%= u.getHeadline() %></div>
                                    <% } %>
                                </div>
                            </div>
                        </td>
                        <td class="text-secondary small"><%= u.getEmail() %></td>
                        <td class="text-end font-monospace text-light fw-medium">
                            <%= currency.format(u.getBalanceVnd()) %>đ
                        </td>
                        <td>
                            <div class="d-flex flex-wrap gap-1">
                                <% if (u.getRoles() != null && !u.getRoles().isEmpty()) {
                                    for (String r : u.getRoles()) {
                                        String badgeClass = "bg-primary-subtle text-primary border-primary-subtle";
                                        if ("ADMIN".equalsIgnoreCase(r)) badgeClass = "bg-danger-subtle text-danger border-danger-subtle";
                                        else if ("INSTRUCTOR".equalsIgnoreCase(r)) badgeClass = "bg-warning-subtle text-warning border-warning-subtle";
                                %>
                                    <span class="badge <%= badgeClass %> border rounded-pill px-2 py-1 small">
                                        <%= r %>
                                    </span>
                                <%  }
                                   } else { %>
                                    <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2 py-1 small">Chưa có vai trò</span>
                                <% } %>
                            </div>
                        </td>
                        <td class="text-center">
                            <% if ("ACTIVE".equalsIgnoreCase(u.getStatus())) { %>
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2.5 py-1">Hoạt động</span>
                            <% } else { %>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2.5 py-1">Đã khóa</span>
                            <% } %>
                        </td>
                        <td class="pe-4 text-end">
                            <div class="d-inline-flex gap-2">
                                <button type="button" class="btn btn-outline-primary btn-sm rounded-3 px-2.5"
                                        title="Phân quyền vai trò"
                                        onclick="openRoleModal(<%= u.getUserId() %>, '<%= u.getFullName().replace("'", "\\'") %>', '<%= String.join(",", u.getRoles() != null ? u.getRoles() : java.util.Collections.emptyList()) %>')">
                                    <i class="bi bi-shield-shaded"></i> Phân quyền
                                </button>

                                <form action="${pageContext.request.contextPath}/admin/user" method="POST" class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc muốn <%= "ACTIVE".equalsIgnoreCase(u.getStatus()) ? "KHÓA" : "MỞ KHÓA" %> tài khoản này?');">
                                    <input type="hidden" name="action" value="status">
                                    <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                    <input type="hidden" name="status" value="<%= "ACTIVE".equalsIgnoreCase(u.getStatus()) ? "LOCKED" : "ACTIVE" %>">
                                    <% if ("ACTIVE".equalsIgnoreCase(u.getStatus())) { %>
                                        <button type="submit" class="btn btn-outline-warning btn-sm rounded-3 px-2.5" title="Khóa tài khoản">
                                            <i class="bi bi-lock"></i>
                                        </button>
                                    <% } else { %>
                                        <button type="submit" class="btn btn-outline-success btn-sm rounded-3 px-2.5" title="Mở khóa tài khoản">
                                            <i class="bi bi-unlock"></i>
                                        </button>
                                    <% } %>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%  }
                       } else { %>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-secondary">Không tìm thấy người dùng phù hợp với điều kiện tìm kiếm.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- ASSIGN ROLES MODAL -->
<div class="modal fade" id="assignRoleModal" tabindex="-1" aria-labelledby="roleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark border border-secondary border-opacity-25 rounded-4 text-white shadow-lg">
            <form action="${pageContext.request.contextPath}/admin/user" method="POST">
                <input type="hidden" name="action" value="roles">
                <input type="hidden" name="userId" id="modalUserId">
                <div class="modal-header border-bottom border-secondary border-opacity-25 p-4">
                    <h5 class="modal-title fw-bold" id="roleModalLabel">
                        <i class="bi bi-shield-shaded text-primary me-2"></i>Phân quyền người dùng
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 d-flex flex-column gap-3">
                    <div class="p-3 rounded-3 bg-body-tertiary border border-secondary border-opacity-25">
                        <span class="text-secondary small d-block">Đang phân quyền cho:</span>
                        <strong class="text-white fs-6" id="modalUserName"></strong>
                    </div>

                    <div>
                        <label class="form-label small fw-semibold text-secondary mb-2">Chọn các vai trò kích hoạt:</label>
                        <div class="d-flex flex-column gap-2">
                            <div class="form-check p-2.5 rounded-3 border border-secondary border-opacity-25 bg-body-tertiary">
                                <input class="form-check-input ms-0 me-2" type="checkbox" name="roles" value="STUDENT" id="roleStudent">
                                <label class="form-check-label text-light fw-medium" for="roleStudent">
                                    <strong class="text-primary">STUDENT</strong> - Học viên (xem khóa học, mua hàng, học bài, làm trắc nghiệm)
                                </label>
                            </div>

                            <div class="form-check p-2.5 rounded-3 border border-secondary border-opacity-25 bg-body-tertiary">
                                <input class="form-check-input ms-0 me-2" type="checkbox" name="roles" value="INSTRUCTOR" id="roleInstructor">
                                <label class="form-check-label text-light fw-medium" for="roleInstructor">
                                    <strong class="text-warning">INSTRUCTOR</strong> - Giảng viên (tạo khóa học, soạn giáo án, quản lý bài giảng)
                                </label>
                            </div>

                            <div class="form-check p-2.5 rounded-3 border border-secondary border-opacity-25 bg-body-tertiary">
                                <input class="form-check-input ms-0 me-2" type="checkbox" name="roles" value="ADMIN" id="roleAdmin">
                                <label class="form-check-label text-light fw-medium" for="roleAdmin">
                                    <strong class="text-danger">ADMIN</strong> - Quản trị viên (quản lý danh mục, phân quyền, kiểm duyệt, đối soát)
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top border-secondary border-opacity-25 p-3">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4 fw-semibold">Lưu phân quyền</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openRoleModal(userId, fullName, rolesStr) {
        document.getElementById('modalUserId').value = userId;
        document.getElementById('modalUserName').textContent = fullName + ' (ID #' + userId + ')';

        const roles = rolesStr ? rolesStr.split(',') : [];
        document.getElementById('roleStudent').checked = roles.includes('STUDENT');
        document.getElementById('roleInstructor').checked = roles.includes('INSTRUCTOR');
        document.getElementById('roleAdmin').checked = roles.includes('ADMIN');

        const modal = new bootstrap.Modal(document.getElementById('assignRoleModal'));
        modal.show();
    }
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
