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

  <!-- ================= ĐỘI NGŨ THỰC HIỆN DỰ ÁN ================= -->
  <section id="team" class="py-5" style="background-color: var(--ftech-nav-bg, var(--bs-body-bg));">
    <div class="container">
      <div class="text-center mb-5">
        <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis px-3 py-2 mb-2">Đội ngũ Ftech</span>
        <h2 class="fw-bold display-6 mb-2">Thành viên & Phân công nhiệm vụ</h2>
        <p class="text-body-secondary mb-0">Năm thành viên cùng phối hợp nghiên cứu, thiết kế và phát triển nền tảng học trực tuyến Ftech.</p>
      </div>

      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-5 g-4 justify-content-center">
        <!-- Thành viên 1: Vương Hoàng Phúc -->
        <div class="col">
          <div class="card h-100 border border-secondary border-opacity-25 rounded-4 text-center p-3 shadow-sm">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-primary text-white fs-2 fw-bold d-flex align-items-center justify-content-center shadow-sm">P</div>
            </div>
            <h3 class="h6 fw-bold mb-1 text-body">Vương Hoàng Phúc</h3>
            <div class="mb-2">
              <span class="badge bg-primary-subtle text-primary-emphasis rounded-pill px-2.5 py-1 small">Trưởng nhóm</span>
            </div>
            <div class="small text-body-secondary border-top border-secondary border-opacity-10 pt-2 text-start" style="font-size: 0.8rem; line-height: 1.5;">
              <span class="fw-semibold text-body d-block mb-1"><i class="bi bi-briefcase me-1 text-primary"></i>Phân công:</span>
              • Quản lý Hồ sơ cá nhân (Profile)<br>
              • Đổi mật khẩu & Bảo mật<br>
              • Thiết kế & Tối ưu hóa UI/UX<br>
              • Chuẩn hóa Dark / Light theme
            </div>
          </div>
        </div>

        <!-- Thành viên 2: Nguyễn Phát Tài -->
        <div class="col">
          <div class="card h-100 border border-secondary border-opacity-25 rounded-4 text-center p-3 shadow-sm">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-success text-white fs-2 fw-bold d-flex align-items-center justify-content-center shadow-sm">T</div>
            </div>
            <h3 class="h6 fw-bold mb-1 text-body">Nguyễn Phát Tài</h3>
            <div class="mb-2">
              <span class="badge bg-success-subtle text-success-emphasis rounded-pill px-2.5 py-1 small">Fullstack Developer</span>
            </div>
            <div class="small text-body-secondary border-top border-secondary border-opacity-10 pt-2 text-start" style="font-size: 0.8rem; line-height: 1.5;">
              <span class="fw-semibold text-body d-block mb-1"><i class="bi bi-briefcase me-1 text-success"></i>Phân công:</span>
              • Quản trị hệ thống Admin<br>
              • Giỏ hàng & Thanh toán<br>
              • Thống kê Doanh thu (Chart.js)<br>
              • Tích hợp hệ thống & Bố cục chung
            </div>
          </div>
        </div>

        <!-- Thành viên 3: Huỳnh Trọng Nhân -->
        <div class="col">
          <div class="card h-100 border border-secondary border-opacity-25 rounded-4 text-center p-3 shadow-sm">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-info text-white fs-2 fw-bold d-flex align-items-center justify-content-center shadow-sm">N</div>
            </div>
            <h3 class="h6 fw-bold mb-1 text-body">Huỳnh Trọng Nhân</h3>
            <div class="mb-2">
              <span class="badge bg-info-subtle text-info-emphasis rounded-pill px-2.5 py-1 small">Backend Developer</span>
            </div>
            <div class="small text-body-secondary border-top border-secondary border-opacity-10 pt-2 text-start" style="font-size: 0.8rem; line-height: 1.5;">
              <span class="fw-semibold text-body d-block mb-1"><i class="bi bi-briefcase me-1 text-info"></i>Phân công:</span>
              • Phòng học trực tuyến (Learning)<br>
              • Lưu tiến độ bài học video<br>
              • Bình luận & Thảo luận bài học<br>
              • Hệ thống Đánh giá khóa học
            </div>
          </div>
        </div>

        <!-- Thành viên 4: Giang Quốc Khánh -->
        <div class="col">
          <div class="card h-100 border border-secondary border-opacity-25 rounded-4 text-center p-3 shadow-sm">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-secondary text-white fs-2 fw-bold d-flex align-items-center justify-content-center shadow-sm">K</div>
            </div>
            <h3 class="h6 fw-bold mb-1 text-body">Giang Quốc Khánh</h3>
            <div class="mb-2">
              <span class="badge bg-secondary-subtle text-secondary-emphasis rounded-pill px-2.5 py-1 small">Backend Developer</span>
            </div>
            <div class="small text-body-secondary border-top border-secondary border-opacity-10 pt-2 text-start" style="font-size: 0.8rem; line-height: 1.5;">
              <span class="fw-semibold text-body d-block mb-1"><i class="bi bi-briefcase me-1 text-secondary"></i>Phân công:</span>
              • Không gian Giảng viên (Studio)<br>
              • Soạn thảo giáo trình khóa học<br>
              • Xác thực Đăng nhập & Đăng ký<br>
              • Bảo mật phiên & Phân quyền
            </div>
          </div>
        </div>

        <!-- Thành viên 5: Trần Minh Khoa -->
        <div class="col">
          <div class="card h-100 border border-secondary border-opacity-25 rounded-4 text-center p-3 shadow-sm">
            <div class="ratio ratio-1x1 w-50 mx-auto mb-3">
              <div class="rounded-circle bg-warning text-dark fs-2 fw-bold d-flex align-items-center justify-content-center shadow-sm">K</div>
            </div>
            <h3 class="h6 fw-bold mb-1 text-body">Trần Minh Khoa</h3>
            <div class="mb-2">
              <span class="badge bg-warning-subtle text-warning-emphasis rounded-pill px-2.5 py-1 small">Backend & Khảo thí</span>
            </div>
            <div class="small text-body-secondary border-top border-secondary border-opacity-10 pt-2 text-start" style="font-size: 0.8rem; line-height: 1.5;">
              <span class="fw-semibold text-body d-block mb-1"><i class="bi bi-briefcase me-1 text-warning"></i>Phân công:</span>
              • Kiểm duyệt khóa học (Approval)<br>
              • Quản trị danh mục & Admin Board<br>
              • Hệ thống Bài trắc nghiệm (Quiz)<br>
              • Ngân hàng câu hỏi & Chấm điểm
            </div>
          </div>
        </div>      </div>
    </div>
  </section>

</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
