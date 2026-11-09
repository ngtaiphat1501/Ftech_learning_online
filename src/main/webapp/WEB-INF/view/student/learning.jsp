<%-- 
    Document   : learning
    Created on : Oct 18, 2026, 7:23:13 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.LearningLesson"%>
<%@page import="model.QuizInfo"%>

<%!
    private String escape(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();

    long courseId = (Long) request.getAttribute("courseId");
    String courseTitle = (String) request.getAttribute("courseTitle");

    List<LearningLesson> lessons
            = (List<LearningLesson>) request.getAttribute("lessons");

    List<QuizInfo> quizzes
            = (List<QuizInfo>) request.getAttribute("quizzes");

    LearningLesson selectedLesson
            = (LearningLesson) request.getAttribute("selectedLesson");

    LearningLesson previousLesson
            = (LearningLesson) request.getAttribute("previousLesson");

    LearningLesson nextLesson
            = (LearningLesson) request.getAttribute("nextLesson");

    String videoUrl = selectedLesson == null
            ? null : util.VideoUtil.toEmbedUrl(selectedLesson.getVideoUrl());

    boolean youtubeVideo = videoUrl != null
            && util.VideoUtil.isYouTube(videoUrl);

    boolean isEnrolled = Boolean.TRUE.equals(request.getAttribute("isEnrolled"));
    boolean isAdminViewer = Boolean.TRUE.equals(request.getAttribute("isAdminViewer"));
    boolean isInstructorViewer = Boolean.TRUE.equals(request.getAttribute("isInstructorViewer"));
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>



<main class="container-fluid px-3 px-lg-5 py-4">

    <div class="mb-4">
        <a href="<%= contextPath %>/student/courses"
           class="text-decoration-none">
            <i class="bi bi-arrow-left me-2"></i>
            Khóa học của tôi
        </a>

        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mt-3">
            <h1 class="h3 fw-bold mb-0">
                <%= escape(courseTitle) %>
            </h1>
            <a href="<%= contextPath %>/student/certificate?courseId=<%= request.getParameter("courseId") %>"
               class="btn btn-warning btn-sm rounded-pill px-3 py-1.5 fw-bold text-dark shadow-sm d-inline-flex align-items-center gap-1.5">
                <i class="bi bi-award-fill fs-6 text-dark"></i>
                <span>Xem chứng chỉ khóa học</span>
            </a>
        </div>
    </div>

    <% if (selectedLesson == null) { %>

    <div class="alert alert-info">
        Khóa học chưa có bài học.
    </div>

    <% } else { %>

    <div class="row g-4">

        <div class="col-lg-8 col-xl-9">

            <div class="card rounded-4 overflow-hidden mb-4">

                <% if (youtubeVideo) { %>

                <div class="ratio ratio-16x9 bg-black">
                    <iframe id="lessonVideoIframe"
                            src="<%= escape(videoUrl) %>?enablejsapi=1&start=<%= selectedLesson.getLastPositionSeconds() %>"
                            title="<%= escape(selectedLesson.getTitle()) %>"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                    </iframe>
                </div>

                <% } else if (videoUrl != null && !videoUrl.isBlank()) { %>

                <div class="ratio ratio-16x9 bg-black">
                    <video id="html5VideoPlayer" controls class="w-100 h-100">
                        <source src="<%= escape(videoUrl) %>">
                        Trình duyệt không hỗ trợ xem video trực tiếp.
                    </video>
                </div>

                <% } else { %>

                <div class="bg-body-tertiary text-center p-5">
                    <i class="bi bi-journal-text display-2 text-primary"></i>

                    <p class="text-body-secondary mt-3 mb-0">
                        Bài học dạng văn bản
                    </p>
                </div>

                <% } %>

                <div class="card-body p-4">

                    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-3">

                        <h2 class="h4 fw-bold mb-0">
                            <%= escape(selectedLesson.getTitle()) %>
                        </h2>

                        <% if (selectedLesson.isCompleted()) { %>

                        <span class="badge text-bg-success">
                            <i class="bi bi-check-circle me-1"></i>
                            Đã hoàn thành
                        </span>

                        <% } else { %>

                        <span class="badge text-bg-secondary">
                            Chưa hoàn thành
                        </span>

                        <% } %>

                    </div>

                    <p class="small text-body-secondary mb-0">
                        <%= escape(selectedLesson.getChapterTitle()) %>
                    </p>

                </div>
            </div>

            <div class="card rounded-4 mb-4">
                <div class="card-body p-4">

                    <h3 class="h5 fw-bold mb-3">
                        <i class="bi bi-file-text me-2"></i>
                        Nội dung bài học
                    </h3>

                    <% if (selectedLesson.getContent() == null
                            || selectedLesson.getContent().isBlank()) { %>

                    <p class="text-body-secondary mb-0">
                        Chưa có nội dung bổ sung cho bài học này.
                    </p>

                    <% } else { %>

                    <div style="white-space: pre-wrap; overflow-wrap: anywhere;"><%= escape(selectedLesson.getContent()) %></div>

                    <% } %>

                </div>
            </div>

            <% if ("1".equals(request.getParameter("saved"))) { %>

            <div class="alert alert-success">
                <i class="bi bi-check-circle me-2"></i>
                Đã lưu tiến độ học tập.
            </div>

            <% } %>

            <% if (!isEnrolled) { %>
            <div class="alert alert-warning border-0 rounded-4 d-flex align-items-center gap-3 mb-4 shadow-sm" style="background: rgba(234, 179, 8, 0.12); border: 1px solid rgba(234, 179, 8, 0.25) !important;">
                <i class="bi bi-shield-lock-fill fs-2 text-warning"></i>
                <div>
                    <div class="fw-bold fs-6">Chế độ xem trước dành cho <%= isAdminViewer ? "Quản trị viên (Admin)" : (isInstructorViewer ? "Giảng viên" : "Người quản lý") %></div>
                    <div class="small opacity-75">Bạn đang theo dõi bài học ở chế độ đặc quyền. Chức năng ghi nhận hoàn thành và lưu tiến độ chỉ áp dụng cho tài khoản Học viên đã đăng ký khóa học.</div>
                </div>
            </div>
            <% } %>

            <div class="card rounded-4 mb-4">
                <div class="card-body p-4">

                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
                        <h3 class="h5 fw-bold mb-0">
                            <i class="bi bi-bookmark-check me-2"></i>Tiến độ bài học
                        </h3>
                        <span id="autoSaveIndicator" class="badge bg-secondary-subtle text-secondary small fw-normal">
                            <i class="bi bi-clock me-1"></i> Tự động đồng bộ video
                        </span>
                    </div>

                    <form id="progressForm" action="<%= contextPath %>/student/progress" method="post">

                        <input type="hidden" name="courseId" value="<%= courseId %>">
                        <input type="hidden" name="lessonId" value="<%= selectedLesson.getId() %>">
                        <input type="hidden" name="csrfToken" value="<%= escape((String) session.getAttribute("csrfToken")) %>">

                        <div class="row g-3 align-items-end mb-2">
                            <div class="col-sm-5">
                                <label for="position" class="form-label small text-secondary">
                                    Giây video hiện tại:
                                    <span id="currentTimeFormatted" class="fw-semibold text-primary ms-1"></span>
                                </label>
                                <input type="number"
                                       id="position"
                                       name="position"
                                       class="form-control"
                                       min="0"
                                       max="2147483647"
                                       step="1"
                                       value="<%= selectedLesson.getLastPositionSeconds() %>"
                                       required>
                            </div>

                            <div class="col-sm-7 d-flex align-items-center flex-wrap gap-2">
                                <button type="button"
                                        id="btnSavePosition"
                                        class="btn btn-outline-primary">
                                    <i class="bi bi-bookmark me-1"></i>
                                    Lưu vị trí hiện tại
                                </button>
                                <span id="saveStatusToast" class="small text-success fw-medium" style="display:none;">
                                    <i class="bi bi-check-circle-fill me-1"></i> Đã lưu!
                                </span>
                            </div>
                        </div>

                        <div class="form-text mb-4 text-secondary">
                            <i class="bi bi-lightning-charge-fill text-warning me-1"></i> Hệ thống tự động bắt đúng giây bạn đang xem trên video. Bạn có thể bấm <strong>Lưu vị trí hiện tại</strong> hoặc hệ thống sẽ tự động lưu khi bạn dừng video.
                        </div>

                        <% if (selectedLesson.isCompleted()) { %>
                        <button type="button" class="btn btn-success" disabled>
                            <i class="bi bi-check-circle me-2"></i> Bài học đã hoàn thành
                        </button>
                        <% } else { %>
                        <button type="submit"
                                name="action"
                                value="complete"
                                class="btn btn-success"
                                id="btnCompleteLesson">
                            <i class="bi bi-check-circle me-2"></i> Đánh dấu hoàn thành
                        </button>
                        <% } %>

                    </form>
                </div>
            </div>

            <%@page import="model.DiscussionPost"%>
<%
    long discussionLessonId=request.getAttribute("lessonId") instanceof Number
            ? ((Number)request.getAttribute("lessonId")).longValue() : selectedLesson.getId();
    long discussionUserId=((Number)session.getAttribute("userId")).longValue();
    String discussionCsrf=escape((String)session.getAttribute("csrfToken"));
    String discussionReturn=Boolean.TRUE.equals(request.getAttribute("standaloneDiscussion"))?"discussion":"learn";
    List<DiscussionPost> discussionPosts=(List<DiscussionPost>)request.getAttribute("discussionPosts");
%>
<style>
    .discussion-toggle[aria-expanded="true"] .show-replies {display:none;}
    .discussion-toggle[aria-expanded="false"] .hide-replies {display:none;}
</style>
<section class="card rounded-4 mb-4" id="lesson-discussion">
<div class="card-body p-3 p-md-4">
    <h3 class="h5 fw-bold mb-2">Bình luận bài học</h3>
    <p class="small text-body-secondary mb-4">Đặt câu hỏi và trao đổi cùng giảng viên, các bạn học.</p>
    <% if("1".equals(request.getParameter("discussionSaved")) || "1".equals(request.getParameter("saved"))) { %>
    <div class="alert alert-success">Đã cập nhật bình luận.</div>
    <% } %>
    <% if(discussionPosts==null) { %>
    <div class="alert alert-info">Chưa tải được bình luận.</div>
    <% } else { %>
    <form method="post" action="<%= contextPath %>/discussion?action=create" class="mb-4">
<input type="hidden" name="returnTo" value="<%= discussionReturn %>">
<input type="hidden" name="lessonId" value="<%= discussionLessonId %>">
<input type="hidden" name="csrfToken" value="<%= discussionCsrf %>">
        <label for="discussion-body" class="visually-hidden">Bình luận của bạn</label>
        <textarea id="discussion-body" name="body" rows="2" class="form-control border-0 border-bottom rounded-0 shadow-none" maxlength="4000" required placeholder="Viết bình luận của bạn…"></textarea>
        <div class="text-end mt-2"><button type="submit" class="btn btn-primary rounded-pill px-4">Bình luận</button></div>
    </form>
    <% if(discussionPosts.isEmpty()) { %>
    <p class="text-body-secondary">Chưa có bình luận. Hãy bắt đầu cuộc trao đổi.</p>
    <% } %>
    <% for(DiscussionPost rootPost:discussionPosts) { %>
    <article class="mb-4">
        <% { DiscussionPost comment=rootPost; %>
        <div class="d-flex gap-3" id="post-<%= comment.getId() %>">
    <div class="rounded-circle bg-primary-subtle text-primary-emphasis d-flex align-items-center justify-content-center flex-shrink-0" style="width:38px;height:38px;"><i class="bi bi-person-fill"></i></div>
    <div class="flex-grow-1" style="min-width:0;">
        <div class="d-flex flex-wrap align-items-center gap-2">
            <strong class="small"><%= escape(comment.getAuthorName()) %></strong>
            <% if(comment.isInstructor()) { %><span class="badge text-bg-primary">Giảng viên</span><% } %>
            <span class="small text-body-secondary"><%= escape(comment.getCreatedAt()) %> (VN)</span>
        </div>
        <% if(comment.isDeleted() || comment.isHidden()) { %>
        <p class="text-body-secondary fst-italic my-2"><%= comment.isDeleted()?"Bình luận đã được xóa.":"Bình luận đã bị ẩn." %></p>
        <% } else { %>
        <% if(comment.getParentId()!=0) { %>
        <span class="small text-primary">Trả lời <%= escape(comment.getReplyToName()) %></span>
        <% } %>
        <div class="my-2" style="white-space:pre-wrap;overflow-wrap:anywhere;"><%= escape(comment.getBody()) %></div>
        <div class="d-flex gap-2 align-items-center">
            <button type="button" class="btn btn-sm btn-link text-decoration-none px-0" data-bs-toggle="collapse" data-bs-target="#reply-form-<%= comment.getId() %>" aria-expanded="false" aria-controls="reply-form-<%= comment.getId() %>">Trả lời</button>
            <% if(comment.getAuthorId()==discussionUserId) { %>
            <form method="post" action="<%= contextPath %>/discussion?action=delete" onsubmit="return confirm('Xóa bình luận này?');">
<input type="hidden" name="returnTo" value="<%= discussionReturn %>">
<input type="hidden" name="lessonId" value="<%= discussionLessonId %>">
<input type="hidden" name="csrfToken" value="<%= discussionCsrf %>">
<input type="hidden" name="postId" value="<%= comment.getId() %>">
                <button type="submit" class="btn btn-sm btn-link text-danger text-decoration-none">Xóa</button>
            </form>
            <% } %>
        </div>
        <div class="collapse mt-2" id="reply-form-<%= comment.getId() %>">
            <form method="post" action="<%= contextPath %>/discussion?action=create">
<input type="hidden" name="returnTo" value="<%= discussionReturn %>">
<input type="hidden" name="lessonId" value="<%= discussionLessonId %>">
<input type="hidden" name="csrfToken" value="<%= discussionCsrf %>">
<input type="hidden" name="parentPostId" value="<%= comment.getId() %>">
                <label for="reply-body-<%= comment.getId() %>" class="visually-hidden">Nội dung trả lời</label>
                <textarea id="reply-body-<%= comment.getId() %>" name="body" class="form-control mb-2" rows="2" maxlength="4000" required placeholder="Viết câu trả lời…"></textarea>
                <div class="d-flex justify-content-end gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-toggle="collapse" data-bs-target="#reply-form-<%= comment.getId() %>">Hủy</button>
                    <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Trả lời</button>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</div>

        <% } %>
        <% if(!rootPost.getReplies().isEmpty()) { %>
        <div class="ms-4 ps-3">
            <button type="button" class="discussion-toggle btn btn-sm btn-link text-decoration-none mt-2" data-bs-toggle="collapse" data-bs-target="#thread-<%= rootPost.getId() %>" aria-expanded="false" aria-controls="thread-<%= rootPost.getId() %>">
                <span class="show-replies"><i class="bi bi-chevron-down me-2"></i>Xem <%= rootPost.getReplies().size() %> phản hồi</span>
                <span class="hide-replies"><i class="bi bi-chevron-up me-2"></i>Ẩn phản hồi</span>
            </button>
            <div class="collapse" id="thread-<%= rootPost.getId() %>">
                <% for(DiscussionPost comment:rootPost.getReplies()) { %>
                <div class="mt-3">
                <div class="d-flex gap-3" id="post-<%= comment.getId() %>">
    <div class="rounded-circle bg-primary-subtle text-primary-emphasis d-flex align-items-center justify-content-center flex-shrink-0" style="width:38px;height:38px;"><i class="bi bi-person-fill"></i></div>
    <div class="flex-grow-1" style="min-width:0;">
        <div class="d-flex flex-wrap align-items-center gap-2">
            <strong class="small"><%= escape(comment.getAuthorName()) %></strong>
            <% if(comment.isInstructor()) { %><span class="badge text-bg-primary">Giảng viên</span><% } %>
            <span class="small text-body-secondary"><%= escape(comment.getCreatedAt()) %> (VN)</span>
        </div>
        <% if(comment.isDeleted() || comment.isHidden()) { %>
        <p class="text-body-secondary fst-italic my-2"><%= comment.isDeleted()?"Bình luận đã được xóa.":"Bình luận đã bị ẩn." %></p>
        <% } else { %>
        <% if(comment.getParentId()!=0) { %>
        <span class="small text-primary">Trả lời <%= escape(comment.getReplyToName()) %></span>
        <% } %>
        <div class="my-2" style="white-space:pre-wrap;overflow-wrap:anywhere;"><%= escape(comment.getBody()) %></div>
        <div class="d-flex gap-2 align-items-center">
            <button type="button" class="btn btn-sm btn-link text-decoration-none px-0" data-bs-toggle="collapse" data-bs-target="#reply-form-<%= comment.getId() %>" aria-expanded="false" aria-controls="reply-form-<%= comment.getId() %>">Trả lời</button>
            <% if(comment.getAuthorId()==discussionUserId) { %>
            <form method="post" action="<%= contextPath %>/discussion?action=delete" onsubmit="return confirm('Xóa bình luận này?');">
<input type="hidden" name="returnTo" value="<%= discussionReturn %>">
<input type="hidden" name="lessonId" value="<%= discussionLessonId %>">
<input type="hidden" name="csrfToken" value="<%= discussionCsrf %>">
<input type="hidden" name="postId" value="<%= comment.getId() %>">
                <button type="submit" class="btn btn-sm btn-link text-danger text-decoration-none">Xóa</button>
            </form>
            <% } %>
        </div>
        <div class="collapse mt-2" id="reply-form-<%= comment.getId() %>">
            <form method="post" action="<%= contextPath %>/discussion?action=create">
<input type="hidden" name="returnTo" value="<%= discussionReturn %>">
<input type="hidden" name="lessonId" value="<%= discussionLessonId %>">
<input type="hidden" name="csrfToken" value="<%= discussionCsrf %>">
<input type="hidden" name="parentPostId" value="<%= comment.getId() %>">
                <label for="reply-body-<%= comment.getId() %>" class="visually-hidden">Nội dung trả lời</label>
                <textarea id="reply-body-<%= comment.getId() %>" name="body" class="form-control mb-2" rows="2" maxlength="4000" required placeholder="Viết câu trả lời…"></textarea>
                <div class="d-flex justify-content-end gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-toggle="collapse" data-bs-target="#reply-form-<%= comment.getId() %>">Hủy</button>
                    <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Trả lời</button>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</div>

                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </article>
    <% } %>
    <% } %>
</div>
</section>


            <div class="d-flex justify-content-between gap-3 mb-4">

                <% if (previousLesson != null) { %>

                <a href="<%= contextPath %>/student/learn?courseId=<%= courseId %>&amp;lessonId=<%= previousLesson.getId() %>"
                   class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>
                    Bài trước
                </a>

                <% } else { %>

                <button type="button"
                        class="btn btn-outline-secondary"
                        disabled>
                    Bài trước
                </button>

                <% } %>

                <% if (nextLesson != null) { %>

                <a href="<%= contextPath %>/student/learn?courseId=<%= courseId %>&amp;lessonId=<%= nextLesson.getId() %>"
                   class="btn btn-primary">
                    Bài tiếp theo
                    <i class="bi bi-arrow-right ms-2"></i>
                </a>

                <% } else { %>

                <button type="button"
                        class="btn btn-outline-secondary"
                        disabled>
                    Bài cuối cùng
                </button>

                <% } %>

            </div>

        </div>

        <div class="col-lg-4 col-xl-3">

            <div class="card rounded-4 overflow-hidden">

                <div class="card-header bg-body-tertiary p-3">
                    <h2 class="h5 fw-bold mb-1">
                        Nội dung khóa học
                    </h2>

                    <span class="small text-body-secondary">
                        <%= lessons.size() %> bài học
                    </span>
                </div>

                <div class="list-group list-group-flush">

                    <%
                        long currentChapterId = -1;

                        for (LearningLesson lesson : lessons) {
                            if (lesson.getChapterId() != currentChapterId) {
                                currentChapterId = lesson.getChapterId();
                    %>

                    <div class="list-group-item bg-body-tertiary fw-semibold py-3">
                        <i class="bi bi-folder2-open me-2"></i>
                        <%= escape(lesson.getChapterTitle()) %>
                    </div>

                    <% } %>

                    <a href="<%= contextPath %>/student/learn?courseId=<%= courseId %>&amp;lessonId=<%= lesson.getId() %>"
                       class="list-group-item list-group-item-action d-flex gap-2 py-3 <%= lesson.getId() == selectedLesson.getId() ? "active" : "" %>">

                        <i class="bi <%= lesson.isCompleted() ? "bi-check-circle-fill" : "bi-play-circle" %>"></i>

                        <span>
                            <%= escape(lesson.getTitle()) %>
                        </span>
                    </a>

                    <% } %>

                    <div class="list-group-item bg-body-tertiary fw-semibold py-3">
                        <i class="bi bi-pencil-square me-2"></i>Bài kiểm tra
                    </div>
                    <% if (quizzes != null && !quizzes.isEmpty()) { %>
                    <% for (QuizInfo quiz : quizzes) { %>
                    <% if (isEnrolled) { %>
                    <a class="list-group-item list-group-item-action py-3"
                       href="<%= contextPath %>/student/quiz?quizId=<%= quiz.getQuizId() %>">
                        <div class="d-flex gap-2 align-items-start">
                            <i class="bi <%= quiz.isPassed() ? "bi-check-circle-fill text-success" : quiz.getActiveAttemptId() != 0 || quiz.isLessonsCompleted() ? "bi-pencil-square" : "bi-lock" %>"></i>
                            <div>
                                <div class="fw-semibold"><%= escape(quiz.getTitle()) %></div>
                                <div class="small text-body-secondary mt-1">
                                    <% if (quiz.getActiveAttemptId() != 0) { %>
                                    <%= quiz.isActiveExpired() ? "Xem kết quả lượt hết giờ" : "Tiếp tục làm bài" %>
                                    <% } else if (quiz.isPassed()) { %>
                                    Đã đạt bài kiểm tra
                                    <% } else if (!quiz.isLessonsCompleted()) { %>
                                    Hoàn thành bài bắt buộc: <%= quiz.getCompletedRequiredLessons() %>/<%= quiz.getTotalRequiredLessons() %>
                                    <% } else if (quiz.getQuestionCount() == 0) { %>
                                    Đề chưa có câu hỏi
                                    <% } else if (quiz.getUsedAttempts() >= quiz.getMaxAttempts()) { %>
                                    Đã hết lượt làm bài
                                    <% } else { %>
                                    Đủ điều kiện — Xem thông tin kiểm tra
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </a>
                    <% } else if (isInstructorViewer) { %>
                    <a class="list-group-item list-group-item-action py-3 d-flex justify-content-between align-items-center"
                       href="<%= contextPath %>/instructor/quiz?courseId=<%= courseId %>">
                        <div class="d-flex gap-2 align-items-center">
                            <i class="bi bi-pencil-square text-primary"></i>
                            <span class="fw-semibold"><%= escape(quiz.getTitle()) %></span>
                        </div>
                        <span class="badge bg-primary-subtle text-primary small">Quản lý đề</span>
                    </a>
                    <% } else { %>
                    <div class="list-group-item py-3 d-flex justify-content-between align-items-center">
                        <div class="d-flex gap-2 align-items-center">
                            <i class="bi bi-pencil-square text-secondary"></i>
                            <span class="fw-semibold"><%= escape(quiz.getTitle()) %></span>
                        </div>
                        <span class="badge bg-secondary-subtle text-secondary small">Xem trước</span>
                    </div>
                    <% } %>
                    <% } %>
                    <% } else { %>
                    <div class="list-group-item text-body-secondary py-3">Khóa học chưa có bài kiểm tra.</div>
                    <% } %>


                </div>
                    
            </div>

        </div>

    </div>

    <% } %>

</main>

<% if (selectedLesson != null) { %>
<script src="https://www.youtube.com/iframe_api"></script>
<script>
(function() {
    let ytPlayer = null;
    let isPlaying = false;
    let lastSavedSecond = <%= selectedLesson.getLastPositionSeconds() %>;

    window.onYouTubeIframeAPIReady = function() {
        const iframe = document.getElementById('lessonVideoIframe');
        if (iframe && window.YT) {
            ytPlayer = new YT.Player('lessonVideoIframe', {
                events: {
                    'onStateChange': onPlayerStateChange
                }
            });
        }
    };

    function onPlayerStateChange(event) {
        if (!window.YT) return;
        if (event.data === YT.PlayerState.PLAYING) {
            isPlaying = true;
        } else if (event.data === YT.PlayerState.PAUSED || event.data === YT.PlayerState.ENDED) {
            isPlaying = false;
            // Auto save when user pauses or finishes video
            autoSaveProgress();
        }
    }

    function getCurrentVideoSeconds() {
        if (ytPlayer && typeof ytPlayer.getCurrentTime === 'function') {
            try {
                const t = Math.floor(ytPlayer.getCurrentTime());
                if (!isNaN(t) && t >= 0) return t;
            } catch(e) {}
        }
        const html5 = document.getElementById('html5VideoPlayer');
        if (html5 && !isNaN(html5.currentTime)) {
            return Math.floor(html5.currentTime);
        }
        const posInput = document.getElementById('position');
        if (posInput && posInput.value) {
            return parseInt(posInput.value, 10) || 0;
        }
        return 0;
    }

    function formatTime(totalSec) {
        const m = Math.floor(totalSec / 60);
        const s = totalSec % 60;
        return (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
    }

    // Auto-update position input box and formatted time every 1s
    setInterval(function() {
        const sec = getCurrentVideoSeconds();
        const posInput = document.getElementById('position');
        const formatted = document.getElementById('currentTimeFormatted');
        if (posInput && document.activeElement !== posInput) {
            posInput.value = sec;
        }
        if (formatted) {
            formatted.textContent = '(' + formatTime(sec) + ')';
        }
    }, 1000);

    // Auto-save periodically every 25 seconds while watching
    setInterval(function() {
        if (isPlaying) {
            const sec = getCurrentVideoSeconds();
            if (Math.abs(sec - lastSavedSecond) >= 10) {
                autoSaveProgress();
            }
        }
    }, 25000);

    function autoSaveProgress(callback) {
        const isEnrolled = <%= isEnrolled ? "true" : "false" %>;
        if (!isEnrolled) {
            if (callback) callback();
            return;
        }
        const sec = getCurrentVideoSeconds();
        const posInput = document.getElementById('position');
        if (posInput) posInput.value = sec;

        const courseId = '<%= courseId %>';
        const lessonId = '<%= selectedLesson.getId() %>';
        const csrfToken = '<%= escape((String) session.getAttribute("csrfToken")) %>';

        const params = new URLSearchParams();
        params.append('courseId', courseId);
        params.append('lessonId', lessonId);
        params.append('position', sec);
        params.append('action', 'save');
        params.append('csrfToken', csrfToken);

        fetch('<%= contextPath %>/student/progress', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params.toString()
        }).then(function(res) {
            if (res.ok) {
                lastSavedSecond = sec;
                const toast = document.getElementById('saveStatusToast');
                if (toast) {
                    toast.style.display = 'inline';
                    toast.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i> Đã lưu ' + formatTime(sec);
                    setTimeout(function() { toast.style.display = 'none'; }, 3000);
                }
                const indicator = document.getElementById('autoSaveIndicator');
                if (indicator) {
                    indicator.className = 'badge bg-success-subtle text-success small fw-normal';
                    indicator.innerHTML = '<i class="bi bi-cloud-check me-1"></i> Đã lưu: ' + formatTime(sec);
                }
            }
            if (callback) callback();
        }).catch(function(err) {
            if (callback) callback();
        });
    }

    function showAppAlertModal(title, message, type) {
        const modalEl = document.getElementById('appAlertModal');
        if (!modalEl) {
            alert(message.replace(/<[^>]+>/g, ''));
            return;
        }
        const titleEl = document.getElementById('appAlertModalTitle');
        const bodyEl = document.getElementById('appAlertModalBody');
        const iconEl = document.getElementById('appAlertModalIcon');

        if (titleEl) titleEl.innerText = title;
        if (bodyEl) bodyEl.innerHTML = message;
        if (iconEl) {
            if (type === 'warning') iconEl.className = 'bi bi-exclamation-triangle-fill text-warning fs-3';
            else if (type === 'danger') iconEl.className = 'bi bi-x-circle-fill text-danger fs-3';
            else if (type === 'info') iconEl.className = 'bi bi-info-circle-fill text-info fs-3';
            else iconEl.className = 'bi bi-check-circle-fill text-success fs-3';
        }

        if (window.bootstrap && bootstrap.Modal) {
            const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        }
    }

    function showAppToast(title, message, type) {
        const toastEl = document.getElementById('appToast');
        if (!toastEl) return;
        const bodyEl = document.getElementById('appToastBody');
        if (bodyEl) {
            let iconHtml = '<i class="bi bi-check-circle-fill text-success fs-5"></i>';
            if (type === 'danger') iconHtml = '<i class="bi bi-x-circle-fill text-danger fs-5"></i>';
            else if (type === 'warning') iconHtml = '<i class="bi bi-exclamation-triangle-fill text-warning fs-5"></i>';
            bodyEl.innerHTML = iconHtml + ' <span>' + message + '</span>';
        }
        if (window.bootstrap && bootstrap.Toast) {
            const toast = bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 3500 });
            toast.show();
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const isEnrolled = <%= isEnrolled ? "true" : "false" %>;

        // Check if redirected with ?error=...
        const urlParams = new URLSearchParams(window.location.search);
        const errorParam = urlParams.get('error');
        if (errorParam) {
            showAppAlertModal('Thông báo', decodeURIComponent(errorParam), 'warning');
            const cleanUrl = window.location.pathname + '?' + window.location.search.replace(/([&?]error=[^&]*)/, '').replace(/^&/, '');
            window.history.replaceState({}, document.title, cleanUrl);
        }

        const btnSave = document.getElementById('btnSavePosition');
        if (btnSave) {
            btnSave.addEventListener('click', function(e) {
                e.preventDefault();
                if (!isEnrolled) {
                    showAppAlertModal('Thông báo quyền hạn', 'Bạn đang xem bài học với tư cách <strong><%= isAdminViewer ? "Quản trị viên (Admin)" : (isInstructorViewer ? "Giảng viên" : "Người quản lý") %></strong>.<br><br>Tính năng lưu vị trí video chỉ áp dụng cho <strong>Học viên đã đăng ký khóa học</strong>.', 'info');
                    return;
                }
                btnSave.disabled = true;
                btnSave.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang lưu...';
                autoSaveProgress(function() {
                    btnSave.disabled = false;
                    btnSave.innerHTML = '<i class="bi bi-bookmark me-1"></i> Lưu vị trí hiện tại';
                });
            });
        }

        const progressForm = document.getElementById('progressForm');
        if (progressForm) {
            progressForm.addEventListener('submit', function(e) {
                e.preventDefault();

                if (!isEnrolled) {
                    showAppAlertModal('Thông báo quyền hạn', 'Bạn đang xem bài học với tư cách <strong><%= isAdminViewer ? "Quản trị viên (Admin)" : (isInstructorViewer ? "Giảng viên" : "Người quản lý") %></strong>.<br><br>Tính năng <em>Đánh dấu hoàn thành</em> chỉ áp dụng cho <strong>Học viên đã ghi danh khóa học</strong>.', 'warning');
                    return;
                }

                const completeBtn = document.getElementById('btnCompleteLesson');
                if (completeBtn) {
                    completeBtn.disabled = true;
                    completeBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang cập nhật...';
                }

                const sec = getCurrentVideoSeconds();
                const posInput = document.getElementById('position');
                if (posInput) posInput.value = sec;

                const courseId = '<%= courseId %>';
                const lessonId = '<%= selectedLesson.getId() %>';
                const csrfToken = '<%= escape((String) session.getAttribute("csrfToken")) %>';

                const params = new URLSearchParams();
                params.append('courseId', courseId);
                params.append('lessonId', lessonId);
                params.append('position', sec);
                params.append('action', 'complete');
                params.append('csrfToken', csrfToken);

                fetch('<%= contextPath %>/student/progress', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-Requested-With': 'XMLHttpRequest',
                        'Accept': 'application/json'
                    },
                    body: params.toString()
                })
                .then(async function(res) {
                    let data = {};
                    try {
                        data = await res.json();
                    } catch(err) {}

                    if (res.ok && data.success !== false) {
                        if (completeBtn) {
                            completeBtn.className = 'btn btn-success';
                            completeBtn.disabled = true;
                            completeBtn.innerHTML = '<i class="bi bi-check-circle me-2"></i> Bài học đã hoàn thành';
                        }
                        showAppToast('Thành công', 'Đã đánh dấu hoàn thành bài học!', 'success');
                    } else {
                        if (completeBtn) {
                            completeBtn.disabled = false;
                            completeBtn.innerHTML = '<i class="bi bi-check-circle me-2"></i> Đánh dấu hoàn thành';
                        }
                        const msg = (data && data.message) ? data.message : 'Bạn không có quyền cập nhật tiến độ bài này (Tiến độ chỉ áp dụng cho học viên đã ghi danh).';
                        showAppAlertModal('Thông báo lỗi', msg, 'warning');
                    }
                })
                .catch(function(err) {
                    if (completeBtn) {
                        completeBtn.disabled = false;
                        completeBtn.innerHTML = '<i class="bi bi-check-circle me-2"></i> Đánh dấu hoàn thành';
                    }
                    showAppAlertModal('Lỗi kết nối', 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.', 'danger');
                });
            });
        }
    });

    window.addEventListener('beforeunload', function() {
        const isEnrolled = <%= isEnrolled ? "true" : "false" %>;
        if (!isEnrolled) return;
        const sec = getCurrentVideoSeconds();
        const courseId = '<%= courseId %>';
        const lessonId = '<%= selectedLesson.getId() %>';
        const csrfToken = '<%= escape((String) session.getAttribute("csrfToken")) %>';
        const params = new URLSearchParams();
        params.append('courseId', courseId);
        params.append('lessonId', lessonId);
        params.append('position', sec);
        params.append('action', 'save');
        params.append('csrfToken', csrfToken);
        if (navigator.sendBeacon) {
            const blob = new Blob([params.toString()], { type: 'application/x-www-form-urlencoded' });
            navigator.sendBeacon('<%= contextPath %>/student/progress', blob);
        }
    });
})();
</script>
<% } %>

<!-- Popup Modal Thong Bao Loi / Quyen Han (Khong nhay trang) -->
<div class="modal fade" id="appAlertModal" tabindex="-1" aria-labelledby="appAlertModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow-lg rounded-4" style="background: var(--ftech-card-bg, var(--bs-card-bg)); color: var(--bs-body-color); border: 1px solid var(--ftech-card-border, var(--bs-border-color)) !important;">
      <div class="modal-header border-bottom border-secondary border-opacity-25 pb-3">
        <h5 class="modal-title d-flex align-items-center gap-2" id="appAlertModalLabel">
          <i id="appAlertModalIcon" class="bi bi-exclamation-triangle-fill text-warning fs-3"></i>
          <span id="appAlertModalTitle" class="fw-bold">Thông báo</span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body py-4" id="appAlertModalBody" style="line-height: 1.6; font-size: 0.95rem;">
      </div>
      <div class="modal-footer border-top border-secondary border-opacity-25 pt-3">
        <button type="button" class="btn btn-primary rounded-pill px-4" data-bs-dismiss="modal">Đã hiểu</button>
      </div>
    </div>
  </div>
</div>

<!-- Floating Toast Notification -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100;">
  <div id="appToast" class="toast align-items-center bg-body-tertiary text-body border rounded-3 shadow" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body d-flex align-items-center gap-2" id="appToastBody">
        <i class="bi bi-check-circle-fill text-success fs-5"></i>
        <span>Thành công!</span>
      </div>
      <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
