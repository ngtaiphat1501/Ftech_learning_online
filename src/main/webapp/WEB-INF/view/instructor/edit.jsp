<%@ page pageEncoding="UTF-8" %>
<%@ page import="model.Course, model.Category, java.util.List" %>

<%!
    private String esc(Object input) {
        if (input == null) return "";

        return String.valueOf(input)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    Course course =
            (Course) request.getAttribute("course");

    if (course == null) {
        response.sendError(404);
        return;
    }

    String context =
            request.getContextPath();

    boolean paid =
            "PAID".equals(
                    course.getPricingType()
            );

    request.setAttribute(
            "pageTitle",
            "Sửa khóa học | Ftech Instructor"
    );
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">

    <div class="row justify-content-center">

        <div class="col-lg-9">

            <div class="mb-4">

                <a href="<%= context %>/instructor/courses"
                   class="text-decoration-none">
                    ← Quay lại khóa học
                </a>

                <h1 class="fw-bold mt-3">
                    Sửa khóa học
                </h1>

                <p class="text-body-secondary">
                    Course ID:
                    <%= course.getId() %>
                </p>

            </div>

            <div class="card border-0 shadow-sm">

                <div class="card-body p-4 p-lg-5">

                    <form method="post"
                          action="<%= context %>/instructor/course?action=edit">

                        <input type="hidden"
                               name="courseId"
                               value="<%= course.getId() %>">

                        <div class="mb-3">

                            <label class="form-label fw-semibold">
                                Tên khóa học
                            </label>

                            <input type="text"
                                   class="form-control"
                                   name="title"
                                   required
                                   maxlength="200"
                                   value="<%= esc(course.getTitle()) %>">

                        </div>

                        <div class="mb-3">

                            <label class="form-label fw-semibold">
                                Slug
                            </label>

                            <input type="text"
                                   class="form-control"
                                   name="slug"
                                   required
                                   maxlength="220"
                                   pattern="[a-z0-9]+(?:-[a-z0-9]+)*"
                                   value="<%= esc(course.getSlug()) %>">

                        </div>

                        <div class="mb-3">

                            <label class="form-label fw-semibold">
                                Danh mục
                            </label>

                            <select class="form-select"
                                    name="categoryId"
                                    required>
                                <%
                                    List<Category> categories = (List<Category>) request.getAttribute("categories");
                                    if (categories != null) {
                                        for (Category cat : categories) {
                                            boolean selected = cat.getId() == course.getCategoryId();
                                %>
                                <option value="<%= cat.getId() %>" <%= selected ? "selected" : "" %>><%= esc(cat.getName()) %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>

                        </div>

                        <div class="mb-4">

                            <label class="form-label fw-semibold">
                                Mô tả
                            </label>

                            <textarea class="form-control"
                                      name="description"
                                      rows="7"
                                      required><%= esc(course.getDescription()) %></textarea>

                        </div>

                        <div class="mb-3">

                            <label class="form-label fw-semibold">
                                Hình thức
                            </label>

                            <div>

                                <label class="me-4">

                                    <input type="radio"
                                           name="pricingType"
                                           value="FREE"
                                           <%= paid ? "" : "checked" %>>

                                    Miễn phí

                                </label>

                                <label>

                                    <input type="radio"
                                           name="pricingType"
                                           value="PAID"
                                           <%= paid ? "checked" : "" %>>

                                    Trả phí

                                </label>

                            </div>

                        </div>

                        <div class="row g-3">

                            <div class="col-md-6">

                                <label class="form-label fw-semibold">
                                    Giá niêm yết
                                </label>

                                <input type="number"
                                       class="form-control"
                                       id="listPriceVnd"
                                       name="listPriceVnd"
                                       min="0"
                                       value="<%=
                                           course.getListPrice() == null
                                           ? "0"
                                           : course.getListPrice().toPlainString()
                                       %>">

                            </div>

                            <div class="col-md-6">

                                <label class="form-label fw-semibold">
                                    Giá ưu đãi
                                </label>

                                <input type="number"
                                       class="form-control"
                                       id="salePriceVnd"
                                       name="salePriceVnd"
                                       min="0"
                                       value="<%=
                                           course.getSalePrice() == null
                                           ? ""
                                           : course.getSalePrice().toPlainString()
                                       %>">

                            </div>

                        </div>

                        <div class="d-flex gap-2 mt-4">

                            <button type="submit"
                                    class="btn btn-primary px-4">
                                Lưu thay đổi
                            </button>

                            <a href="<%= context %>/instructor/courses"
                               class="btn btn-outline-secondary px-4">
                                Hủy
                            </a>

                        </div>

                    </form>

                </div>

            </div>

        </div>

    </div>

</main>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>