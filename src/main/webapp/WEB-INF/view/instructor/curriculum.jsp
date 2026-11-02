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

    List<CurriculumChapter> chapters
            = (List<CurriculumChapter>) request.getAttribute("chapters");

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

        <a href="<%= context%>/instructor/courses"
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


    <% if ("chapter-delete".equals(success)) { %>

    <div class="alert alert-success">
        Xóa chương thành công.
    </div>

    <% } %>


    <% if ("lesson-create".equals(success)) { %>

    <div class="alert alert-success">
        Thêm bài học thành công.
    </div>

    <% } %>


    <% if ("lesson-edit".equals(success)) { %>

    <div class="alert alert-success">
        Cập nhật bài học thành công.
    </div>

    <% } %>


    <% if ("lesson-delete".equals(success)) { %>

    <div class="alert alert-success">
        Xóa bài học thành công.
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


    <% if ("chapter-delete".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể xóa chương.
        Chương có thể đã có dữ liệu học
        hoặc khóa học không còn được phép chỉnh sửa.
    </div>

    <% } %>


    <% if ("lesson-title".equals(error)) { %>

    <div class="alert alert-warning">
        Tên bài học không được để trống.
    </div>

    <% } %>


    <% if ("lesson-duration".equals(error)) { %>

    <div class="alert alert-warning">
        Thời lượng bài học không hợp lệ.
    </div>

    <% } %>


    <% if ("lesson-create".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể thêm bài học.
    </div>

    <% } %>


    <% if ("lesson-edit".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể cập nhật bài học.
    </div>

    <% } %>


    <% if ("lesson-delete".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể xóa bài học.
        Bài học có thể đã có dữ liệu học viên
        hoặc khóa học không còn được phép chỉnh sửa.
    </div>

    <% }%>


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

                <%= escapeHtml(
                        course.getTitle()
                )%>

            </h1>

            <div>

                <span class="badge text-bg-secondary">

                    <%= escapeHtml(
                            course.getStatus()
                    )%>

                </span>

                <span class="text-body-secondary ms-2">

                    Course ID:
                    <%= course.getId()%>

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
                  action="<%= context%>/instructor/chapter?action=create">

                <input type="hidden"
                       name="courseId"
                       value="<%= course.getId()%>">


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

            <i class="bi
               bi-journal-x
               fs-1
               text-body-secondary">
            </i>

            <h3 class="h5
                fw-bold
                mt-3">

                Chưa có chương nào

            </h3>

            <p class="text-body-secondary
               mb-0">

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
                 align-items-start
                 gap-3">


                <div>

                    <div class="small
                         text-body-secondary
                         mb-1">

                        Chương
                        <%= chapter.getSortOrder()%>

                    </div>


                    <h2 class="h5
                        fw-bold
                        mb-1">

                        <%= escapeHtml(
                                chapter.getTitle()
                        )%>

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
                        )%>

                    </div>


                    <%
                        }
                    %>

                </div>


                <span class="badge
                      text-bg-light">

                    <%= chapter
                            .getLessons()
                            .size()%>

                    bài học

                </span>


            </div>


            <%
                if ("DRAFT".equals(
                        course.getStatus())) {
            %>


            <div class="d-flex
                 flex-wrap
                 align-items-start
                 gap-2
                 mt-3">


                <details>

                    <summary class="btn
                             btn-sm
                             btn-outline-primary">

                        <i class="bi
                           bi-pencil
                           me-1">
                        </i>

                        Sửa chương

                    </summary>


                    <div class="card
                         border
                         shadow-sm
                         mt-3">

                        <div class="card-body">


                            <form method="post"
                                  action="<%= context%>/instructor/chapter?action=edit">


                                <input type="hidden"
                                       name="courseId"
                                       value="<%= course.getId()%>">

                                <input type="hidden"
                                       name="chapterId"
                                       value="<%= chapter.getChapterId()%>">


                                <div class="mb-3">

                                    <label class="form-label">
                                        Tên chương
                                    </label>

                                    <input type="text"
                                           name="title"
                                           class="form-control"
                                           value="<%= escapeHtml(
                                                   chapter.getTitle()
                                           )%>"
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
                                              )%></textarea>

                                </div>


                                <div class="mb-3">

                                    <label class="form-label">
                                        Vị trí chương
                                    </label>

                                    <input type="number"
                                           name="sortOrder"
                                           class="form-control"
                                           min="1"
                                           value="<%= chapter.getSortOrder()%>"
                                           required>

                                </div>


                                <button type="submit"
                                        class="btn btn-primary">

                                    <i class="bi
                                       bi-check-lg
                                       me-1">
                                    </i>

                                    Lưu thay đổi

                                </button>


                            </form>

                        </div>

                    </div>

                </details>


                <form method="post"
                      action="<%= context%>/instructor/chapter?action=delete"
                      onsubmit="return confirm('Bạn có chắc muốn xóa chương này?');">


                    <input type="hidden"
                           name="courseId"
                           value="<%= course.getId()%>">

                    <input type="hidden"
                           name="chapterId"
                           value="<%= chapter.getChapterId()%>">


                    <button type="submit"
                            class="btn
                            btn-sm
                            btn-outline-danger">

                        <i class="bi
                           bi-trash
                           me-1">
                        </i>

                        Xóa chương

                    </button>


                </form>


                <details>

                    <summary class="btn
                             btn-sm
                             btn-success">

                        <i class="bi
                           bi-plus-lg
                           me-1">
                        </i>

                        Thêm bài học

                    </summary>


                    <div class="card
                         border
                         shadow-sm
                         mt-3">

                        <div class="card-body">

                            <h3 class="h6
                                fw-bold
                                mb-3">

                                Bài học mới

                            </h3>


                            <form method="post"
                                  action="<%= context%>/instructor/lesson?action=create">


                                <input type="hidden"
                                       name="courseId"
                                       value="<%= course.getId()%>">

                                <input type="hidden"
                                       name="chapterId"
                                       value="<%= chapter.getChapterId()%>">


                                <div class="mb-3">

                                    <label class="form-label">
                                        Tên bài học
                                    </label>

                                    <input type="text"
                                           name="title"
                                           class="form-control"
                                           placeholder="Ví dụ: Java là gì?"
                                           required>

                                </div>


                                <div class="mb-3">

                                    <label class="form-label">
                                        Nội dung
                                    </label>

                                    <textarea name="content"
                                              class="form-control"
                                              rows="4"
                                              placeholder="Nhập nội dung bài học"></textarea>

                                </div>


                                <div class="mb-3">

                                    <label class="form-label">
                                        Video URL
                                    </label>

                                    <input type="text"
                                           name="videoUrl"
                                           class="form-control"
                                           placeholder="https://...">

                                </div>


                                <div class="mb-3">

                                    <label class="form-label">
                                        Thời lượng (giây)
                                    </label>

                                    <input type="number"
                                           name="durationSeconds"
                                           class="form-control"
                                           min="0"
                                           value="600">

                                    <div class="form-text">

                                        600 giây = 10 phút.

                                    </div>

                                </div>


                                <div class="form-check mb-2">

                                    <input class="form-check-input"
                                           type="checkbox"
                                           name="isPreview"
                                           id="preview-<%= chapter.getChapterId()%>">

                                    <label class="form-check-label"
                                           for="preview-<%= chapter.getChapterId()%>">

                                        Cho phép xem thử

                                    </label>

                                </div>


                                <div class="form-check mb-3">

                                    <input class="form-check-input"
                                           type="checkbox"
                                           name="isRequired"
                                           id="required-<%= chapter.getChapterId()%>"
                                           checked>

                                    <label class="form-check-label"
                                           for="required-<%= chapter.getChapterId()%>">

                                        Bài học bắt buộc

                                    </label>

                                </div>


                                <button type="submit"
                                        class="btn btn-success">

                                    <i class="bi
                                       bi-plus-lg
                                       me-1">
                                    </i>

                                    Thêm bài học

                                </button>


                            </form>

                        </div>

                    </div>

                </details>


            </div>


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

                <i class="bi
                   bi-journal-text
                   d-block
                   fs-4
                   mb-2">
                </i>

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

                            <%= lesson.getSortOrder()%>

                        </div>


                        <div>


                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        lesson.getTitle()
                                )%>

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

                                    <i class="bi
                                       bi-clock
                                       me-1">
                                    </i>

                                    <%= minutes%> phút

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


                    <%
                        if ("DRAFT".equals(
                                course.getStatus())) {
                    %>


                    <div class="d-flex gap-2">


                        <a href="<%= context%>/instructor/lesson?view=edit&id=<%= lesson.getLessonId()%>"
                           class="btn
                           btn-sm
                           btn-outline-primary">

                            <i class="bi
                               bi-pencil
                               me-1">
                            </i>

                            Sửa

                        </a>


                        <form method="post"
                              action="<%= context%>/instructor/lesson?action=delete"
                              onsubmit="return confirm('Bạn có chắc muốn xóa bài học này?');">


                            <input type="hidden"
                                   name="lessonId"
                                   value="<%= lesson.getLessonId()%>">


                            <button type="submit"
                                    class="btn
                                    btn-sm
                                    btn-outline-danger">

                                <i class="bi
                                   bi-trash
                                   me-1">
                                </i>

                                Xóa

                            </button>


                        </form>


                    </div>


                    <%
                        }
                    %>


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