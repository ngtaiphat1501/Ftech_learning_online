<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Certificate"%>
<%@page import="java.time.format.DateTimeFormatter"%>

<%
    Certificate cert = (Certificate) request.getAttribute("cert");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd 'tháng' MM 'năm' yyyy");
    String formattedDate = cert != null && cert.getIssuedAt() != null 
            ? cert.getIssuedAt().format(dtf) 
            : java.time.LocalDate.now().format(dtf);

    String verifyUrl = request.getRequestURL().toString();
    if (request.getQueryString() != null) {
        verifyUrl += "?" + request.getQueryString();
    }
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .cert-page-wrapper {
        padding: 3rem 1rem 5rem 1rem;
        min-height: 85vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }

    /* Classical Diploma / Certificate Container */
    .certificate-frame {
        max-width: 960px;
        width: 100%;
        background: #ffffff;
        color: #1e293b;
        border: 14px solid #1e293b;
        border-radius: 12px;
        position: relative;
        padding: 12px;
        box-shadow: 0 25px 60px rgba(0, 0, 0, 0.45);
        font-family: 'Times New Roman', Times, serif;
    }

    .certificate-inner {
        border: 2px solid #d97706;
        padding: 3.5rem 3rem 2.5rem 3rem;
        position: relative;
        background: radial-gradient(circle at center, #ffffff 60%, #fffbeb 100%);
    }

    /* Ornamental Corner Ribbons */
    .corner-decor {
        position: absolute;
        width: 44px;
        height: 44px;
        border-color: #d97706;
        border-style: solid;
    }
    .corner-tl { top: 8px; left: 8px; border-width: 3px 0 0 3px; }
    .corner-tr { top: 8px; right: 8px; border-width: 3px 3px 0 0; }
    .corner-bl { bottom: 8px; left: 8px; border-width: 0 0 3px 3px; }
    .corner-br { bottom: 8px; right: 8px; border-width: 0 3px 3px 0; }

    /* Academy & Institution Title */
    .cert-institution {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        text-transform: uppercase;
        letter-spacing: 2.5px;
        font-size: 0.95rem;
        font-weight: 700;
        color: #b45309;
        margin-bottom: 0.25rem;
    }

    .cert-subinstitution {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 0.85rem;
        color: #64748b;
        letter-spacing: 1px;
        text-transform: uppercase;
        margin-bottom: 1.5rem;
    }

    .cert-main-title {
        font-size: 2.5rem;
        font-weight: 700;
        color: #0f172a;
        letter-spacing: 2px;
        text-transform: uppercase;
        margin-bottom: 0.5rem;
        line-height: 1.2;
    }

    .cert-subtitle {
        font-style: italic;
        font-size: 1.15rem;
        color: #64748b;
        margin-bottom: 1.5rem;
    }

    .cert-recipient-name {
        font-size: 2.6rem;
        font-weight: bold;
        color: #1e3a8a;
        border-bottom: 2px solid #d97706;
        display: inline-block;
        padding: 0 2rem 0.4rem 2rem;
        margin-bottom: 1.25rem;
        font-family: Georgia, 'Times New Roman', serif;
    }

    .cert-course-title {
        font-size: 1.75rem;
        font-weight: 700;
        color: #0f172a;
        margin: 0.75rem 0 1.25rem 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .cert-description {
        max-width: 680px;
        margin: 0 auto 2.5rem auto;
        font-size: 1rem;
        color: #475569;
        line-height: 1.6;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    /* Red Certified Official Stamp */
    .cert-official-seal {
        width: 105px;
        height: 105px;
        border: 3px double #dc2626;
        border-radius: 50%;
        color: #dc2626;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-transform: uppercase;
        font-size: 0.62rem;
        font-weight: 800;
        transform: rotate(-8deg);
        box-shadow: 0 0 12px rgba(220, 38, 38, 0.2);
        padding: 4px;
        text-align: center;
        margin: 0 auto;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .cert-code-pill {
        font-family: 'Courier New', Courier, monospace;
        background-color: #f1f5f9;
        padding: 0.35rem 1rem;
        border-radius: 999px;
        font-size: 0.85rem;
        color: #334155;
        border: 1px solid #cbd5e1;
        font-weight: 600;
        letter-spacing: 1px;
    }

    /* Signatures Section */
    .cert-signature-name {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-weight: 700;
        font-size: 1rem;
        color: #0f172a;
        margin-top: 0.5rem;
    }
    .cert-signature-role {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 0.8rem;
        color: #64748b;
        text-transform: uppercase;
    }
    .cert-signature-draw {
        font-family: 'Brush Script MT', cursive, sans-serif;
        font-size: 1.8rem;
        color: #1e3a8a;
        height: 38px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    /* Print Controls */
    @media print {
        header, nav, footer, .cert-action-bar, #ftech-meteor-layer {
            display: none !important;
        }
        body {
            background: #ffffff !important;
            padding: 0 !important;
            margin: 0 !important;
        }
        .cert-page-wrapper {
            padding: 0 !important;
            min-height: auto !important;
        }
        .certificate-frame {
            box-shadow: none !important;
            border-width: 8px !important;
            max-width: 100% !important;
            page-break-inside: avoid;
        }
        @page {
            size: A4 landscape;
            margin: 1cm;
        }
    }
</style>

<main class="container cert-page-wrapper">

    <!-- Action Toolbar (Hidden during print) -->
    <div class="cert-action-bar mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3 w-100" style="max-width: 960px;">
        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-outline-secondary rounded-pill px-4 py-2 border-secondary border-opacity-50">
            <i class="bi bi-arrow-left me-1"></i> Khóa học của tôi
        </a>
        <div class="d-flex align-items-center gap-2">
            <button type="button" onclick="window.print()" class="btn btn-primary rounded-pill px-4 py-2 fw-semibold shadow-sm d-flex align-items-center gap-2">
                <i class="bi bi-printer-fill fs-5"></i>
                <span>In chứng chỉ / Lưu PDF</span>
            </button>
            <button type="button" onclick="navigator.clipboard.writeText(window.location.href); alert('Đã sao chép liên kết chứng chỉ!');" class="btn btn-outline-light rounded-pill px-3 py-2" title="Chia sẻ liên kết xác thực">
                <i class="bi bi-share"></i>
            </button>
        </div>
    </div>

    <!-- THE DIPLOMA / CERTIFICATE -->
    <div class="certificate-frame">
        <div class="certificate-inner text-center">

            <!-- Ornamental Corners -->
            <div class="corner-decor corner-tl"></div>
            <div class="corner-decor corner-tr"></div>
            <div class="corner-decor corner-bl"></div>
            <div class="corner-decor corner-br"></div>

            <!-- Institution Brand -->
            <div class="cert-institution">TRƯỜNG ĐẠI HỌC FPT • HỌC VIỆN CÔNG NGHỆ LEARNORA</div>
            <div class="cert-subinstitution">FPT UNIVERSITY - CAN THO CAMPUS • PRJ WEB APPLICATION</div>

            <!-- Crest / Medal Icon -->
            <div class="mb-3">
                <span class="d-inline-flex align-items-center justify-content-center rounded-circle" 
                      style="width: 58px; height: 58px; background: rgba(217, 119, 6, 0.12); border: 2px solid #d97706; color: #d97706; font-size: 1.8rem;">
                    <i class="bi bi-mortarboard-fill"></i>
                </span>
            </div>

            <!-- Title -->
            <div class="cert-main-title">CHỨNG NHẬN HOÀN THÀNH</div>
            <div class="cert-subtitle">CERTIFICATE OF COURSE COMPLETION</div>

            <p class="cert-subtitle mb-2" style="font-size: 1rem;">Học viện Learnora chứng nhận học viên</p>

            <!-- Student Name -->
            <div>
                <span class="cert-recipient-name"><%= cert.getStudentName() != null ? cert.getStudentName() : "Học viên Learnora" %></span>
            </div>

            <p class="text-secondary small mb-1" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
                Đã hoàn thành xuất sắc toàn bộ nội dung lý thuyết, bài thực hành và bài kiểm tra đánh giá năng lực của khóa học:
            </p>

            <!-- Course Title -->
            <div class="cert-course-title"><%= cert.getCourseTitle() %></div>

            <!-- Description -->
            <div class="cert-description">
                Được công nhận đáp ứng đầy đủ chuẩn đầu ra về kiến thức lập trình, kỹ năng xây dựng hệ thống phần mềm và đạt chuẩn tốt nghiệp môn học tại nền tảng giáo dục trực tuyến Learnora.
            </div>

            <!-- Signatures, Official Seal & QR -->
            <div class="row align-items-end g-4 pt-3 border-top border-warning border-opacity-25 mt-2">
                
                <!-- Left Signature: Instructor -->
                <div class="col-4 text-center">
                    <div class="cert-signature-draw"><%= cert.getInstructorName() != null ? cert.getInstructorName() : "Instructor" %></div>
                    <div style="border-top: 1px solid #cbd5e1; width: 180px; margin: 0.25rem auto;"></div>
                    <div class="cert-signature-name"><%= cert.getInstructorName() != null ? cert.getInstructorName() : "Giảng viên phụ trách" %></div>
                    <div class="cert-signature-role">Giảng viên hướng dẫn</div>
                </div>

                <!-- Center: Official Seal & Date -->
                <div class="col-4 text-center">
                    <div class="cert-official-seal mb-2">
                        <i class="bi bi-patch-check-fill fs-5 mb-0.5"></i>
                        <span>LEARNORA LMS</span>
                        <span>OFFICIAL CERTIFIED</span>
                        <span>★ VERIFIED ★</span>
                    </div>
                    <div class="small text-secondary" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
                        Cấp ngày <%= formattedDate %>
                    </div>
                </div>

                <!-- Right Signature: Academic Director -->
                <div class="col-4 text-center">
                    <div class="cert-signature-draw">Vương Hoàng Phúc</div>
                    <div style="border-top: 1px solid #cbd5e1; width: 180px; margin: 0.25rem auto;"></div>
                    <div class="cert-signature-name">Vương Hoàng Phúc</div>
                    <div class="cert-signature-role">Chủ tịch Hội đồng Đào tạo</div>
                </div>

            </div>

            <!-- Metadata & Verification Code Footer -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-4 mt-3 border-top border-secondary border-opacity-10 small text-secondary" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
                <div class="d-flex align-items-center gap-2">
                    <span>Mã chứng chỉ:</span>
                    <span class="cert-code-pill"><%= cert.getCertificateCode() %></span>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-shield-check text-success"></i>
                    <span>Trạng thái: <b>HỢP LỆ (VALID)</b></span>
                </div>
            </div>

        </div>
    </div>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
