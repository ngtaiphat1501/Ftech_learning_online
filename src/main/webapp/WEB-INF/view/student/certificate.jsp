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

<!-- Google Fonts for Prestigious World-Class Academic Certificates -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800;900&family=Great+Vibes&family=Montserrat:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;0,700;0,800;1,400;1,600&display=swap" rel="stylesheet">

<style>
    .cert-page-wrapper {
        padding: 2.5rem 1rem 5rem 1rem;
        min-height: 85vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }

    /* Master Academic Certificate Container */
    .certificate-frame {
        max-width: 1040px;
        width: 100%;
        background: #0f172a;
        padding: 14px;
        border-radius: 16px;
        box-shadow: 0 30px 80px rgba(0, 0, 0, 0.65), 0 0 0 1px rgba(212, 175, 55, 0.35);
        position: relative;
    }

    .certificate-outer-border {
        border: 3px solid #d4af37;
        padding: 6px;
        border-radius: 12px;
        background: linear-gradient(135deg, #b8860b 0%, #d4af37 25%, #fff8dc 50%, #d4af37 75%, #996515 100%);
    }

    .certificate-inner {
        background: #fffdf9;
        color: #0f172a;
        border: 2px solid #b8860b;
        border-radius: 8px;
        padding: 3.5rem 3.5rem 2.8rem 3.5rem;
        position: relative;
        overflow: hidden;
        background-image: 
            radial-gradient(circle at 50% 50%, rgba(255, 255, 255, 0.96) 0%, rgba(254, 250, 240, 0.92) 100%),
            repeating-linear-gradient(45deg, rgba(212, 175, 55, 0.02) 0, rgba(212, 175, 55, 0.02) 1px, transparent 0, transparent 24px);
    }

    /* Watermark Emblem in Background */
    .certificate-watermark {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 440px;
        height: 440px;
        opacity: 0.045;
        pointer-events: none;
        background-repeat: no-repeat;
        background-position: center;
        background-size: contain;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    /* Ornamental Corner Flourishes */
    .corner-filigree {
        position: absolute;
        width: 72px;
        height: 72px;
        pointer-events: none;
    }
    .corner-filigree svg {
        width: 100%;
        height: 100%;
        fill: #b8860b;
    }
    .corner-filigree.c-tl { top: 12px; left: 12px; }
    .corner-filigree.c-tr { top: 12px; right: 12px; transform: scaleX(-1); }
    .corner-filigree.c-bl { bottom: 12px; left: 12px; transform: scaleY(-1); }
    .corner-filigree.c-br { bottom: 12px; right: 12px; transform: scale(-1); }

    /* Academy & Institution Title */
    .cert-institution-badge {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        background: rgba(184, 134, 11, 0.1);
        border: 1px solid rgba(184, 134, 11, 0.35);
        padding: 0.35rem 1.25rem;
        border-radius: 999px;
        font-family: 'Montserrat', sans-serif;
        font-size: 0.78rem;
        font-weight: 700;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #855800;
        margin-bottom: 0.75rem;
    }

    .cert-institution-name {
        font-family: 'Cinzel', serif;
        font-size: 1.15rem;
        font-weight: 800;
        letter-spacing: 3px;
        color: #0b192c;
        text-transform: uppercase;
        margin-bottom: 0.25rem;
    }

    .cert-subinstitution {
        font-family: 'Montserrat', sans-serif;
        font-size: 0.78rem;
        letter-spacing: 1.5px;
        color: #64748b;
        text-transform: uppercase;
        margin-bottom: 1.5rem;
    }

    /* Certificate Main Titles */
    .cert-grand-title {
        font-family: 'Cinzel', serif;
        font-size: 2.5rem;
        font-weight: 900;
        letter-spacing: 4px;
        color: #0b192c;
        text-transform: uppercase;
        line-height: 1.2;
        margin-bottom: 0.25rem;
        text-shadow: 0 1px 2px rgba(0,0,0,0.08);
    }

    .cert-grand-subtitle {
        font-family: 'Playfair Display', serif;
        font-size: 1.15rem;
        font-style: italic;
        color: #b8860b;
        letter-spacing: 2px;
        margin-bottom: 1.25rem;
        font-weight: 600;
    }

    .cert-award-statement {
        font-family: 'Montserrat', sans-serif;
        font-size: 0.95rem;
        color: #475569;
        font-style: normal;
        margin-bottom: 0.5rem;
    }

    /* Recipient Name */
    .cert-recipient-name {
        font-family: 'Cinzel', serif;
        font-size: 2.85rem;
        font-weight: 800;
        color: #0a2540;
        letter-spacing: 1.5px;
        padding: 0 2rem;
        margin: 0.25rem 0 0.5rem 0;
        display: inline-block;
        position: relative;
    }

    .cert-divider-flourish {
        width: 320px;
        height: 16px;
        margin: 0 auto 1.5rem auto;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
    }
    .cert-divider-flourish::before, .cert-divider-flourish::after {
        content: "";
        flex: 1;
        height: 1px;
        background: linear-gradient(90deg, transparent, #b8860b, transparent);
    }
    .cert-divider-flourish i {
        color: #b8860b;
        font-size: 0.85rem;
    }

    /* Course Recognition */
    .cert-for-statement {
        font-family: 'Montserrat', sans-serif;
        font-size: 0.92rem;
        color: #475569;
        margin-bottom: 0.5rem;
    }

    .cert-course-title {
        font-family: 'Playfair Display', serif;
        font-size: 1.95rem;
        font-weight: 800;
        color: #0b192c;
        margin-bottom: 1rem;
        line-height: 1.35;
        max-width: 860px;
        margin-left: auto;
        margin-right: auto;
    }

    /* Honors & Outcome Badges */
    .cert-badges-row {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-wrap: wrap;
        gap: 0.75rem;
        margin-bottom: 1.5rem;
    }
    .cert-honor-badge {
        font-family: 'Montserrat', sans-serif;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 0.35rem 0.9rem;
        border-radius: 999px;
        letter-spacing: 0.75px;
        display: inline-flex;
        align-items: center;
        gap: 0.35rem;
    }
    .cert-honor-gold {
        background: rgba(212, 175, 55, 0.15);
        color: #855800;
        border: 1px solid rgba(184, 134, 11, 0.4);
    }
    .cert-honor-navy {
        background: rgba(10, 37, 64, 0.08);
        color: #0a2540;
        border: 1px solid rgba(10, 37, 64, 0.2);
    }

    .cert-description {
        max-width: 740px;
        margin: 0 auto 2.5rem auto;
        font-size: 0.92rem;
        line-height: 1.65;
        color: #475569;
        font-family: 'Montserrat', sans-serif;
    }

    /* 3D Wax Seal with Realistic Satin Ribbon */
    .cert-seal-wrapper {
        position: relative;
        display: inline-block;
        margin-bottom: 0.5rem;
    }
    .cert-wax-seal {
        width: 108px;
        height: 108px;
        border-radius: 50%;
        background: radial-gradient(circle at 35% 35%, #e11d48, #9f1239 70%, #881337 100%);
        border: 3px double #fde047;
        color: #fffbeb;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-transform: uppercase;
        font-family: 'Cinzel', serif;
        box-shadow: 0 8px 24px rgba(159, 18, 57, 0.45), inset 0 2px 4px rgba(255, 255, 255, 0.4);
        position: relative;
        z-index: 2;
        padding: 6px;
        text-align: center;
    }
    .cert-wax-seal span {
        font-size: 0.56rem;
        font-weight: 800;
        letter-spacing: 1px;
        line-height: 1.15;
    }
    .cert-wax-seal .seal-star {
        color: #fde047;
        font-size: 0.65rem;
        margin: 1px 0;
    }
    /* Ribbon Tails hanging down */
    .cert-seal-ribbon {
        position: absolute;
        bottom: -22px;
        left: 50%;
        transform: translateX(-50%);
        width: 70px;
        height: 36px;
        z-index: 1;
        display: flex;
        justify-content: space-between;
    }
    .ribbon-tail-l, .ribbon-tail-r {
        width: 28px;
        height: 34px;
        background: #9f1239;
        clip-path: polygon(0 0, 100% 0, 100% 100%, 50% 75%, 0 100%);
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
    }
    .ribbon-tail-l { transform: rotate(-12deg); margin-left: 4px; }
    .ribbon-tail-r { transform: rotate(12deg); margin-right: 4px; }

    /* Signatures */
    .cert-signature-draw {
        font-family: 'Great Vibes', cursive;
        font-size: 2.35rem;
        color: #0b2545;
        height: 48px;
        display: flex;
        align-items: center;
        justify-content: center;
        text-shadow: 0 0 1px rgba(11, 37, 69, 0.2);
    }
    .cert-signature-line {
        border-top: 1.5px solid #0f172a;
        width: 190px;
        margin: 0.25rem auto 0.5rem auto;
    }
    .cert-signature-name {
        font-family: 'Cinzel', serif;
        font-weight: 700;
        font-size: 0.98rem;
        color: #0f172a;
        letter-spacing: 0.5px;
    }
    .cert-signature-role {
        font-family: 'Montserrat', sans-serif;
        font-size: 0.76rem;
        font-weight: 600;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* Verification & Security Footer */
    .cert-security-footer {
        padding-top: 1.75rem;
        margin-top: 1.75rem;
        border-top: 1px solid rgba(184, 134, 11, 0.25);
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 1rem;
        font-family: 'Montserrat', sans-serif;
    }
    .cert-code-badge {
        font-family: 'Courier New', Courier, monospace;
        font-weight: 700;
        background: #f1f5f9;
        border: 1px solid #cbd5e1;
        padding: 0.25rem 0.85rem;
        border-radius: 6px;
        font-size: 0.85rem;
        color: #0f172a;
        letter-spacing: 1px;
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
            border-radius: 0 !important;
            max-width: 100% !important;
            padding: 0 !important;
            page-break-inside: avoid;
        }
        .certificate-outer-border {
            border-radius: 0 !important;
            padding: 4px !important;
        }
        .certificate-inner {
            border-radius: 0 !important;
            padding: 2.5cm 2cm 2cm 2cm !important;
        }
        @page {
            size: A4 landscape;
            margin: 0.8cm;
        }
    }
</style>

<main class="container cert-page-wrapper">

    <!-- Action Toolbar (Hidden during print) -->
    <div class="cert-action-bar mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3 w-100" style="max-width: 1040px;">
        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-outline-secondary rounded-pill px-4 py-2 text-white border-secondary border-opacity-50">
            <i class="bi bi-arrow-left me-1"></i> Khóa học của tôi
        </a>
        <div class="d-flex align-items-center gap-2">
            <button type="button" onclick="window.print()" class="btn btn-warning rounded-pill px-4 py-2 fw-bold text-dark shadow d-flex align-items-center gap-2" style="background: linear-gradient(135deg, #fde047, #eab308);">
                <i class="bi bi-printer-fill fs-5"></i>
                <span>In chứng chỉ / Lưu PDF</span>
            </button>
            <button type="button" onclick="navigator.clipboard.writeText(window.location.href); if (window.ftechToast) window.ftechToast('Đã sao chép liên kết chứng chỉ!', 'success'); else alert('Đã sao chép liên kết chứng chỉ!');" class="btn btn-outline-light rounded-pill px-3 py-2" title="Sao chép liên kết xác thực">
                <i class="bi bi-share me-1"></i><span>Chia sẻ</span>
            </button>
        </div>
    </div>

    <!-- THE DIPLOMA / CERTIFICATE FRAME -->
    <div class="certificate-frame">
        <div class="certificate-outer-border">
            <div class="certificate-inner text-center">

                <!-- Subtle Background Watermark -->
                <div class="certificate-watermark">
                    <svg viewBox="0 0 200 200" fill="currentColor">
                        <path d="M100 15 L170 45 L170 110 C170 155 135 185 100 195 C65 185 30 155 30 110 L30 45 Z"/>
                    </svg>
                </div>

                <!-- 4 Classical Victorian Corner Filigree SVGs -->
                <div class="corner-filigree c-tl">
                    <svg viewBox="0 0 100 100">
                        <path d="M10 10 L80 10 C50 20 20 50 10 80 Z M22 22 L60 22 C40 32 32 40 22 60 Z M10 10 L10 40 C15 25 25 15 40 10 Z"/>
                        <circle cx="28" cy="28" r="4"/>
                    </svg>
                </div>
                <div class="corner-filigree c-tr">
                    <svg viewBox="0 0 100 100">
                        <path d="M10 10 L80 10 C50 20 20 50 10 80 Z M22 22 L60 22 C40 32 32 40 22 60 Z M10 10 L10 40 C15 25 25 15 40 10 Z"/>
                        <circle cx="28" cy="28" r="4"/>
                    </svg>
                </div>
                <div class="corner-filigree c-bl">
                    <svg viewBox="0 0 100 100">
                        <path d="M10 10 L80 10 C50 20 20 50 10 80 Z M22 22 L60 22 C40 32 32 40 22 60 Z M10 10 L10 40 C15 25 25 15 40 10 Z"/>
                        <circle cx="28" cy="28" r="4"/>
                    </svg>
                </div>
                <div class="corner-filigree c-br">
                    <svg viewBox="0 0 100 100">
                        <path d="M10 10 L80 10 C50 20 20 50 10 80 Z M22 22 L60 22 C40 32 32 40 22 60 Z M10 10 L10 40 C15 25 25 15 40 10 Z"/>
                        <circle cx="28" cy="28" r="4"/>
                    </svg>
                </div>

                <!-- Academy Badge & Top Header -->
                <div>
                    <span class="cert-institution-badge">
                        <i class="bi bi-shield-shaded"></i>
                        <span>FTECH ACADEMY OF ADVANCED TECHNOLOGY</span>
                    </span>
                </div>
                <div class="cert-institution-name">HỌC VIỆN CÔNG NGHỆ FTECH • HỘI ĐỒNG KHẢO THÍ ĐÀO TẠO</div>
                <div class="cert-subinstitution">FPT UNIVERSITY CAMPUS • ENTERPRISE SOFTWARE ENGINEERING CREDENTIAL</div>

                <!-- Grand Title -->
                <div class="cert-grand-title">CHỨNG CHỈ TỐT NGHIỆP CHUYÊN NGHIỆP</div>
                <div class="cert-grand-subtitle">PROFESSIONAL CERTIFICATE OF EXCELLENCE</div>

                <!-- Award Statement -->
                <div class="cert-award-statement">Chứng chỉ này được trân trọng trao tặng cho</div>

                <!-- Recipient Name -->
                <div>
                    <span class="cert-recipient-name">
                        <%= cert.getStudentName() != null ? cert.getStudentName() : "Học viên Ftech" %>
                    </span>
                </div>

                <!-- Elegant Gold Divider Flourish -->
                <div class="cert-divider-flourish">
                    <i class="bi bi-gem"></i>
                </div>

                <div class="cert-for-statement">
                    Đã hoàn thành xuất sắc toàn bộ chương trình đào tạo, đồ án thực hành chuyên sâu và đạt chuẩn đầu ra năng lực của khóa học:
                </div>

                <!-- Course Title -->
                <div class="cert-course-title">
                    <%= cert.getCourseTitle() %>
                </div>

                <!-- Honors & Performance Badges -->
                <div class="cert-badges-row">
                    <span class="cert-honor-badge cert-honor-gold">
                        <i class="bi bi-patch-check-fill text-warning"></i>
                        <span>XẾP LOẠI TỐT NGHIỆP: XUẤT SẮC (DISTINCTION WITH HONORS)</span>
                    </span>
                    <span class="cert-honor-badge cert-honor-navy">
                        <i class="bi bi-award-fill text-primary"></i>
                        <span>TÍCH LŨY: 100% CHUẨN ĐẦU RA KIẾN TRÚC HỆ THỐNG</span>
                    </span>
                </div>

                <!-- Official Endorsement Description -->
                <div class="cert-description">
                    Được công nhận đáp ứng toàn diện các tiêu chuẩn kỹ năng lập trình, tư duy kiến trúc phần mềm doanh nghiệp, năng lực phân tích tối ưu hiệu năng và được cấp quyền chứng nhận chuyên môn tại nền tảng giáo dục trực tuyến Ftech.
                </div>

                <!-- Signatures, Official 3D Seal & Real-Time QR Verification -->
                <div class="row align-items-end g-4 pt-3 border-top border-warning border-opacity-25 mt-2">
                    
                    <!-- Left: Lead Instructor Signature -->
                    <div class="col-4 text-center">
                        <div class="cert-signature-draw">
                            <%= cert.getInstructorName() != null ? cert.getInstructorName() : "TS. Tran Minh Khoa" %>
                        </div>
                        <div class="cert-signature-line"></div>
                        <div class="cert-signature-name">
                            <%= cert.getInstructorName() != null ? cert.getInstructorName() : "TS. Trần Minh Khoa" %>
                        </div>
                        <div class="cert-signature-role">Giảng viên Chuyên môn & Kiến trúc sư Phần mềm</div>
                    </div>

                    <!-- Center: 3D Wax Seal with Satin Ribbon Tails -->
                    <div class="col-4 text-center">
                        <div class="cert-seal-wrapper">
                            <div class="cert-wax-seal">
                                <span>FTECH LMS</span>
                                <div class="seal-star">★ ★ ★</div>
                                <span>OFFICIAL</span>
                                <span>CREDENTIAL</span>
                            </div>
                            <div class="cert-seal-ribbon">
                                <div class="ribbon-tail-l"></div>
                                <div class="ribbon-tail-r"></div>
                            </div>
                        </div>
                        <div class="small text-secondary mt-3 fw-medium" style="font-family: 'Montserrat', sans-serif; font-size: 0.8rem;">
                            Cấp ngày <%= formattedDate %>
                        </div>
                    </div>

                    <!-- Right: Chairman of Academic Board (Võ Thế Vinh) -->
                    <div class="col-4 text-center">
                        <div class="cert-signature-draw">Võ Thế Vinh</div>
                        <div class="cert-signature-line"></div>
                        <div class="cert-signature-name">Võ Thế Vinh</div>
                        <div class="cert-signature-role">Chủ tịch Hội đồng Đào tạo & Khảo thí</div>
                    </div>

                </div>

                <!-- Metadata & Security Footer with QR Code -->
                <div class="cert-security-footer">
                    <div class="d-flex align-items-center gap-3">
                        <!-- Direct QR Code for verification -->
                        <div class="bg-white p-1 rounded-2 shadow-sm border border-secondary border-opacity-25" style="width: 58px; height: 58px;">
                            <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=<%= java.net.URLEncoder.encode(verifyUrl, "UTF-8") %>" 
                                 alt="QR Verify" 
                                 class="w-100 h-100 object-fit-contain">
                        </div>
                        <div class="text-start lh-sm">
                            <span class="text-secondary small d-block mb-1">Mã định danh chứng chỉ:</span>
                            <span class="cert-code-badge"><%= cert.getCertificateCode() %></span>
                        </div>
                    </div>

                    <div class="d-flex align-items-center gap-2">
                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; background: rgba(34, 197, 94, 0.15); color: #16a34a;">
                            <i class="bi bi-shield-check fs-6"></i>
                        </div>
                        <div class="text-start lh-sm">
                            <span class="fw-bold text-success small d-block">CHỨNG CHỈ HỢP LỆ VĨNH VIỄN</span>
                            <span class="text-secondary" style="font-size: 0.75rem;">Verified Digital Credential • Tamper-evident</span>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
