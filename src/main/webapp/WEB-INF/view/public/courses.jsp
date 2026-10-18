<%-- 
    Document   : course
    Created on : Oct 18, 2026, 5:49:25 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Course"%>
<%@page import="model.Category"%>

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
    List<Course> list = (List<Course>) request.getAttribute("list");
    List<Category> categories
            = (List<Category>) request.getAttribute("categories");

    String keyword = (String) request.getAttribute("keyword");
    String pricingType = (String) request.getAttribute("pricingType");
    long categoryId = (Long) request.getAttribute("categoryId");

    String contextPath = request.getContextPath();

    NumberFormat moneyFormat
            = NumberFormat.getIntegerInstance(new Locale("vi", "VN"));
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>

<style>
    .catalog-hero {
        background: linear-gradient(120deg, #16386d, #34216b);
    }

    .catalog-accent {
        color: #b795ff;
    }

    .catalog-filter {
        --bs-btn-color: var(--bs-secondary-color);
        --bs-btn-border-color: var(--bs-border-color);
        --bs-btn-hover-color: #fff;
        --bs-btn-hover-bg: #7952b3;
        --bs-btn-hover-border-color: #7952b3;
    }

    .catalog-filter.active,
    .catalog-primary {
        background-color: #7952b3;
        border-color: #7952b3;
        color: #fff;
    }

    .catalog-primary:hover {
        background-color: #68449c;
        border-color: #68449c;
        color: #fff;
    }

    .course-card {
        transition: transform .2s, border-color .2s;
    }

    .course-card:hover {
        transform: translateY(-4px);
        border-color: #a879ef !important;
    }

    .course-image {
        width: 100%;
        aspect-ratio: 16 / 9;
        object-fit: cover;
    }

    .course-title {
        min-height: 3rem;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .catalog-category {
        background: rgba(153, 102, 255, .12);
        color: #b795ff;
    }
</style>

<main class="container-xl py-4 py-lg-5">

    <section class="catalog-hero rounded-4 p-4 p-lg-5 mb-4 text-white">
        <div class="row align-items-center g-3">
            <div class="col-md-9">
                <h1 class="fw-bold mb-3">Khám phá khóa học</h1>
                <p class="mb-0 fs-5 text-white-50">
                    Học kiến thức mới, phát triển kỹ năng theo cách của bạn.
                </p>
            </div>

            <div class="col-md-3 text-center d-none d-md-block">
                <i class="bi bi-book display-1"></i>
            </div>
        </div>
    </section>

    <form action="<%= contextPath %>/courses" method="get" class="mb-4">

        <div class="d-flex flex-wrap gap-2 mb-3">
            <button type="submit"
                    name="categoryId"
                    value="0"
                    class="btn catalog-filter rounded-pill px-3 <%= categoryId == 0 ? "active" : "" %>">
                <i class="bi bi-grid me-1"></i>
                Tất cả
            </button>

            <% for (Category category : categories) { %>

            <button type="submit"
                    name="categoryId"
                    value="<%= category.getId() %>"
                    class="btn catalog-filter rounded-pill px-3 <%= categoryId == category.getId() ? "active" : "" %>">
                <%= escape(category.getName()) %>
            </button>

            <% } %>
        </div>

        <div class="row g-3">
            <div class="col-lg-6">
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-search"></i>
                    </span>

                    <input type="search"
                           name="keyword"
                           class="form-control"
                           value="<%= escape(keyword) %>"
                           placeholder="Bạn muốn học gì hôm nay?">
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <select name="pricingType" class="form-select">
                    <option value="">Tất cả học phí</option>

                    <option value="FREE"
                            <%= "FREE".equals(pricingType) ? "selected" : "" %>>
                        Miễn phí
                    </option>

                    <option value="PAID"
                            <%= "PAID".equals(pricingType) ? "selected" : "" %>>
                        Có phí
                    </option>
                </select>
            </div>

            <div class="col-sm-6 col-lg-3">
                <button type="submit"
                        name="categoryId"
                        value="<%= categoryId %>"
                        class="btn catalog-primary w-100">
                    <i class="bi bi-funnel me-1"></i>
                    Tìm khóa học
                </button>
            </div>
        </div>
    </form>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="h4 fw-bold mb-0">Khóa học dành cho bạn</h2>

        <span class="text-body-secondary small">
            <%= list.size() %> khóa học
        </span>
    </div>

    <% if (list.isEmpty()) { %>

    <div class="border rounded-4 text-center py-5">
        <i class="bi bi-search display-5 text-body-secondary"></i>

        <h3 class="h5 mt-3">
            Chưa tìm thấy khóa học phù hợp
        </h3>

        <p class="text-body-secondary">
            Thử đổi từ khóa hoặc chọn danh mục khác.
        </p>

        <a href="<%= contextPath %>/courses"
           class="btn catalog-primary">
            Xóa bộ lọc
        </a>
    </div>

    <% } else { %>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">

        <% for (Course course : list) {
            boolean free = "FREE".equals(course.getPricingType());

            BigDecimal price = course.getSalePrice() != null
                    ? course.getSalePrice()
                    : course.getListPrice();

            boolean discounted = !free
                    && price.compareTo(course.getListPrice()) < 0;

            String imageUrl = course.getThumbnailUrl();

            boolean hasImage = imageUrl != null
                    && (imageUrl.startsWith("https://")
                    || imageUrl.startsWith("http://"));
        %>

        <div class="col">
            <article class="card course-card h-100 rounded-4 overflow-hidden">

                <div class="position-relative">

                    <% if (hasImage) { %>

                    <img src="<%= escape(imageUrl) %>"
                         class="course-image"
                         alt="<%= escape(course.getTitle()) %>"
                         loading="lazy">

                    <% } else { %>

                    <div class="course-image bg-body-tertiary d-flex align-items-center justify-content-center">
                        <i class="bi bi-book display-3 catalog-accent"></i>
                    </div>

                    <% } %>

                    <span class="badge rounded-pill position-absolute top-0 start-0 m-3 <%= free ? "text-bg-success" : "text-bg-primary" %>">
                        <%= free ? "Miễn phí" : "Có phí" %>
                    </span>
                </div>

                <div class="card-body d-flex flex-column p-3 p-xl-4">

                    <div class="mb-3">
                        <span class="badge catalog-category text-wrap text-start">
                            <%= escape(course.getCategoryName()) %>
                        </span>
                    </div>

                    <h3 class="h5 fw-bold course-title mb-3">
                        <%= escape(course.getTitle()) %>
                    </h3>

                    <p class="text-body-secondary small mb-3">
                        <i class="bi bi-person-circle me-2"></i>
                        <%= escape(course.getInstructorName()) %>
                    </p>

                    <div class="d-flex flex-wrap gap-3 small text-body-secondary mb-4">
                        <span>
                            <i class="bi bi-collection-play me-1"></i>
                            <%= course.getLessonCount() %> bài học
                        </span>

                        <span>
                            <i class="bi bi-clock me-1"></i>
                            <%= course.getEstimatedHours() %> giờ
                        </span>
                    </div>

                    <div class="mt-auto pt-3 border-top">

                        <% if (free) { %>

                        <div class="text-success fw-bold fs-5 mb-3">
                            Miễn phí
                        </div>

                        <% } else { %>

                        <div class="d-flex flex-wrap align-items-center gap-2 mb-3">

                            <% if (discounted) { %>

                            <del class="small text-body-secondary">
                                <%= moneyFormat.format(course.getListPrice()) %>đ
                            </del>

                            <% } %>

                            <span class="catalog-accent fw-bold fs-5">
                                <%= moneyFormat.format(price) %>đ
                            </span>
                        </div>

                        <% } %>

                        <button type="button"
                                class="btn btn-outline-secondary w-100"
                                disabled>
                            Chi tiết sẽ được bổ sung
                            <i class="bi bi-arrow-right ms-1"></i>
                        </button>
                    </div>
                </div>
            </article>
        </div>

        <% } %>

    </div>

    <% } %>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>