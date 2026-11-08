<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Certificate"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    Certificate cert = (Certificate) request.getAttribute("certificate");
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
    String issuedDate = cert.getIssuedAt() != null ? df.format(cert.getIssuedAt()) : "";
    String contextPath = request.getContextPath();
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>

<style>
    .cert-wrapper {
        max-width: 960px;
        margin: 40px auto;
        background: #fff;
        color: #1a202c;
        border: 12px solid #1a365d;
        border-image: linear-gradient(to bottom right, #d4af37, #1a365d, #d4af37) 1;
        padding: 50px 60px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.25);
        position: relative;
        text-align: center;
        background-color: #fdfbf7;
    }
    .cert-inner-border {
        border: 2px dashed #d4af37;
        padding: 40px 30px;
        position: relative;
    }
    .cert-badge {
        width: 90px;
        height: 90px;
        background: radial-gradient(circle, #f6e05e, #d69e2e);
        color: #744210;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 2.2rem;
        box-shadow: 0 4px 10px rgba(214, 158, 46, 0.4);
        margin-bottom: 15px;
    }
    .cert-academy {
        letter-spacing: 4px;
        font-weight: 700;
        font-size: 1.1rem;
        color: #2b6cb0;
        text-transform: uppercase;
    }
    .cert-title {
        font-family: 'Georgia', serif;
        font-size: 2.3rem;
        font-weight: bold;
        color: #1a365d;
        margin: 15px 0 25px 0;
        text-transform: uppercase;
        letter-spacing: 2px;
    }
    .cert-recipient {
        font-family: 'Georgia', serif;
        font-size: 2.2rem;
        font-weight: bold;
        color: #b7791f;
        border-bottom: 2px solid #ecc94b;
        display: inline-block;
        padding: 0 40px 10px 40px;
        margin: 15px 0 20px 0;
    }
    .cert-course {
        font-size: 1.4rem;
        font-weight: 600;
        color: #2d3748;
        margin: 15px 0 35px 0;
    }
    .cert-signatures {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-top: 50px;
        padding: 0 20px;
    }
    .sig-line {
        border-top: 1px solid #718096;
        width: 220px;
        padding-top: 8px;
        font-weight: 600;
        font-size: 0.95rem;
    }
    .cert-seal {
        border: 2px solid #b7791f;
        border-radius: 50%;
        width: 100px;
        height: 100px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #b7791f;
        font-weight: bold;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    @media print {
        body * {
            visibility: hidden;
        }
        .cert-wrapper, .cert-wrapper * {
            visibility: visible;
        }
        .cert-wrapper {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            margin: 0;
            box-shadow: none;
            border-width: 8px;
        }
        .no-print {
            display: none !important;
        }
    }
</style>

<main class="container py-4">
    <!-- Action buttons bar (hidden on print) -->
    <div class="d-flex justify-content-between align-items-center mb-4 no-print flex-wrap gap-2">
        <a href="<%= contextPath %>/student/courses" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Khóa học của tôi
        </a>
        <div class="d-flex gap-2">
            <button onclick="window.print()" class="btn btn-primary">
                <i class="bi bi-printer me-1"></i> In / Tải chứng chỉ (PDF)
            </button>
            <a href="<%= contextPath %>/course?id=<%= cert.getCourseId() %>" class="btn btn-outline-primary">
                <i class="bi bi-book me-1"></i> Xem thông tin khóa học
            </a>
        </div>
    </div>

    <!-- The Certificate Document -->
    <div class="cert-wrapper">
        <div class="cert-inner-border">
            <div class="cert-badge">
                <i class="bi bi-award-fill"></i>
            </div>
            <div class="cert-academy">LEARNORA EDUCATION PLATFORM</div>
            <h1 class="cert-title">CHỨNG NHẬN HOÀN THÀNH KHÓA HỌC</h1>
            <p class="text-muted mb-1" style="font-size: 1.05rem;">Chứng nhận trao cho học viên</p>
            
            <div class="cert-recipient"><%= cert.getStudentName() %></div>
            
            <p class="text-muted mb-1" style="font-size: 1.05rem;">Đã hoàn thành xuất sắc chương trình đào tạo</p>
            <div class="cert-course">"<%= cert.getCourseTitle() %>"</div>

            <div class="d-flex justify-content-center gap-4 text-muted small my-3">
                <span><i class="bi bi-calendar-check me-1"></i> Ngày cấp: <strong><%= issuedDate %></strong></span>
                <span><i class="bi bi-shield-check text-success me-1"></i> Mã chứng chỉ: <strong class="font-monospace"><%= cert.getCertificateCode() %></strong></span>
                <span><i class="bi bi-check-circle-fill text-success me-1"></i> Trạng thái: <strong>Hợp lệ</strong></span>
            </div>

            <div class="cert-signatures">
                <div class="text-center">
                    <div style="font-family: 'Brush Script MT', cursive; font-size: 1.8rem; color: #2c5282; margin-bottom: 5px;">
                        <%= cert.getInstructorName() %>
                    </div>
                    <div class="sig-line">
                        <%= cert.getInstructorName() %><br>
                        <span class="text-muted small fw-normal">Giảng viên chuyên môn</span>
                    </div>
                </div>

                <div class="cert-seal">
                    LEARNORA<br>VERIFIED
                </div>

                <div class="text-center">
                    <div style="font-family: 'Brush Script MT', cursive; font-size: 1.8rem; color: #2c5282; margin-bottom: 5px;">
                        Learnora Academic Board
                    </div>
                    <div class="sig-line">
                        Hội đồng Đào tạo<br>
                        <span class="text-muted small fw-normal">Learnora LMS</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>
