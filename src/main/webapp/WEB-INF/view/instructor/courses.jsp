<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Course" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    String context = request.getContextPath();
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    request.setAttribute("pageTitle", "Khóa học của tôi | Ftech Instructor Studio");

    java.math.BigDecimal totalRev = (java.math.BigDecimal) request.getAttribute("totalRevenue");
    java.math.BigDecimal balVnd = (java.math.BigDecimal) request.getAttribute("balanceVnd");
    Integer totalStu = (Integer) request.getAttribute("totalStudents");
    Integer pubCount = (Integer) request.getAttribute("publishedCount");

    long totalRevVal = totalRev != null ? totalRev.longValue() : 0L;
    long balVal = balVnd != null ? balVnd.longValue() : 0L;
    int totalStuVal = totalStu != null ? totalStu : 0;
    int pubCountVal = pubCount != null ? pubCount : 0;

    List<java.util.Map<String, Object>> monthlyRevList = (List<java.util.Map<String, Object>>) request.getAttribute("monthlyRevenue");
    Integer selYear = (Integer) request.getAttribute("selectedYear");
    if (selYear == null) selYear = 2026;

    long[] monthRevArr = new long[12];
    int[] monthOrdersArr = new int[12];
    if (monthlyRevList != null) {
        for (java.util.Map<String, Object> m : monthlyRevList) {
            int mo = (Integer) m.get("month");
            if (mo >= 1 && mo <= 12) {
                java.math.BigDecimal r = (java.math.BigDecimal) m.get("revenue");
                monthRevArr[mo - 1] = r != null ? r.longValue() : 0L;
                Integer oc = (Integer) m.get("totalSold");
                monthOrdersArr[mo - 1] = oc != null ? oc : 0;
            }
        }
    }

    StringBuilder mRevSb = new StringBuilder("[");
    StringBuilder mOrdSb = new StringBuilder("[");
    for (int i = 0; i < 12; i++) {
        if (i > 0) {
            mRevSb.append(",");
            mOrdSb.append(",");
        }
        mRevSb.append(monthRevArr[i]);
        mOrdSb.append(monthOrdersArr[i]);
    }
    mRevSb.append("]");
    mOrdSb.append("]");
%>

<%@ include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>

