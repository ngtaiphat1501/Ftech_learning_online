<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<!-- Spline Viewer: chỉ nạp một lần trên trang này -->
<script type="module" src="https://cdn.spline.design/@splinetool/viewer@2.0.93/build/spline-viewer.js"></script>

<!-- Bootstrap xử lý toàn bộ grid/card/spacing. CSS nhỏ này chỉ dành cho lớp Spline 3D và responsive. -->
<style>
  .ftech-hero {
    min-height: 620px;
    isolation: isolate;
  }
  .ftech-hero-copy {
    position: relative;
    z-index: 2;
  }
  .ftech-hero-3d {
    position: absolute;
    z-index: 0;
    top: 0;
    right: 0;
    width: 70%;
    height: 100%;
    overflow: hidden;
  }
  .ftech-hero-3d spline-viewer {
    display: block;
    width: 100%;
    height: 100%;
    transform: scale(1.15);
    transform-origin: 70% 50%;
  }
  /* Làm mềm phần giao giữa chữ và scene; không chặn tương tác chuột */
  .ftech-hero::after {
    content: "";
    position: absolute;
    z-index: 1;
    inset: 0;
    background: linear-gradient(90deg,
      var(--bs-body-bg) 0%,
      var(--bs-body-bg) 17%,
      color-mix(in srgb, var(--bs-body-bg) 86%, transparent) 32%,
      transparent 62%);
    pointer-events: none;
  }
  @media (max-width: 991.98px) {
    .ftech-hero { min-height: 0; }
    .ftech-hero::after { display: none; }
    .ftech-hero-3d {
      position: relative;
      width: 100%;
      height: 360px;
      margin-top: -8px;
    }
    .ftech-hero-3d spline-viewer {
      transform: none;
    }
  }
  @media (max-width: 575.98px) {
    .ftech-hero-3d { height: 300px; }
  }
  @media (prefers-reduced-motion: reduce) {
    .ftech-hero-3d { scroll-behavior: auto; }
  }
</style>

