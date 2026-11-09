<%@ page pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "400 - Yêu cầu không hợp lệ | Ftech");
    String contextPath = request.getContextPath();
    String errorMsg = (String) request.getAttribute("jakarta.servlet.error.message");
    if (errorMsg == null || errorMsg.isBlank()) {
        errorMsg = "Yêu cầu từ trình duyệt không hợp lệ hoặc thiếu thông tin cần thiết.";
    }
%>
<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .error-page-container {
        min-height: 70vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 3rem 1rem;
    }
    .error-card {
        background-color: var(--ftech-card-bg, #151821);
        border: 1px solid var(--ftech-card-border, rgba(255, 255, 255, 0.1));
        border-radius: 1.5rem;
        padding: 3rem 2.5rem;
        max-width: 620px;
        width: 100%;
        color: var(--ftech-text-main, #ffffff);
    }
    [data-bs-theme="light"] .error-card {
        background-color: #ffffff !important;
        border-color: rgba(0, 0, 0, 0.08) !important;
        color: #0f172a !important;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.06);
    }
    .error-icon-box {
        width: 88px;
        height: 88px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 1.5rem;
        background: rgba(234, 179, 8, 0.12);
        border: 2px solid rgba(234, 179, 8, 0.3);
    }
</style>

<main class="container error-page-container">
    <div class="error-card text-center shadow-lg">
        <div class="error-icon-box">
            <i class="bi bi-exclamation-octagon text-warning" style="font-size: 2.8rem;"></i>
        </div>
        <div>
            <span class="badge bg-warning-subtle text-warning px-3 py-2 rounded-pill fw-semibold mb-3">HTTP 400 • BAD REQUEST</span>
        </div>
        <h1 class="h2 fw-bold mb-3">Yêu cầu không hợp lệ</h1>
        <p class="text-secondary fs-6 mb-4" style="line-height: 1.6;">
            <%= errorMsg %>
        </p>
        <div class="d-flex flex-wrap justify-content-center gap-3 pt-2">
            <button type="button" onclick="window.history.back()" class="btn btn-outline-secondary rounded-pill px-4 py-2">
                <i class="bi bi-arrow-left me-2"></i>Quay lại trang trước
            </button>
            <a href="<%= contextPath %>/home" class="btn btn-primary rounded-pill px-4 py-2">
                <i class="bi bi-house-door me-2"></i>Về trang chủ
            </a>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>
