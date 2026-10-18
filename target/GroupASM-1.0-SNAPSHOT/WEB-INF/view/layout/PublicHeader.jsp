<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${empty pageTitle ? 'Ftech PRJ đỉnh cao' : pageTitle}</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <style>
    /* Chỉ giữ lại 2 thứ Bootstrap không có sẵn */
    .logo-gradient { background: linear-gradient(90deg,#3b82f6,#c084fc,#f472b6); -webkit-background-clip: text; background-clip: text; color: transparent; }
    .btn-icon { width: 2.75rem; height: 2.75rem; }
  </style>
</head>
<body>

<header>
  <nav class="navbar navbar-expand-lg bg-body border-bottom px-3 py-3">
    <div class="container-fluid">

      <!-- Logo -->
      <a class="navbar-brand fw-bolder fst-italic fs-3 me-4 logo-gradient" href="${pageContext.request.contextPath}/">Ftech</a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse"
              data-bs-target="#fesNav" aria-controls="fesNav" aria-expanded="false" aria-label="Mở menu">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="fesNav">

        <!-- Menu -->
        <ul class="navbar-nav me-auto gap-lg-1">
          <li class="nav-item">
            <a class="nav-link rounded-3 px-3 ${activeMenu == 'home' ? 'active bg-primary-subtle text-primary-emphasis' : ''}"
               href="${pageContext.request.contextPath}/">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link rounded-3 px-3 ${activeMenu == 'courses' ? 'active bg-primary-subtle text-primary-emphasis' : ''}"
               href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a>
          </li>
        </ul>

        <!-- Right side -->
        <div class="d-flex align-items-center gap-2 mt-3 mt-lg-0">

          <!-- Search -->
          <div class="input-group flex-grow-1" style="min-width: 320px;">
            <span class="input-group-text bg-body-tertiary border-0"><i class="bi bi-search"></i></span>
            <input type="search" class="form-control bg-body-tertiary border-0 shadow-none" placeholder="Search" aria-label="Search" id="searchInput">
            <span class="input-group-text bg-body-tertiary border-0 d-none d-md-flex gap-1">
              <kbd>Ctrl</kbd><kbd>K</kbd>
            </span>
          </div>

          <!-- Theme -->
          <button type="button" id="themeToggle" class="btn btn-icon rounded-circle bg-body-tertiary border-0 d-inline-flex align-items-center justify-content-center" aria-label="Đổi giao diện">
            <i class="bi bi-brightness-high"></i>
          </button>

          <!-- Giỏ hàng -->
          <a href="${pageContext.request.contextPath}/cart"
             class="btn btn-icon position-relative rounded-circle bg-body-tertiary border-0 d-inline-flex align-items-center justify-content-center"
             aria-label="Giỏ hàng">
            <i class="bi bi-cart3"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
              ${empty cartCount ? 0 : cartCount}
            </span>
          </a>

          <!-- Settings -->
          <button type="button" class="btn btn-icon rounded-circle bg-body-tertiary border-0 d-inline-flex align-items-center justify-content-center" aria-label="Cài đặt">
            <i class="bi bi-gear"></i>
          </button>

        </div>
      </div>
    </div>
  </nav>
</header>