<%@ page pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    Long currentUserId = null;

    Object uidObj = session.getAttribute("userId");

    if (uidObj instanceof Number) {
        currentUserId = ((Number) uidObj).longValue();
    }

    String currentUserFullName
            = (String) session.getAttribute("fullName");

    User currentUser
            = (User) session.getAttribute("user");

    String loginError
            = (String) session.getAttribute("loginError");

    String registerError
            = (String) session.getAttribute("registerError");

    String loginSuccess
            = (String) session.getAttribute("loginSuccess");

    String loginEmail
            = (String) session.getAttribute("loginEmail");

    boolean isRemembered = false;
    if ((loginEmail == null || loginEmail.isEmpty()) && request.getCookies() != null) {
        for (jakarta.servlet.http.Cookie c : request.getCookies()) {
            if ("rememberedUser".equals(c.getName())) {
                try {
                    loginEmail = java.net.URLDecoder.decode(c.getValue(), java.nio.charset.StandardCharsets.UTF_8);
                    isRemembered = true;
                } catch (Exception ignored) {}
                break;
            }
        }
    }

    String regFullName
            = (String) session.getAttribute("regFullName");

    String regEmail
            = (String) session.getAttribute("regEmail");

    session.removeAttribute("loginError");
    session.removeAttribute("registerError");
    session.removeAttribute("loginSuccess");
    session.removeAttribute("loginEmail");
    session.removeAttribute("regFullName");
    session.removeAttribute("regEmail");

    String currentUri
            = (String) request.getAttribute(
                    "jakarta.servlet.forward.request_uri"
            );

    if (currentUri == null) {
        currentUri = request.getRequestURI();
    }

    String queryString
            = (String) request.getAttribute(
                    "jakarta.servlet.forward.query_string"
            );

    if (queryString == null) {
        queryString = request.getQueryString();
    }

    String redirectUrl = currentUri;

    if (queryString != null
            && !queryString.isBlank()) {

        String cleanQuery
                = queryString
                        .replaceAll(
                                "(?i)(&|^)authModal=[^&]*",
                                ""
                        )
                        .replaceAll(
                                "^&",
                                ""
                        );

        if (!cleanQuery.isBlank()) {

            redirectUrl
                    += "?"
                    + cleanQuery;
        }
    }


    /*
     * ==========================================
     * LOGIN CAPTCHA
     * ==========================================
     */
    Integer loginCaptchaA
            = (Integer) session.getAttribute(
                    "loginCaptchaA"
            );

    Integer loginCaptchaB
            = (Integer) session.getAttribute(
                    "loginCaptchaB"
            );

    Integer loginCaptchaAnswer
            = (Integer) session.getAttribute(
                    "loginCaptchaAnswer"
            );


    /*
     * Login là modal nằm ngay trong Header.
     *
     * Người dùng có thể mở Sign In trực tiếp
     * mà không đi qua GET /login.
     *
     * Vì vậy nếu chưa có CAPTCHA thì tạo tại đây.
     */
    if (currentUserId == null
            && (loginCaptchaA == null
            || loginCaptchaB == null
            || loginCaptchaAnswer == null)) {

        loginCaptchaA
                = java.util.concurrent.ThreadLocalRandom
                        .current()
                        .nextInt(
                                1,
                                10
                        );

        loginCaptchaB
                = java.util.concurrent.ThreadLocalRandom
                        .current()
                        .nextInt(
                                1,
                                10
                        );

        loginCaptchaAnswer
                = loginCaptchaA
                + loginCaptchaB;

        session.setAttribute(
                "loginCaptchaA",
                loginCaptchaA
        );

        session.setAttribute(
                "loginCaptchaB",
                loginCaptchaB
        );

        session.setAttribute(
                "loginCaptchaAnswer",
                loginCaptchaAnswer
        );
    }
%>

<!DOCTYPE html>

<html lang="vi"
      data-bs-theme="dark">

    <head>
        <script>
            (function() {
                function getCookie(name) {
                    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                    return match ? match[2] : null;
                }
                var savedTheme = getCookie('ftech_theme') || localStorage.getItem('ftech_theme') || 'dark';
                document.documentElement.setAttribute('data-bs-theme', savedTheme);
                document.documentElement.dataset.bsTheme = savedTheme;
            })();
        </script>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1">

        <title>
            ${empty pageTitle
              ? 'Ftech PRJ đỉnh cao'
              : pageTitle}
        </title>


        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
            rel="stylesheet">


        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
            rel="stylesheet">

        


        <style>
            /* =========================================
   FTECH METEOR / SHOOTING STAR EFFECT
   ========================================= */

            #ftech-meteor-layer {
                position: fixed;
                inset: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                overflow: hidden;
                z-index: 0;
            }

            .ftech-meteor {
                position: absolute;

                width: 1.5px;
                height: var(--meteor-length);

                background: linear-gradient(
                    to bottom,
                    rgba(255, 255, 255, 0),
                    rgba(255, 255, 255, 0.8)
                    );

                border-radius: 999px;

                opacity: 0;

                transform:
                    rotate(-45deg)
                    translateY(-120px);

                filter:
                    drop-shadow(
                    0 0 3px
                    rgba(120, 170, 255, 0.6)
                    );

                animation:
                    ftech-meteor-fall
                    var(--meteor-duration)
                    linear
                    infinite;

                animation-delay:
                    var(--meteor-delay);
            }

            .ftech-meteor::before {
                content: "";

                position: absolute;

                bottom: 0;
                left: 50%;

                width: 3px;
                height: 3px;

                transform:
                    translateX(-50%);

                border-radius: 50%;

                background: #fff;

                box-shadow:
                    0 0 4px #fff,
                    0 0 8px rgba(96, 165, 250, 0.6);
            }

            /* Giao diện sáng: đổi sao băng sang tông xanh tím đậm hơn để nổi trên nền trắng */
            [data-bs-theme="light"] .ftech-meteor {
                background: linear-gradient(
                    to bottom,
                    rgba(99, 102, 241, 0),
                    rgba(99, 102, 241, 0.45) 55%,
                    rgba(79, 70, 229, 0.9)
                    );

                filter:
                    drop-shadow(
                    0 0 3px
                    rgba(99, 102, 241, 0.45)
                    );
            }

            [data-bs-theme="light"] .ftech-meteor::before {
                background: #4f46e5;

                box-shadow:
                    0 0 4px rgba(79, 70, 229, 0.85),
                    0 0 10px rgba(129, 140, 248, 0.65);
            }

            @keyframes ftech-meteor-fall {

                0% {
                    opacity: 0;

                    transform:
                        rotate(-45deg)
                        translateY(-150px);
                }

                8% {
                    opacity: 1;
                }

                70% {
                    opacity: 1;
                }

                100% {
                    opacity: 0;

                    transform:
                        rotate(-45deg)
                        translateY(120vh);
                }
            }
            
            /* ============================================================
               FTECH METEOR DIAGONAL SWEEP THEME TRANSITION
               ============================================================ */
            /* ============================================================
               REALISTIC WATER RIPPLE / TELEGRAM THEME TRANSITION
               (LÀN SÓNG GỢN NƯỚC CHUYỂN ĐỘNG THẬT 1.05S)
               ============================================================ */
            ::view-transition-old(root),
            ::view-transition-new(root) {
                animation: none;
                mix-blend-mode: normal;
            }

            ::view-transition-old(root) {
                z-index: 1;
            }

            ::view-transition-new(root) {
                z-index: 999999;
                animation: ftechRealisticCircularReveal 1.05s cubic-bezier(0.18, 0.9, 0.32, 1) forwards;
            }

            @keyframes ftechRealisticCircularReveal {
                0% {
                    clip-path: circle(0px at var(--ftech-click-x, 50%) var(--ftech-click-y, 50%));
                }
                100% {
                    clip-path: circle(var(--ftech-radius, 150vmax) at var(--ftech-click-x, 50%) var(--ftech-click-y, 50%));
                }
            }

            /* Vành gợn sóng nước thực tế (Realistic Shockwave Ripples) */
            #ftechWaveRing {
                position: fixed;
                pointer-events: none;
                z-index: 10000000;
                border-radius: 50%;
                transform: translate(-50%, -50%) scale(0);
                opacity: 0;
                will-change: transform, opacity;
            }

            /* Gợn sóng đồng tâm thứ hai (Secondary concentric ripple) */
            #ftechWaveRing::before {
                content: '';
                position: absolute;
                inset: 16px;
                border-radius: 50%;
                pointer-events: none;
                opacity: 0.65;
            }

            #ftechWaveRing.wave-active-dark {
                border: 3.5px solid #38bdf8;
                box-shadow: 
                    0 0 35px 8px rgba(56, 189, 248, 0.85),
                    inset 0 0 25px 6px rgba(56, 189, 248, 0.6),
                    0 0 70px 20px rgba(139, 92, 246, 0.5);
                animation: ftechRealisticWaveAnim 1.05s cubic-bezier(0.18, 0.9, 0.32, 1) forwards;
            }

            #ftechWaveRing.wave-active-dark::before {
                border: 2px dashed rgba(56, 189, 248, 0.7);
            }

            #ftechWaveRing.wave-active-light {
                border: 3.5px solid #f59e0b;
                box-shadow: 
                    0 0 35px 8px rgba(245, 158, 11, 0.85),
                    inset 0 0 25px 6px rgba(245, 158, 11, 0.6),
                    0 0 70px 20px rgba(96, 165, 250, 0.5);
                animation: ftechRealisticWaveAnim 1.05s cubic-bezier(0.18, 0.9, 0.32, 1) forwards;
            }

            #ftechWaveRing.wave-active-light::before {
                border: 2px dashed rgba(245, 158, 11, 0.7);
            }

            @keyframes ftechRealisticWaveAnim {
                0% {
                    transform: translate(-50%, -50%) scale(0);
                    opacity: 0.95;
                }
                20% {
                    opacity: 1;
                }
                70% {
                    opacity: 0.85;
                }
                100% {
                    transform: translate(-50%, -50%) scale(1);
                    opacity: 0;
                }
            }

            .ftech-theme-icon-spin {
                animation: ftechThemeIconSpin 0.85s cubic-bezier(0.34, 1.56, 0.64, 1) forwards !important;
            }

            @keyframes ftechThemeIconSpin {
                0% { transform: rotate(0deg) scale(1); }
                50% { transform: rotate(180deg) scale(0.6); opacity: 0.4; }
                100% { transform: rotate(360deg) scale(1); opacity: 1; }
            }

            [data-bs-theme="light"] #ftech-meteor-layer {
                opacity: 0.15;
                transition: opacity 0.85s ease;
            }

            [data-bs-theme="dark"] #ftech-meteor-layer {
                opacity: 1;
                transition: opacity 0.85s ease;
            }

