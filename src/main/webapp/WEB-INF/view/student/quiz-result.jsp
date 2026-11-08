<%-- 
    Document   : quiz-result
    Created on : Oct 18, 2026, 10:19:54 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.QuizAttemptData"%>
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
    boolean passed = attempt.getScore().compareTo(attempt.getPassingScore()) >= 0;
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>
<main class="container py-5">
    <div class="row justify-content-center"><div class="col-lg-8">
        <div class="card rounded-4"><div class="card-body p-4 p-lg-5 text-center">
            <i class="bi <%= passed ? "bi-check-circle text-success" : "bi-x-circle text-danger" %> display-3"></i>
            <h1 class="h3 mt-3">Kết quả bài kiểm tra</h1>
            <p class="text-body-secondary"><%= escape(attempt.getTitle()) %></p>
            <div class="display-4 fw-bold my-4"><%= attempt.getScore() %>%</div>
            <span class="badge fs-6 <%= passed ? "text-bg-success" : "text-bg-danger" %>"><%= passed ? "Đạt" : "Chưa đạt" %></span>
            <div class="row g-3 my-4">
                <div class="col-4">Lượt thi<div class="fw-bold mt-2"><%= attempt.getAttemptNumber() %></div></div>
                <div class="col-4">Điểm<div class="fw-bold mt-2"><%= attempt.getEarnedPoints() %>/<%= attempt.getTotalPoints() %></div></div>
                <div class="col-4">Ngưỡng đạt<div class="fw-bold mt-2"><%= attempt.getPassingScore() %>%</div></div>
            </div>
            <div class="alert <%= "TIMEOUT".equals(attempt.getFinishReason()) ? "alert-warning" : "alert-info" %>">
                <%= "TIMEOUT".equals(attempt.getFinishReason()) ? "Hết giờ. Hệ thống đã chấm các đáp án được lưu đúng hạn." : "Bạn đã nộp bài thành công." %>
            </div>
            <p class="small text-body-secondary">Điều kiện hoàn thành khóa đã được kiểm tra lại sau khi chấm bài.</p>
            <div class="d-flex justify-content-center flex-wrap gap-2">
                <a class="btn btn-primary" href="<%= contextPath %>/student/quiz?quizId=<%= attempt.getQuizId() %>">Thông tin đề / Làm lại</a>
                <a class="btn btn-outline-secondary" href="<%= contextPath %>/student/learn?courseId=<%= attempt.getCourseId() %>">Quay lại học</a>
                <a class="btn btn-outline-secondary" href="<%= contextPath %>/student/courses">Khóa học của tôi</a>
            </div>
        </div></div>
    </div></div>
</main>
<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
