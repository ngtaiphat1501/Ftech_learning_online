<%@ page pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "403 - Quyền truy cập bị từ chối | Ftech");
    String contextPath = request.getContextPath();
    String errorMsg = (String) request.getAttribute("jakarta.servlet.error.message");
    if (errorMsg == null || errorMsg.isBlank()) {
        errorMsg = "Bạn không có quyền thực hiện thao tác hoặc truy cập vào tài nguyên này.";
    }
%>
<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<div class="container py-5 my-5 text-center" style="max-width: 650px;">
    <div class="p-5 rounded-4 shadow-lg border border-secondary border-opacity-25" style="background: radial-gradient(circle at top, #1e293b 0%, #0f172a 100%);">
        <div class="mb-4">
            <span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 90px; height: 90px; background: rgba(239, 68, 68, 0.15); border: 2px solid rgba(239, 68, 68, 0.3);">
                <i class="bi bi-shield-lock-fill text-danger" style="font-size: 2.8rem;"></i>
            </span>
        </div>
        <span class="badge bg-danger-subtle text-danger px-3 py-2 rounded-pill fw-semibold mb-3">HTTP 403 • FORBIDDEN</span>
        <h1 class="h2 fw-bold text-white mb-3">Truy cập bị từ chối</h1>
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
            <a href="<%= contextPath %>/student/courses" class="btn btn-outline-secondary rounded-pill px-4 py-2">
                <i class="bi bi-journal-bookmark me-2"></i>Khóa học của tôi
            </a>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>
