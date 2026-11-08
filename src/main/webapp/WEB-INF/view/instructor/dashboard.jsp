<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Course" %>
<%@ page import="model.CurriculumChapter" %>
<%@ page import="model.CurriculumLesson" %>

<%!
    private String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    Course course
            = (Course) request.getAttribute("course");
    if (course == null) {
        java.util.List<model.Course> coursesList = (java.util.List<model.Course>) request.getAttribute("courses");
        if (coursesList != null && !coursesList.isEmpty()) {
            course = coursesList.get(0);
        } else {
            course = new model.Course();
            course.setTitle("Khoá học của tôi");
            course.setStatus("DRAFT");
        }
    }

    List<CurriculumChapter> chapters
            = (List<CurriculumChapter>)
                    request.getAttribute("chapters");

    request.setAttribute(
            "pageTitle",
            "Nội dung khóa học | Ftech Instructor"
    );

    String context
            = request.getContextPath();

    String success
            = request.getParameter("success");

    String error
            = request.getParameter("error");
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">

    <div class="mb-4">

        <a href="<%= context %>/instructor/courses"
           class="text-decoration-none">

            <i class="bi bi-arrow-left me-1"></i>
            Quay lại khóa học

        </a>

    </div>


    <% if ("chapter".equals(success)) { %>

    <div class="alert alert-success">
        Thêm chương thành công.
    </div>

    <% } %>


    <% if ("chapter-edit".equals(success)) { %>

    <div class="alert alert-success">
        Cập nhật chương thành công.
    </div>

    <% } %>


    <% if ("title".equals(error)) { %>

    <div class="alert alert-warning">
        Tên chương không được để trống.
    </div>

    <% } %>


    <% if ("status".equals(error)) { %>

    <div class="alert alert-warning">
        Chỉ khóa học DRAFT mới được chỉnh sửa nội dung.
    </div>

    <% } %>


    <% if ("chapter-edit".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể cập nhật chương.
    </div>

    <% } %>


    <div class="d-flex
                justify-content-between
                align-items-start
                gap-3
                mb-4">

        <div>

            <div class="text-body-secondary small mb-2">
                QUẢN LÝ NỘI DUNG
            </div>

            <h1 class="fw-bold mb-2">
                <%= escapeHtml(course.getTitle()) %>
            </h1>

            <div>

                <span class="badge text-bg-secondary">
                    <%= escapeHtml(course.getStatus()) %>
                </span>

                <span class="text-body-secondary ms-2">
                    Course ID:
                    <%= course.getId() %>
                </span>

            </div>

        </div>

    </div>


    <%
        if ("DRAFT".equals(course.getStatus())) {
    %>

    <div class="card
                border-0
                shadow-sm
                mb-4">

        <div class="card-body">

            <h2 class="h5 fw-bold mb-3">
                Thêm chương mới
            </h2>

            <form method="post"
                  action="<%= context %>/instructor/chapter?action=create">

                <input type="hidden"
                       name="courseId"
                       value="<%= course.getId() %>">

                <div class="mb-3">

                    <label class="form-label">
                        Tên chương
                    </label>

                    <input type="text"
                           name="title"
                           class="form-control"
                           placeholder="Ví dụ: Java cơ bản"
                           required>

                </div>


                <div class="mb-3">

                    <label class="form-label">
                        Mô tả
                    </label>

                    <textarea name="description"
                              class="form-control"
                              rows="3"
                              placeholder="Mô tả ngắn về chương"></textarea>

                </div>


                <button type="submit"
                        class="btn btn-primary">

                    <i class="bi bi-plus-lg me-1"></i>
                    Thêm chương

                </button>

            </form>

        </div>

    </div>

    <%
        }
    %>


    <%
        if (chapters == null
                || chapters.isEmpty()) {
    %>

    <div class="card
                border-0
                shadow-sm">

        <div class="card-body
                    text-center
                    py-5">

            <i class="bi bi-journal-x
                      fs-1
                      text-body-secondary">
            </i>

            <h3 class="h5 fw-bold mt-3">
                Chưa có chương nào
            </h3>

            <p class="text-body-secondary mb-0">
                Khóa học này chưa có nội dung.
            </p>

        </div>

    </div>

    <%
        } else {

            for (CurriculumChapter chapter
                    : chapters) {
    %>


    <section class="card
                    border-0
                    shadow-sm
                    mb-4">

        <div class="card-header
                    bg-body
                    py-3">

            <div class="d-flex
                        justify-content-between
                        align-items-center
                        gap-3">

                <div>

                    <div class="small
                                text-body-secondary
                                mb-1">

                        Chương
                        <%= chapter.getSortOrder() %>

                    </div>


                    <h2 class="h5
                               fw-bold
                               mb-1">

                        <%= escapeHtml(
                                chapter.getTitle()
                        ) %>

                    </h2>


                    <%
                        if (chapter.getDescription() != null
                                && !chapter.getDescription()
                                        .isBlank()) {
                    %>

                    <div class="small
                                text-body-secondary">

                        <%= escapeHtml(
                                chapter.getDescription()
                        ) %>

                    </div>

                    <%
                        }
                    %>

                </div>


                <span class="badge
                             text-bg-light">

                    <%= chapter
                            .getLessons()
                            .size() %>
                    bài học

                </span>

            </div>


            <%
                if ("DRAFT".equals(
                        course.getStatus())) {
            %>

            <details class="mt-3">

                <summary class="btn
                                btn-sm
                                btn-outline-primary">

                    <i class="bi bi-pencil me-1"></i>
                    Sửa chương

                </summary>


                <form method="post"
                      action="<%= context %>/instructor/chapter?action=edit"
                      class="mt-3">

                    <input type="hidden"
                           name="courseId"
                           value="<%= course.getId() %>">

                    <input type="hidden"
                           name="chapterId"
                           value="<%= chapter.getChapterId() %>">


                    <div class="mb-3">

                        <label class="form-label">
                            Tên chương
                        </label>

                        <input type="text"
                               name="title"
                               class="form-control"
                               value="<%= escapeHtml(
                                       chapter.getTitle()
                               ) %>"
                               required>

                    </div>


                    <div class="mb-3">

                        <label class="form-label">
                            Mô tả
                        </label>

                        <textarea name="description"
                                  class="form-control"
                                  rows="2"><%= escapeHtml(
                                          chapter.getDescription()
                                  ) %></textarea>

                    </div>


                    <div class="mb-3">

                        <label class="form-label">
                            Vị trí chương
                        </label>

                        <input type="number"
                               name="sortOrder"
                               class="form-control"
                               min="1"
                               value="<%= chapter.getSortOrder() %>"
                               required>

                    </div>


                    <button type="submit"
                            class="btn btn-primary">

                        <i class="bi bi-check-lg me-1"></i>
                        Lưu thay đổi

                    </button>

                </form>

            </details>

            <%
                }
            %>

        </div>


        <div class="list-group
                    list-group-flush">

            <%
                if (chapter.getLessons()
                        .isEmpty()) {
            %>

            <div class="list-group-item
                        py-4
                        text-center
                        text-body-secondary">

                Chương này chưa có bài học.

            </div>

            <%
                } else {

                    for (CurriculumLesson lesson
                            : chapter.getLessons()) {
            %>


            <div class="list-group-item py-3">

                <div class="d-flex
                            justify-content-between
                            align-items-center
                            gap-3">

                    <div class="d-flex
                                align-items-center
                                gap-3">

                        <div class="fw-bold
                                    text-body-secondary">

                            <%= lesson.getSortOrder() %>

                        </div>


                        <div>

                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        lesson.getTitle()
                                ) %>

                            </div>


                            <div class="small
                                        text-body-secondary">

                                <%
                                    if (lesson
                                            .getDurationSeconds()
                                            != null) {

                                        int minutes
                                                = (lesson
                                                        .getDurationSeconds()
                                                + 59)
                                                / 60;
                                %>

                                <span class="me-3">

                                    <i class="bi bi-clock me-1"></i>

                                    <%= minutes %> phút

                                </span>

                                <%
                                    }
                                %>


                                <%
                                    if (lesson.isPreview()) {
                                %>

                                <span class="badge
                                             text-bg-info
                                             me-1">

                                    Preview

                                </span>

                                <%
                                    }
                                %>


                                <%
                                    if (lesson.isRequired()) {
                                %>

                                <span class="badge
                                             text-bg-secondary">

                                    Bắt buộc

                                </span>

                                <%
                                    }
                                %>

                            </div>

                        </div>

                    </div>

                </div>

            </div>

            <%
                    }
                }
            %>

        </div>

    </section>


    <%
            }
        }
    %>

</main>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>