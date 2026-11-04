<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Course"%>
<%@page import="model.QuizInfo"%>

<%
    Course course = (Course) request.getAttribute("course");
    List<QuizInfo> quizzes = (List<QuizInfo>) request.getAttribute("quizzes");
    int quizCount = quizzes != null ? quizzes.size() : 0;
    String msg = request.getParameter("msg");
    String err = request.getParameter("error");
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
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

    <!-- Header bar -->
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-sm btn-outline-secondary rounded-pill mb-2">
                <i class="bi bi-arrow-left me-1"></i>Về danh sách khóa học
            </a>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-patch-question text-primary me-2"></i>Quản lý Đề kiểm tra (Quiz)
            </h1>
            <p class="text-secondary small mb-0">
                Khóa học: <strong class="text-white"><%= course != null ? course.getTitle() : "Khóa học" %></strong> 
                (Tổng cộng <%= quizCount %> đề thi)
            </p>
        </div>

        <div>
            <button type="button" class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#createQuizModal">
                <i class="bi bi-plus-lg me-1"></i>Tạo Đề Thi Mới
            </button>
        </div>
    </div>

    <!-- Quizzes Table -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="table-responsive">
            <table class="table table-dark table-hover align-middle mb-0">
                <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                    <tr>
                        <th class="ps-4">Thứ tự & Tên đề thi</th>
                        <th class="text-center">Thời gian</th>
                        <th class="text-center">Điểm đạt</th>
                        <th class="text-center">Lượt thi tối đa</th>
                        <th class="text-center">Số câu hỏi</th>
                        <th class="text-center">Đã thi</th>
                        <th class="text-end pe-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (quizzes == null || quizzes.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center py-5 text-secondary">
                                <i class="bi bi-journal-x fs-1 opacity-50 d-block mb-2"></i>
                                Khóa học này chưa có đề kiểm tra trắc nghiệm nào. Hãy tạo đề thi đầu tiên!
                            </td>
                        </tr>
                    <% } else {
                        for (QuizInfo q : quizzes) {
                            boolean locked = q.getAttemptCount() > 0;
                    %>
                        <tr>
                            <td class="ps-4">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge bg-secondary-subtle text-light rounded-pill">#<%= q.getSortOrder() %></span>
                                    <div>
                                        <div class="fw-semibold text-white"><%= q.getTitle() %></div>
                                        <div class="small text-secondary text-truncate" style="max-width: 300px;">
                                            <%= q.getDescription() != null ? q.getDescription() : "Không có mô tả" %>
                                        </div>
                                    </div>
                                    <% if (q.isRequired()) { %>
                                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill small" style="font-size: 0.7rem;">Bắt buộc</span>
                                    <% } %>
                                </div>
                            </td>
                            <td class="text-center font-monospace">
                                <%= q.getDurationMinutes() %> phút
                            </td>
                            <td class="text-center font-monospace text-success fw-bold">
                                <%= q.getPassingScore() %>%
                            </td>
                            <td class="text-center font-monospace">
                                <%= q.getMaxAttempts() %> lần
                            </td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/instructor/question?quizId=<%= q.getQuizId() %>"
                                   class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2.5 py-1 text-decoration-none">
                                    <i class="bi bi-question-circle me-1"></i><%= q.getQuestionCount() %> câu
                                </a>
                            </td>
                            <td class="text-center">
                                <% if (locked) { %>
                                    <span class="badge bg-info-subtle text-info border border-info-subtle rounded-pill">
                                        <i class="bi bi-people-fill me-1"></i><%= q.getAttemptCount() %> lượt thi
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-secondary-subtle text-secondary rounded-pill">Chưa có</span>
                                <% } %>
                            </td>
                            <td class="text-end pe-4">
                                <div class="d-inline-flex gap-1">
                                    <!-- Questions button -->
                                    <a href="${pageContext.request.contextPath}/instructor/question?quizId=<%= q.getQuizId() %>"
                                       class="btn btn-sm btn-outline-primary rounded-pill px-2.5" title="Quản lý câu hỏi">
                                        <i class="bi bi-list-check me-1"></i>Câu hỏi
                                    </a>

                                    <!-- Edit button -->
                                    <button type="button" class="btn btn-sm btn-outline-warning rounded-pill px-2"
                                            <%= locked ? "disabled title='Đã có học viên thi, bị khóa sửa'" : "title='Sửa thông tin đề'" %>
                                            onclick="openEditQuizModal(<%= q.getQuizId() %>, '<%= q.getTitle().replace("'", "\\'") %>', '<%= q.getDescription() != null ? q.getDescription().replace("'", "\\'") : "" %>', <%= q.getDurationMinutes() %>, <%= q.getMaxAttempts() %>, <%= q.getPassingScore() %>, <%= q.isRequired() %>, <%= q.getSortOrder() %>)">
                                        <i class="bi bi-pencil"></i>
                                    </button>

                                    <!-- Delete form -->
                                    <form action="${pageContext.request.contextPath}/instructor/quiz" method="POST" class="d-inline"
                                          onsubmit="return confirm('Bạn có chắc chắn muốn xóa vĩnh viễn đề kiểm tra này và toàn bộ câu hỏi liên quan?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="courseId" value="<%= course != null ? course.getCourseId() : "" %>">
                                        <input type="hidden" name="quizId" value="<%= q.getQuizId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2"
                                                <%= locked ? "disabled title='Đã có học viên thi, không thể xóa'" : "title='Xóa đề thi'" %>>
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
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

<!-- Create Quiz Modal -->
<div class="modal fade" id="createQuizModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/instructor/quiz" method="POST">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="courseId" value="<%= course != null ? course.getCourseId() : "" %>">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold">
                        <i class="bi bi-plus-circle text-primary me-2"></i>Tạo Đề Kiểm Tra Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Tiêu đề đề thi <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                               placeholder="VD: Kiểm tra cuối khóa, Trắc nghiệm kiến thức..." required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Mô tả hướng dẫn</label>
                        <textarea name="description" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                  rows="2" placeholder="Hướng dẫn thí sinh chuẩn bị..."></textarea>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thời gian (Phút) <span class="text-danger">*</span></label>
                            <input type="number" name="durationMinutes" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="20" min="1" max="300" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Lượt thi tối đa <span class="text-danger">*</span></label>
                            <input type="number" name="maxAttempts" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="3" min="1" max="50" required>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Điểm đạt (%) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" name="passingScore" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="70.00" min="0" max="100" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thứ tự hiển thị</label>
                            <input type="number" name="sortOrder" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="<%= quizCount + 1 %>" min="1">
                        </div>
                    </div>

                    <div class="form-check form-switch mt-2">
                        <input class="form-check-input" type="checkbox" name="isRequired" id="createIsRequired" checked>
                        <label class="form-check-label text-white small" for="createIsRequired">
                            Bắt buộc phải đạt để hoàn thành khóa học (Certificate Requirement)
                        </label>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">Tạo Đề Thi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Quiz Modal -->
<div class="modal fade" id="editQuizModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/instructor/quiz" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="courseId" value="<%= course != null ? course.getCourseId() : "" %>">
                <input type="hidden" name="quizId" id="editQuizId">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold text-warning">
                        <i class="bi bi-pencil-square me-2"></i>Chỉnh Sửa Đề Kiểm Tra
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Tiêu đề đề thi <span class="text-danger">*</span></label>
                        <input type="text" name="title" id="editTitle" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Mô tả hướng dẫn</label>
                        <textarea name="description" id="editDescription" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" rows="2"></textarea>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thời gian (Phút) <span class="text-danger">*</span></label>
                            <input type="number" name="durationMinutes" id="editDuration" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Lượt thi tối đa <span class="text-danger">*</span></label>
                            <input type="number" name="maxAttempts" id="editMaxAttempts" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace" required>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Điểm đạt (%) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" name="passingScore" id="editPassingScore" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thứ tự hiển thị</label>
                            <input type="number" name="sortOrder" id="editSortOrder" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace">
                        </div>
                    </div>

                    <div class="form-check form-switch mt-2">
                        <input class="form-check-input" type="checkbox" name="isRequired" id="editIsRequired">
                        <label class="form-check-label text-white small" for="editIsRequired">
                            Bắt buộc phải đạt để hoàn thành khóa học
                        </label>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning rounded-pill px-4 fw-medium">Cập Nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openEditQuizModal(id, title, desc, duration, maxAttempts, passingScore, isReq, sortOrder) {
    document.getElementById('editQuizId').value = id;
    document.getElementById('editTitle').value = title;
    document.getElementById('editDescription').value = desc || '';
    document.getElementById('editDuration').value = duration;
    document.getElementById('editMaxAttempts').value = maxAttempts;
    document.getElementById('editPassingScore').value = passingScore;
    document.getElementById('editSortOrder').value = sortOrder;
    document.getElementById('editIsRequired').checked = (isReq === true || isReq === 'true');

    var modal = new bootstrap.Modal(document.getElementById('editQuizModal'));
    modal.show();
}
</script>

<%@include file="/WEB-INF/view/layout/PublicFooter.jsp" %>
