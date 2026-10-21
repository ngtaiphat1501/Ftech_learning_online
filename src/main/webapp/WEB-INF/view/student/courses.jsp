<%-- 
    Document   : courses
    Created on : Oct 18, 2026, 6:45:01 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.StudentCourse"%>

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
    List<StudentCourse> list
            = (List<StudentCourse>) request.getAttribute("list");

    String contextPath = request.getContextPath();

    int studyingCount = 0;
    int completedCount = 0;
    int unavailableCount = 0;

    for (StudentCourse course : list) {
        if (!"ACTIVE".equals(course.getAccessStatus())) {
            unavailableCount++;
        } else if (course.isCompleted()) {
            completedCount++;
        } else {
            studyingCount++;
        }
    }
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>

<main class="container-xl py-4 py-lg-5">

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <div>
            <h1 class="h2 fw-bold mb-2">Khóa học của tôi</h1>
            <p class="text-body-secondary mb-0">
                Theo dõi tiến độ và tiếp tục hành trình học tập của bạn.
            </p>
        </div>

        <a href="<%= contextPath %>/courses"
           class="btn btn-outline-primary rounded-pill px-4">
            <i class="bi bi-search me-2"></i>
            Khám phá khóa học
        </a>
    </div>

    <div class="row g-3 mb-4">

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Tổng số khóa
                    </div>
                    <div class="h3 fw-bold mb-0">
                        <%= list.size() %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Chưa hoàn thành
                    </div>
                    <div class="h3 fw-bold text-primary mb-0">
                        <%= studyingCount %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Đã hoàn thành
                    </div>
                    <div class="h3 fw-bold text-success mb-0">
                        <%= completedCount %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Tạm dừng / thu hồi
                    </div>
                    <div class="h3 fw-bold text-warning mb-0">
                        <%= unavailableCount %>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <% if (list.isEmpty()) { %>

    <div class="card rounded-4 text-center">
        <div class="card-body py-5">
            <i class="bi bi-journal-bookmark display-3 text-body-secondary"></i>

            <h2 class="h4 mt-4">Bạn chưa đăng ký khóa học nào</h2>

            <p class="text-body-secondary mb-4">
                Khám phá và chọn một khóa học phù hợp để bắt đầu.
            </p>

            <a href="<%= contextPath %>/courses"
               class="btn btn-primary rounded-pill px-4">
                Khám phá ngay
            </a>
        </div>
    </div>

    <% } else { %>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">

        <% for (StudentCourse course : list) {
            boolean active = "ACTIVE".equals(course.getAccessStatus());
            boolean revoked = "REVOKED".equals(course.getAccessStatus());

            String imageUrl = course.getThumbnailUrl();

            boolean hasImage = imageUrl != null
                    && (imageUrl.startsWith("https://")
                    || imageUrl.startsWith("http://"));

            String progress = course.getProgressPercent().toPlainString();
        %>

        <div class="col">
            <article class="card h-100 rounded-4 overflow-hidden">

                <div class="ratio ratio-16x9 bg-body-tertiary">

                    <% if (hasImage) { %>

                    <img src="<%= escape(imageUrl) %>"
                         alt="<%= escape(course.getTitle()) %>"
                         class="object-fit-cover"
                         loading="lazy">

                    <% } else { %>

                    <div class="d-flex align-items-center justify-content-center">
                        <i class="bi bi-book display-3 text-primary"></i>
                    </div>

                    <% } %>

                </div>

                <div class="card-body d-flex flex-column p-4">

                    <div class="mb-3">

                        <% if (!active) { %>

                        <span class="badge <%= revoked ? "text-bg-danger" : "text-bg-warning" %>">
                            <%= revoked ? "Đã thu hồi quyền học" : "Tạm dừng quyền học" %>
                        </span>

                        <% } else if (course.isCompleted()) { %>

                        <span class="badge text-bg-success">
                            Đã hoàn thành
                        </span>

                        <% } else { %>

                        <span class="badge text-bg-primary">
                            Chưa hoàn thành
                        </span>

                        <% } %>

                    </div>

                    <h2 class="h5 fw-bold mb-3">
                        <%= escape(course.getTitle()) %>
                    </h2>

                    <p class="small text-body-secondary mb-4">
                        <i class="bi bi-person-circle me-2"></i>
                        <%= escape(course.getInstructorName()) %>
                    </p>

                    <div class="mt-auto">

                        <div class="d-flex justify-content-between small mb-2">
                            <span>Tiến độ bài học</span>
                            <span class="fw-semibold">
                                <%= progress %>%
                            </span>
                        </div>

                        <div class="progress mb-2"
                             role="progressbar"
                             aria-label="Tiến độ bài học"
                             aria-valuenow="<%= progress %>"
                             aria-valuemin="0"
                             aria-valuemax="100">

                            <div class="progress-bar <%= course.isCompleted() ? "bg-success" : "" %>"
                                 style="width: <%= progress %>%">
                            </div>
                        </div>

                        <p class="small text-body-secondary mb-4">
                            Đã hoàn thành
                            <%= course.getCompletedLessons() %>/<%= course.getTotalLessons() %>
                            bài bắt buộc
                        </p>

                        <% if (active) { %>

                        <a href="<%= contextPath %>/student/learn?courseId=<%= course.getCourseId() %>"
                           class="btn btn-primary w-100">
                            <i class="bi bi-play-circle me-2"></i>
                            <%= course.isCompleted() ? "Xem lại khóa học" : "Tiếp tục học" %>
                        </a>

                        <% } else { %>

                        <button type="button"
                                class="btn btn-outline-secondary w-100"
                                disabled>
                            <i class="bi bi-lock me-2"></i>
                            Chưa thể truy cập
                        </button>

                        <% } %>

                    </div>
                </div>
            </article>
        </div>

        <% } %>

    </div>

    <% } %>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>