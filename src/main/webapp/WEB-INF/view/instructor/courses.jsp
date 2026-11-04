<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Course" %>

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
    List<Course> courses
            = (List<Course>)
                    request.getAttribute("courses");

    String context
            = request.getContextPath();

    String success
            = request.getParameter("success");

    String error
            = request.getParameter("error");

    request.setAttribute(
            "pageTitle",
            "Khóa học của tôi | Ftech Instructor"
    );
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">

    <div class="d-flex
                justify-content-between
                align-items-center
                flex-wrap
                gap-3
                mb-4">

        <div>

            <div class="small
                        text-body-secondary
                        mb-1">

                INSTRUCTOR

            </div>

            <h1 class="fw-bold mb-0">
                Khóa học của tôi
            </h1>

        </div>


        <a href="<%= context%>/instructor/course?view=create"
           class="btn btn-primary">

            <i class="bi bi-plus-lg me-1"></i>
            Tạo khóa học

        </a>

    </div>


    <% if ("create".equals(success)) { %>

    <div class="alert alert-success">

        <i class="bi bi-check-circle me-1"></i>
        Tạo khóa học thành công.

    </div>

    <% } %>


    <% if ("edit".equals(success)) { %>

    <div class="alert alert-success">

        <i class="bi bi-check-circle me-1"></i>
        Cập nhật khóa học thành công.

    </div>

    <% } %>


    <% if ("archive".equals(success)) { %>

    <div class="alert alert-success">

        <i class="bi bi-check-circle me-1"></i>
        Đã lưu trữ khóa học.

    </div>

    <% } %>


    <% if ("reopen".equals(success)) { %>

    <div class="alert alert-success">

        <i class="bi bi-check-circle me-1"></i>
        Đã mở lại khóa học để chỉnh sửa.

    </div>

    <% } %>


    <% if ("submit".equals(success)) { %>

    <div class="alert alert-success">

        <i class="bi bi-check-circle me-1"></i>
        Đã gửi khóa học để duyệt.

    </div>

    <% } %>


    <% if ("create".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể tạo khóa học.
    </div>

    <% } %>


    <% if ("edit".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể cập nhật khóa học.
    </div>

    <% } %>


    <% if ("archive".equals(error)) { %>

    <div class="alert alert-warning">
        Không thể lưu trữ khóa học.
    </div>

    <% } %>


    <% if ("reopen".equals(error)) { %>

    <div class="alert alert-warning">

        Không thể mở lại khóa học.
        Khóa học có thể đã có học viên.

    </div>

    <% } %>


    <% if ("submit-content".equals(error)) { %>

    <div class="alert alert-warning">

        <i class="bi bi-exclamation-triangle me-1"></i>

        Khóa học cần có ít nhất
        một chương và một bài học
        trước khi gửi duyệt.

    </div>

    <% } %>


    <% if ("submit".equals(error)) { %>

    <div class="alert alert-warning">

        <i class="bi bi-exclamation-triangle me-1"></i>

        Không thể gửi khóa học để duyệt.
        Khóa học có thể không còn ở trạng thái DRAFT.

    </div>

    <% } %>


    <%
        if (courses == null
                || courses.isEmpty()) {
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

            <h2 class="h5 fw-bold mt-3">
                Chưa có khóa học
            </h2>

            <p class="text-body-secondary mb-4">
                Bạn chưa tạo khóa học nào.
            </p>

            <a href="<%= context%>/instructor/course?view=create"
               class="btn btn-primary">

                <i class="bi bi-plus-lg me-1"></i>
                Tạo khóa học đầu tiên

            </a>

        </div>

    </div>


    <%
        } else {
    %>


    <div class="card
                border-0
                shadow-sm">

        <div class="table-responsive">

            <table class="table
                          table-hover
                          align-middle
                          mb-0">


                <thead class="table-light">

                    <tr>

                        <th class="px-4 py-3">
                            ID
                        </th>

                        <th class="py-3">
                            Khóa học
                        </th>

                        <th class="py-3">
                            Trạng thái
                        </th>

                        <th class="py-3">
                            Học viên
                        </th>

                        <th class="py-3
                                   text-end
                                   px-4">

                            Thao tác

                        </th>

                    </tr>

                </thead>


                <tbody>


                    <%
                        for (Course course
                                : courses) {
                    %>


                    <tr>


                        <td class="px-4">

                            <span class="text-body-secondary">

                                #<%= course.getId()%>

                            </span>

                        </td>


                        <td>

                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        course.getTitle()
                                )%>

                            </div>

                        </td>


                        <td>

                            <%
                                String status
                                        = course.getStatus();
                            %>


                            <% if ("DRAFT".equals(status)) { %>

                            <span class="badge
                                         text-bg-secondary">

                                DRAFT

                            </span>


                            <% } else if ("PENDING_APPROVAL".equals(status)) { %>

                            <span class="badge
                                         text-bg-warning">

                                PENDING_APPROVAL

                            </span>


                            <% } else if ("PUBLISHED".equals(status)) { %>

                            <span class="badge
                                         text-bg-success">

                                PUBLISHED

                            </span>


                            <% } else if ("ARCHIVED".equals(status)) { %>

                            <span class="badge
                                         text-bg-dark">

                                ARCHIVED

                            </span>


                            <% } else if ("SUSPENDED".equals(status)) { %>

                            <span class="badge
                                         text-bg-danger">

                                SUSPENDED

                            </span>


                            <% } else { %>

                            <span class="badge
                                         text-bg-secondary">

                                <%= escapeHtml(status)%>

                            </span>

                            <% } %>

                        </td>


                        <td>

                            <i class="bi bi-people me-1"></i>

                            <%= course.getEnrollmentCount()%>

                        </td>


                        <td class="text-end px-4">


                            <div class="d-flex
                                        flex-wrap
                                        justify-content-end
                                        gap-2">


                                <!-- ========================= -->
                                <!-- CURRICULUM -->
                                <!-- ========================= -->

                                <a href="<%= context%>/instructor/curriculum?courseId=<%= course.getId()%>"
                                   class="btn
                                          btn-sm
                                          btn-outline-secondary
                                          rounded-pill">

                                    <i class="bi
                                              bi-list-nested
                                              me-1">
                                    </i>

                                    Nội dung

                                </a>


                                <!-- ========================= -->
                                <!-- STUDENTS -->
                                <!-- ========================= -->

                                <a href="<%= context%>/instructor/students?courseId=<%= course.getId()%>"
                                   class="btn
                                          btn-sm
                                          btn-outline-info
                                          rounded-pill">

                                    <i class="bi
                                              bi-people
                                              me-1">
                                    </i>

                                    Học viên

                                </a>


                                <!-- ========================= -->
                                <!-- DRAFT -->
                                <!-- ========================= -->

                                <%
                                    if ("DRAFT".equals(
                                            course.getStatus())) {
                                %>


                                <!-- EDIT COURSE -->

                                <a href="<%= context%>/instructor/course?view=edit&id=<%= course.getId()%>"
                                   class="btn
                                          btn-sm
                                          btn-outline-primary
                                          rounded-pill">

                                    <i class="bi
                                              bi-pencil
                                              me-1">
                                    </i>

                                    Chỉnh sửa

                                </a>


                                <!-- SUBMIT COURSE -->

                                <form method="post"
                                      action="<%= context%>/instructor/course/submit"
                                      class="d-inline"
                                      onsubmit="return confirm('Gửi khóa học này để Admin duyệt?');">


                                    <input type="hidden"
                                           name="courseId"
                                           value="<%= course.getId()%>">


                                    <button type="submit"
                                            class="btn
                                                   btn-sm
                                                   btn-success
                                                   rounded-pill">

                                        <i class="bi
                                                  bi-send
                                                  me-1">
                                        </i>

                                        Gửi duyệt

                                    </button>


                                </form>


                                <%
                                    }
                                %>


                                <!-- ========================= -->
                                <!-- PENDING APPROVAL -->
                                <!-- ========================= -->

                                <%
                                    if ("PENDING_APPROVAL".equals(
                                            course.getStatus())) {
                                %>


                                <span class="badge
                                             text-bg-warning
                                             align-self-center
                                             py-2">

                                    <i class="bi
                                              bi-hourglass-split
                                              me-1">
                                    </i>

                                    Đang chờ duyệt

                                </span>


                                <%
                                    }
                                %>


                                <!-- ========================= -->
                                <!-- PUBLISHED -->
                                <!-- ========================= -->

                                <%
                                    if ("PUBLISHED".equals(
                                            course.getStatus())) {
                                %>


                                <!-- ARCHIVE -->

                                <form method="post"
                                      action="<%= context%>/instructor/course?action=archive"
                                      class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc muốn lưu trữ khóa học này?');">


                                    <input type="hidden"
                                           name="id"
                                           value="<%= course.getId()%>">


                                    <button type="submit"
                                            class="btn
                                                   btn-sm
                                                   btn-outline-danger
                                                   rounded-pill">

                                        <i class="bi
                                                  bi-archive
                                                  me-1">
                                        </i>

                                        Archive

                                    </button>


                                </form>


                                <!-- REOPEN -->

                                <%
                                    if (course
                                            .getEnrollmentCount()
                                            == 0) {
                                %>


                                <form method="post"
                                      action="<%= context%>/instructor/course?action=reopen"
                                      class="d-inline"
                                      onsubmit="return confirm('Mở khóa học này về DRAFT để chỉnh sửa?');">


                                    <input type="hidden"
                                           name="id"
                                           value="<%= course.getId()%>">


                                    <button type="submit"
                                            class="btn
                                                   btn-sm
                                                   btn-outline-primary
                                                   rounded-pill">

                                        <i class="bi
                                                  bi-arrow-counterclockwise
                                                  me-1">
                                        </i>

                                        Reopen

                                    </button>


                                </form>


                                <%
                                    } else {
                                %>


                                <span class="badge
                                             text-bg-light
                                             border
                                             align-self-center
                                             py-2">

                                    <i class="bi
                                              bi-people
                                              me-1">
                                    </i>

                                    Đã có học viên

                                </span>


                                <%
                                        }
                                    }
                                %>


                                <!-- ========================= -->
                                <!-- ARCHIVED -->
                                <!-- ========================= -->

                                <%
                                    if ("ARCHIVED".equals(
                                            course.getStatus())) {
                                %>


                                <span class="badge
                                             text-bg-dark
                                             align-self-center
                                             py-2">

                                    <i class="bi
                                              bi-archive
                                              me-1">
                                    </i>

                                    Đã lưu trữ

                                </span>


                                <%
                                    }
                                %>


                                <!-- ========================= -->
                                <!-- SUSPENDED -->
                                <!-- ========================= -->

                                <%
                                    if ("SUSPENDED".equals(
                                            course.getStatus())) {
                                %>


                                <span class="badge
                                             text-bg-danger
                                             align-self-center
                                             py-2">

                                    <i class="bi
                                              bi-exclamation-triangle
                                              me-1">
                                    </i>

                                    Đã tạm ngưng

                                </span>


                                <%
                                    }
                                %>


                            </div>


                        </td>


                    </tr>


                    <%
                        }
                    %>


                </tbody>

            </table>

        </div>

    </div>


    <%
        }
    %>


</main>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>