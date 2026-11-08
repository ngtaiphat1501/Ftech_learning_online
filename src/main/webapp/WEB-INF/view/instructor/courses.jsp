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
        java.math.BigDecimal totalRev = (java.math.BigDecimal) request.getAttribute("totalRevenue");
        java.math.BigDecimal balVnd = (java.math.BigDecimal) request.getAttribute("balanceVnd");
        Integer totalStu = (Integer) request.getAttribute("totalStudents");
        Integer pubCount = (Integer) request.getAttribute("publishedCount");

        long totalRevVal = totalRev != null ? totalRev.longValue() : 0L;
        long balVal = balVnd != null ? balVnd.longValue() : 0L;
        int totalStuVal = totalStu != null ? totalStu : 0;
        int pubCountVal = pubCount != null ? pubCount : 0;
    %>

    <!-- KPI STATS CARDS -->
    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                    <div class="rounded-4 bg-success-subtle text-success p-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                        <i class="bi bi-cash-stack fs-3"></i>
                    </div>
                    <div>
                        <div class="text-body-secondary small fw-medium">Tổng doanh thu bán</div>
                        <div class="fs-4 fw-bold text-success"><%= String.format("%,d đ", totalRevVal) %></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                    <div class="rounded-4 bg-primary-subtle text-primary p-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                        <i class="bi bi-wallet2 fs-3"></i>
                    </div>
                    <div>
                        <div class="text-body-secondary small fw-medium">Số dư ví giảng viên</div>
                        <div class="fs-4 fw-bold text-primary"><%= String.format("%,d đ", balVal) %></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                    <div class="rounded-4 bg-info-subtle text-info p-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                        <i class="bi bi-people-fill fs-3"></i>
                    </div>
                    <div>
                        <div class="text-body-secondary small fw-medium">Tổng lượt học viên</div>
                        <div class="fs-4 fw-bold text-body-emphasis"><%= totalStuVal %></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                    <div class="rounded-4 bg-warning-subtle text-warning p-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                        <i class="bi bi-journal-check fs-3"></i>
                    </div>
                    <div>
                        <div class="text-body-secondary small fw-medium">Khóa học mở bán</div>
                        <div class="fs-4 fw-bold text-body-emphasis"><%= pubCountVal %></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

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

                        <th class="py-3">
                            Doanh thu
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

                        <td>
                            <span class="text-success fw-bold">
                                <%= course.getRevenueVnd() != null ? String.format("%,d đ", course.getRevenueVnd().longValue()) : "0 đ" %>
                            </span>
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

<a href="<%= context%>/instructor/quiz?courseId=<%= course.getId()%>"
                                   class="btn
                                          btn-sm
                                          btn-outline-warning
                                          rounded-pill">

                                    <i class="bi
                                              bi-patch-question
                                              me-1">
                                    </i>

                                    Đề thi

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