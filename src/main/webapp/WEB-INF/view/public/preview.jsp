<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Lesson"%>

<%
    Lesson lesson = (Lesson) request.getAttribute("lesson");
    String courseTitle = (String) request.getAttribute("courseTitle");
    String chapterTitle = (String) request.getAttribute("chapterTitle");
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5" style="min-height: 70vh;">

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/courses" class="text-secondary text-decoration-none">Courses</a>
            </li>
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/course?id=<%= lesson.getCourseId() %>" class="text-secondary text-decoration-none"><%= courseTitle %></a>
            </li>
            <li class="breadcrumb-item active text-white" aria-current="page">Học thử</li>
        </ol>
    </nav>

    <div class="row g-4 justify-content-center">
        <div class="col-12 col-lg-10">

            <!-- Video Player Box -->
            <div class="card bg-black border border-secondary border-opacity-25 rounded-4 overflow-hidden mb-4 shadow-lg">
                <div class="ratio ratio-16x9">
                    <% if (lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank()) { %>
                        <iframe src="<%= lesson.getVideoUrl() %>"
                                title="<%= lesson.getTitle() %>"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen></iframe>
                    <% } else { %>
                        <div class="d-flex align-items-center justify-content-center text-secondary">
                            <i class="bi bi-camera-video display-1"></i>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Lesson Info Card -->
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 shadow-sm mb-4">
                <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-3 border-bottom border-secondary border-opacity-25">
                    <div>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1 mb-2 fw-medium">
                            <i class="bi bi-play-circle-fill me-1"></i>Bài học xem thử miễn phí
                        </span>
                        <h1 class="h3 fw-bold text-white mb-1"><%= lesson.getTitle() %></h1>
                        <p class="text-secondary small mb-0"><%= chapterTitle %> · <%= courseTitle %></p>
                    </div>

                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/course?id=<%= lesson.getCourseId() %>"
                           class="btn btn-primary rounded-pill px-4 py-2 fw-semibold shadow-sm">
                            Xem toàn bộ khóa học
                        </a>
                    </div>
                </div>

                <% if (lesson.getContent() != null && !lesson.getContent().isBlank()) { %>
                    <div class="text-light lh-lg article-content" style="font-size: 0.95rem;">
                        <%= lesson.getContent() %>
                    </div>
                <% } %>
            </div>

        </div>
    </div>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
