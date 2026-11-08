<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Category"%>

<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-tags text-primary me-2"></i>Quản lý Danh mục khóa học
            </h1>
            <p class="text-secondary small mb-0">
                Thêm mới, chỉnh sửa thông tin và xóa danh mục (ràng buộc không xóa danh mục đang có khóa học).
            </p>
        </div>

        <button type="button" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm d-flex align-items-center gap-2"
                data-bs-toggle="modal" data-bs-target="#createCategoryModal">
            <i class="bi bi-plus-circle"></i>
            <span>Thêm danh mục</span>
        </button>
    </div>

    <!-- Table of Categories -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead>
                    <tr class="text-secondary small border-bottom border-secondary border-opacity-25">
                        <th class="ps-4 py-3" style="width: 70px;">ID</th>
                        <th class="py-3">Tên danh mục</th>
                        <th class="py-3">Slug</th>
                        <th class="py-3">Icon</th>
                        <th class="py-3 text-center">Số khóa học</th>
                        <th class="py-3 text-center">Trạng thái</th>
                        <th class="pe-4 py-3 text-end" style="width: 180px;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (categories != null && !categories.isEmpty()) {
                        for (Category cat : categories) {
                    %>
                    <tr class="border-bottom border-secondary border-opacity-10">
                        <td class="ps-4 text-secondary small fw-medium">#<%= cat.getId() %></td>
                        <td>
                            <div class="fw-semibold text-white"><%= cat.getName() %></div>
                            <% if (cat.getDescription() != null && !cat.getDescription().isBlank()) { %>
                                <div class="text-secondary small text-truncate" style="max-width: 280px;"><%= cat.getDescription() %></div>
                            <% } %>
                        </td>
                        <td class="text-secondary font-monospace small"><%= cat.getSlug() != null ? cat.getSlug() : "-" %></td>
                        <td>
                            <span class="badge bg-body-tertiary text-light border border-secondary border-opacity-25 p-2 rounded-3">
                                <i class="bi <%= cat.getIconClass() %> me-1"></i><%= cat.getIconClass() %>
                            </span>
                        </td>
                        <td class="text-center">
                            <% if (cat.getCourseCount() > 0) { %>
                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2.5 py-1">
                                    <%= cat.getCourseCount() %> khóa
                                </span>
                            <% } else { %>
                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2.5 py-1">
                                    0 khóa
                                </span>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <% if (cat.isActive()) { %>
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2.5 py-1">Hoạt động</span>
                            <% } else { %>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2.5 py-1">Ẩn</span>
                            <% } %>
                        </td>
                        <td class="pe-4 text-end">
                            <div class="d-inline-flex gap-2">
                                <button type="button"
                                        class="btn btn-outline-primary btn-sm rounded-3 px-2.5"
                                        title="Chỉnh sửa"
                                        onclick="openEditCategoryModal(<%= cat.getId() %>, '<%= cat.getName().replace("'", "\\'") %>', '<%= cat.getSlug() != null ? cat.getSlug() : "" %>', '<%= cat.getIconClass() %>', '<%= cat.getDescription() != null ? cat.getDescription().replace("'", "\\'").replace("\n", " ") : "" %>', <%= cat.isActive() %>)">
                                    <i class="bi bi-pencil-square"></i> Sửa
                                </button>

                                <% if (cat.getCourseCount() > 0) { %>
                                    <button type="button"
                                            class="btn btn-outline-secondary btn-sm rounded-3 px-2.5 opacity-50"
                                            title="Không thể xóa vì đang có <%= cat.getCourseCount() %> khóa học tham chiếu"
                                            disabled>
                                        <i class="bi bi-trash3"></i> Xóa
                                    </button>
                                <% } else { %>
                                    <form action="${pageContext.request.contextPath}/admin/category" method="POST" class="d-inline"
                                          onsubmit="return confirm('Bạn có chắc chắn muốn xóa danh mục &quot;<%= cat.getName() %>&quot; không?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= cat.getId() %>">
                                        <button type="submit" class="btn btn-outline-danger btn-sm rounded-3 px-2.5" title="Xóa danh mục">
                                            <i class="bi bi-trash3"></i> Xóa
                                        </button>
                                    </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%  }
                       } else { %>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-secondary">Chưa có danh mục nào trong hệ thống.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- CREATE CATEGORY MODAL -->
<div class="modal fade" id="createCategoryModal" tabindex="-1" aria-labelledby="createModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark border border-secondary border-opacity-25 rounded-4 text-white shadow-lg">
            <form action="${pageContext.request.contextPath}/admin/category" method="POST">
                <input type="hidden" name="action" value="create">
                <div class="modal-header border-bottom border-secondary border-opacity-25 p-4">
                    <h5 class="modal-title fw-bold" id="createModalLabel">
                        <i class="bi bi-folder-plus text-primary me-2"></i>Thêm Danh mục mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 d-flex flex-column gap-3">
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Tên danh mục <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" placeholder="VD: Lập trình Java, Thiết kế Web..." required>
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Slug (đường dẫn)</label>
                        <input type="text" name="slug" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" placeholder="Tự động tạo nếu để trống">
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Bootstrap Icon Class</label>
                        <input type="text" name="iconClass" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" value="bi-code-square" placeholder="VD: bi-code-square, bi-database...">
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Mô tả ngắn</label>
                        <textarea name="description" rows="3" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" placeholder="Mô tả mục tiêu của danh mục..."></textarea>
                    </div>
                    <div class="form-check form-switch pt-1">
                        <input class="form-check-input" type="checkbox" role="switch" name="isActive" value="1" id="createActiveSwitch" checked>
                        <label class="form-check-label text-light small fw-medium" for="createActiveSwitch">Kích hoạt hiển thị cho học viên</label>
                    </div>
                </div>
                <div class="modal-footer border-top border-secondary border-opacity-25 p-3">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4 fw-semibold">Tạo danh mục</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- EDIT CATEGORY MODAL -->
<div class="modal fade" id="editCategoryModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark border border-secondary border-opacity-25 rounded-4 text-white shadow-lg">
            <form action="${pageContext.request.contextPath}/admin/category" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editCatId">
                <div class="modal-header border-bottom border-secondary border-opacity-25 p-4">
                    <h5 class="modal-title fw-bold" id="editModalLabel">
                        <i class="bi bi-pencil-square text-primary me-2"></i>Cập nhật Danh mục
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 d-flex flex-column gap-3">
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Tên danh mục <span class="text-danger">*</span></label>
                        <input type="text" name="name" id="editCatName" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" required>
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Slug</label>
                        <input type="text" name="slug" id="editCatSlug" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white">
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Bootstrap Icon Class</label>
                        <input type="text" name="iconClass" id="editCatIcon" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white">
                    </div>
                    <div>
                        <label class="form-label small fw-semibold text-secondary">Mô tả ngắn</label>
                        <textarea name="description" id="editCatDesc" rows="3" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"></textarea>
                    </div>
                    <div class="form-check form-switch pt-1">
                        <input class="form-check-input" type="checkbox" role="switch" name="isActive" value="1" id="editCatActive">
                        <label class="form-check-label text-light small fw-medium" for="editCatActive">Kích hoạt hiển thị cho học viên</label>
                    </div>
                </div>
                <div class="modal-footer border-top border-secondary border-opacity-25 p-3">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4 fw-semibold">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openEditCategoryModal(id, name, slug, icon, desc, isActive) {
        document.getElementById('editCatId').value = id;
        document.getElementById('editCatName').value = name;
        document.getElementById('editCatSlug').value = slug;
        document.getElementById('editCatIcon').value = icon;
        document.getElementById('editCatDesc').value = desc;
        document.getElementById('editCatActive').checked = Boolean(isActive);

        const modal = new bootstrap.Modal(document.getElementById('editCategoryModal'));
        modal.show();
    }
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