<style>
    .course-studio-page { min-height: calc(100vh - 76px); background: var(--bs-body-bg); }
    .course-studio-container { max-width: 1510px; }
    .course-studio-sidebar {
        background: var(--bs-tertiary-bg); border: 1px solid var(--bs-border-color);
        border-radius: 22px; padding: 18px 12px;
    }
    .course-studio-brand { display: flex; gap: 12px; align-items: center; padding: 12px 14px 19px;
        border-bottom: 1px solid var(--bs-border-color); margin-bottom: 16px; }
    .course-studio-brand-icon { width: 45px; height: 45px; display: grid; place-items: center;
        border-radius: 13px; color: white; font-size: 1.25rem;
        background: linear-gradient(125deg, #4b63e8, #9a4be1); }
    .course-studio-nav-title { padding: 10px 16px; font-size: .72rem; font-weight: 800;
        letter-spacing: .1em; color: var(--bs-secondary-color); }
    .course-studio-nav { display: flex; align-items: center; gap: 11px; padding: 12px 16px;
        margin: 4px 0; border-radius: 13px; color: var(--bs-body-color);
        font-weight: 600; text-decoration: none; }
    .course-studio-nav i { width: 22px; }
    .course-studio-nav:hover { background: var(--bs-secondary-bg); color: var(--bs-body-color); }
    .course-studio-nav.active { background: rgba(112, 97, 238, .17); color: #a69bff; }
    [data-bs-theme="light"] .course-studio-nav.active { color: #5844d0; }
    .course-studio-hero { overflow: hidden; position: relative; padding: 29px 33px;
        border: 1px solid rgba(143,126,255,.25); border-radius: 24px;
        background: radial-gradient(circle at 95% 12%, rgba(166,101,230,.37), transparent 44%),
                    linear-gradient(110deg, #182857, #242044 80%); color: #fff; }
    .course-studio-hero p { color: #cad0e8; }
    .course-studio-hero-mark { position: absolute; font-size: 9rem; top: -33px; right: 30px;
        color: rgba(255,255,255,.07); pointer-events: none; }
    .course-studio-submit { color: white; border: 0; padding: .75rem 1.3rem;
        background: linear-gradient(100deg,#4965ec,#8150e8); text-decoration: none; }
    .course-studio-submit:hover { color: #fff; filter: brightness(1.08); }
</style>

<main class="course-studio-page">
    <div class="container-fluid course-studio-container py-4 py-lg-5">
        <div class="row g-4">
            <!-- STUDIO SIDEBAR -->
            <aside class="col-12 col-lg-3 col-xl-2" aria-label="Điều hướng giảng viên">
                <nav class="course-studio-sidebar sticky-lg-top" style="top: 20px">
                    <div class="course-studio-brand">
                        <div class="course-studio-brand-icon"><i class="bi bi-mortarboard-fill"></i></div>
                        <div><div class="fw-bold">Instructor</div><div class="small text-body-secondary">Ftech Studio</div></div>
                    </div>
                    <div class="course-studio-nav-title">KHÔNG GIAN GIẢNG VIÊN</div>
                    <a class="course-studio-nav" href="<%= context %>/instructor/courses">
                        <i class="bi bi-grid-1x2-fill"></i> Tổng quan
                    </a>
                    <a class="course-studio-nav active" aria-current="page" href="<%= context %>/instructor/courses">
                        <i class="bi bi-collection-play"></i> Khóa học của tôi
                    </a>
                    <a class="course-studio-nav" href="<%= context %>/instructor/course?view=create">
                        <i class="bi bi-plus-square-fill"></i> Tạo khóa học
                    </a>
                    <hr class="mx-3 my-3">
                    <a class="course-studio-nav" href="<%= context %>/">
                        <i class="bi bi-house-door"></i> Về trang chủ
                    </a>
                </nav>
            </aside>

            <!-- MAIN CONTENT AREA -->
            <section class="col-12 col-lg-9 col-xl-10" aria-label="Khóa học của tôi">
                <!-- HERO BANNER -->
                <div class="course-studio-hero mb-4">
                    <div class="course-studio-hero-mark"><i class="bi bi-mortarboard"></i></div>
                    <div class="position-relative d-flex flex-wrap justify-content-between align-items-center gap-3">
                        <div>
                            <div class="small fw-bold mb-2" style="letter-spacing:.12em;color:#d9d1ff">FTECH INSTRUCTOR STUDIO</div>
                            <h1 class="fw-bold display-6 mb-2">Khóa học của tôi</h1>
                            <p class="mb-0">Theo dõi doanh thu bán khóa, số lượng học viên và tình trạng xuất bản của các khóa học.</p>
                        </div>
                        <div>
                            <a href="<%= context %>/instructor/course?view=create" class="btn course-studio-submit rounded-pill shadow-sm">
                                <i class="bi bi-plus-lg me-1"></i> Tạo khóa học mới
                            </a>
                        </div>
                    </div>
                </div>

                <!-- ALERTS -->
                <% if ("create".equals(success)) { %>
                    <div class="alert alert-success rounded-4"><i class="bi bi-check-circle me-1"></i> Tạo khóa học thành công.</div>
                <% } %>
                <% if ("edit".equals(success)) { %>
                    <div class="alert alert-success rounded-4"><i class="bi bi-check-circle me-1"></i> Cập nhật khóa học thành công.</div>
                <% } %>
                <% if ("archive".equals(success)) { %>
                    <div class="alert alert-success rounded-4"><i class="bi bi-check-circle me-1"></i> Đã lưu trữ khóa học.</div>
                <% } %>
                <% if ("reopen".equals(success)) { %>
                    <div class="alert alert-success rounded-4"><i class="bi bi-check-circle me-1"></i> Đã mở lại khóa học để chỉnh sửa.</div>
                <% } %>
                <% if ("submit".equals(success)) { %>
                    <div class="alert alert-success rounded-4"><i class="bi bi-check-circle me-1"></i> Đã gửi khóa học để duyệt.</div>
                <% } %>
                <% if ("create".equals(error)) { %>
                    <div class="alert alert-warning rounded-4">Không thể tạo khóa học.</div>
                <% } %>
                <% if ("edit".equals(error)) { %>
                    <div class="alert alert-warning rounded-4">Không thể cập nhật khóa học.</div>
                <% } %>
                <% if ("archive".equals(error)) { %>
                    <div class="alert alert-warning rounded-4">Không thể lưu trữ khóa học.</div>
                <% } %>
                <% if ("reopen".equals(error)) { %>
                    <div class="alert alert-warning rounded-4">Không thể mở lại khóa học. Khóa học có thể đã có học viên.</div>
                <% } %>
                <% if ("submit-content".equals(error)) { %>
                    <div class="alert alert-warning rounded-4"><i class="bi bi-exclamation-triangle me-1"></i> Khóa học cần có ít nhất một chương và một bài học trước khi gửi duyệt.</div>
                <% } %>
                <% if ("submit".equals(error)) { %>
                    <div class="alert alert-warning rounded-4"><i class="bi bi-exclamation-triangle me-1"></i> Không thể gửi khóa học để duyệt. Khóa học có thể không còn ở trạng thái DRAFT.</div>
                <% } %>

                <!-- 4 KPI STATS CARDS -->
                <div class="row g-3 mb-4">
                    <div class="col-12 col-sm-6 col-xl-3">
                        <div class="card bg-dark border border-secondary border-opacity-25 shadow-sm rounded-4 h-100">
                            <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                                <div class="rounded-4 bg-success-subtle text-success p-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px;">
                                    <i class="bi bi-cash-stack fs-3"></i>
                                </div>
                                <div>
                                    <div class="text-secondary small fw-medium">Tổng doanh thu bán</div>
                                    <div class="fs-4 fw-bold text-success font-monospace"><%= String.format("%,d đ", totalRevVal) %></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-sm-6 col-xl-3">
                        <div class="card bg-dark border border-secondary border-opacity-25 shadow-sm rounded-4 h-100">
                            <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                                <div class="rounded-4 bg-primary-subtle text-primary p-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px;">
                                    <i class="bi bi-wallet2 fs-3"></i>
                                </div>
                                <div>
                                    <div class="text-secondary small fw-medium">Số dư ví giảng viên</div>
                                    <div class="fs-4 fw-bold text-primary font-monospace"><%= String.format("%,d đ", balVal) %></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-sm-6 col-xl-3">
                        <div class="card bg-dark border border-secondary border-opacity-25 shadow-sm rounded-4 h-100">
                            <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                                <div class="rounded-4 bg-info-subtle text-info p-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px;">
                                    <i class="bi bi-people-fill fs-3"></i>
                                </div>
                                <div>
                                    <div class="text-secondary small fw-medium">Tổng lượt học viên</div>
                                    <div class="fs-4 fw-bold text-white"><%= totalStuVal %></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-sm-6 col-xl-3">
                        <div class="card bg-dark border border-secondary border-opacity-25 shadow-sm rounded-4 h-100">
                            <div class="card-body p-3 p-md-4 d-flex align-items-center gap-3">
                                <div class="rounded-4 bg-warning-subtle text-warning p-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px;">
                                    <i class="bi bi-journal-check fs-3"></i>
                                </div>
                                <div>
                                    <div class="text-secondary small fw-medium">Khóa học mở bán</div>
                                    <div class="fs-4 fw-bold text-white"><%= pubCountVal %></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MONTHLY REVENUE ANALYTICS CHART (FULL WIDTH) -->
                <div class="card bg-dark border border-secondary border-opacity-25 shadow-sm rounded-4 p-3 p-md-4 mb-4">
                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                        <div>
                            <h5 class="fw-bold text-white mb-1">
                                <i class="bi bi-graph-up text-success me-2"></i>Biến động Doanh thu theo tháng (Năm <%= selYear %>)
                            </h5>
                            <p class="text-secondary small mb-0">Thống kê tổng doanh thu bán khóa học và số lượt học viên mới theo 12 tháng</p>
                        </div>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                            <i class="bi bi-check2-circle me-1"></i>Doanh thu thời gian thực
                        </span>
                    </div>
                    <div style="position: relative; height: 300px; width: 100%;">
                        <canvas id="instructorMonthlyChart"></canvas>
                    </div>
                </div>

                <!-- COURSES TABLE -->
                <% if (courses == null || courses.isEmpty()) { %>
                    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm text-center py-5">
                        <div class="card-body py-5">
                            <i class="bi bi-journal-x fs-1 text-secondary"></i>
                            <h2 class="h5 fw-bold text-white mt-3">Chưa có khóa học</h2>
                            <p class="text-secondary mb-4">Bạn chưa tạo khóa học nào.</p>
                            <a href="<%= context %>/instructor/course?view=create" class="btn course-studio-submit rounded-pill px-4">
                                <i class="bi bi-plus-lg me-1"></i> Tạo khóa học đầu tiên
                            </a>
                        </div>
                    </div>
                <% } else { %>
                    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden mb-4">
                        <div class="table-responsive">
                            <table class="table table-dark table-hover align-middle mb-0">
                                <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                                    <tr>
                                        <th class="px-4 py-3" style="width: 80px;">ID</th>
                                        <th class="py-3">Khóa học</th>
                                        <th class="py-3" style="width: 140px;">Trạng thái</th>
                                        <th class="py-3 text-center" style="width: 110px;">Học viên</th>
                                        <th class="py-3" style="width: 140px;">Doanh thu</th>
                                        <th class="py-3 text-end px-4" style="width: 320px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Course course : courses) {
                                        String status = course.getStatus();
                                    %>
                                    <tr>
                                        <td class="px-4">
                                            <span class="text-secondary font-monospace">#<%= course.getId() %></span>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-white mb-1"><%= escapeHtml(course.getTitle()) %></div>
                                            <div class="small text-secondary"><%= escapeHtml(course.getCategoryName()) %></div>
                                        </td>
                                        <td>
                                            <% if ("DRAFT".equals(status)) { %>
                                                <span class="badge text-bg-secondary rounded-pill">DRAFT</span>
                                            <% } else if ("PENDING_APPROVAL".equals(status)) { %>
                                                <span class="badge text-bg-warning rounded-pill">PENDING</span>
                                            <% } else if ("PUBLISHED".equals(status)) { %>
                                                <span class="badge text-bg-success rounded-pill">PUBLISHED</span>
                                            <% } else if ("ARCHIVED".equals(status)) { %>
                                                <span class="badge text-bg-dark rounded-pill">ARCHIVED</span>
                                            <% } else if ("SUSPENDED".equals(status)) { %>
                                                <span class="badge text-bg-danger rounded-pill">SUSPENDED</span>
                                            <% } else { %>
                                                <span class="badge text-bg-secondary rounded-pill"><%= escapeHtml(status) %></span>
                                            <% } %>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-secondary bg-opacity-25 text-light rounded-pill px-2.5">
                                                <i class="bi bi-people me-1"></i><%= course.getEnrollmentCount() %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="text-success fw-bold font-monospace">
                                                <%= course.getRevenueVnd() != null ? String.format("%,d đ", course.getRevenueVnd().longValue()) : "0 đ" %>
                                            </span>
                                        </td>
                                        <td class="text-end px-4">
                                            <div class="d-flex flex-wrap justify-content-end gap-1.5">
                                                <!-- CURRICULUM -->
                                                <a href="<%= context %>/instructor/curriculum?courseId=<%= course.getId() %>"
                                                   class="btn btn-sm btn-outline-secondary rounded-pill">
                                                    <i class="bi bi-list-nested me-1"></i>Nội dung
                                                </a>
                                                <!-- STUDENTS -->
                                                <a href="<%= context %>/instructor/students?courseId=<%= course.getId() %>"
                                                   class="btn btn-sm btn-outline-info rounded-pill">
                                                    <i class="bi bi-people me-1"></i>Học viên
                                                </a>
                                                <!-- QUIZ -->
                                                <a href="<%= context %>/instructor/quiz?courseId=<%= course.getId() %>"
                                                   class="btn btn-sm btn-outline-warning rounded-pill">
                                                    <i class="bi bi-patch-question me-1"></i>Đề thi
                                                </a>
                                                <!-- DRAFT ACTIONS -->
                                                <% if ("DRAFT".equals(course.getStatus())) { %>
                                                    <a href="<%= context %>/instructor/course?view=edit&id=<%= course.getId() %>"
                                                       class="btn btn-sm btn-outline-primary rounded-pill">
                                                        <i class="bi bi-pencil me-1"></i>Sửa
                                                    </a>
                                                    <form method="post" action="<%= context %>/instructor/course/submit" class="d-inline"
                                                          onsubmit="return confirm('Gửi khóa học này để Admin duyệt?');">
                                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                                        <button type="submit" class="btn btn-sm btn-success rounded-pill">
                                                            <i class="bi bi-send me-1"></i>Gửi duyệt
                                                        </button>
                                                    </form>
                                                <% } %>
                                                <!-- PENDING APPROVAL -->
                                                <% if ("PENDING_APPROVAL".equals(course.getStatus())) { %>
                                                    <span class="badge text-bg-warning align-self-center py-2 px-3 rounded-pill">
                                                        <i class="bi bi-hourglass-split me-1"></i>Chờ duyệt
                                                    </span>
                                                <% } %>
                                                <!-- PUBLISHED ACTIONS -->
                                                <% if ("PUBLISHED".equals(course.getStatus())) { %>
                                                    <form method="post" action="<%= context %>/instructor/course?action=archive" class="d-inline"
                                                          onsubmit="return confirm('Bạn có chắc muốn lưu trữ khóa học này?');">
                                                        <input type="hidden" name="id" value="<%= course.getId() %>">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill">
                                                            <i class="bi bi-archive me-1"></i>Lưu trữ
                                                        </button>
                                                    </form>
                                                <% } %>
                                                <!-- ARCHIVED ACTIONS -->
                                                <% if ("ARCHIVED".equals(course.getStatus())) { %>
                                                    <form method="post" action="<%= context %>/instructor/course?action=reopen" class="d-inline"
                                                          onsubmit="return confirm('Mở lại khóa học để tiếp tục chỉnh sửa?');">
                                                        <input type="hidden" name="id" value="<%= course.getId() %>">
                                                        <button type="submit" class="btn btn-sm btn-outline-success rounded-pill">
                                                            <i class="bi bi-arrow-counterclockwise me-1"></i>Mở lại
                                                        </button>
                                                    </form>
                                                <% } %>
                                                <!-- SUSPENDED -->
                                                <% if ("SUSPENDED".equals(course.getStatus())) { %>
                                                    <span class="badge text-bg-danger align-self-center py-2 px-3 rounded-pill">
                                                        <i class="bi bi-exclamation-triangle me-1"></i>Tạm ngưng
                                                    </span>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } %>
            </section>
        </div>
    </div>
</main>

<script>
(function initInstructorMonthlyChart() {
    function render() {
        if (typeof Chart === 'undefined') {
            setTimeout(render, 100);
            return;
        }

        const months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
        const revenueData = <%= mRevSb.toString() %>;
        const ordersData = <%= mOrdSb.toString() %>;

        const ctx = document.getElementById('instructorMonthlyChart');
        if (ctx) {
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: months,
                    datasets: [
                        {
                            type: 'line',
                            label: 'Lượt mua / Học viên mới',
                            data: ordersData,
                            borderColor: '#0dcaf0',
                            backgroundColor: '#0dcaf0',
                            borderWidth: 2,
                            tension: 0.35,
                            yAxisID: 'yOrders',
                            pointRadius: 4,
                            pointHoverRadius: 6
                        },
                        {
                            type: 'bar',
                            label: 'Doanh thu (VNĐ)',
                            data: revenueData,
                            backgroundColor: 'rgba(25, 135, 84, 0.7)',
                            borderColor: '#198754',
                            borderWidth: 1.5,
                            borderRadius: 6,
                            yAxisID: 'yRevenue'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false
                    },
                    plugins: {
                        legend: {
                            labels: { color: '#adb5bd', font: { size: 12 } }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    if (context.dataset.yAxisID === 'yRevenue') {
                                        return 'Doanh thu: ' + new Intl.NumberFormat('vi-VN').format(context.parsed.y) + ' đ';
                                    } else {
                                        return 'Học viên mới: ' + context.parsed.y + ' lượt';
                                    }
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: 'rgba(255, 255, 255, 0.08)' },
                            ticks: { color: '#adb5bd' }
                        },
                        yRevenue: {
                            type: 'linear',
                            position: 'left',
                            grid: { color: 'rgba(255, 255, 255, 0.08)' },
                            ticks: {
                                color: '#adb5bd',
                                callback: function (val) {
                                    if (val >= 1000000) return (val / 1000000) + 'M';
                                    if (val >= 1000) return (val / 1000) + 'k';
                                    return val;
                                }
                            }
                        },
                        yOrders: {
                            type: 'linear',
                            position: 'right',
                            grid: { drawOnChartArea: false },
                            ticks: { color: '#0dcaf0', stepSize: 1 }
                        }
                    }
                }
            });
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', render);
    } else {
        render();
    }
})();
</script>

<%@ include file="/WEB-INF/view/layout/publicFooter.jsp" %>
