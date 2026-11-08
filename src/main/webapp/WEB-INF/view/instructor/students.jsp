<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Course" %>
<%@ page import="model.InstructorStudentProgress" %>

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
            = (Course)
                    request.getAttribute("course");

    List<InstructorStudentProgress> students
            = (List<InstructorStudentProgress>)
                    request.getAttribute("students");

    String context
            = request.getContextPath();

    request.setAttribute(
            "pageTitle",
            "Học viên | Ftech Instructor"
    );
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


    <div class="mb-4">

        <div class="small
                    text-body-secondary
                    mb-1">

            HỌC VIÊN KHÓA HỌC

        </div>

        <h1 class="fw-bold mb-2">

            <%= escapeHtml(
                    course.getTitle()
            )%>

        </h1>

        <span class="badge text-bg-secondary">

            Course ID:
            <%= course.getId()%>

        </span>

        <div class="mt-3">
            <a href="<%= context %>/instructor/students?action=export&courseId=<%= course.getId() %>"
               class="btn btn-success d-inline-flex align-items-center gap-2 px-3 py-2 rounded-3 shadow-sm">
                <i class="bi bi-file-earmark-excel-fill fs-5"></i>
                <span>Xuất danh sách học viên Excel (.xlsx)</span>
            </a>
        </div>

    </div>


    <%
        if (students == null
                || students.isEmpty()) {
    %>


    <div class="card
                border-0
                shadow-sm">

        <div class="card-body
                    text-center
                    py-5">

            <i class="bi
                      bi-people
                      fs-1
                      text-body-secondary">
            </i>

            <h2 class="h5 fw-bold mt-3">

                Chưa có học viên

            </h2>

            <p class="text-body-secondary mb-0">

                Khóa học này chưa có học viên đăng ký.

            </p>

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
                            Học viên
                        </th>

                        <th class="py-3">
                            Trạng thái
                        </th>

                        <th class="py-3">
                            Lesson
                        </th>

                        <th class="py-3">
                            Quiz
                        </th>

                        <th class="py-3">
                            Tiến độ
                        </th>

                        <th class="py-3 px-4">
                            Hoàn thành
                        </th>

                    </tr>

                </thead>


                <tbody>

                    <%
                        for (InstructorStudentProgress student
                                : students) {

                            String progress
                                    = student
                                            .getProgressPercent()
                                    == null
                                    ? "0.00"
                                    : student
                                            .getProgressPercent()
                                            .toPlainString();
                    %>


                    <tr>

                        <td class="px-4">

                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        student.getFullName()
                                )%>

                            </div>

                            <div class="small
                                        text-body-secondary">

                                <%= escapeHtml(
                                        student.getEmail()
                                )%>

                            </div>

                        </td>


                        <td>

                            <%
                                if ("ACTIVE".equals(
                                        student
                                                .getAccessStatus())) {
                            %>

                            <span class="badge
                                         text-bg-success">

                                ACTIVE

                            </span>

                            <%
                                } else if ("REVOKED".equals(
                                        student
                                                .getAccessStatus())) {
                            %>

                            <span class="badge
                                         text-bg-danger">

                                REVOKED

                            </span>

                            <%
                                } else {
                            %>

                            <span class="badge
                                         text-bg-warning">

                                <%= escapeHtml(
                                        student
                                                .getAccessStatus()
                                )%>

                            </span>

                            <%
                                }
                            %>

                        </td>


                        <td>

                            <%= student
                                    .getCompletedRequiredLessons()%>
                            /
                            <%= student
                                    .getTotalRequiredLessons()%>

                        </td>


                        <td>

                            <%= student
                                    .getPassedRequiredQuizzes()%>
                            /
                            <%= student
                                    .getTotalRequiredQuizzes()%>

                        </td>


                        <td style="min-width: 180px;">

                            <div class="d-flex
                                        justify-content-between
                                        small
                                        mb-1">

                                <span>
                                    Tiến độ
                                </span>

                                <span class="fw-semibold">

                                    <%= progress%>%

                                </span>

                            </div>


                            <div class="progress"
                                 style="height: 8px;">

                                <div class="progress-bar"
                                     role="progressbar"
                                     style="width: <%= progress%>%;"
                                     aria-valuenow="<%= progress%>"
                                     aria-valuemin="0"
                                     aria-valuemax="100">
                                </div>

                            </div>

                        </td>


                        <td class="px-4">

                            <%
                                if (student
                                        .isEligibleForCompletion()) {
                            %>

                            <span class="badge
                                         text-bg-success">

                                <i class="bi
                                          bi-check-circle
                                          me-1">
                                </i>

                                Đủ điều kiện

                            </span>

                            <%
                                } else {
                            %>

                            <span class="badge
                                         text-bg-light
                                         border">

                                Đang học

                            </span>

                            <%
                                }
                            %>

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