.logo-gradient {

                background:
                    linear-gradient(
                    90deg,
                    #3b82f6,
                    #c084fc,
                    #f472b6
                    );

                -webkit-background-clip:
                    text;

                background-clip:
                    text;

                color:
                    transparent;
            }


            .btn-icon {

                width:
                    2.75rem;

                height:
                    2.75rem;
            }


            /* =================================== */
            /* THEME DESIGN SYSTEM                 */
            /* =================================== */
            :root, [data-bs-theme="dark"] {
                --ftech-nav-bg: rgba(11, 15, 25, 0.88);
                --ftech-nav-border: rgba(255, 255, 255, 0.08);
                --ftech-card-bg: #111726;
                --ftech-card-border: rgba(255, 255, 255, 0.08);
                --ftech-input-bg: #0b0f19;
                --ftech-input-border: rgba(255, 255, 255, 0.14);
                --ftech-text-main: #f8fafc;
                --ftech-text-sub: #94a3b8;
                --ftech-dropdown-bg: #131b2e;
                --ftech-dropdown-hover: rgba(255, 255, 255, 0.07);
                --ftech-social-bg: #1e293b;
            }
            [data-bs-theme="light"] {
                --ftech-nav-bg: rgba(255, 255, 255, 0.94);
                --ftech-nav-border: rgba(0, 0, 0, 0.08);
                --ftech-card-bg: #ffffff;
                --ftech-card-border: rgba(0, 0, 0, 0.08);
                --ftech-input-bg: #f8fafc;
                --ftech-input-border: rgba(0, 0, 0, 0.16);
                --ftech-text-main: #0f172a;
                --ftech-text-sub: #64748b;
                --ftech-dropdown-bg: #ffffff;
                --ftech-dropdown-hover: #f1f5f9;
                --ftech-social-bg: #f1f5f9;
            }

            .ftech-navbar {
                background-color: var(--ftech-nav-bg) !important;
                border-bottom: 1px solid var(--ftech-nav-border) !important;
                backdrop-filter: blur(12px);
                -webkit-backdrop-filter: blur(12px);
                transition: background-color 0.25s ease, border-color 0.25s ease;
            }

            [data-bs-theme="light"] body {
                background-color: #f8fafc;
                color: #0f172a;
            }
            [data-bs-theme="dark"] body {
                background-color: #0b0f19;
                color: #e2e8f0;
            }
            [data-bs-theme="light"] .card {
                background-color: #ffffff;
                border-color: rgba(0, 0, 0, 0.08);
                color: #0f172a;
            }
            [data-bs-theme="dark"] .card {
                background-color: #111726;
                border-color: rgba(255, 255, 255, 0.08);
                color: #f1f5f9;
            }

            /* Safeguards for pristine Light & Dark Theme rendering */
            [data-bs-theme="light"] .detail-card,
            [data-bs-theme="light"] .checkout-card,
            [data-bs-theme="light"] .success-card,
            [data-bs-theme="light"] .cart-item-card,
            [data-bs-theme="light"] .summary-card,
            [data-bs-theme="light"] .review-card,
            [data-bs-theme="light"] .modal-content:not(.btn) {
                background-color: #ffffff !important;
                border-color: rgba(0, 0, 0, 0.08) !important;
                color: #0f172a !important;
            }

            [data-bs-theme="light"] .catalog-accent {
                color: #6d28d9 !important;
            }
            [data-bs-theme="dark"] .catalog-accent {
                color: #c4b5fd !important;
            }

            [data-bs-theme="light"] .text-white:not(.btn-primary):not(.btn-primary *):not(.btn-success):not(.btn-success *):not(.btn-danger):not(.btn-danger *):not(.btn-warning *):not(.badge) {
                color: var(--ftech-text-main) !important;
            }
            [data-bs-theme="light"] .text-white-50 {
                color: var(--ftech-text-sub) !important;
            }

            [data-bs-theme="light"] .btn-outline-secondary,
            [data-bs-theme="light"] .btn-outline-secondary.text-white,
            [data-bs-theme="light"] .btn-outline-secondary .text-white,
            [data-bs-theme="light"] .btn-outline-secondary * {
                color: #334155 !important;
            }
            [data-bs-theme="light"] .btn-outline-secondary:hover,
            [data-bs-theme="light"] .btn-outline-secondary:hover * {
                color: #0f172a !important;
                background-color: #f1f5f9 !important;
            }

            [data-bs-theme="light"] .bg-dark:not(.ftech-meteor):not(spline-viewer):not(.badge):not(.btn-primary):not(.btn-success):not(.btn-danger) {
                background-color: var(--ftech-card-bg) !important;
                color: var(--ftech-text-main) !important;
            }
            [data-bs-theme="dark"] .btn-outline-secondary {
                color: #e2e8f0 !important;
                border-color: rgba(255, 255, 255, 0.28) !important;
            }
            [data-bs-theme="dark"] .btn-outline-secondary:hover {
                color: #ffffff !important;
                background-color: rgba(255, 255, 255, 0.12) !important;
                border-color: rgba(255, 255, 255, 0.45) !important;
            }

            [data-bs-theme="light"] .bg-dark-subtle {
                background-color: var(--ftech-dropdown-hover) !important;
            }
            [data-bs-theme="light"] .border-secondary {
                border-color: rgba(0, 0, 0, 0.12) !important;
            }

            /* =================================== */
            /* AUTH DROPDOWN                       */
            /* =================================== */

            .auth-dropdown-menu {
                min-width: 290px;
                background-color: var(--ftech-dropdown-bg) !important;
                border: 1px solid var(--ftech-card-border) !important;
                border-radius: 1rem !important;
                box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15) !important;
                padding: 0.75rem !important;
            }

            .auth-dropdown-menu .dropdown-item {
                border-radius: 0.65rem;
                color: var(--ftech-text-main);
                transition: all 0.2s ease;
                font-size: 0.95rem;
            }

            .auth-dropdown-menu .dropdown-item:hover {
                background-color: var(--ftech-dropdown-hover);
                color: var(--bs-primary);
            }

            /* =================================== */
            /* AUTH MODAL                          */
            /* =================================== */

            .auth-modal-dialog {
                max-width: 450px;
            }

            .auth-modal-content {
                background-color: var(--ftech-card-bg) !important;
                border: 1px solid var(--ftech-card-border) !important;
                border-radius: 1.25rem !important;
                box-shadow: 0 25px 60px rgba(0, 0, 0, 0.25) !important;
                color: var(--ftech-text-main) !important;
            }

            .btn-social {
                background-color: var(--ftech-social-bg);
                border: 1px solid var(--ftech-card-border);
                color: var(--ftech-text-main);
                border-radius: 0.75rem;
                padding: 0.65rem 1rem;
                font-weight: 500;
                font-size: 0.95rem;
                transition: all 0.2s;
            }

            .btn-social:hover {
                background-color: var(--ftech-input-bg);
                border-color: var(--ftech-card-border);
                color: var(--bs-primary);
            }

            .auth-input {
                background-color: var(--ftech-input-bg) !important;
                border: 1px solid var(--ftech-input-border) !important;
                color: var(--ftech-text-main) !important;
                border-radius: 0.75rem !important;
                padding: 0.65rem 0.9rem !important;
                font-size: 0.95rem;
            }

            .auth-input:focus {
                border-color: #3b82f6 !important;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.25) !important;
            }

            .auth-divider {
                display: flex;
                align-items: center;
                text-align: center;
                color: var(--ftech-text-sub);
                font-size: 0.8rem;
                font-weight: 600;
                margin: 1.25rem 0;
            }

            .auth-divider::before,
            .auth-divider::after {
                content: '';
                flex: 1;
                border-bottom: 1px solid var(--ftech-card-border);
            }

            .auth-divider:not(:empty)::before {
                margin-right: .75em;
            }

            .auth-divider:not(:empty)::after {
                margin-left: .75em;
            }

            /* =================================== */
            /* CAPTCHA                             */
            /* =================================== */

            .captcha-question {
                min-width: 115px;
                background-color: var(--ftech-social-bg) !important;
                border: 1px solid var(--ftech-input-border) !important;
                color: #eab308 !important;
                font-weight: 700;
                justify-content: center;
                border-radius: 0.75rem 0 0 0.75rem !important;
            }

            .captcha-input {
                border-radius: 0 0.75rem 0.75rem 0 !important;
            }

        </style>

    </head>


    <body>

        <div id="ftech-meteor-layer" aria-hidden="true"></div>
        <div id="ftechThemeSweep" aria-hidden="true"></div>

        <!-- ========================================== -->
        <!-- HEADER                                     -->
        <!-- ========================================== -->

        <header>


            <nav
                class="
                navbar
                navbar-expand-lg
                ftech-navbar
                sticky-top
                px-3
                py-2.5">


                <div class="container-fluid">


                    <!-- Logo -->

                    <a
                        class="
                        navbar-brand
                        fw-bolder
                        fst-italic
                        fs-3
                        me-4
                        logo-gradient"

                        href="${pageContext.request.contextPath}/">

                        Ftech

                    </a>


                    <button
                        class="
                        navbar-toggler
                        border-0"

                        type="button"

                        data-bs-toggle="collapse"

                        data-bs-target="#fesNav"

                        aria-controls="fesNav"

                        aria-expanded="false"

                        aria-label="Mở menu">


                        <span
                            class="navbar-toggler-icon">
                        </span>

                    </button>


                    <div
                        class="
                        collapse
                        navbar-collapse"

                        id="fesNav">


                        <!-- ================================== -->
                        <!-- MENU                               -->
                        <!-- ================================== -->

                        <ul
                            class="
                            navbar-nav
                            me-auto
                            gap-lg-1">


                            <li class="nav-item">

                                <a
                                    class="
                                    nav-link
                                    rounded-3
                                    px-3
                                    ${activeMenu == 'home'
                                      ? 'active bg-primary-subtle text-primary-emphasis'
                                      : ''}"

                                    href="${pageContext.request.contextPath}/">

                                    Home

                                </a>

                            </li>


                            <li class="nav-item">

                                <a
                                    class="
                                    nav-link
                                    rounded-3
                                    px-3
                                    ${activeMenu == 'courses'
                                      ? 'active bg-primary-subtle text-primary-emphasis'
                                      : ''}"

                                    href="${pageContext.request.contextPath}/courses">

                                    Khám phá khóa học

                                </a>

                            </li>


                            <% if (currentUserId != null) { %>
                            <li class="nav-item">
                                <a
                                    class="
                                    nav-link
                                    rounded-3
                                    px-3
                                    ${activeMenu == 'myCourses'
                                      ? 'active bg-primary-subtle text-primary-emphasis'
                                      : ''}"
                                    href="${pageContext.request.contextPath}/student/courses">
                                    Khóa học của tôi
                                </a>
                            </li>


                            <% } %>

                        </ul>


                        <!-- ================================== -->
                        <!-- RIGHT SIDE                         -->
                        <!-- ================================== -->

                        <div
                            class="
                            d-flex
                            align-items-center
                            gap-2
                            mt-3
                            mt-lg-0">


                            <!-- Search -->

                            <form action="${pageContext.request.contextPath}/courses"
                                  method="get"
                                  role="search"
                                  class="input-group flex-grow-1"
                                  style="min-width: 300px;">


                                <button type="submit"
                                        class="input-group-text bg-body-tertiary border-0 text-body"
                                        aria-label="Tìm kiếm">


                                    <i
                                        class="
                                        bi
                                        bi-search">
                                    </i>

                                </button>


                                <input
                                    type="search"

                                    class="
                                    form-control
                                    bg-body-tertiary
                                    border-0
                                    shadow-none"

                                    placeholder="Tìm khóa học..."

                                    aria-label="Tìm khóa học"

                                    id="searchInput"

                                    name="keyword"

                                    maxlength="100"

                                    autocomplete="off"

                                    value="<%= request.getAttribute("keyword") == null ? "" : String.valueOf(request.getAttribute("keyword")).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") %>">


                                <span
                                    class="
                                    input-group-text
                                    bg-body-tertiary
                                    border-0
                                    d-none
                                    d-md-flex
                                    gap-1">


                                    <kbd>
                                        Ctrl
                                    </kbd>


                                    <kbd>
                                        K
                                    </kbd>

                                </span>

                            </form>


                            <!-- Theme -->

                            <button
                                type="button"

                                id="themeToggle"

                                class="
                                btn
                                btn-icon
                                rounded-circle
                                bg-body-tertiary
                                border-0
                                d-inline-flex
                                align-items-center
                                justify-content-center"

                                aria-label="Đổi giao diện">


                                <i
                                    class="
                                    bi
                                    bi-brightness-high">
                                </i>

                            </button>
                            <% if (currentUser == null || !currentUser.isAdmin()) { %>
                            <a href="${pageContext.request.contextPath}/student/cart"
                               onclick="if (typeof handleOpenCart === 'function') {
                                           handleOpenCart();
                                           return false;
                                       }"
                               class="
                               btn
                               btn-icon
                               position-relative
                               rounded-circle
                               bg-body-tertiary
                               border-0
                               d-inline-flex
                               align-items-center
                               justify-content-center"

                               aria-label="Giỏ hàng">

                                <i class="bi bi-cart3"></i>

                                <span
                                    id="headerCartBadge"

                                    class="
                                    position-absolute
                                    top-0
                                    start-100
                                    translate-middle
                                    badge
                                    rounded-pill
                                    bg-danger
                                    ${empty cartCount || cartCount == 0
                                      ? 'd-none'
                                      : ''}">

                                    ${empty cartCount ? 0 : cartCount}

                                </span>

                            </a>
                            <% } %>


                            <!-- ================================== -->
                            <!-- USER AUTH                           -->
                            <!-- ================================== -->

                            <% if (currentUserId == null) { %>


                            <!-- Guest -->

                            <div class="dropdown">


                                <button
                                    type="button"

                                    class="
                                    btn
                                    btn-icon
                                    rounded-circle
                                    bg-body-tertiary
                                    border-0
                                    d-inline-flex
                                    align-items-center
                                    justify-content-center
                                    text-body
                                    shadow-sm"

                                    id="guestDropdown"

                                    data-bs-toggle="dropdown"

                                    aria-expanded="false"

                                    aria-label="Tài khoản">


                                    <i
                                        class="
                                        bi
                                        bi-person
                                        fs-5">
                                    </i>

                                </button>


                                <div
                                    class="
                                    dropdown-menu
                                    dropdown-menu-end
                                    auth-dropdown-menu"

                                    aria-labelledby="guestDropdown">


                                    <div
                                        class="
                                        d-flex
                                        align-items-center
                                        gap-3
                                        px-3
                                        py-2">


                                        <div
                                            class="
                                            rounded-circle
                                            bg-dark
                                            d-flex
                                            align-items-center
                                            justify-content-center
                                            flex-shrink-0"

                                            style="
                                            width:42px;
                                            height:42px;
                                            border:
                                            1px solid
                                            rgba(
                                            255,
                                            255,
                                            255,
                                            0.15
                                            );">


                                            <i
                                                class="
                                                bi
                                                bi-person
                                                fs-5
                                                text-secondary">
                                            </i>

                                        </div>


                                        <span
                                            class="
                                            text-secondary
                                            small
                                            fw-medium">

                                            Sign in to track your progress

                                        </span>

                                    </div>


                                    <hr
                                        class="
                                        dropdown-divider
                                        border-secondary
                                        my-2">


                                    <button
                                        type="button"

                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"

                                        data-bs-toggle="modal"

                                        data-bs-target="#signInModal" onclick="window.openSignInModal && window.openSignInModal()">


                                        <i
                                            class="
                                            bi
                                            bi-box-arrow-in-right
                                            fs-5
                                            text-secondary">
                                        </i>


                                        <span
                                            class="fw-semibold">

                                            Sign In

                                        </span>

                                    </button>


                                    <button
                                        type="button"

                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"

                                        data-bs-toggle="modal"

                                        data-bs-target="#signUpModal" onclick="window.openSignUpModal && window.openSignUpModal()">


                                        <i
                                            class="
                                            bi
                                            bi-person-plus
                                            fs-5
                                            text-secondary">
                                        </i>


                                        <span
                                            class="fw-semibold">

                                            Sign Up

                                        </span>

                                    </button>

                                </div>

                            </div>




                            <% } else { %>


                            <!-- Logged user -->

                            <div class="dropdown">


                                <button
                                    type="button"

                                    class="
                                    btn
                                    btn-icon
                                    rounded-circle
                                    bg-primary-subtle
                                    border
                                    border-primary-subtle
                                    d-inline-flex
                                    align-items-center
                                    justify-content-center
                                    text-primary-emphasis
                                    p-0
                                    overflow-hidden
                                    shadow-sm"

                                    id="userDropdown"

                                    data-bs-toggle="dropdown"

                                    aria-expanded="false"

                                    aria-label="Tài khoản của bạn">


                                    <%
                                        if (currentUser != null
                                                && currentUser.getAvatarUrl() != null
                                                && !currentUser.getAvatarUrl().isBlank()) {
                                    %>


                                    <img
                                        src="<%= currentUser.getAvatarUrl()%>"

                                        alt=""

                                        class="rounded-circle"

                                        style="width:100%;height:100%;object-fit:cover;"
                                        onerror="this.style.display='none';if(this.nextElementSibling)this.nextElementSibling.style.display='block';">
                                    <i class="bi bi-person-fill fs-5" style="display:none;"></i>


                                    <% } else { %>


                                    <i
                                        class="
                                        bi
                                        bi-person-fill
                                        fs-5">
                                    </i>


                                    <% }%>

                                </button>


                                <div
                                    class="
                                    dropdown-menu
                                    dropdown-menu-end
                                    auth-dropdown-menu"

                                    aria-labelledby="userDropdown">


                                    <div
                                        class="
                                        px-3
                                        py-2">


                                        <div
                                            class="
                                            fw-bold
                                            text-white
                                            text-truncate"

                                            style="
                                            max-width:
                                            220px;">

                                            <%= currentUserFullName != null
                                                    ? currentUserFullName
                                                    : "Học viên"%>

                                        </div>


                                        <div
                                            class="
                                            text-secondary
                                            small
                                            text-truncate"

                                            style="
                                            max-width:
                                            220px;">

                                            <%= currentUser != null
                                                    && currentUser.getEmail() != null
                                                    ? currentUser.getEmail()
                                                    : ""%>

                                        </div>


                                        <div
                                            class="
                                            mt-2
                                            d-flex
                                            flex-wrap
                                            gap-1">


                                            <%
                                                if (currentUser != null
                                                        && currentUser.getRoles() != null) {

                                                    for (String role
                                                            : currentUser.getRoles()) {
                                            %>


                                            <span
                                                class="
                                                badge
                                                bg-primary-subtle
                                                text-primary
                                                border
                                                border-primary-subtle">

                                                <%= role%>

                                            </span>


                                            <%
                                                    }
                                                }
                                            %>

                                        </div>

                                    </div>


                                    <hr
                                        class="
                                        dropdown-divider
                                        border-secondary
                                        my-2">


                                    <a
                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"
                                        href="${pageContext.request.contextPath}/profile">
                                        <i class="bi bi-person-circle text-primary fs-5"></i>
                                        <span>Hồ sơ cá nhân</span>
                                    </a>

                                    <a
                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"
                                        href="${pageContext.request.contextPath}/student/courses">
                                        <i class="bi bi-mortarboard text-secondary fs-5"></i>
                                        <span>Khóa học của tôi</span>
                                    </a>

                                    <a
                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"
                                        href="${pageContext.request.contextPath}/student/orders">
                                        <i class="bi bi-receipt text-info fs-5"></i>
                                        <span>Lịch sử đơn hàng</span>
                                    </a>


                                    <% if (currentUser != null
                                                && currentUser.isInstructor()) {
                                    %>


                                    <a
                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"

                                        href="${pageContext.request.contextPath}/instructor/dashboard">


                                        <i
                                            class="
                                            bi
                                            bi-journal-check
                                            text-warning
                                            fs-5">
                                        </i>


                                        <span>
                                            Quản lý giảng dạy
                                        </span>

                                    </a>


                                    <% } %>


                                    <% if (currentUser != null
                                                && currentUser.isAdmin()) {
                                    %>


                                    <a
                                        class="
                                        dropdown-item
                                        d-flex
                                        align-items-center
                                        gap-3
                                        py-2"

                                        href="${pageContext.request.contextPath}/admin/dashboard">


                                        <i
                                            class="
                                            bi
                                            bi-speedometer2
                                            text-danger
                                            fs-5">
                                        </i>


                                        <span>
                                            Quản trị hệ thống
                                        </span>

                                    </a>


                                    <% } %>




                                    <hr
                                        class="
                                        dropdown-divider
                                        border-secondary
                                        my-2">


                                    <form
                                        action="${pageContext.request.contextPath}/logout"

                                        method="POST"

                                        class="
                                        m-0
                                        p-0">


                                        <button
                                            type="submit"

                                            class="
                                            dropdown-item
                                            d-flex
                                            align-items-center
                                            gap-3
                                            py-2
                                            text-danger">


                                            <i
                                                class="
                                                bi
                                                bi-box-arrow-right
                                                fs-5">
                                            </i>


                                            <span>
                                                Sign Out
                                            </span>

                                        </button>

                                    </form>

                                </div>

                            </div>


                            <% } %>

                        </div>

                    </div>

                </div>

            </nav>

        </header>

        <% if (currentUser == null || !currentUser.isAdmin()) { %>
        <%@include file="/WEB-INF/view/student/cart-drawer.jsp" %>
        <%@include file="/WEB-INF/view/student/checkout-modal.jsp" %>
        <% } %>

        <!-- ========================================== -->
        <!-- SIGN IN MODAL                              -->
        <!-- ========================================== -->

        <div
            class="
            modal
            fade"

            id="signInModal"

            tabindex="-1"

            aria-labelledby="signInModalLabel"

            aria-hidden="true">


            <div
                class="
                modal-dialog
                modal-dialog-centered
                auth-modal-dialog">


                <div
                    class="
                    modal-content
                    auth-modal-content
                    p-3
                    p-md-4">


                    <div
                        class="
                        modal-header
                        border-0
                        pb-1">


                        <div
                            class="
                            w-100
                            text-center">


                            <h4
                                class="
                                modal-title
                                fw-bold
                                text-white"

                                id="signInModalLabel">

                                Sign In

                            </h4>


                            <p
                                class="
                                text-secondary
                                small
                                mb-0
                                mt-1">

                                Sign in to your account to continue

                            </p>

                        </div>


                        <button
                            type="button"

                            class="
                            btn-close
                            btn-close-white
                            position-absolute
                            top-0
                            end-0
                            m-3"

                            data-bs-dismiss="modal"

                            aria-label="Close">
                        </button>

                    </div>


                    <div
                        class="
                        modal-body
                        pt-3">


                        <!-- Social -->

                        <div
                            class="
                            d-flex
                            flex-column
                            gap-2
                            mb-2">


                            <button
                                type="button"

                                class="
                                btn
                                btn-social
                                d-flex
                                align-items-center
                                justify-content-center
                                gap-2">


                                <svg
                                    width="18"
                                    height="18"
                                    viewBox="0 0 24 24">


                                <path
                                    fill="#4285F4"
                                    d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z"/>


                                <path
                                    fill="#34A853"
                                    d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.26v3.15C3.25 21.36 7.33 24 12 24z"/>


                                <path
                                    fill="#FBBC05"
                                    d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.14-1.55.38-2.27V6.58H1.26C.46 8.16 0 9.94 0 12s.46 3.84 1.26 5.42l4.02-3.15z"/>


                                <path
                                    fill="#EA4335"
                                    d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.25 2.64 1.26 6.58l4.02 3.15c.95-2.83 3.6-4.98 6.72-4.98z"/>

                                </svg>


                                <span>
                                    Sign in with Google
                                </span>

                            </button>


                            <button
                                type="button"

                                class="
                                btn
                                btn-social
                                d-flex
                                align-items-center
                                justify-content-center
                                gap-2">


                                <i
                                    class="
                                    bi
                                    bi-github
                                    fs-5">
                                </i>


                                <span>
                                    Sign in with GitHub
                                </span>

                            </button>

                        </div>


                        <div class="auth-divider">

                            OR

                        </div>



                        <!-- ================================= -->
                        <!-- LOGIN ERROR                       -->
                        <!-- ================================= -->

                        <% if (loginError != null) {%>


                        <div
                            class="
                            alert
                            alert-danger
                            py-2
                            small
                            mb-3
                            border-0
                            d-flex
                            align-items-center
                            gap-2">


                            <i
                                class="
                                bi
                                bi-exclamation-triangle-fill
                                flex-shrink-0">
                            </i>


                            <span>
                                <%= loginError%>
                            </span>

                        </div>


                        <% } %>



                        <% if (loginSuccess != null) {%>


                        <div
                            class="
                            alert
                            alert-success
                            py-2
                            small
                            mb-3
                            border-0
                            d-flex
                            align-items-center
                            gap-2">


                            <i
                                class="
                                bi
                                bi-check-circle-fill
                                flex-shrink-0">
                            </i>


                            <span>
                                <%= loginSuccess%>
                            </span>

                        </div>


                        <% }%>



                        <!-- ================================= -->
                        <!-- LOGIN FORM                        -->
                        <!-- ================================= -->

                        <form
                            action="${pageContext.request.contextPath}/login"

                            method="POST">


                            <input
                                type="hidden"

                                name="redirectUrl"

                                value="<%= redirectUrl%>">



                            <!-- Email -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Email or username

                                </label>


                                <input
                                    type="text"

                                    name="emailOrUsername"

                                    class="
                                    form-control
                                    auth-input"

                                    placeholder="Enter your email or username"

                                    value="<%= loginEmail != null
                                            ? loginEmail
                                            : ""%>"

                                    required>

                            </div>



                            <!-- Password -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Password

                                </label>


                                <div class="input-group">


                                    <input
                                        type="password"

                                        name="password"

                                        id="signInPassword"

                                        class="
                                        form-control
                                        auth-input"

                                        placeholder="Enter your password"

                                        required>


                                    <button
                                        class="
                                        btn
                                        btn-outline-secondary
                                        border-secondary-subtle
                                        px-3"

                                        type="button"

                                        onclick="
                                                toggleAuthPassword(
                                                        'signInPassword',
                                                        this
                                                        )"

                                        aria-label="Hiện mật khẩu">


                                        <i
                                            class="
                                            bi
                                            bi-eye
                                            text-secondary">
                                        </i>

                                    </button>

                                </div>

                            </div>



                            <!-- ================================= -->
                            <!-- CAPTCHA                           -->
                            <!-- ================================= -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    CAPTCHA

                                </label>


                                <div class="input-group">


                                    <span
                                        class="
                                        input-group-text
                                        captcha-question">


                                        <%= loginCaptchaA%>

                                        +

                                        <%= loginCaptchaB%>

                                        = ?

                                    </span>


                                    <input
                                        type="number"

                                        name="captchaInput"

                                        class="
                                        form-control
                                        auth-input
                                        captcha-input"

                                        placeholder="Enter result"

                                        autocomplete="off"

                                        required>

                                </div>


                                <div
                                    class="
                                    form-text
                                    text-secondary"

                                    style="
                                    font-size:
                                    0.8rem;">

                                    Solve the calculation to continue.

                                </div>

                            </div>



                            <!-- Remember / Forgot -->

                            <div
                                class="
                                d-flex
                                justify-content-between
                                align-items-center
                                mb-4">


                                <div
                                    class="
                                    form-check
                                    mb-0">


                                    <input
                                        class="
                                        form-check-input"

                                        type="checkbox"

                                        name="rememberMe"
                                        value="true"
                                        <%= isRemembered ? "checked" : "" %>

                                        id="rememberMe">


                                    <label
                                        class="
                                        form-check-label
                                        text-secondary
                                        small"

                                        for="rememberMe">

                                        Remember me

                                    </label>

                                </div>


                                <a
                                    href="javascript:void(0)"

                                    class="
                                    text-secondary
                                    small
                                    text-decoration-none">

                                    Forgot Password?

                                </a>

                            </div>



                            <!-- Sign In -->

                            <button
                                type="submit"

                                class="
                                btn
                                btn-primary
                                w-100
                                py-2
                                fw-semibold
                                rounded-3
                                shadow-sm">

                                Sign In

                            </button>

                        </form>



                        <div
                            class="
                            text-center
                            text-secondary
                            small
                            mt-4">

                            Don't have an account?


                            <a
                                href="javascript:void(0)"

                                class="
                                text-primary
                                text-decoration-none
                                fw-semibold"

                                data-bs-target="#signUpModal"

                                data-bs-toggle="modal">

                                Sign Up

                            </a>

                        </div>

                    </div>

                </div>

            </div>

        </div>



        <!-- ========================================== -->
        <!-- SIGN UP MODAL                              -->
        <!-- ========================================== -->

        <div
            class="
            modal
            fade"

            id="signUpModal"

            tabindex="-1"

            aria-labelledby="signUpModalLabel"

            aria-hidden="true">


            <div
                class="
                modal-dialog
                modal-dialog-centered
                auth-modal-dialog">


                <div
                    class="
                    modal-content
                    auth-modal-content
                    p-3
                    p-md-4">


                    <div
                        class="
                        modal-header
                        border-0
                        pb-1">


                        <div
                            class="
                            w-100
                            text-center">


                            <h4
                                class="
                                modal-title
                                fw-bold
                                text-white"

                                id="signUpModalLabel">

                                Sign Up

                            </h4>


                            <p
                                class="
                                text-secondary
                                small
                                mb-0
                                mt-1">

                                Create an account to continue

                            </p>

                        </div>


                        <button
                            type="button"

                            class="
                            btn-close
                            btn-close-white
                            position-absolute
                            top-0
                            end-0
                            m-3"

                            data-bs-dismiss="modal"

                            aria-label="Close">
                        </button>

                    </div>


                    <div
                        class="
                        modal-body
                        pt-3">


                        <!-- Social -->

                        <div
                            class="
                            d-flex
                            flex-column
                            gap-2
                            mb-2">


                            <button
                                type="button"

                                class="
                                btn
                                btn-social
                                d-flex
                                align-items-center
                                justify-content-center
                                gap-2">


                                <svg
                                    width="18"
                                    height="18"
                                    viewBox="0 0 24 24">


                                <path
                                    fill="#4285F4"
                                    d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z"/>


                                <path
                                    fill="#34A853"
                                    d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.26v3.15C3.25 21.36 7.33 24 12 24z"/>


                                <path
                                    fill="#FBBC05"
                                    d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.14-1.55.38-2.27V6.58H1.26C.46 8.16 0 9.94 0 12s.46 3.84 1.26 5.42l4.02-3.15z"/>


                                <path
                                    fill="#EA4335"
                                    d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.25 2.64 1.26 6.58l4.02 3.15c.95-2.83 3.6-4.98 6.72-4.98z"/>

                                </svg>


                                <span>
                                    Sign in with Google
                                </span>

                            </button>


                            <button
                                type="button"

                                class="
                                btn
                                btn-social
                                d-flex
                                align-items-center
                                justify-content-center
                                gap-2">


                                <i
                                    class="
                                    bi
                                    bi-github
                                    fs-5">
                                </i>


                                <span>
                                    Sign in with GitHub
                                </span>

                            </button>

                        </div>


                        <div class="auth-divider">

                            OR

                        </div>



                        <!-- Register Error -->

                        <% if (registerError != null) {%>


                        <div
                            class="
                            alert
                            alert-danger
                            py-2
                            small
                            mb-3
                            border-0
                            d-flex
                            align-items-center
                            gap-2">


                            <i
                                class="
                                bi
                                bi-exclamation-triangle-fill
                                flex-shrink-0">
                            </i>


                            <span>
                                <%= registerError%>
                            </span>

                        </div>


                        <% }%>



                        <!-- ================================= -->
                        <!-- REGISTER FORM                     -->
                        <!-- ================================= -->

                        <form
                            action="${pageContext.request.contextPath}/register"

                            method="POST">


                            <input
                                type="hidden"

                                name="redirectUrl"

                                value="<%= redirectUrl%>">



                            <!-- Full name -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Full name

                                </label>


                                <input
                                    type="text"

                                    name="fullName"

                                    class="
                                    form-control
                                    auth-input"

                                    placeholder="Enter your full name"

                                    value="<%= regFullName != null
                                            ? regFullName
                                            : ""%>"

                                    required>

                            </div>



                            <!-- Email -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Email

                                </label>


                                <input
                                    type="email"

                                    name="email"

                                    class="
                                    form-control
                                    auth-input"

                                    placeholder="Enter your email"

                                    value="<%= regEmail != null
                                            ? regEmail
                                            : ""%>"

                                    required>

                            </div>



                            <!-- Username -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Username

                                </label>


                                <input
                                    type="text"

                                    name="username"

                                    class="
                                    form-control
                                    auth-input"

                                    placeholder="Choose a username (optional)">


                                <div
                                    class="
                                    form-text
                                    text-secondary"

                                    style="
                                    font-size:
                                    0.8rem;">

                                    Leave blank to auto-generate from your email

                                </div>

                            </div>



                            <!-- Password -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Password

                                </label>


                                <div class="input-group">


                                    <input
                                        type="password"

                                        name="password"

                                        id="signUpPassword"

                                        class="
                                        form-control
                                        auth-input"

                                        placeholder="Enter your password"

                                        required>


                                    <button
                                        class="
                                        btn
                                        btn-outline-secondary
                                        border-secondary-subtle
                                        px-3"

                                        type="button"

                                        onclick="
                                                toggleAuthPassword(
                                                        'signUpPassword',
                                                        this
                                                        )"

                                        aria-label="Hiện mật khẩu">


                                        <i
                                            class="
                                            bi
                                            bi-eye
                                            text-secondary">
                                        </i>

                                    </button>

                                </div>

                            </div>



                            <!-- Confirm password -->

                            <div class="mb-3">


                                <label
                                    class="
                                    form-label
                                    text-light
                                    small
                                    fw-medium
                                    mb-1">

                                    Confirm password

                                </label>


                                <div class="input-group">


                                    <input
                                        type="password"

                                        name="confirmPassword"

                                        id="signUpConfirmPassword"

                                        class="
                                        form-control
                                        auth-input"

                                        placeholder="Confirm your password"

                                        required>


                                    <button
                                        class="
                                        btn
                                        btn-outline-secondary
                                        border-secondary-subtle
                                        px-3"

                                        type="button"

                                        onclick="
                                                toggleAuthPassword(
                                                        'signUpConfirmPassword',
                                                        this
                                                        )"

                                        aria-label="Hiện mật khẩu">


                                        <i
                                            class="
                                            bi
                                            bi-eye
                                            text-secondary">
                                        </i>

                                    </button>

                                </div>

                            </div>



                            <!-- Terms -->

                            <div
                                class="
                                form-check
                                mb-4">


                                <input
                                    class="
                                    form-check-input"

                                    type="checkbox"

                                    id="agreeTerms"

                                    required>


                                <label
                                    class="
                                    form-check-label
                                    text-secondary
                                    small"

                                    for="agreeTerms">

                                    I have read and agree to the

                                    <a
                                        href="javascript:void(0)"

                                        class="
                                        text-white
                                        text-decoration-underline">

                                        Terms of Service

                                    </a>

                                    and

                                    <a
                                        href="javascript:void(0)"

                                        class="
                                        text-white
                                        text-decoration-underline">

                                        Privacy Policy

                                    </a>

                                </label>

                            </div>



                            <!-- Sign up -->

                            <button
                                type="submit"

                                class="
                                btn
                                btn-primary
                                w-100
                                py-2
                                fw-semibold
                                rounded-3
                                shadow-sm">

                                Sign Up

                            </button>

                        </form>



                        <div
                            class="
                            text-center
                            text-secondary
                            small
                            mt-4">

                            Already have an account?


                            <a
                                href="javascript:void(0)"

                                class="
                                text-primary
                                text-decoration-none
                                fw-semibold"

                                data-bs-target="#signInModal"

                                data-bs-toggle="modal">

                                Sign In

                            </a>

                        </div>

                    </div>

                </div>

            </div>

        </div>



        <!-- ========================================== -->
        <!-- SCRIPT                                     -->
        <!-- ========================================== -->

        <script>

            function toggleAuthPassword(
                    inputId,
                    btn) {

                const input
                        = document.getElementById(
                                inputId
                                );

                if (!input) {
                    return;
                }


                const icon
                        = btn.querySelector(
                                'i'
                                );


                if (input.type === 'password') {

                    input.type = 'text';

                    if (icon) {

                        icon.classList.remove(
                                'bi-eye'
                                );

                        icon.classList.add(
                                'bi-eye-slash'
                                );
                    }

                } else {

                    input.type = 'password';

                    if (icon) {

                        icon.classList.remove(
                                'bi-eye-slash'
                                );

                        icon.classList.add(
                                'bi-eye'
                                );
                    }
                }
            }



            document.addEventListener(
                    'DOMContentLoaded',
                    function () {


                        const urlParams
                                = new URLSearchParams(
                                        window.location.search
                                        );


                        const authModal
                                = urlParams.get(
                                        'authModal'
                                        );


            <% if (loginError != null
                        || loginSuccess != null) { %>


                        const signInModalEl
                                = document.getElementById(
                                        'signInModal'
                                        );


                        if (signInModalEl
                                && typeof bootstrap
                                !== 'undefined') {

                            new bootstrap.Modal(
                                    signInModalEl
                                    ).show();
                        }


            <% } else if (registerError != null) { %>


                        const signUpModalEl
                                = document.getElementById(
                                        'signUpModal'
                                        );


                        if (signUpModalEl
                                && typeof bootstrap
                                !== 'undefined') {

                            new bootstrap.Modal(
                                    signUpModalEl
                                    ).show();
                        }


            <% } else { %>


                        if (authModal
                                === 'signin') {


                            const el
                                    = document.getElementById(
                                            'signInModal'
                                            );


                            if (el
                                    && typeof bootstrap
                                    !== 'undefined') {

                                new bootstrap.Modal(
                                        el
                                        ).show();
                            }


                        } else if (
                                authModal
                                === 'signup') {


                            const el
                                    = document.getElementById(
                                            'signUpModal'
                                            );


                            if (el
                                    && typeof bootstrap
                                    !== 'undefined') {

                                new bootstrap.Modal(
                                        el
                                        ).show();
                            }
                        }


            <% }%>

                    }
            );

        </script>
        <script>
            // FTECH METEOR SPAWN ENGINE
            window.ftechSpawnMeteors = function(burst) {
                const meteorLayer = document.getElementById("ftech-meteor-layer");
                if (!meteorLayer) return;

                if (!burst) {
                    meteorLayer.innerHTML = "";
                }

                const count = burst ? 22 : (window.innerWidth < 768 ? 12 : 30);
                for (let i = 0; i < count; i++) {
                    const meteor = document.createElement("span");
                    meteor.className = "ftech-meteor";
                    const left = Math.random() * 120 - 10;
                    const top = burst ? (Math.random() * 30 - 20) : (Math.random() * 80 - 40);
                    const length = burst ? (55 + Math.random() * 80) : (30 + Math.random() * 60);
                    const duration = burst ? (2.2 + Math.random() * 2.8) : (3 + Math.random() * 5);
                    const delay = burst ? (Math.random() * 0.4) : (-Math.random() * 12);

                    meteor.style.left = left + "vw";
                    meteor.style.top = top + "vh";
                    meteor.style.setProperty("--meteor-length", length + "px");
                    meteor.style.setProperty("--meteor-duration", duration + "s");
                    meteor.style.setProperty("--meteor-delay", delay + "s");

                    meteorLayer.appendChild(meteor);

                    if (burst) {
                        setTimeout(() => {
                            if (meteor.parentNode) meteor.remove();
                        }, (duration + 1) * 1000);
                    }
                }
            };

            let _isThemeSwitching = false;
            window.ftechSwitchTheme = async function(targetTheme, event) {
                if (_isThemeSwitching) return;

                const html = document.documentElement;
                const currentTheme = html.getAttribute('data-bs-theme') || html.dataset.bsTheme || 'dark';
                const newTheme = targetTheme || (currentTheme === 'dark' ? 'light' : 'dark');

                if (newTheme === currentTheme) return;

                const themeBtn = document.getElementById('themeToggle');
                const icon = themeBtn ? themeBtn.querySelector('i') : null;

                // Tọa độ click chuột chính xác để làn sóng khởi phát
                const rect = themeBtn ? themeBtn.getBoundingClientRect() : null;
                const x = (event && typeof event.clientX === 'number' && event.clientX > 0)
                    ? event.clientX
                    : (rect ? rect.left + rect.width / 2 : window.innerWidth / 2);
                const y = (event && typeof event.clientY === 'number' && event.clientY > 0)
                    ? event.clientY
                    : (rect ? rect.top + rect.height / 2 : window.innerHeight / 2);

                const endRadius = Math.hypot(
                    Math.max(x, window.innerWidth - x),
                    Math.max(y, window.innerHeight - y)
                );

                // Gán biến CSS cho mặt nạ Circular Reveal
                html.style.setProperty('--ftech-click-x', x + 'px');
                html.style.setProperty('--ftech-click-y', y + 'px');
                html.style.setProperty('--ftech-radius', endRadius + 'px');

                // Vành sóng nước phát quang chân thực
                let waveRing = document.getElementById('ftechWaveRing');
                if (!waveRing) {
                    waveRing = document.createElement('div');
                    waveRing.id = 'ftechWaveRing';
                    waveRing.setAttribute('aria-hidden', 'true');
                    document.body.appendChild(waveRing);
                }

                // Căn chỉnh tâm và kích thước vành sóng nước bám sát viền vòng tròn
                waveRing.style.left = x + 'px';
                waveRing.style.top = y + 'px';
                waveRing.style.width = (endRadius * 2.02) + 'px';
                waveRing.style.height = (endRadius * 2.02) + 'px';

                _isThemeSwitching = true;

                if (icon) {
                    icon.classList.remove('ftech-theme-icon-spin');
                    void icon.offsetWidth;
                    icon.classList.add('ftech-theme-icon-spin');
                }

                // Bắt đầu kích hoạt vành sóng gợn nước
                waveRing.className = newTheme === 'dark' ? 'wave-active-dark' : 'wave-active-light';

                const applyTheme = () => {
                    html.setAttribute('data-bs-theme', newTheme);
                    html.dataset.bsTheme = newTheme;
                    localStorage.setItem('ftech_theme', newTheme);
                    document.cookie = 'ftech_theme=' + newTheme + ';path=/;max-age=31536000';

                    if (icon) {
                        icon.className = newTheme === 'dark'
                            ? 'bi bi-brightness-high fs-5 text-warning'
                            : 'bi bi-moon-stars fs-5 text-primary';
                    }

                    if (newTheme === 'dark' && typeof window.ftechSpawnMeteors === 'function') {
                        window.ftechSpawnMeteors(true);
                    }

                    window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: newTheme } }));
                };

                if (document.startViewTransition) {
                    const transition = document.startViewTransition(() => {
                        applyTheme();
                    });

                    try {
                        await transition.finished;
                    } catch (e) {
                        // ignore abort
                    } finally {
                        setTimeout(() => {
                            waveRing.className = '';
                            if (icon) icon.classList.remove('ftech-theme-icon-spin');
                            _isThemeSwitching = false;
                        }, 50);
                    }
                } else {
                    applyTheme();
                    setTimeout(() => {
                        waveRing.className = '';
                        if (icon) icon.classList.remove('ftech-theme-icon-spin');
                        _isThemeSwitching = false;
                    }, 1050);
                }
            };

            document.addEventListener("DOMContentLoaded", function () {
                window.ftechSpawnMeteors(false);
            });
        </script>

