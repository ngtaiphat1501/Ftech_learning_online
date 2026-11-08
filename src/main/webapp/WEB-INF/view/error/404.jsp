<%@ page pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "404 - Không tìm thấy trang | Ftech");
    String contextPath = request.getContextPath();
    String errorMsg = (String) request.getAttribute("jakarta.servlet.error.message");
    if (errorMsg == null || errorMsg.isBlank()) {
        errorMsg = "Trang bạn đang tìm kiếm không tồn tại hoặc đã được chuyển sang địa chỉ khác.";
    }
%>
<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<div class="container py-5 my-5 text-center" style="max-width: 650px;">
    <div class="p-5 rounded-4 shadow-lg border border-secondary border-opacity-25" style="background: radial-gradient(circle at top, #1e293b 0%, #0f172a 100%);">
        <div class="mb-4">
            <span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 90px; height: 90px; background: rgba(59, 130, 246, 0.15); border: 2px solid rgba(59, 130, 246, 0.3);">
                <i class="bi bi-compass text-primary" style="font-size: 2.8rem;"></i>
            </span>
        </div>
        <span class="badge bg-primary-subtle text-primary px-3 py-2 rounded-pill fw-semibold mb-3">HTTP 404 • NOT FOUND</span>
        <h1 class="h2 fw-bold text-white mb-3">Không tìm thấy trang</h1>
        <p class="text-secondary fs-6 mb-4" style="line-height: 1.6;">
            <%= errorMsg %>
        </p>
        <div class="d-flex flex-wrap justify-content-center gap-3 pt-2">
            <button type="button" onclick="window.history.back()" class="btn btn-outline-light rounded-pill px-4 py-2">
                <i class="bi bi-arrow-left me-2"></i>Quay lại trang trước
            </button>
            <a href="<%= contextPath %>/home" class="btn btn-primary rounded-pill px-4 py-2">
                <i class="bi bi-house-door me-2"></i>Về trang chủ
            </a>
            <a href="<%= contextPath %>/courses" class="btn btn-outline-secondary rounded-pill px-4 py-2">
                <i class="bi bi-search me-2"></i>Khám phá khóa học
            </a>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>
