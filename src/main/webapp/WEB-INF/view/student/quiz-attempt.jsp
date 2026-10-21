<%-- 
    Document   : quiz-attempt
    Created on : Oct 18, 2026, 10:21:01 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.QuizAttemptData,model.QuizQuestion,model.QuizOption"%>
<%!
    private String escape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String contextPath = request.getContextPath();
    QuizAttemptData attempt = (QuizAttemptData) request.getAttribute("attempt");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>
<main class="container py-4">
    <div class="d-flex flex-wrap justify-content-between gap-3 align-items-center mb-4">
        <div><h1 class="h3"><%= escape(attempt.getTitle()) %></h1><span class="text-body-secondary">Lượt <%= attempt.getAttemptNumber() %></span></div>
        <div class="border rounded-3 p-3">Còn lại: <strong id="timer" class="text-warning"><%= Math.max(0, attempt.getRemainingSeconds()) %> giây</strong></div>
    </div>
    <% if ("1".equals(request.getParameter("saved"))) { %>
    <div class="alert alert-success">Đã lưu các lựa chọn.</div>
    <% } %>
    <div class="alert alert-info">Bấm “Lưu đáp án” trước khi rời trang. Đồng hồ không được đặt lại khi tải lại trang.</div>
    <form id="quizForm" method="post" action="<%= contextPath %>/student/quiz/save">
        <input type="hidden" name="attemptId" value="<%= attempt.getAttemptId() %>">
        <input type="hidden" name="csrfToken" value="<%= escape((String) session.getAttribute("csrfToken")) %>">
        <% int number = 0; for (QuizQuestion question : attempt.getQuestions()) { number++; %>
        <fieldset class="card rounded-4 mb-3">
            <div class="card-body p-4">
                <legend class="h5">Câu <%= number %> <span class="small text-body-secondary">(<%= question.getPoints() %> điểm)</span></legend>
                <p style="white-space: pre-wrap;"><%= escape(question.getContent()) %></p>
                <% for (QuizOption option : question.getOptions()) { %>
                <div class="form-check border rounded-3 p-3 ps-5 mb-2">
                    <input class="form-check-input" type="radio"
                           name="answer_<%= question.getId() %>" id="option_<%= option.getId() %>"
                           value="<%= option.getId() %>" <%= question.getSelectedOptionId() == option.getId() ? "checked" : "" %>>
                    <label class="form-check-label w-100" for="option_<%= option.getId() %>"><%= escape(option.getContent()) %></label>
                </div>
                <% } %>
            </div>
        </fieldset>
        <% } %>
        <div class="d-flex flex-wrap gap-3 my-4">
            <button id="saveButton" class="btn btn-outline-primary" type="submit">Lưu đáp án</button>
            <button id="submitButton" class="btn btn-primary" type="submit" formaction="<%= contextPath %>/student/quiz/submit">Nộp bài</button>
            <a class="btn btn-outline-secondary" href="<%= contextPath %>/student/quiz?quizId=<%= attempt.getQuizId() %>">Thông tin đề</a>
        </div>
    </form>
</main>
<script>
    const deadline = Date.now() + <%= Math.max(0, attempt.getRemainingSeconds()) %> * 1000;
    const timer = document.getElementById('timer');
    const form = document.getElementById('quizForm');
    const resultUrl = '<%= contextPath %>/student/quiz/result?attemptId=<%= attempt.getAttemptId() %>';
    let leaving = false;
    document.getElementById('submitButton').addEventListener('click', function (event) {
        if (!confirm('Bạn muốn nộp bài và kết thúc lượt thi?')) event.preventDefault();
    });
    form.addEventListener('submit', function () { leaving = true; });
    function updateTimer() {
        const remaining = Math.max(0, Math.ceil((deadline - Date.now()) / 1000));
        const minutes = Math.floor(remaining / 60);
        const seconds = remaining % 60;
        timer.textContent = minutes + ':' + String(seconds).padStart(2, '0');
        if (remaining === 0 && !leaving) {
            leaving = true;
            document.getElementById('saveButton').disabled = true;
            document.getElementById('submitButton').disabled = true;
            window.location.replace(resultUrl);
        }
    }
    updateTimer();
    setInterval(updateTimer, 1000);
</script>
<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