<!-- ============================================================
     FTECH GLOBAL NOTIFICATION & DIALOG HUB
     ============================================================ -->
<style>
.ftech-glass-modal {
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
}
[data-bs-theme="light"] .ftech-glass-modal {
    background: #ffffff !important;
    border-color: rgba(0, 0, 0, 0.1) !important;
    color: #0f172a !important;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15) !important;
}
.ftech-notice-icon-box {
    width: 68px;
    height: 68px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.ftech-icon-error {
    background: rgba(239, 68, 68, 0.15);
    color: #ef4444;
    box-shadow: 0 0 24px rgba(239, 68, 68, 0.25);
}
.ftech-icon-warning {
    background: rgba(245, 158, 11, 0.15);
    color: #f59e0b;
    box-shadow: 0 0 24px rgba(245, 158, 11, 0.25);
}
.ftech-icon-success {
    background: rgba(16, 185, 129, 0.15);
    color: #10b981;
    box-shadow: 0 0 24px rgba(16, 185, 129, 0.25);
}
.ftech-icon-info {
    background: rgba(59, 130, 246, 0.15);
    color: #3b82f6;
    box-shadow: 0 0 24px rgba(59, 130, 246, 0.25);
}
.ftech-toast-progress {
    height: 3px;
    width: 100%;
    background: #3b82f6;
    animation: ftechToastCountdown 3.5s linear forwards;
}
@keyframes ftechToastCountdown {
    from { width: 100%; }
    to { width: 0%; }
}
[data-bs-theme="light"] #ftechGlobalToast {
    background: #ffffff !important;
    border-color: rgba(0, 0, 0, 0.1) !important;
    color: #0f172a !important;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12) !important;
}
[data-bs-theme="light"] #ftechGlobalToast .btn-close {
    filter: none;
}
</style>

