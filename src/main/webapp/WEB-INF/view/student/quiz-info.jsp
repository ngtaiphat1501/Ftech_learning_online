<%-- 
    Document   : quiz-info
    Created on : Oct 18, 2026, 9:41:05 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.QuizInfo"%>
<%!
    private String escape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String contextPath = request.getContextPath();
    QuizInfo quiz = (QuizInfo) request.getAttribute("quiz");
    boolean canStart = Boolean.TRUE.equals(request.getAttribute("canStart"));
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>
<main class="container py-5">
    <a href="<%= contextPath %>/student/learn?courseId=<%= quiz.getCourseId() %>">Quay lại khóa học</a>
    <div class="card rounded-4 mt-4"><div class="card-body p-4 p-lg-5">
        <span class="badge text-bg-secondary mb-3"><%= quiz.isRequired() ? "Bắt buộc" : "Tự chọn" %></span>
        <h1 class="h3 fw-bold"><%= escape(quiz.getTitle()) %></h1>
        <p class="text-body-secondary" style="white-space: pre-wrap;"><%= escape(quiz.getDescription()) %></p>
        <div class="row g-3 my-3">
            <div class="col-6 col-md-3"><div class="border rounded-3 p-3">Số câu<h2 class="h4 mt-2"><%= quiz.getQuestionCount() %></h2></div></div>
            <div class="col-6 col-md-3"><div class="border rounded-3 p-3">Thời gian<h2 class="h4 mt-2"><%= quiz.getDurationMinutes() %> phút</h2></div></div>
            <div class="col-6 col-md-3"><div class="border rounded-3 p-3">Điểm đạt<h2 class="h4 mt-2"><%= quiz.getPassingScore() %>%</h2></div></div>
            <div class="col-6 col-md-3"><div class="border rounded-3 p-3">Lượt đã dùng<h2 class="h4 mt-2"><%= quiz.getUsedAttempts() %>/<%= quiz.getMaxAttempts() %></h2></div></div>
        </div>
        <div class="border rounded-3 p-3 mb-3">
            <h2 class="h6 fw-bold">Điều kiện tham gia</h2>
            <p class="mb-2">Hoàn thành bài học bắt buộc:
                <strong><%= quiz.getCompletedRequiredLessons() %>/<%= quiz.getTotalRequiredLessons() %></strong>
            </p>
            <% if (quiz.getTotalRequiredLessons() == 0) { %>
            <p class="text-warning mb-0">Khóa học chưa có bài học bắt buộc. Chưa thể bắt đầu kiểm tra.</p>
            <% } else if (!quiz.isLessonsCompleted()) { %>
            <p class="text-warning mb-0">Bạn cần hoàn thành thêm
                <%= quiz.getTotalRequiredLessons() - quiz.getCompletedRequiredLessons() %> bài học bắt buộc.</p>
            <% } else { %>
            <p class="text-success mb-0"><i class="bi bi-check-circle me-2"></i>Đã hoàn thành các bài học bắt buộc.</p>
            <% } %>
        </div>
        <% if (quiz.isPassed()) { %>
        <div class="alert alert-success">Bạn đã có ít nhất một lượt đạt bài kiểm tra này.</div>
        <% } %>
        <% if (quiz.getActiveAttemptId() != 0) { %>
        <div class="alert alert-warning"><%= quiz.isActiveExpired()
                ? "Lượt cũ đã hết giờ. Mở lượt để hệ thống chốt các đáp án đã lưu."
                : "Bạn có lượt đang làm. Tiếp tục lượt đó, thời gian không được đặt lại." %></div>
        <a class="btn btn-primary" href="<%= contextPath %>/student/quiz/attempt?attemptId=<%= quiz.getActiveAttemptId() %>">
            <%= quiz.isActiveExpired() ? "Xem kết quả lượt hết giờ" : "Tiếp tục làm bài" %>
        </a>
        <% } else if (canStart) { %>
        <div class="alert alert-info">Bạn còn lượt làm bài. Thời gian bắt đầu tính ngay khi bấm nút bên dưới.</div>
        <form method="post" action="<%= contextPath %>/student/quiz/start">
            <input type="hidden" name="quizId" value="<%= quiz.getQuizId() %>">
            <input type="hidden" name="csrfToken" value="<%= escape((String) session.getAttribute("csrfToken")) %>">
            <button class="btn btn-primary" type="submit">Bắt đầu làm bài</button>
        </form>
        <% } else { %>
        <button class="btn btn-secondary mb-3" type="button" disabled>Bắt đầu làm bài</button>
        <div class="alert alert-warning"><%= !quiz.isLessonsCompleted() ? "Chưa đủ điều kiện học tập để bắt đầu kiểm tra."
                : quiz.getQuestionCount() == 0 ? "Đề chưa có câu hỏi." : "Bạn đã hết lượt làm bài." %></div>
        <% } %>
        <p class="small text-body-secondary mt-4 mb-0">Mỗi câu chọn một đáp án. Bấm lưu để giữ lựa chọn trước khi rời trang. Khi hết giờ, chỉ các đáp án đã lưu đúng hạn được chấm. Lượt đang làm cũng tính vào giới hạn lượt.</p>
    </div></div>
</main>
<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
