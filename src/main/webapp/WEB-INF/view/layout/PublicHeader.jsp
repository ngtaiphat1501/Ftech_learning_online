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

                width: 2px;
                height: var(--meteor-length);

                background: linear-gradient(
                    to bottom,
                    rgba(255, 255, 255, 0),
                    rgba(255, 255, 255, 0.95)
                    );

                border-radius: 999px;

                opacity: 0;

                transform:
                    rotate(-45deg)
                    translateY(-120px);

                filter:
                    drop-shadow(
                    0 0 5px
                    rgba(120, 170, 255, 0.8)
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

                width: 4px;
                height: 4px;

                transform:
                    translateX(-50%);

                border-radius: 50%;

                background: #fff;

                box-shadow:
                    0 0 6px #fff,
                    0 0 12px rgba(96, 165, 250, 0.8);
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
            /* AUTH DROPDOWN                       */
            /* =================================== */

            .auth-dropdown-menu {

                min-width:
                    290px;

                background-color:
                    #171a21 !important;

                border:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.12
                    ) !important;

                border-radius:
                    1rem !important;

                box-shadow:
                    0 15px 35px
                    rgba(
                    0,
                    0,
                    0,
                    0.6
                    ) !important;

                padding:
                    0.75rem !important;
            }


            .auth-dropdown-menu
            .dropdown-item {

                border-radius:
                    0.65rem;

                color:
                    #e2e8f0;

                transition:
                    all 0.2s ease;

                font-size:
                    0.95rem;
            }


            .auth-dropdown-menu
            .dropdown-item:hover {

                background-color:
                    rgba(
                    255,
                    255,
                    255,
                    0.08
                    );

                color:
                    #fff;
            }


            /* =================================== */
            /* AUTH MODAL                          */
            /* =================================== */

            .auth-modal-dialog {

                max-width:
                    450px;
            }


            .auth-modal-content {

                background-color:
                    #151820 !important;

                border:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.12
                    ) !important;

                border-radius:
                    1.25rem !important;

                box-shadow:
                    0 25px 60px
                    rgba(
                    0,
                    0,
                    0,
                    0.8
                    ) !important;
            }


            .btn-social {

                background-color:
                    #1f232d;

                border:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.12
                    );

                color:
                    #f1f5f9;

                border-radius:
                    0.75rem;

                padding:
                    0.65rem 1rem;

                font-weight:
                    500;

                font-size:
                    0.95rem;

                transition:
                    all 0.2s;
            }


            .btn-social:hover {

                background-color:
                    #272c38;

                border-color:
                    rgba(
                    255,
                    255,
                    255,
                    0.25
                    );

                color:
                    #ffffff;
            }


            .auth-input {

                background-color:
                    #101218 !important;

                border:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.16
                    ) !important;

                color:
                    #f8fafc !important;

                border-radius:
                    0.75rem !important;

                padding:
                    0.65rem 0.9rem !important;

                font-size:
                    0.95rem;
            }


            .auth-input:focus {

                border-color:
                    #3b82f6 !important;

                box-shadow:
                    0 0 0 3px
                    rgba(
                    59,
                    130,
                    246,
                    0.25
                    ) !important;
            }


            .auth-divider {

                display:
                    flex;

                align-items:
                    center;

                text-align:
                    center;

                color:
                    #64748b;

                font-size:
                    0.8rem;

                font-weight:
                    600;

                margin:
                    1.25rem 0;
            }


            .auth-divider::before,
            .auth-divider::after {

                content:
                    '';

                flex:
                    1;

                border-bottom:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.1
                    );
            }


            .auth-divider:not(:empty)::before {

                margin-right:
                    .75em;
            }


            .auth-divider:not(:empty)::after {

                margin-left:
                    .75em;
            }


            /* =================================== */
            /* CAPTCHA                             */
            /* =================================== */

            .captcha-question {

                min-width:
                    115px;

                background-color:
                    #1f232d !important;

                border:
                    1px solid
                    rgba(
                    255,
                    255,
                    255,
                    0.16
                    ) !important;

                color:
                    #facc15 !important;

                font-weight:
                    700;

                justify-content:
                    center;

                border-radius:
                    0.75rem 0 0 0.75rem !important;
            }


            .captcha-input {

                border-radius:
                    0 0.75rem 0.75rem 0 !important;
            }

        </style>

    </head>


    <body>

        <div id="ftech-meteor-layer" aria-hidden="true"></div>

        <!-- ========================================== -->
        <!-- HEADER                                     -->
        <!-- ========================================== -->

        <header>


            <nav
                class="
                navbar
                navbar-expand-lg
                bg-body
                border-bottom
                px-3
                py-3">


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

                            <li class="nav-item">
                                <a
                                    class="
                                    nav-link
                                    rounded-3
                                    px-3
                                    ${activeMenu == 'orders'
                                      ? 'active bg-primary-subtle text-primary-emphasis'
                                      : ''}"
                                    href="${pageContext.request.contextPath}/student/orders">
                                    Lịch sử đơn hàng
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

                            <div
                                class="
                                input-group
                                flex-grow-1"

                                style="
                                min-width:
                                300px;">


                                <span
                                    class="
                                    input-group-text
                                    bg-body-tertiary
                                    border-0">


                                    <i
                                        class="
                                        bi
                                        bi-search">
                                    </i>

                                </span>


                                <input
                                    type="search"

                                    class="
                                    form-control
                                    bg-body-tertiary
                                    border-0
                                    shadow-none"

                                    placeholder="Search"

                                    aria-label="Search"

                                    id="searchInput">


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

                            </div>


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
                                justify-content-center"

                                aria-label="Cài đặt">

                                <i class="bi bi-gear"></i>

                            </button>

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
                                    text-light
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

                                        data-bs-target="#signInModal">


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

                                        data-bs-target="#signUpModal">


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

                                        alt="Avatar"

                                        class="rounded-circle"

                                        style="
                                        width:100%;
                                        height:100%;
                                        object-fit:cover;">


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

                                        href="${pageContext.request.contextPath}/instructor/courses">


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

        <%@include file="/WEB-INF/view/student/cart-drawer.jsp" %>
        <%@include file="/WEB-INF/view/student/checkout-modal.jsp" %>

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
            document.addEventListener(
                    "DOMContentLoaded",
                    function () {

                        const meteorLayer =
                                document.getElementById(
                                        "ftech-meteor-layer"
                                        );

                        if (!meteorLayer) {
                            return;
                        }

                        meteorLayer.innerHTML = "";

                        const meteorCount =
                                window.innerWidth < 768
                                ? 20
                                : 50;

                        for (
                                let i = 0;
                                i < meteorCount;
                                i++
                                ) {

                            const meteor =
                                    document.createElement(
                                            "span"
                                            );

                            meteor.className =
                                    "ftech-meteor";

                            const left =
                                    Math.random()
                                    * 120
                                    - 10;

                            const top =
                                    Math.random()
                                    * 80
                                    - 40;

                            const length =
                                    50
                                    + Math.random()
                                    * 100;

                            const duration =
                                    3
                                    + Math.random()
                                    * 5;

                            const delay =
                                    -Math.random()
                                    * 12;

                            meteor.style.left =
                                    left + "vw";

                            meteor.style.top =
                                    top + "vh";

                            meteor.style.setProperty(
                                    "--meteor-length",
                                    length + "px"
                                    );

                            meteor.style.setProperty(
                                    "--meteor-duration",
                                    duration + "s"
                                    );

                            meteor.style.setProperty(
                                    "--meteor-delay",
                                    delay + "s"
                                    );

                            meteorLayer.appendChild(
                                    meteor
                                    );
                        }
                    }
            );
        </script>