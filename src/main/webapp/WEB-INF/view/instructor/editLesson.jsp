<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.CurriculumLesson" %>
<%@ page import="model.LessonResource" %>

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
    CurriculumLesson lesson
            = (CurriculumLesson)
                    request.getAttribute("lesson");

    List<LessonResource> resources
            = (List<LessonResource>)
                    request.getAttribute("resources");

    String context
            = request.getContextPath();

    String error
            = request.getParameter("error");

    String success
            = request.getParameter("success");

    request.setAttribute(
            "pageTitle",
            "Sửa bài học | Ftech Instructor"
    );
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">

    <div class="mb-4">

        <a href="<%= context%>/instructor/curriculum?courseId=<%= lesson.getCourseId()%>"
           class="text-decoration-none">

            <i class="bi bi-arrow-left me-1"></i>
            Quay lại nội dung khóa học

        </a>

    </div>


    <% if ("resource".equals(success)) { %>

    <div class="alert alert-success">
        Thêm tài liệu thành công.
    </div>

    <% } %>


    <% if ("resource-delete".equals(success)) { %>

    <div class="alert alert-success">
        Xóa tài liệu thành công.
    </div>

    <% } %>


    <% if ("title".equals(error)) { %>

    <div class="alert alert-warning">
        Tên bài học không được để trống.
    </div>

    <% } %>


    <% if ("duration".equals(error)) { %>

    <div class="alert alert-warning">
        Thời lượng không hợp lệ.
    </div>

    <% } %>


    <% if ("resource".equals(error)) { %>

    <div class="alert alert-warning">
        Dữ liệu tài liệu không hợp lệ.
    </div>

    <% } %>


    <% if ("resource-delete".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể xóa tài liệu.
    </div>

    <% } %>


    <div class="card border-0 shadow-sm mb-4">

        <div class="card-body p-4">

            <h1 class="h3 fw-bold mb-4">
                Sửa bài học
            </h1>


            <form method="post"
                  action="<%= context%>/instructor/lesson?action=edit">

                <input type="hidden"
                       name="lessonId"
                       value="<%= lesson.getLessonId()%>">


                <div class="mb-3">

                    <label class="form-label">
                        Tên bài học
                    </label>

                    <input type="text"
                           name="title"
                           class="form-control"
                           value="<%= escapeHtml(
                                   lesson.getTitle()
                           )%>"
                           required>

                </div>


                <div class="mb-3">

                    <label class="form-label">
                        Nội dung
                    </label>

                    <textarea name="content"
                              class="form-control"
                              rows="7"><%= escapeHtml(
                                      lesson.getContent()
                              )%></textarea>

                </div>


                <div class="mb-3">

                    <label class="form-label">
                        Video URL
                    </label>

                    <input type="text"
                           name="videoUrl"
                           class="form-control"
                           value="<%= escapeHtml(
                                   lesson.getVideoUrl()
                           )%>">

                </div>


                <div class="mb-3">

                    <label class="form-label">
                        Thời lượng (giây)
                    </label>

                    <input type="number"
                           name="durationSeconds"
                           class="form-control"
                           min="0"
                           value="<%= lesson
                                   .getDurationSeconds()
                                   == null
                                   ? ""
                                   : lesson
                                           .getDurationSeconds()%>">

                </div>


                <div class="mb-3">

                    <label class="form-label">
                        Vị trí bài học
                    </label>

                    <input type="number"
                           name="sortOrder"
                           class="form-control"
                           min="1"
                           value="<%= lesson.getSortOrder()%>"
                           required>

                </div>


                <div class="form-check mb-2">

                    <input class="form-check-input"
                           type="checkbox"
                           name="isPreview"
                           id="isPreview"
                           <%= lesson.isPreview()
                                   ? "checked"
                                   : ""%>>

                    <label class="form-check-label"
                           for="isPreview">

                        Cho phép xem thử

                    </label>

                </div>


                <div class="form-check mb-4">

                    <input class="form-check-input"
                           type="checkbox"
                           name="isRequired"
                           id="isRequired"
                           <%= lesson.isRequired()
                                   ? "checked"
                                   : ""%>>

                    <label class="form-check-label"
                           for="isRequired">

                        Bài học bắt buộc

                    </label>

                </div>


                <button type="submit"
                        class="btn btn-primary">

                    <i class="bi bi-check-lg me-1"></i>
                    Lưu thay đổi

                </button>

            </form>

        </div>

    </div>


    <div class="card border-0 shadow-sm">

        <div class="card-body p-4">

            <h2 class="h4 fw-bold mb-4">
                Tài liệu bài học
            </h2>


            <form method="post"
                  action="<%= context%>/instructor/resource?action=create"
                  class="mb-4">

                <input type="hidden"
                       name="lessonId"
                       value="<%= lesson.getLessonId()%>">


                <div class="row g-3">

                    <div class="col-md-4">

                        <label class="form-label">
                            Tên tài liệu
                        </label>

                        <input type="text"
                               name="title"
                               class="form-control"
                               required>

                    </div>


                    <div class="col-md-4">

                        <label class="form-label">
                            URL
                        </label>

                        <input type="text"
                               name="resourceUrl"
                               class="form-control"
                               required>

                    </div>


                    <div class="col-md-2">

                        <label class="form-label">
                            Loại
                        </label>

                        <select name="resourceType"
                                class="form-select">

                            <option value="PDF">
                                PDF
                            </option>

                            <option value="SLIDE">
                                SLIDE
                            </option>

                            <option value="CODE">
                                CODE
                            </option>

                            <option value="LINK">
                                LINK
                            </option>

                            <option value="ZIP">
                                ZIP
                            </option>

                            <option value="DOC">
                                DOC
                            </option>

                        </select>

                    </div>


                    <div class="col-md-2 d-flex
                         align-items-end">

                        <button type="submit"
                                class="btn
                                btn-success
                                w-100">

                            Thêm

                        </button>

                    </div>

                </div>

            </form>


            <%
                if (resources == null
                        || resources.isEmpty()) {
            %>

            <div class="text-body-secondary">
                Chưa có tài liệu.
            </div>

            <%
                } else {

                    for (LessonResource resource
                            : resources) {
            %>


            <div class="border
                 rounded
                 p-3
                 mb-2
                 d-flex
                 justify-content-between
                 align-items-center
                 gap-3">

                <div>

                    <div class="fw-semibold">
                        <%= escapeHtml(
                                resource.getTitle()
                        )%>
                    </div>

                    <div class="small
                         text-body-secondary">

                        <span class="badge
                              text-bg-secondary
                              me-2">

                            <%= escapeHtml(
                                    resource
                                            .getResourceType()
                            )%>

                        </span>

                        <%= escapeHtml(
                                resource.getResourceUrl()
                        )%>

                    </div>

                </div>


                <form method="post"
                      action="<%= context%>/instructor/resource?action=delete"
                      onsubmit="return confirm('Xóa tài liệu này?');">

                    <input type="hidden"
                           name="lessonId"
                           value="<%= lesson.getLessonId()%>">

                    <input type="hidden"
                           name="resourceId"
                           value="<%= resource.getResourceId()%>">

                    <button type="submit"
                            class="btn
                            btn-sm
                            btn-outline-danger">

                        Xóa

                    </button>

                </form>

            </div>


            <%
                    }
                }
            %>

        </div>

    </div>

</main>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>