<!-- 1. Global Alert / Error / Warning / Success Modal -->
<div class="modal fade" id="ftechGlobalAlertModal" tabindex="-1" aria-labelledby="ftechGlobalAlertTitle" aria-hidden="true" style="z-index: 10600;">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
        <div class="modal-content border-0 shadow-lg rounded-4 ftech-glass-modal" style="background: var(--ftech-card-bg, #151821); color: var(--ftech-text-main, #ffffff); border: 1px solid var(--ftech-card-border, rgba(255,255,255,0.1)) !important;">
            <div class="modal-body text-center p-4 pt-5">
                <div id="ftechGlobalAlertIconBox" class="ftech-notice-icon-box mx-auto mb-3 ftech-icon-error">
                    <i id="ftechGlobalAlertIcon" class="bi bi-exclamation-triangle-fill fs-1"></i>
                </div>
                <h5 class="fw-bold mb-2" id="ftechGlobalAlertTitle">Thông báo</h5>
                <p class="text-secondary mb-4 small" id="ftechGlobalAlertMessage" style="line-height: 1.6; word-break: break-word;"></p>
                <div class="d-grid gap-2">
                    <button type="button" id="ftechGlobalAlertBtn" class="btn btn-primary rounded-pill py-2 fw-semibold shadow-sm" data-bs-dismiss="modal">
                        Đã hiểu
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 2. Global Confirmation Modal (replaces native confirm) -->
<div class="modal fade" id="ftechGlobalConfirmModal" tabindex="-1" aria-labelledby="ftechGlobalConfirmTitle" aria-hidden="true" style="z-index: 10650;">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 460px;">
        <div class="modal-content border-0 shadow-lg rounded-4 ftech-glass-modal" style="background: var(--ftech-card-bg, #151821); color: var(--ftech-text-main, #ffffff); border: 1px solid var(--ftech-card-border, rgba(255,255,255,0.1)) !important;">
            <div class="modal-body text-center p-4 pt-5">
                <div id="ftechGlobalConfirmIconBox" class="ftech-notice-icon-box mx-auto mb-3 ftech-icon-warning">
                    <i id="ftechGlobalConfirmIcon" class="bi bi-question-circle-fill fs-1"></i>
                </div>
                <h5 class="fw-bold mb-2" id="ftechGlobalConfirmTitle">Xác nhận thao tác</h5>
                <p class="text-secondary mb-4 small" id="ftechGlobalConfirmMessage" style="line-height: 1.6; word-break: break-word;"></p>
                <div class="d-flex gap-2 justify-content-center">
                    <button type="button" id="ftechGlobalConfirmCancelBtn" class="btn btn-outline-secondary rounded-pill px-4 py-2" data-bs-dismiss="modal">
                        Hủy bỏ
                    </button>
                    <button type="button" id="ftechGlobalConfirmOkBtn" class="btn btn-danger rounded-pill px-4 py-2 fw-semibold shadow-sm">
                        Xác nhận
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 3. Global Floating Toast Container -->
<div id="ftechToastContainer" class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 10700;">
    <div id="ftechGlobalToast" class="toast align-items-center border-0 rounded-4 shadow-lg overflow-hidden" role="alert" aria-live="assertive" aria-atomic="true" style="background: var(--ftech-card-bg, #1a202c); color: var(--ftech-text-main, #ffffff); border: 1px solid var(--ftech-card-border, rgba(255,255,255,0.15)) !important;">
        <div class="d-flex p-3 align-items-center gap-3">
            <div id="ftechToastIconBox" class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 38px; height: 38px;">
                <i id="ftechToastIcon" class="bi fs-5"></i>
            </div>
            <div class="flex-grow-1" style="min-width: 0;">
                <div class="fw-bold small" id="ftechToastTitle">Thông báo</div>
                <div class="small opacity-75" id="ftechToastMessage">Nội dung</div>
            </div>
            <button type="button" class="btn-close btn-close-white me-1 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div id="ftechToastProgress" class="ftech-toast-progress"></div>
    </div>