<main>

  <!-- ================= HERO: SLOGAN + SPLINE NẰM DƯỚI LỚP NỘI DUNG ================= -->
  <section class="ftech-hero position-relative overflow-hidden d-flex align-items-center">

    <!-- Nội dung nằm trên lớp 3D -->
    <div class="container position-relative py-5">
      <div class="row align-items-center">
        <div class="col-12 col-lg-7 col-xl-6 ftech-hero-copy">

          <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis px-3 py-2 mb-4">
            Nền tảng học lập trình theo lộ trình
          </span>

          <h1 class="display-3 fw-bold lh-sm mb-4">
            Một hành trình rõ ràng,<br>
            <span class="text-primary">một tương lai rộng mở.</span>
          </h1>

          <p class="lead text-body-secondary mb-4">
            Ftech đồng hành cùng bạn từ những kiến thức đầu tiên đến kỹ năng thực tế:
            khám phá khóa học, luyện tập và từng bước chinh phục mục tiêu của mình.
          </p>

          <div class="d-flex flex-wrap gap-3 mb-4">
            <a href="${pageContext.request.contextPath}/courses"
               class="btn btn-primary btn-lg rounded-pill px-4">Khám phá khóa học ↗</a>
            <a href="#roadmap" class="btn btn-outline-primary btn-lg rounded-pill px-4">Xem lộ trình ↓</a>
          </div>

          <div class="d-flex flex-wrap gap-3 gap-md-4 small text-body-secondary">
            <span>✓ Học có lộ trình</span>
            <span>✓ Luyện tập thực tế</span>
            <span>✓ Theo dõi tiến độ</span>
          </div>

        </div>
      </div>
    </div>

    <!-- Chiếm 70% chiều rộng Hero trên desktop, ở lớp nền phía phải -->
    <div class="ftech-hero-3d" aria-label="Mô hình 3D trang trí tương tác của Ftech">
      <spline-viewer
        url="https://prod.spline.design/H7xybsdJWgc6ZWbN/scene.splinecode">
      </spline-viewer>
    </div>

  </section>

  <!-- ================= LỘ TRÌNH TĨNH: 4 BƯỚC, KHÔNG CÓ TAB ================= -->
  <section id="roadmap" class="container py-5 my-lg-4">
    <div class="text-center mb-5">
      <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis px-3 py-2 mb-3">
        LEARNING JOURNEY
      </span>
      <h2 class="display-6 fw-bold">Lộ trình học tập cùng Ftech</h2>
      <p class="text-body-secondary mx-auto mb-0" style="max-width: 650px;">
        Chỉ với bốn chặng rõ ràng, bạn biết mình sẽ bắt đầu từ đâu, học những gì và đạt được kết quả nào.
      </p>
    </div>

    <div class="row row-cols-1 row-cols-md-2 row-cols-xl-4 g-3 g-lg-4">
      <div class="col">
        <article class="card h-100 bg-body-tertiary border-0 shadow-sm rounded-4">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="badge rounded-pill text-bg-primary px-3 py-2">Bước 01</span>
              <i class="bi bi-house-door fs-2 text-primary" aria-hidden="true"></i>
            </div>
            <h3 class="h5 fw-bold">Khám phá</h3>
            <p class="text-body-secondary mb-0">
              Từ trang chủ, tìm hiểu các lĩnh vực và chọn hướng học phù hợp với mục tiêu của bạn.
            </p>
          </div>
        </article>
      </div>

      <div class="col">
        <article class="card h-100 bg-body-tertiary border-0 shadow-sm rounded-4">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="badge rounded-pill text-bg-primary px-3 py-2">Bước 02</span>
              <i class="bi bi-grid-1x2 fs-2 text-primary" aria-hidden="true"></i>
            </div>
            <h3 class="h5 fw-bold">Không gian môn học</h3>
            <p class="text-body-secondary mb-0">
              Truy cập tài liệu, lộ trình và các khóa học thuộc môn học bạn quan tâm.
            </p>
          </div>
        </article>
      </div>

      <div class="col">
        <article class="card h-100 bg-body-tertiary border-0 shadow-sm rounded-4">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="badge rounded-pill text-bg-primary px-3 py-2">Bước 03</span>
              <i class="bi bi-journal-code fs-2 text-primary" aria-hidden="true"></i>
            </div>
            <h3 class="h5 fw-bold">Học và luyện tập</h3>
            <p class="text-body-secondary mb-0">
              Theo dõi bài giảng, thực hành kiến thức và củng cố bằng bài tập hoặc quiz.
            </p>
          </div>
        </article>
      </div>

      <div class="col">
        <article class="card h-100 bg-body-tertiary border-0 shadow-sm rounded-4">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="badge rounded-pill text-bg-primary px-3 py-2">Bước 04</span>
              <i class="bi bi-trophy fs-2 text-primary" aria-hidden="true"></i>
            </div>
            <h3 class="h5 fw-bold">Đạt thành quả</h3>
            <p class="text-body-secondary mb-0">
              Xem tiến độ, kết quả học tập và vận dụng kiến thức vào dự án thực tế.
            </p>
          </div>
        </article>
      </div>
    </div>
  </section>

  <!-- ================= ĐỘI NGŨ (GIỮ NGUYÊN 5 THÀNH VIÊN) ================= -->
  <section id="team" class="bg-body-tertiary py-5">
    <div class="container">
      <div class="text-center mb-5">
        <h2 class="fw-bold">Đội ngũ thực hiện</h2>
        <p class="text-body-secondary mb-0">Năm thành viên cùng xây dựng Ftech.</p>
      </div>

      <div class="row row-cols-2 row-cols-md-3 row-cols-lg-5 g-3 justify-content-center">
        <div class="col">
          <div class="card h-100 border-0 text-center p-3">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary-subtle text-primary-emphasis fs-2 fw-bold d-flex align-items-center justify-content-center">A</div>
            </div>
            <h3 class="h6 fw-semibold mb-1">Thành viên 1</h3>
            <p class="small text-body-secondary mb-0">Trưởng nhóm</p>
          </div>
        </div>
        <div class="col">
          <div class="card h-100 border-0 text-center p-3">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary-subtle text-primary-emphasis fs-2 fw-bold d-flex align-items-center justify-content-center">B</div>
            </div>
            <h3 class="h6 fw-semibold mb-1">Thành viên 2</h3>
            <p class="small text-body-secondary mb-0">Backend</p>
          </div>
        </div>
        <div class="col">
          <div class="card h-100 border-0 text-center p-3">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary-subtle text-primary-emphasis fs-2 fw-bold d-flex align-items-center justify-content-center">C</div>
            </div>
            <h3 class="h6 fw-semibold mb-1">Thành viên 3</h3>
            <p class="small text-body-secondary mb-0">Frontend</p>
          </div>
        </div>
        <div class="col">
          <div class="card h-100 border-0 text-center p-3">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary-subtle text-primary-emphasis fs-2 fw-bold d-flex align-items-center justify-content-center">D</div>
            </div>
            <h3 class="h6 fw-semibold mb-1">Thành viên 4</h3>
            <p class="small text-body-secondary mb-0">Cơ sở dữ liệu</p>
          </div>
        </div>
        <div class="col">
          <div class="card h-100 border-0 text-center p-3">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary-subtle text-primary-emphasis fs-2 fw-bold d-flex align-items-center justify-content-center">E</div>
            </div>
            <h3 class="h6 fw-semibold mb-1">Thành viên 5</h3>
            <p class="small text-body-secondary mb-0">Kiểm thử</p>
          </div>
        </div>
      </div>
    </div>
  </section>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
