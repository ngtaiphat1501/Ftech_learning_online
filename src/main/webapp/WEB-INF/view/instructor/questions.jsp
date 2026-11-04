<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Course"%>
<%@page import="model.QuizInfo"%>
<%@page import="model.QuizQuestion"%>
<%@page import="model.QuizOption"%>

<%
    Course course = (Course) request.getAttribute("course");
    QuizInfo quiz = (QuizInfo) request.getAttribute("quiz");
    List<QuizQuestion> questions = (List<QuizQuestion>) request.getAttribute("questions");

    int qCount = questions != null ? questions.size() : 0;
    boolean locked = quiz != null && quiz.getAttemptCount() > 0;
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

    <% if (locked) { %>
        <div class="alert alert-warning border-0 rounded-4 p-3 mb-4 shadow-sm">
            <i class="bi bi-shield-lock-fill me-2 fs-5 align-middle"></i>
            <strong>Đề thi này đã có <%= quiz.getAttemptCount() %> lượt thi thực tế từ học viên.</strong> 
            Để đảm bảo tính công bằng và toàn vẹn của kết quả thi, thao tác thêm/sửa/xóa câu hỏi đã được tự động khóa.
        </div>
    <% } %>

    <!-- Header bar -->
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <a href="${pageContext.request.contextPath}/instructor/quiz?courseId=<%= quiz != null ? quiz.getCourseId() : "" %>" class="btn btn-sm btn-outline-secondary rounded-pill mb-2">
                <i class="bi bi-arrow-left me-1"></i>Về danh sách đề thi
            </a>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-list-check text-primary me-2"></i>Ngân Hàng Câu Hỏi & Đáp Án
            </h1>
            <p class="text-secondary small mb-0">
                Đề thi: <strong class="text-white"><%= quiz != null ? quiz.getTitle() : "Quiz" %></strong> 
                (Thời gian: <%= quiz != null ? quiz.getDurationMinutes() : 0 %> phút, <%= qCount %> câu hỏi)
            </p>
        </div>

        <div>
            <button type="button" class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#createQuestionModal"
                    <%= locked ? "disabled" : "" %>>
                <i class="bi bi-plus-lg me-1"></i>Thêm Câu Hỏi Mới
            </button>
        </div>
    </div>

    <!-- Questions List -->
    <% if (questions == null || questions.isEmpty()) { %>
        <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-5 text-center shadow-sm">
            <i class="bi bi-chat-square-dots fs-1 opacity-50 text-secondary d-block mb-3"></i>
            <h5 class="text-white fw-bold">Chưa có câu hỏi nào trong đề thi này</h5>
            <p class="text-secondary small mb-4">Hãy bấm "Thêm Câu Hỏi Mới" để bắt đầu soạn các câu hỏi trắc nghiệm và phương án trả lời.</p>
            <div>
                <button type="button" class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#createQuestionModal"
                        <%= locked ? "disabled" : "" %>>
                    <i class="bi bi-plus-lg me-1"></i>Tạo câu hỏi đầu tiên
                </button>
            </div>
        </div>
    <% } else {
        char[] letters = new char[]{'A', 'B', 'C', 'D', 'E', 'F'};
        for (int i = 0; i < questions.size(); i++) {
            QuizQuestion qn = questions.get(i);
            List<QuizOption> options = qn.getOptions();
    %>
        <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 mb-3 shadow-sm">
            <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1.5 fw-bold">
                        Câu <%= i + 1 %>
                    </span>
                    <span class="badge bg-secondary-subtle text-secondary rounded-pill small">
                        <%= qn.getPoints() %> điểm
                    </span>
                </div>

                <div class="d-flex gap-1">
                    <button type="button" class="btn btn-sm btn-outline-warning rounded-pill px-2.5"
                            <%= locked ? "disabled title='Đã có lượt thi'" : "title='Sửa câu hỏi'" %>
                            onclick="openEditQuestionModal(<%= qn.getId() %>, '<%= qn.getContent().replace("'", "\\'").replace("\n", " ") %>', '<%= qn.getExplanation() != null ? qn.getExplanation().replace("'", "\\'").replace("\n", " ") : "" %>', <%= qn.getPoints() %>, <%= qn.getSortOrder() %>)">
                        <i class="bi bi-pencil me-1"></i>Sửa
                    </button>

                    <form action="${pageContext.request.contextPath}/instructor/question" method="POST" class="d-inline"
                          onsubmit="return confirm('Bạn có chắc chắn muốn xóa câu hỏi này?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="quizId" value="<%= quiz.getQuizId() %>">
                        <input type="hidden" name="questionId" value="<%= qn.getId() %>">
                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2.5"
                                <%= locked ? "disabled" : "" %>>
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Question content -->
            <h5 class="fw-semibold text-white mb-3"><%= qn.getContent() %></h5>

            <!-- Options list -->
            <div class="row g-2 mb-3">
                <% if (options != null) {
                    for (int j = 0; j < options.size(); j++) {
                        QuizOption opt = options.get(j);
                        char prefix = j < letters.length ? letters[j] : (char)('A' + j);
                        String borderClass = opt.isCorrect() ? "border-success border-2 bg-success-subtle bg-opacity-25" : "border-secondary border-opacity-25 bg-body-tertiary";
                %>
                    <div class="col-12 col-md-6">
                        <div class="p-2.5 rounded-3 border <%= borderClass %> d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center gap-2 text-white small">
                                <span class="badge <%= opt.isCorrect() ? "bg-success text-white" : "bg-dark text-secondary border border-secondary border-opacity-25" %> fw-bold">
                                    <%= prefix %>
                                </span>
                                <span><%= opt.getContent() %></span>
                            </div>
                            <% if (opt.isCorrect()) { %>
                                <span class="badge bg-success rounded-pill small ms-2">
                                    <i class="bi bi-check2"></i> Đáp án đúng
                                </span>
                            <% } %>
                        </div>
                    </div>
                <% }
                } %>
            </div>

            <!-- Explanation -->
            <% if (qn.getExplanation() != null && !qn.getExplanation().isBlank()) { %>
                <div class="alert alert-secondary bg-opacity-25 border-0 rounded-3 p-2.5 mb-0 small text-secondary">
                    <i class="bi bi-lightbulb-fill text-warning me-1"></i>
                    <strong class="text-white">Giải thích đáp án:</strong> <%= qn.getExplanation() %>
                </div>
            <% } %>
        </div>
    <% }
    } %>
