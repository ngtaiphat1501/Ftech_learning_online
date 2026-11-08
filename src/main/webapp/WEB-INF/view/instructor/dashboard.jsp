<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Course" %>
<%@ page import="model.User" %>

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
    User instructorUser = (User) request.getAttribute("instructorUser");
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    List<Map<String, Object>> recentEnrollments = (List<Map<String, Object>>) request.getAttribute("recentEnrollments");
    List<Map<String, Object>> monthlyRevList = (List<Map<String, Object>>) request.getAttribute("monthlyRevenue");

    String context = request.getContextPath();
    String instructorName = (instructorUser != null && instructorUser.getFullName() != null) ? instructorUser.getFullName() : "Giảng viên";

    request.setAttribute("pageTitle", "Tổng quan Giảng viên | Ftech Instructor Studio");

    java.math.BigDecimal totalRev = (java.math.BigDecimal) request.getAttribute("totalRevenue");
    java.math.BigDecimal balVnd = (java.math.BigDecimal) request.getAttribute("balanceVnd");
    Integer totalStu = (Integer) request.getAttribute("totalStudents");
    Integer pubCount = (Integer) request.getAttribute("publishedCount");

    long totalRevVal = totalRev != null ? totalRev.longValue() : 0L;
    long balVal = balVnd != null ? balVnd.longValue() : 0L;
    int totalStuVal = totalStu != null ? totalStu : 0;
    int pubCountVal = pubCount != null ? pubCount : 0;

    Integer selYear = (Integer) request.getAttribute("selectedYear");
    if (selYear == null) selYear = 2026;

    long[] monthRevArr = new long[12];
    int[] monthOrdersArr = new int[12];
    if (monthlyRevList != null) {
        for (Map<String, Object> m : monthlyRevList) {
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

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
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
                    <a class="course-studio-nav active" aria-current="page" href="<%= context %>/instructor/dashboard">
                        <i class="bi bi-grid-1x2-fill"></i> Tổng quan
                    </a>
                    <a class="course-studio-nav" href="<%= context %>/instructor/courses">
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
            <section class="col-12 col-lg-9 col-xl-10" aria-label="Tổng quan giảng viên">
                <!-- HERO BANNER -->
                <div class="course-studio-hero mb-4">
                    <div class="course-studio-hero-mark"><i class="bi bi-speedometer2"></i></div>
                    <div class="position-relative d-flex flex-wrap justify-content-between align-items-center gap-3">
                        <div>
                            <div class="small fw-bold mb-2" style="letter-spacing:.12em;color:#d9d1ff">FTECH INSTRUCTOR STUDIO</div>
                            <h1 class="fw-bold display-6 mb-2">Xin chào, <%= escapeHtml(instructorName) %>!</h1>
                            <p class="mb-0">Bảng điều khiển tổng quan số liệu tài chính, lượt học viên và hiệu quả các khóa học của bạn.</p>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="<%= context %>/instructor/course?view=create" class="btn course-studio-submit rounded-pill shadow-sm">
                                <i class="bi bi-plus-lg me-1"></i> Tạo khóa học
                            </a>
                            <a href="<%= context %>/instructor/courses" class="btn btn-outline-light rounded-pill px-3 shadow-sm">
                                <i class="bi bi-collection-play me-1"></i> Quản lý khóa
                            </a>
                        </div>
                    </div>
                </div>

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
                            <p class="text-secondary small mb-0">Thống kê tổng doanh thu thực nhận và số lượt đăng ký mới theo 12 tháng</p>
                        </div>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                            <i class="bi bi-broadcast me-1"></i>Thời gian thực
                        </span>
                    </div>
                    <div style="position: relative; height: 300px; width: 100%;">
                        <canvas id="instructorMonthlyChart"></canvas>
                    </div>
                </div>

                <!-- BOTTOM ROW: RECENT ENROLLMENTS & TOP COURSES -->
                <div class="row g-4 mb-4">
                    <!-- Recent Enrollments (Left) -->
                    <div class="col-12 col-lg-7">
                        <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden h-100">
                            <div class="card-header bg-transparent border-bottom border-secondary border-opacity-25 py-3 d-flex justify-content-between align-items-center">
                                <h5 class="fw-bold text-white mb-0">
                                    <i class="bi bi-person-check text-info me-2"></i>Học viên ghi danh mới nhất
                                </h5>
                                <a href="<%= context %>/instructor/courses" class="small text-info text-decoration-none">
                                    Xem tất cả →
                                </a>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-dark table-hover align-middle mb-0">
                                    <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                                        <tr>
                                            <th class="ps-3">Học viên</th>
                                            <th>Khóa học</th>
                                            <th class="text-center">Trạng thái</th>
                                            <th class="text-end pe-3">Ngày ghi danh</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (recentEnrollments == null || recentEnrollments.isEmpty()) { %>
                                            <tr>
                                                <td colspan="4" class="text-center py-4 text-secondary">Chưa có học viên nào ghi danh gần đây.</td>
                                            </tr>
                                        <% } else {
                                            for (Map<String, Object> re : recentEnrollments) {
                                                String cTitle = (String) re.get("courseTitle");
                                                if (cTitle != null && cTitle.length() > 25) {
                                                    cTitle = cTitle.substring(0, 25) + "...";
                                                }
                                                java.sql.Timestamp et = (java.sql.Timestamp) re.get("enrolledAt");
                                        %>
                                            <tr>
                                                <td class="ps-3">
                                                    <div class="text-white small fw-medium"><%= escapeHtml((String) re.get("studentName")) %></div>
                                                    <div class="text-secondary small" style="font-size: 0.75rem;"><%= escapeHtml((String) re.get("studentEmail")) %></div>
                                                </td>
                                                <td>
                                                    <span class="text-light small text-truncate d-inline-block" style="max-width: 180px;">
                                                        <%= escapeHtml(cTitle) %>
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill small">
                                                        <%= escapeHtml((String) re.get("accessStatus")) %>
                                                    </span>
                                                </td>
                                                <td class="text-end pe-3 small text-secondary">
                                                    <%= et != null ? sdf.format(et) : "N/A" %>
                                                </td>
                                            </tr>
                                        <% }
                                        } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Top Courses of Instructor (Right) -->
                    <div class="col-12 col-lg-5">
                        <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden h-100">
                            <div class="card-header bg-transparent border-bottom border-secondary border-opacity-25 py-3 d-flex justify-content-between align-items-center">
                                <h5 class="fw-bold text-white mb-0">
                                    <i class="bi bi-trophy text-warning me-2"></i>Khóa học nhiều học viên nhất
                                </h5>
                                <a href="<%= context %>/instructor/courses" class="small text-warning text-decoration-none">
                                    Quản lý khóa →
                                </a>
                            </div>
                            <div class="p-3">
                                <% if (courses == null || courses.isEmpty()) { %>
                                    <p class="text-secondary small mb-0 text-center py-4">Chưa có khóa học nào.</p>
                                <% } else { %>
                                    <div class="list-group list-group-flush gap-2">
                                        <% 
                                            // Top 4 courses
                                            int limitCount = Math.min(courses.size(), 4);
                                            for (int i = 0; i < limitCount; i++) {
                                                Course c = courses.get(i);
                                                String thumb = (c.getThumbnailUrl() != null && !c.getThumbnailUrl().isBlank())
                                                        ? c.getThumbnailUrl()
                                                        : "https://placehold.co/100x65/212529/ced4da?text=Course";
                                        %>
                                            <div class="list-group-item bg-dark-subtle border border-secondary border-opacity-25 rounded-3 d-flex align-items-center gap-3 p-2.5">
                                                <div class="fw-bold fs-5 text-secondary px-2">#<%= i + 1 %></div>
                                                <img src="<%= thumb %>" alt="thumb" class="rounded-2 object-fit-cover" style="width: 54px; height: 36px;">
                                                <div class="flex-grow-1 text-truncate">
                                                    <a href="<%= context %>/instructor/curriculum?courseId=<%= c.getId() %>"
                                                       class="fw-semibold text-white text-decoration-none small d-block text-truncate">
                                                        <%= escapeHtml(c.getTitle()) %>
                                                    </a>
                                                    <div class="small text-success font-monospace" style="font-size: 0.75rem;">
                                                        <%= c.getRevenueVnd() != null ? String.format("%,d đ", c.getRevenueVnd().longValue()) : "0 đ" %>
                                                    </div>
                                                </div>
                                                <div class="text-end">
                                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill small">
                                                        <i class="bi bi-people me-1"></i><%= c.getEnrollmentCount() %> HV
                                                    </span>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
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