</div>

<script>
// ============================================================
// GLOBAL FTECH NOTIFICATION API
// ============================================================

// Global Auth Modal openers
window.openSignInModal = function() {
    var el = document.getElementById('signInModal');
    if (el && typeof bootstrap !== 'undefined') {
        bootstrap.Modal.getOrCreateInstance(el).show();
    }
};
window.openSignUpModal = function() {
    var el = document.getElementById('signUpModal');
    if (el && typeof bootstrap !== 'undefined') {
        bootstrap.Modal.getOrCreateInstance(el).show();
    }
};

window.ftechAlert = function(options) {
    if (typeof options === 'string') {
        options = { message: options, type: 'warning' };
    }
    const title = options.title || (options.type === 'error' ? 'Có lỗi xảy ra' : (options.type === 'success' ? 'Thành công' : 'Thông báo'));
    const message = options.message || '';
    const type = options.type || 'warning';
    const buttonText = options.buttonText || 'Đã hiểu';

    const modalEl = document.getElementById('ftechGlobalAlertModal');
    if (!modalEl || typeof bootstrap === 'undefined') {
        window._nativeAlert ? window._nativeAlert(message) : console.warn(message);
        return;
    }

    const titleEl = document.getElementById('ftechGlobalAlertTitle');
    const msgEl = document.getElementById('ftechGlobalAlertMessage');
    const iconBox = document.getElementById('ftechGlobalAlertIconBox');
    const icon = document.getElementById('ftechGlobalAlertIcon');
    const btn = document.getElementById('ftechGlobalAlertBtn');

    if (titleEl) titleEl.innerText = title;
    if (msgEl) msgEl.innerText = message;
    if (btn) btn.innerText = buttonText;

    if (iconBox && icon) {
        iconBox.className = 'ftech-notice-icon-box mx-auto mb-3 ftech-icon-' + type;
        if (type === 'error') icon.className = 'bi bi-x-circle-fill fs-1 text-danger';
        else if (type === 'success') icon.className = 'bi bi-check-circle-fill fs-1 text-success';
        else if (type === 'info') icon.className = 'bi bi-info-circle-fill fs-1 text-info';
        else icon.className = 'bi bi-exclamation-triangle-fill fs-1 text-warning';
    }

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
};