</main>

<!-- Create Question Modal -->
<div class="modal fade" id="createQuestionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/instructor/question" method="POST">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="quizId" value="<%= quiz != null ? quiz.getQuizId() : "" %>">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold">
                        <i class="bi bi-plus-circle text-primary me-2"></i>Thêm Câu Hỏi Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Nội dung câu hỏi <span class="text-danger">*</span></label>
                        <textarea name="content" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                  rows="3" placeholder="Nhập câu hỏi trắc nghiệm tại đây..." required></textarea>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Điểm số</label>
                            <input type="number" step="0.5" name="points" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="1.0" min="0.5" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thứ tự hiển thị</label>
                            <input type="number" name="sortOrder" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace"
                                   value="<%= qCount + 1 %>" min="1">
                        </div>
                    </div>

                    <h6 class="fw-bold text-white mb-2">Các phương án trả lời & Chọn đáp án đúng:</h6>
                    <p class="text-secondary small mb-3">Tích chọn nút tròn bên cạnh đáp án đúng duy nhất của câu hỏi.</p>

                    <div class="d-flex flex-column gap-3 mb-3">
                        <!-- Option A -->
                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" value="0" checked title="Chọn làm đáp án đúng">
                                <span class="ms-2 fw-bold text-secondary">A</span>
                            </div>
                            <input type="text" name="options" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                   placeholder="Nhập nội dung đáp án A..." required>
                        </div>

                        <!-- Option B -->
                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" value="1" title="Chọn làm đáp án đúng">
                                <span class="ms-2 fw-bold text-secondary">B</span>
                            </div>
                            <input type="text" name="options" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                   placeholder="Nhập nội dung đáp án B..." required>
                        </div>

                        <!-- Option C -->
                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" value="2" title="Chọn làm đáp án đúng">
                                <span class="ms-2 fw-bold text-secondary">C</span>
                            </div>
                            <input type="text" name="options" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                   placeholder="Nhập nội dung đáp án C (Tùy chọn)...">
                        </div>

                        <!-- Option D -->
                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" value="3" title="Chọn làm đáp án đúng">
                                <span class="ms-2 fw-bold text-secondary">D</span>
                            </div>
                            <input type="text" name="options" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                   placeholder="Nhập nội dung đáp án D (Tùy chọn)...">
                        </div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label text-secondary small fw-medium">Giải thích đáp án (Hiển thị khi học viên xem lại kết quả)</label>
                        <textarea name="explanation" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                  rows="2" placeholder="Nêu lý do vì sao đáp án này là chính xác..."></textarea>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">Lưu Câu Hỏi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Question Modal -->
