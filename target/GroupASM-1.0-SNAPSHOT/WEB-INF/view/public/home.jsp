
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="/WEB-INF/view/layout/publicHeader.jsp" %>

<main>

  <!-- ================= HERO + LỘ TRÌNH ================= -->
  <section class="container py-5">
    <div class="row align-items-center g-5">

      <!-- Trái: slogan + lộ trình -->
      <div class="col-lg-6">
        <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-normal px-3 py-2 mb-3">
          Nền tảng học lập trình theo lộ trình
        </span>

        <h1 class="display-5 fw-bold mb-3">
          Một hành trình rõ ràng, từ trang chủ đến thành quả thực tế
        </h1>

        <p class="lead text-body-secondary mb-4">
          Ftech dẫn bạn từ trang chủ vào không gian từng môn học, qua các khóa học có bài giảng
          và bài tập, rồi đến những kết quả cụ thể: dự án, thành tích và định hướng nghề nghiệp.
        </p>

        <div class="d-flex flex-wrap gap-2 mb-5">
          <a href="#" class="btn btn-primary rounded-pill px-4">Bắt đầu học</a>
          <a href="#team" class="btn btn-outline-secondary rounded-pill px-4">Gặp đội ngũ</a>
        </div>

        <!-- Lộ trình học -->
        <div class="list-group" id="roadmap" role="tablist">

          <button type="button" class="list-group-item list-group-item-action active d-flex gap-3 align-items-start"
                  data-bs-toggle="list" data-bs-target="#step1" role="tab" aria-controls="step1">
            <span class="badge rounded-pill text-bg-secondary mt-1">1</span>
            <span>
              <span class="d-block fw-semibold">Trang chủ</span>
              <span class="d-block small">Điểm bắt đầu: chọn hướng đi và làm quen với hệ thống.</span>
            </span>
          </button>

          <button type="button" class="list-group-item list-group-item-action d-flex gap-3 align-items-start"
                  data-bs-toggle="list" data-bs-target="#step2" role="tab" aria-controls="step2">
            <span class="badge rounded-pill text-bg-secondary mt-1">2</span>
            <span>
              <span class="d-block fw-semibold">Không gian môn học</span>
              <span class="d-block small">Mỗi môn có chỗ riêng: tài liệu, lộ trình và tiến độ.</span>
            </span>
          </button>

          <button type="button" class="list-group-item list-group-item-action d-flex gap-3 align-items-start"
                  data-bs-toggle="list" data-bs-target="#step3" role="tab" aria-controls="step3">
            <span class="badge rounded-pill text-bg-secondary mt-1">3</span>
            <span>
              <span class="d-block fw-semibold">Khóa học và luyện tập</span>
              <span class="d-block small">Học qua bài giảng có cấu trúc, làm bài tập ngay sau mỗi bài.</span>
            </span>
          </button>

          <button type="button" class="list-group-item list-group-item-action d-flex gap-3 align-items-start"
                  data-bs-toggle="list" data-bs-target="#step4" role="tab" aria-controls="step4">
            <span class="badge rounded-pill text-bg-secondary mt-1">4</span>
            <span>
              <span class="d-block fw-semibold">Thành quả</span>
              <span class="d-block small">Dự án thực tế, thành tích và định hướng nghề nghiệp.</span>
            </span>
          </button>

        </div>
      </div>

      <!-- Phải: nội dung đổi theo bước đang chọn -->
      <div class="col-lg-6">
        <div class="tab-content">

          <div class="tab-pane fade show active" id="step1" role="tabpanel">
            <div class="card border-primary-subtle text-center py-5">
              <div class="card-body py-5">
                <i class="bi bi-house-door-fill display-1 text-primary"></i>
                <h2 class="h4 mt-3">Trang chủ</h2>
                <p class="text-body-secondary mb-0">Chọn hướng đi phù hợp với bạn.</p>
              </div>
            </div>
          </div>

          <div class="tab-pane fade" id="step2" role="tabpanel">
            <div class="card border-primary-subtle text-center py-5">
              <div class="card-body py-5">
                <i class="bi bi-compass-fill display-1 text-primary"></i>
                <h2 class="h4 mt-3">Không gian môn học</h2>
                <p class="text-body-secondary mb-0">Tài liệu, lộ trình và tiến độ của từng môn.</p>
              </div>
            </div>
          </div>

          <div class="tab-pane fade" id="step3" role="tabpanel">
            <div class="card border-primary-subtle text-center py-5">
              <div class="card-body py-5">
                <i class="bi bi-journal-code display-1 text-primary"></i>
                <h2 class="h4 mt-3">Khóa học và luyện tập</h2>
                <p class="text-body-secondary mb-0">Bài giảng rõ ràng, bài tập ngay sau mỗi bài.</p>
              </div>
            </div>
          </div>

          <div class="tab-pane fade" id="step4" role="tabpanel">
            <div class="card border-primary-subtle text-center py-5">
              <div class="card-body py-5">
                <i class="bi bi-trophy-fill display-1 text-primary"></i>
                <h2 class="h4 mt-3">Thành quả</h2>
                <p class="text-body-secondary mb-0">Dự án, thành tích và định hướng nghề nghiệp.</p>
              </div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </section>

  <!-- ================= ĐỘI NGŨ ================= -->
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