window.ftechToast = function(message, type, title) {
    type = type || 'success';
    const toastEl = document.getElementById('ftechGlobalToast');
    if (!toastEl || typeof bootstrap === 'undefined') {
        window.ftechAlert({ message: message, type: type, title: title });
        return;
    }

    const titleEl = document.getElementById('ftechToastTitle');
    const msgEl = document.getElementById('ftechToastMessage');
    const iconBox = document.getElementById('ftechToastIconBox');
    const icon = document.getElementById('ftechToastIcon');
    const prog = document.getElementById('ftechToastProgress');

    if (titleEl) titleEl.innerText = title || (type === 'success' ? 'Thành công' : (type === 'error' ? 'Thất bại' : 'Thông báo'));
    if (msgEl) msgEl.innerHTML = message || '';

    if (iconBox && icon) {
        if (type === 'success') {
            iconBox.style.background = 'rgba(16, 185, 129, 0.15)';
            icon.className = 'bi bi-check-circle-fill text-success';
            if (prog) prog.style.background = '#10b981';
        } else if (type === 'error') {
            iconBox.style.background = 'rgba(239, 68, 68, 0.15)';
            icon.className = 'bi bi-x-circle-fill text-danger';
            if (prog) prog.style.background = '#ef4444';
        } else {
            iconBox.style.background = 'rgba(59, 130, 246, 0.15)';
            icon.className = 'bi bi-info-circle-fill text-primary';
            if (prog) prog.style.background = '#3b82f6';
        }
    }

    if (prog) {
        prog.style.animation = 'none';
        prog.offsetHeight;
        prog.style.animation = 'ftechToastCountdown 3.5s linear forwards';
    }

    const toast = bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 3500 });
    toast.show();
};

