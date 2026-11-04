<%@ page pageEncoding="UTF-8" %>
<%!
    // Escape text rendered from form parameters or server error messages.
    private String esc(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String field(jakarta.servlet.http.HttpServletRequest request, String name, String fallback) {
        String value = request.getParameter(name);
        return esc(value == null ? fallback : value);
    }
%>
<%
    // The servlet should forward to this JSP on GET and when POST validation fails.
    // It must authenticate the instructor and provide InstructorId on the server.
    request.setAttribute("pageTitle", "Tạo khóa học | Ftech Instructor");
    String context = request.getContextPath();
    String priceType = request.getParameter("pricingType");
    boolean paidSelected = "PAID".equals(priceType);
    Object errorObj = request.getAttribute("error");
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .course-create-page { min-height: calc(100vh - 76px); background: var(--bs-body-bg); }
    .course-create-container { max-width: 1510px; }
    .course-create-sidebar {
        background: var(--bs-tertiary-bg); border: 1px solid var(--bs-border-color);
        border-radius: 22px; padding: 18px 12px;
    }
    .course-create-brand { display: flex; gap: 12px; align-items: center; padding: 12px 14px 19px;
        border-bottom: 1px solid var(--bs-border-color); margin-bottom: 16px; }
    .course-create-brand-icon { width: 45px; height: 45px; display: grid; place-items: center;
        border-radius: 13px; color: white; font-size: 1.25rem;
        background: linear-gradient(125deg, #4b63e8, #9a4be1); }
    .course-create-nav-title { padding: 10px 16px; font-size: .72rem; font-weight: 800;
        letter-spacing: .1em; color: var(--bs-secondary-color); }
    .course-create-nav { display: flex; align-items: center; gap: 11px; padding: 12px 16px;
        margin: 4px 0; border-radius: 13px; color: var(--bs-body-color);
        font-weight: 600; text-decoration: none; }
    .course-create-nav i { width: 22px; }
    .course-create-nav:hover { background: var(--bs-secondary-bg); color: var(--bs-body-color); }
    .course-create-nav.active { background: rgba(112, 97, 238, .17); color: #a69bff; }
    [data-bs-theme="light"] .course-create-nav.active { color: #5844d0; }
    .course-create-hero { overflow: hidden; position: relative; padding: 29px 33px;
        border: 1px solid rgba(143,126,255,.25); border-radius: 24px;
        background: radial-gradient(circle at 95% 12%, rgba(166,101,230,.37), transparent 44%),
                    linear-gradient(110deg, #182857, #242044 80%); color: #fff; }
    .course-create-hero p { color: #cad0e8; }
    .course-create-hero-mark { position: absolute; font-size: 9rem; top: -33px; right: 30px;
        color: rgba(255,255,255,.07); pointer-events: none; }
    .course-create-panel { background: var(--bs-tertiary-bg); border: 1px solid var(--bs-border-color);
        border-radius: 22px; padding: 25px; }
    .course-create-panel + .course-create-panel { margin-top: 20px; }
    .course-create-section-head { display: flex; align-items: center; gap: 12px; margin-bottom: 22px; }
    .course-create-section-icon { width: 42px; height: 42px; display: grid; place-items: center;
        background: rgba(118,93,241,.18); color: #a8a0ff; border-radius: 12px; font-size: 1.2rem; }
    .course-create-label { font-size: .88rem; font-weight: 650; margin-bottom: 8px; }
    .course-create-required { color: #f08e99; }
    .course-create-help { font-size: .8rem; color: var(--bs-secondary-color); margin-top: 6px; }
    .course-create-panel .form-control, .course-create-panel .form-select,
    .course-create-panel .input-group-text { border-color: var(--bs-border-color); }
    .course-create-panel .form-control, .course-create-panel .form-select { padding: .78rem .9rem; }
    .course-create-panel textarea { resize: vertical; min-height: 155px; }
    .course-create-price-option { border: 1px solid var(--bs-border-color); background: var(--bs-body-bg);
        border-radius: 15px; padding: 16px; height: 100%; cursor: pointer; }
    .course-create-price-option:has(input:checked) { border-color: #7770ed;
        box-shadow: 0 0 0 2px rgba(119,112,237,.12); }
    .course-create-summary { position: sticky; top: 20px; }
    .course-create-summary-note { background: var(--bs-body-bg); border: 1px dashed var(--bs-border-color);
        padding: 15px; border-radius: 13px; }
    .course-create-submit { color: white; border: 0; padding: .85rem 1.4rem;
        background: linear-gradient(100deg,#4965ec,#8150e8); }
    .course-create-submit:hover { color: #fff; filter: brightness(1.08); }
    @media (max-width: 1199.98px) { .course-create-summary { position: static; } }
    @media (max-width: 575.98px) {
        .course-create-hero { padding: 26px 21px; }
        .course-create-panel { padding: 19px; }
        .course-create-hero-mark { display: none; }
    }
</style>

<main class="course-create-page">
    <div class="container-fluid course-create-container py-4 py-lg-5">
        <div class="row g-4">
            <aside class="col-12 col-lg-3 col-xl-2" aria-label="Điều hướng giảng viên">
                <nav class="course-create-sidebar sticky-lg-top" style="top: 20px">
                    <div class="course-create-brand">
                        <div class="course-create-brand-icon"><i class="bi bi-mortarboard-fill"></i></div>
                        <div><div class="fw-bold">Instructor</div><div class="small text-body-secondary">Ftech Studio</div></div>
                    </div>
                    <div class="course-create-nav-title">KHÔNG GIAN GIẢNG VIÊN</div>
                    <a class="course-create-nav" href="<%= context %>/instructor/dashboard">
                        <i class="bi bi-grid-1x2-fill"></i> Tổng quan
                    </a>
                    <a class="course-create-nav" href="<%= context %>/instructor/courses">
                        <i class="bi bi-collection-play"></i> Khóa học của tôi
                    </a>
                    <a class="course-create-nav active" aria-current="page"
                       href="<%= context %>/instructor/courses?view=create">
                        <i class="bi bi-plus-square-fill"></i> Tạo khóa học
                    </a>
                    <hr class="mx-3 my-3">
                    <a class="course-create-nav" href="<%= context %>/">
                        <i class="bi bi-house-door"></i> Về trang chủ
                    </a>
                </nav>
            </aside>

            <section class="col-12 col-lg-9 col-xl-10" aria-label="Tạo khóa học mới">
                <div class="course-create-hero mb-4">
                    <div class="course-create-hero-mark"><i class="bi bi-journal-plus"></i></div>
                    <div class="position-relative">
                        <div class="small fw-bold mb-2" style="letter-spacing:.12em;color:#d9d1ff">FTECH INSTRUCTOR STUDIO</div>
                        <h1 class="fw-bold display-6 mb-2">Tạo khóa học mới</h1>
                        <p class="mb-0">Điền thông tin cơ bản và lưu khóa học ở trạng thái bản nháp.</p>
                    </div>
                </div>

                <% if (errorObj != null) { %>
                    <div class="alert alert-danger rounded-4" role="alert">
                        <i class="bi bi-exclamation-triangle me-2" aria-hidden="true"></i>
                        <%= esc(errorObj) %>
                    </div>
                <% } %>

                <form id="courseCreateForm" method="post"
                      action="<%= context %>/instructor/courses?action=create"
                      accept-charset="UTF-8">
                    <%-- Khong truyen InstructorId tu client; Servlet phai lay tu user da xac thuc. --%>
                    <div class="row g-4">
                        <div class="col-12 col-xl-8">
                            <section class="course-create-panel">
                                <div class="course-create-section-head">
                                    <span class="course-create-section-icon"><i class="bi bi-journal-text"></i></span>
                                    <div>
                                        <h2 class="h5 fw-bold mb-1">Thông tin khóa học</h2>
                                        <div class="small text-body-secondary">Các thông tin bắt buộc để tạo bản nháp</div>
                                    </div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="course-create-label" for="title">Tên khóa học <span class="course-create-required">*</span></label>
                                        <input class="form-control" type="text" id="title" name="title"
                                               maxlength="200" minlength="3" required
                                               placeholder="Ví dụ: Java Servlet và JSP từ cơ bản đến nâng cao"
                                               value="<%= field(request, "title", "") %>">
                                    </div>
                                    <div class="col-12">
                                        <label class="course-create-label" for="slug">Slug (đường dẫn khóa học) <span class="course-create-required">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text">/courses/</span>
                                            <input class="form-control" type="text" id="slug" name="slug"
                                                   required maxlength="220" pattern="[a-z0-9]+(?:-[a-z0-9]+)*"
                                                   placeholder="java-servlet-jsp-co-ban"
                                                   value="<%= field(request, "slug", "") %>">
                                        </div>
                                        <div class="course-create-help">Tự gợi ý từ tên khóa học; viết thường, không dấu, dùng dấu gạch ngang. Slug phải duy nhất.</div>
                                    </div>
                                    <div class="col-12">
                                        <label class="course-create-label" for="categoryId">Mã danh mục (CategoryId) <span class="course-create-required">*</span></label>
                                        <input class="form-control" type="number" id="categoryId" name="categoryId"
                                               min="1" step="1" inputmode="numeric" required placeholder="Nhập ID danh mục có trong database"
                                               value="<%= field(request, "categoryId", "") %>">
                                        <div class="course-create-help">Chọn ID đã tồn tại trong bảng Categories. Khi có CategoryDAO, có thể thay ô này bằng dropdown danh mục.</div>
                                    </div>
                                    <div class="col-12">
                                        <label class="course-create-label" for="description">Mô tả khóa học <span class="course-create-required">*</span></label>
                                        <textarea class="form-control" id="description" name="description" required
                                                  placeholder="Giới thiệu nội dung, mục tiêu và lợi ích của khóa học"><%= field(request, "description", "") %></textarea>
                                        <div class="course-create-help">Mô tả sẽ được lưu vào cột Description của bảng Courses.</div>
                                    </div>
                                </div>
                            </section>

                            <section class="course-create-panel">
                                <div class="course-create-section-head">
                                    <span class="course-create-section-icon"><i class="bi bi-tags"></i></span>
                                    <div>
                                        <h2 class="h5 fw-bold mb-1">Giá khóa học</h2>
                                        <div class="small text-body-secondary">Chọn hình thức và khai báo giá niêm yết</div>
                                    </div>
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-12 col-md-6">
                                        <label class="course-create-price-option d-block" for="typeFree">
                                            <span class="d-flex align-items-start gap-2">
                                                <input class="form-check-input mt-1" id="typeFree" type="radio" name="pricingType"
                                                       value="FREE" <%= paidSelected ? "" : "checked" %>>
                                                <span><strong class="d-block">Miễn phí</strong>
                                                    <small class="text-body-secondary">Giá niêm yết = 0 VND</small></span>
                                            </span>
                                        </label>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label class="course-create-price-option d-block" for="typePaid">
                                            <span class="d-flex align-items-start gap-2">
                                                <input class="form-check-input mt-1" id="typePaid" type="radio" name="pricingType"
                                                       value="PAID" <%= paidSelected ? "checked" : "" %>>
                                                <span><strong class="d-block">Trả phí</strong>
                                                    <small class="text-body-secondary">Giá niêm yết lớn hơn 0 VND</small></span>
                                            </span>
                                        </label>
                                    </div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-12 col-md-6">
                                        <label class="course-create-label" for="listPriceVnd">Giá niêm yết (VND) <span class="course-create-required">*</span></label>
                                        <div class="input-group">
                                            <input class="form-control" type="number" min="0" step="1" id="listPriceVnd"
                                                   name="listPriceVnd" required placeholder="0"
                                                   value="<%= field(request, "listPriceVnd", "0") %>">
                                            <span class="input-group-text">₫</span>
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label class="course-create-label" for="salePriceVnd">Giá ưu đãi (VND)</label>
                                        <div class="input-group">
                                            <input class="form-control" type="number" min="0" step="1" id="salePriceVnd"
                                                   name="salePriceVnd" placeholder="Để trống nếu không giảm giá"
                                                   value="<%= field(request, "salePriceVnd", "") %>">
                                            <span class="input-group-text">₫</span>
                                        </div>
                                        <div class="course-create-help">Chỉ áp dụng cho khóa học trả phí; không được lớn hơn giá niêm yết.</div>
                                    </div>
                                </div>
                            </section>
                        </div>

                        <div class="col-12 col-xl-4">
                            <div class="course-create-summary">
                                <section class="course-create-panel">
                                    <h2 class="h5 fw-bold mb-3">Lưu bản nháp</h2>
                                    <div class="course-create-summary-note mb-3">
                                        <div class="small text-body-secondary mb-1">Tên khóa học</div>
                                        <div id="previewTitle" class="fw-semibold mb-3 text-break">Chưa nhập tên khóa học</div>
                                        <div class="small text-body-secondary mb-1">Hình thức</div>
                                        <div id="previewPrice" class="fw-semibold">Miễn phí</div>
                                    </div>
                                    <p class="small text-body-secondary mb-3">
                                        Khóa học mới sẽ được lưu với trạng thái <strong>DRAFT</strong>.
                                        Sau khi lưu, giảng viên có thể tiếp tục xây dựng nội dung.
                                    </p>
                                    <button type="submit" class="btn course-create-submit fw-semibold w-100 rounded-pill">
                                        <i class="bi bi-floppy me-2"></i> Tạo khóa học
                                    </button>
                                    <a class="btn btn-outline-secondary rounded-pill w-100 mt-2"
                                       href="<%= context %>/instructor/courses">Hủy</a>
                                    <div class="small text-body-secondary mt-3">
                                        Lưu ý: Form này cần Servlet có POST mapping
                                        <code>/instructor/courses?action=create</code> để thực sự ghi dữ liệu.
                                    </div>
                                </section>
                            </div>
                        </div>
                    </div>
                </form>
            </section>
        </div>
    </div>
</main>

<script>
(function () {
    'use strict';

    const form = document.getElementById('courseCreateForm');
    if (!form) return;

    const title = document.getElementById('title');
    const slug = document.getElementById('slug');
    const free = document.getElementById('typeFree');
    const paid = document.getElementById('typePaid');
    const listPrice = document.getElementById('listPriceVnd');
    const salePrice = document.getElementById('salePriceVnd');
    const previewTitle = document.getElementById('previewTitle');
    const previewPrice = document.getElementById('previewPrice');

    let slugManuallyChanged = slug.value.trim() !== '';
    function slugify(value) {
        return value.toLowerCase().replace(/đ/g, 'd')
            .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
            .slice(0, 220).replace(/-+$/g, '');
    }

    title.addEventListener('input', function () {
        previewTitle.textContent = title.value.trim() || 'Chưa nhập tên khóa học';
        if (!slugManuallyChanged) slug.value = slugify(title.value);
    });
    slug.addEventListener('input', function () {
        slugManuallyChanged = slug.value.trim() !== '';
    });

    function syncPricing() {
        const isPaid = paid.checked;
        listPrice.readOnly = !isPaid;
        salePrice.disabled = !isPaid;
        if (!isPaid) {
            listPrice.value = '0';
            salePrice.value = '';
        }
        listPrice.min = isPaid ? '1' : '0';
        previewPrice.textContent = isPaid ? 'Trả phí' : 'Miễn phí';
        listPrice.setCustomValidity('');
        salePrice.setCustomValidity('');
    }

    function validatePricing() {
        listPrice.setCustomValidity('');
        salePrice.setCustomValidity('');
        if (paid.checked) {
            const amount = Number(listPrice.value);
            if (!Number.isFinite(amount) || amount <= 0) {
                listPrice.setCustomValidity('Giá niêm yết phải lớn hơn 0.');
                return false;
            }
            if (salePrice.value.trim() !== '' && Number(salePrice.value) > amount) {
                salePrice.setCustomValidity('Giá ưu đãi không được lớn hơn giá niêm yết.');
                return false;
            }
        }
        return true;
    }

    free.addEventListener('change', syncPricing);
    paid.addEventListener('change', syncPricing);
    listPrice.addEventListener('input', validatePricing);
    salePrice.addEventListener('input', validatePricing);
    form.addEventListener('submit', function (event) {
        if (!validatePricing() || !form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });

    previewTitle.textContent = title.value.trim() || 'Chưa nhập tên khóa học';
    syncPricing();
})();
</script>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>
