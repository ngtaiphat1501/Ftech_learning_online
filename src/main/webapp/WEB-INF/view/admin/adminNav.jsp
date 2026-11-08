<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentAdminTab = (String) request.getAttribute("adminTab");
    if (currentAdminTab == null) currentAdminTab = "";
%>

<div class="border-bottom border-secondary border-opacity-25 bg-dark-subtle py-3 mb-4">
    <div class="container d-flex flex-wrap align-items-center justify-content-between gap-3">
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3 py-1.5 fw-semibold">
                <i class="bi bi-shield-lock-fill me-1"></i>Khu vực Quản trị (Admin)
            </span>
            <span class="text-secondary small d-none d-md-inline">Hệ thống quản lý Learnora LMS</span>
        </div>

        <nav class="nav nav-pills gap-1">
            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "dashboard".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2 me-1"></i>Tổng quan
            </a>

            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "approvals".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/approvals">
                <i class="bi bi-patch-check me-1"></i>Duyệt khóa học
            </a>

            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "categories".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/category">
                <i class="bi bi-tags me-1"></i>Danh mục
            </a>

            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "users".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people me-1"></i>Người dùng & Quyền
            </a>

            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "moderation".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/moderation">
                <i class="bi bi-shield-check me-1"></i>Kiểm duyệt
            </a>

            <a class="nav-link rounded-pill px-3 py-1.5 small <%= "orders".equals(currentAdminTab) ? "active bg-primary" : "text-light" %>"
               href="${pageContext.request.contextPath}/admin/orders">
                <i class="bi bi-receipt me-1"></i>Đơn hàng
            </a>
        </nav>
    </div>
</div>

<%-- Alert notifications --%>
<%
    String msg = request.getParameter("msg");
    String err = request.getParameter("error");
%>
<% if (msg != null && !msg.isBlank()) { %>
    <div class="container mb-3">
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </div>
<% } %>

<% if (err != null && !err.isBlank()) { %>
    <div class="container mb-3">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= err %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </div>
<% } %>