window.ftechConfirm = function(message, options) {
    options = options || {};
    const title = options.title || 'Xác nhận thao tác';
    const confirmText = options.confirmText || 'Xác nhận';
    const cancelText = options.cancelText || 'Hủy bỏ';
    const isDanger = options.isDanger !== false;

    return new Promise(function(resolve) {
        const modalEl = document.getElementById('ftechGlobalConfirmModal');
        if (!modalEl || typeof bootstrap === 'undefined') {
            resolve(window._nativeConfirm ? window._nativeConfirm(message) : true);
            return;
        }

        const titleEl = document.getElementById('ftechGlobalConfirmTitle');
        const msgEl = document.getElementById('ftechGlobalConfirmMessage');
        const okBtn = document.getElementById('ftechGlobalConfirmOkBtn');
        const cancelBtn = document.getElementById('ftechGlobalConfirmCancelBtn');

        if (titleEl) titleEl.innerText = title;
        if (msgEl) msgEl.innerText = message;
        if (okBtn) {
            okBtn.innerText = confirmText;
            okBtn.className = isDanger ? 'btn btn-danger rounded-pill px-4 py-2 fw-semibold shadow-sm' : 'btn btn-primary rounded-pill px-4 py-2 fw-semibold shadow-sm';
        }
        if (cancelBtn) cancelBtn.innerText = cancelText;

        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);

        function handleConfirm() {
            cleanup();
            modal.hide();
            resolve(true);
        }
        function handleCancel() {
            cleanup();
            resolve(false);
        }

        function cleanup() {
            okBtn.removeEventListener('click', handleConfirm);
            cancelBtn.removeEventListener('click', handleCancel);
        }

        okBtn.addEventListener('click', handleConfirm);
        cancelBtn.addEventListener('click', handleCancel);

        modal.show();
    });
};

