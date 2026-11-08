<%@page contentType="text/html" pageEncoding="UTF-8"%>

<style>
    .ftech-footer {
        background-color: var(--bs-body-bg);
        border-top: 1px solid var(--bs-border-color) !important;
        color: var(--bs-body-color);
        transition: background-color 0.25s ease, border-color 0.25s ease, color 0.25s ease;
    }
    [data-bs-theme="dark"] .ftech-footer {
        background-color: #0b0f19 !important;
        border-top-color: rgba(255, 255, 255, 0.08) !important;
    }
    [data-bs-theme="light"] .ftech-footer {
        background-color: #f8fafc !important;
        border-top-color: rgba(0, 0, 0, 0.08) !important;
    }
    .ftech-footer-link {
        color: var(--bs-secondary-color);
        transition: color 0.2s ease, transform 0.2s ease;
        display: inline-block;
    }
    .ftech-footer-link:hover {
        color: var(--bs-primary) !important;
        transform: translateX(3px);
    }
</style>

<footer class="ftech-footer border-top mt-auto" aria-label="Ftech footer">
    <div class="container py-5">
        <div class="row g-4 g-lg-5">

            <%-- Brand --%>
            <div class="col-12 col-md-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/"
                   class="d-inline-flex align-items-center gap-2 text-decoration-none mb-3">
                    <span class="rounded-3 d-inline-flex align-items-center justify-content-center p-2 shadow-sm"
                          style="background: linear-gradient(135deg, #3b82f6, #6366f1); color: #fff;">
                        <i class="bi bi-mortarboard-fill fs-4" aria-hidden="true"></i>
                    </span>
                    <span class="fs-3 fw-bolder fst-italic logo-gradient">Ftech</span>
                </a>
                <p class="text-body-secondary mb-3" style="line-height: 1.6;">
                    Học lập trình theo lộ trình rõ ràng. Khám phá kiến thức,
                    thực hành kỹ năng và từng bước xây dựng tương lai của bạn.
                </p>
                <span class="small text-body-secondary d-inline-flex align-items-center gap-1">
                    <i class="bi bi-stars text-warning me-1" aria-hidden="true"></i>
                    Học hôm nay, phát triển ngày mai.
                </span>
            </div>

            <%-- Explore --%>
            <div class="col-6 col-md-3 col-lg-2">
                <h2 class="h6 fw-bold mb-3 text-body">Khám phá</h2>
                <nav class="d-flex flex-column gap-2" aria-label="Khám phá">
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/">Trang chủ</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/courses">Khóa học</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/#roadmap">Lộ trình học</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/#team">Đội ngũ</a>
                </nav>
            </div>

            <%-- Support --%>
            <div class="col-6 col-md-3 col-lg-2">
                <h2 class="h6 fw-bold mb-3 text-body">Hỗ trợ</h2>
                <nav class="d-flex flex-column gap-2" aria-label="Hỗ trợ">
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/faq">Câu hỏi thường gặp</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/contact">Liên hệ</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/terms">Điều khoản</a>
                    <a class="ftech-footer-link text-decoration-none" href="${pageContext.request.contextPath}/privacy">Bảo mật</a>
                </nav>
            </div>

            <%-- CTA --%>
            <div class="col-12 col-md-6 col-lg-4">
                <h2 class="h6 fw-bold mb-3 text-body">Bắt đầu hành trình của bạn</h2>
                <p class="text-body-secondary mb-3" style="line-height: 1.6;">
                    Sẵn sàng nâng cao kỹ năng? Hãy khám phá các khóa học phù hợp với bạn.
                </p>
                <a href="${pageContext.request.contextPath}/courses"
                   class="btn btn-primary rounded-pill px-4 py-2.5 shadow-sm fw-medium d-inline-flex align-items-center gap-2">
                    <span>Khám phá khóa học</span>
                    <i class="bi bi-arrow-up-right" aria-hidden="true"></i>
                </a>
            </div>
        </div>

        <%-- Copyright --%>
        <div class="border-top border-secondary border-opacity-10 mt-5 pt-4 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-2">
            <p class="small text-body-secondary mb-0">
                &copy; <%= java.time.Year.now().getValue() %> Ftech Inc. All rights reserved.
            </p>
            <p class="small text-body-secondary mb-0">
                Learn <span class="text-primary">&bull;</span>
                Practice <span class="text-primary">&bull;</span>
                Grow
            </p>
        </div>
    </div>
</footer>

<!-- Thư viện JS của Bootstrap (giúp menu mobile co giãn và dropdown hoạt động) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
  (function () {
    const html = document.documentElement;
    const themeBtn = document.getElementById('themeToggle');
    const icon = themeBtn ? themeBtn.querySelector('i') : null;

    // 1. Đồng bộ icon theo theme hiện tại
    function syncThemeIcon(theme) {
      if (icon) {
        icon.className = theme === 'dark' ? 'bi bi-brightness-high fs-5 text-warning' : 'bi bi-moon-stars fs-5 text-primary';
      }
    }

    const currentTheme = localStorage.getItem('ftech_theme') || 'dark';
    html.setAttribute('data-bs-theme', currentTheme);
    html.dataset.bsTheme = currentTheme;
    syncThemeIcon(currentTheme);

    // 2. Bắt sự kiện click để bật tắt Sáng / Tối
    if (themeBtn) {
      themeBtn.addEventListener('click', () => {
        const isDark = (html.getAttribute('data-bs-theme') || html.dataset.bsTheme) === 'dark';
        const newTheme = isDark ? 'light' : 'dark';
        
        html.setAttribute('data-bs-theme', newTheme);
        html.dataset.bsTheme = newTheme;
        localStorage.setItem('ftech_theme', newTheme);
        syncThemeIcon(newTheme);

        // Bắn sự kiện để các biểu đồ Chart.js và thành phần giao diện khác cập nhật lại nếu cần
        window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: newTheme } }));
      });
    }

    // 3. Phím tắt tiện ích: nhấn Ctrl + K để nhảy vào ô Search
    document.addEventListener('keydown', e => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        const search = document.getElementById('searchInput');
        if (search) {
          e.preventDefault();
          search.focus();
        }
      }
    });
  })();
</script>

</body>
</html>