<div class="modal fade" id="editQuestionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow">
            <form action="${pageContext.request.contextPath}/instructor/question" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="quizId" value="<%= quiz != null ? quiz.getQuizId() : "" %>">
                <input type="hidden" name="questionId" id="editQuestionId">

                <div class="modal-header border-secondary border-opacity-25">
                    <h5 class="modal-title fw-bold text-warning">
                        <i class="bi bi-pencil-square me-2"></i>Chỉnh Sửa Câu Hỏi & Đáp Án
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Nội dung câu hỏi <span class="text-danger">*</span></label>
                        <textarea name="content" id="editContent" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white"
                                  rows="3" required></textarea>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Điểm số</label>
                            <input type="number" step="0.5" name="points" id="editPoints" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small fw-medium">Thứ tự hiển thị</label>
                            <input type="number" name="sortOrder" id="editSortOrder" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace">
                        </div>
                    </div>

                    <h6 class="fw-bold text-white mb-2">Cập nhật 4 phương án trả lời:</h6>
                    <div class="d-flex flex-column gap-3 mb-3">
                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" id="editRadio0" value="0">
                                <span class="ms-2 fw-bold text-secondary">A</span>
                            </div>
                            <input type="text" name="options" id="editOption0" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" required>
                        </div>

                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" id="editRadio1" value="1">
                                <span class="ms-2 fw-bold text-secondary">B</span>
                            </div>
                            <input type="text" name="options" id="editOption1" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" required>
                        </div>

                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" id="editRadio2" value="2">
                                <span class="ms-2 fw-bold text-secondary">C</span>
                            </div>
                            <input type="text" name="options" id="editOption2" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white">
                        </div>

                        <div class="input-group">
                            <div class="input-group-text bg-body-tertiary border-secondary border-opacity-25">
                                <input class="form-check-input mt-0" type="radio" name="correctOptionIndex" id="editRadio3" value="3">
                                <span class="ms-2 fw-bold text-secondary">D</span>
                            </div>
                            <input type="text" name="options" id="editOption3" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white">
                        </div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label text-secondary small fw-medium">Giải thích đáp án</label>
                        <textarea name="explanation" id="editExplanation" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white" rows="2"></textarea>
                    </div>
                </div>

                <div class="modal-footer border-secondary border-opacity-25">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning rounded-pill px-4 fw-medium">Cập Nhật Câu Hỏi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openEditQuestionModal(id, content, explanation, points, sortOrder) {
    document.getElementById('editQuestionId').value = id;
    document.getElementById('editContent').value = content;
    document.getElementById('editExplanation').value = explanation || '';
    document.getElementById('editPoints').value = points;
    document.getElementById('editSortOrder').value = sortOrder;

    var modal = new bootstrap.Modal(document.getElementById('editQuestionModal'));
    modal.show();
}
</script>

<%@include file="/WEB-INF/view/layout/PublicFooter.jsp" %>