// 4. SMART OVERRIDE for window.alert
if (!window._nativeAlert) {
    window._nativeAlert = window.alert;
    window.alert = function(msg) {
        if (typeof msg !== 'string') {
            try { msg = JSON.stringify(msg); } catch (e) { msg = String(msg); }
        }
        const lower = msg.toLowerCase();
        if (lower.includes('sao chép') || lower.includes('thành công') || lower.includes('đã lưu')) {
            window.ftechToast(msg, 'success');
        } else {
            window.ftechAlert({ message: msg, type: 'warning', title: 'Thông báo' });
        }
    };
}

// 5. SMART INTERCEPTOR for forms with onsubmit="return confirm(...)"
document.addEventListener('submit', function(e) {
    const form = e.target;
    if (!form || form.tagName !== 'FORM') return;
    if (form.dataset.ftechConfirmed === 'true') return;

    const onsubmitAttr = form.getAttribute('onsubmit');
    if (onsubmitAttr && onsubmitAttr.includes('confirm(')) {
        e.preventDefault();
        e.stopImmediatePropagation();

        const match = onsubmitAttr.match(/confirm\s*\(\s*['"](.*?)['"]\s*\)/);
        const confirmMsg = match ? match[1] : 'Bạn có chắc chắn muốn thực hiện thao tác này?';

        window.ftechConfirm(confirmMsg).then(function(confirmed) {
            if (confirmed) {
                form.dataset.ftechConfirmed = 'true';
                form.submit();
            }
        });
    }
}, true);

// 6. AUTO-TRIGGER from URL (?error=... or ?msg=...)
document.addEventListener('DOMContentLoaded', function() {
    try {
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        const msg = urlParams.get('msg');
        if (error) {
            window.ftechAlert({ title: 'Thông báo lỗi', message: error, type: 'error' });
        } else if (msg) {
            window.ftechToast(msg, 'success');
        }
    } catch (e) {}
});
</script>
