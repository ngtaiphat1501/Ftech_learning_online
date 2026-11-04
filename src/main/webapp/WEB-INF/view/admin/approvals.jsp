<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="model.ApprovalCourse" %>

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
    List<ApprovalCourse> courses
            = (List<ApprovalCourse>)
                    request.getAttribute("courses");

    DecimalFormat money
            = new DecimalFormat("#,###");

    String context
            = request.getContextPath();

    request.setAttribute(
            "pageTitle",
            "Khóa học chờ duyệt | Ftech Admin"
    );
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">

    <div class="mb-4">

        <div class="small
                    text-body-secondary
                    mb-1">

            ADMIN

        </div>

        <h1 class="fw-bold mb-2">

            Khóa học chờ duyệt

        </h1>

        <p class="text-body-secondary mb-0">

            Danh sách khóa học đang ở trạng thái
            PENDING_APPROVAL.

        </p>

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
                      bi-check2-circle
                      fs-1
                      text-body-secondary">
            </i>

            <h2 class="h5
                       fw-bold
                       mt-3">

                Không có khóa học chờ duyệt

            </h2>

            <p class="text-body-secondary
                      mb-0">

                Hiện tại không có yêu cầu duyệt mới.

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
                            Course
                        </th>

                        <th class="py-3">
                            Instructor
                        </th>

                        <th class="py-3">
                            Giá
                        </th>

                        <th class="py-3">
                            Trạng thái
                        </th>

                        <th class="py-3 px-4">
                            Gửi duyệt
                        </th>

                    </tr>

                </thead>


                <tbody>

                    <%
                        for (ApprovalCourse course
                                : courses) {
                    %>


                    <tr>


                        <td class="px-4">

                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        course.getTitle()
                                )%>

                            </div>

                            <div class="small
                                        text-body-secondary">

                                Course ID:
                                <%= course.getCourseId()%>

                            </div>

                        </td>


                        <td>

                            <div class="fw-semibold">

                                <%= escapeHtml(
                                        course.getInstructorName()
                                )%>

                            </div>

                            <div class="small
                                        text-body-secondary">

                                <%= escapeHtml(
                                        course.getInstructorEmail()
                                )%>

                            </div>

                        </td>


                        <td>

                            <%
                                if ("FREE".equals(
                                        course.getPricingType())) {
                            %>

                            <span class="badge
                                         text-bg-success">

                                FREE

                            </span>

                            <%
                                } else {
                            %>

                            <div class="fw-semibold">

                                <%
                                    if (course
                                            .getProposedPriceVnd()
                                            != null) {
                                %>

                                <%= money.format(
                                        course
                                                .getProposedPriceVnd()
                                )%>
                                đ

                                <%
                                    } else if (course
                                            .getSalePriceVnd()
                                            != null) {
                                %>

                                <%= money.format(
                                        course
                                                .getSalePriceVnd()
                                )%>
                                đ

                                <%
                                    } else {
                                %>

                                <%= money.format(
                                        course
                                                .getListPriceVnd()
                                )%>
                                đ

                                <%
                                    }
                                %>

                            </div>

                            <div class="small
                                        text-body-secondary">

                                PAID

                            </div>

                            <%
                                }
                            %>

                        </td>


                        <td>

                            <span class="badge
                                         text-bg-warning">

                                PENDING_APPROVAL

                            </span>

                        </td>


                        <td class="px-4">

                            <%
                                if (course
                                        .getSubmittedAt()
                                        != null) {
                            %>

                            <div class="small">

                                <%= course
                                        .getSubmittedAt()%>

                            </div>

                            <%
                                } else {
                            %>

                            <span class="text-body-secondary">

                                -

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