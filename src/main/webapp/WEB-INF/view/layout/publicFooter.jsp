<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%--
  FTECH PUBLIC FOOTER
  Bootstrap 5 + Bootstrap Icons (assumes already loaded in PublicHeader.jsp).
  Replace suggested routes with actual servlet mappings in your application.
  This is a footer fragment. Keep the existing closing </body> and </html>
  tags in your layout if your current publicFooter.jsp contains them.
--%>
<footer class="bg-dark text-light border-top border-secondary" aria-label="Ftech footer">
    <div class="container py-5">
        <div class="row g-4 g-lg-5">

            <%-- Brand --%>
            <div class="col-12 col-md-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/"
                   class="d-inline-flex align-items-center gap-2 text-white text-decoration-none mb-3">
                    <span class="bg-primary rounded-3 d-inline-flex align-items-center justify-content-center p-2">
                        <i class="bi bi-mortarboard-fill fs-4" aria-hidden="true"></i>
                    </span>
                    <span class="fs-3 fw-bold">Ftech</span>
                </a>
                <p class="text-white-50 mb-3">
                    Học lập trình theo lộ trình rõ ràng. Khám phá kiến thức,
                    thực hành kỹ năng và từng bước xây dựng tương lai của bạn.
                </p>
                <span class="small text-white-50">
                    <i class="bi bi-stars me-1" aria-hidden="true"></i>
                    Học hôm nay, phát triển ngày mai.
                </span>
            </div>
            <%-- Explore --%>
            <div class="col-6 col-md-3 col-lg-2">
                <h2 class="h6 fw-bold mb-3">Khám phá</h2>
                <nav class="d-flex flex-column gap-3" aria-label="Khám phá">
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/">Trang chủ</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/courses">Khóa học</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/#roadmap">Lộ trình học</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/#team">Đội ngũ</a>
                </nav>
            </div>

            <%-- Support --%>
            <div class="col-6 col-md-3 col-lg-2">
                <h2 class="h6 fw-bold mb-3">Hỗ trợ</h2>
                <nav class="d-flex flex-column gap-3" aria-label="Hỗ trợ">
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/faq">Câu hỏi thường gặp</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/contact">Liên hệ</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/terms">Điều khoản</a>
                    <a class="text-white-50 text-decoration-none" href="${pageContext.request.contextPath}/privacy">Bảo mật</a>
                </nav>
            </div>

            <%-- CTA --%>
            <div class="col-12 col-md-6 col-lg-4">
                <h2 class="h6 fw-bold mb-3">Bắt đầu hành trình của bạn</h2>
                <p class="text-white-50 mb-3">
                    Sẵn sàng nâng cao kỹ năng? Hãy khám phá các khóa học phù hợp với bạn.
                </p>
                <a href="${pageContext.request.contextPath}/courses"
                   class="btn btn-primary rounded-pill px-4 py-2">
                    Khám phá khóa học
                    <i class="bi bi-arrow-up-right ms-2" aria-hidden="true"></i>
                </a>
            </div>
        </div>

        <%-- Copyright --%>
        <div class="border-top border-secondary mt-5 pt-4 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-2">
            <p class="small text-white-50 mb-0">
                &copy; <%= java.time.Year.now().getValue() %> Ftech. All rights reserved.
            </p>
            <p class="small text-white-50 mb-0">
                Learn <span class="text-primary">&bull;</span>
                Practice <span class="text-primary">&bull;</span>
                Grow
            </p>
        </div>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
