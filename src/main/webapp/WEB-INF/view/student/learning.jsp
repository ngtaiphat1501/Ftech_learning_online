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
            ? null : selectedLesson.getVideoUrl();

    boolean youtubeVideo = videoUrl != null
            && videoUrl.matches(
                    "^https://www\\.youtube\\.com/embed/[A-Za-z0-9_-]+$"
            );
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>



<main class="container-fluid px-3 px-lg-5 py-4">

    <div class="mb-4">
        <a href="<%= contextPath %>/student/courses"
           class="text-decoration-none">
            <i class="bi bi-arrow-left me-2"></i>
            Khóa học của tôi
        </a>

        <h1 class="h3 fw-bold mt-3 mb-0">
            <%= escape(courseTitle) %>
        </h1>
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
                    <iframe src="<%= escape(videoUrl) %>?start=<%= selectedLesson.getLastPositionSeconds() %>"
                            title="<%= escape(selectedLesson.getTitle()) %>"
                            allow="accelerometer; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                    </iframe>
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

            <div class="card rounded-4 mb-4">
                <div class="card-body p-4">

                    <h3 class="h5 fw-bold mb-3">
                        <i class="bi bi-bookmark-check me-2"></i>
                        Tiến độ bài học
                    </h3>

                    <form action="<%= contextPath %>/student/progress"
                          method="post">

                        <input type="hidden"
                               name="courseId"
                               value="<%= courseId %>">

                        <input type="hidden"
                               name="lessonId"
                               value="<%= selectedLesson.getId() %>">

                        <input type="hidden"
                               name="csrfToken"
                               value="<%= escape((String) session.getAttribute("csrfToken")) %>">

                        <label for="position" class="form-label">
                            Vị trí xem muốn lưu, tính bằng giây
                        </label>

                        <div class="row g-3 align-items-end">

                            <div class="col-sm-5">
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

                            <div class="col-sm-7">
                                <button type="submit"
                                        name="action"
                                        value="save"
                                        class="btn btn-outline-primary">
                                    <i class="bi bi-bookmark me-2"></i>
                                    Lưu vị trí
                                </button>
                            </div>

                        </div>

                        <div class="form-text mb-4">
                            Ví dụ: xem tới phút thứ 5 thì nhập 300.
                            Vị trí video chưa được lưu tự động.
                        </div>

                        <% if (selectedLesson.isCompleted()) { %>

                        <button type="button"
                                class="btn btn-success"
                                disabled>
                            <i class="bi bi-check-circle me-2"></i>
                            Bài học đã hoàn thành
                        </button>

                        <% } else { %>

                        <button type="submit"
                                name="action"
                                value="complete"
                                class="btn btn-success">
                            <i class="bi bi-check-circle me-2"></i>
                            Đánh dấu hoàn thành
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

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
