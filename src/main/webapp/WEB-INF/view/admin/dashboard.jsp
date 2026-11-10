<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.Order"%>
<%@page import="model.Course"%>

<%
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    List<Course> topCourses = (List<Course>) request.getAttribute("topCourses");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM HH:mm");

    BigDecimal totalRevenue = (stats != null && stats.get("totalRevenue") != null) ? (BigDecimal) stats.get("totalRevenue") : BigDecimal.ZERO;
    int totalStudents = (stats != null && stats.get("totalStudents") != null) ? (Integer) stats.get("totalStudents") : 0;
    int totalInstructors = (stats != null && stats.get("totalInstructors") != null) ? (Integer) stats.get("totalInstructors") : 0;
    int publishedCourses = (stats != null && stats.get("publishedCourses") != null) ? (Integer) stats.get("publishedCourses") : 0;
    int pendingCourses = (stats != null && stats.get("pendingCourses") != null) ? (Integer) stats.get("pendingCourses") : 0;
    int paidOrders = (stats != null && stats.get("paidOrders") != null) ? (Integer) stats.get("paidOrders") : 0;
    int pendingOrders = (stats != null && stats.get("pendingOrders") != null) ? (Integer) stats.get("pendingOrders") : 0;
    int reviewOrders = (stats != null && stats.get("reviewOrders") != null) ? (Integer) stats.get("reviewOrders") : 0;
    int totalEnrollments = (stats != null && stats.get("totalEnrollments") != null) ? (Integer) stats.get("totalEnrollments") : 0;

    List<Map<String, Object>> monthlyRevList = (List<Map<String, Object>>) request.getAttribute("monthlyRevenue");
    List<Map<String, Object>> catRevList = (List<Map<String, Object>>) request.getAttribute("categoryRevenue");
    Map<String, Integer> orderDistMap = (Map<String, Integer>) request.getAttribute("orderStatusDistribution");
    Integer selYear = (Integer) request.getAttribute("selectedYear");
    if (selYear == null) selYear = 2026;

    long[] monthRevArr = new long[12];
    int[] monthOrdersArr = new int[12];
    if (monthlyRevList != null) {
        for (Map<String, Object> m : monthlyRevList) {
            int mo = (Integer) m.get("month");
            if (mo >= 1 && mo <= 12) {
                BigDecimal r = (BigDecimal) m.get("revenue");
                monthRevArr[mo - 1] = r != null ? r.longValue() : 0L;
                Integer oc = (Integer) m.get("orderCount");
                monthOrdersArr[mo - 1] = oc != null ? oc : 0;
            }
        }
    }

    StringBuilder catNamesSb = new StringBuilder("[");
    StringBuilder catRevsSb = new StringBuilder("[");
    if (catRevList != null && !catRevList.isEmpty()) {
        for (int i = 0; i < catRevList.size(); i++) {
            Map<String, Object> c = catRevList.get(i);
            String cName = (String) c.get("categoryName");
            BigDecimal cRev = (BigDecimal) c.get("revenue");
            if (i > 0) {
                catNamesSb.append(",");
                catRevsSb.append(",");
            }
            catNamesSb.append("\"").append(cName != null ? cName.replace('"', '\'') : "Khác").append("\"");
            catRevsSb.append(cRev != null ? cRev.longValue() : 0L);
        }
    }
    catNamesSb.append("]");
    catRevsSb.append("]");

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

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>
<%@include file="/WEB-INF/view/admin/adminNav.jsp" %>

<main class="container mb-5" style="min-height: 65vh;">
    <!-- Header title -->
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 pb-3 mb-4 border-bottom border-secondary border-opacity-25">
        <div>
            <h1 class="h3 fw-bold text-white mb-1">
                <i class="bi bi-speedometer2 text-primary me-2"></i>Bảng Điều Khiển Quản Trị Hệ Thống
            </h1>
            <p class="text-secondary small mb-0">
                Thống kê số liệu học tập thời gian thực, doanh thu thực nhận từ đơn hàng PAID và tình trạng vận hành nền tảng Ftech.
            </p>
        </div>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/approvals" class="btn btn-warning rounded-pill px-3 fw-medium">
                <i class="bi bi-patch-check me-1"></i>Duyệt khóa học 
                <% if (pendingCourses > 0) { %>
                    <span class="badge bg-danger rounded-pill ms-1"><%= pendingCourses %></span>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-light rounded-pill px-3">
                <i class="bi bi-receipt me-1"></i>Đối soát đơn
            </a>
        </div>
    </div>

    <!-- KPI Metric Cards Row -->
    <div class="row g-3 mb-4">
        <!-- Revenue Card -->
        <div class="col-12 col-md-6 col-xl-3">
            <div class="card bg-dark border border-success border-opacity-25 rounded-4 p-3 shadow-sm h-100">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-secondary small fw-medium">Tổng Doanh Thu (PAID)</span>
                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                        <i class="bi bi-cash-stack"></i>
                    </span>
                </div>
                <div class="h3 fw-bold text-success font-monospace mb-1">
                    <%= currency.format(totalRevenue) %> đ
                </div>
                <div class="small text-secondary">
                    Từ <strong class="text-white"><%= paidOrders %></strong> đơn hoàn tất thanh toán
                </div>
            </div>
        </div>

        <!-- Students Card -->
        <div class="col-6 col-md-6 col-xl-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm h-100">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-secondary small fw-medium">Học Viên Đăng Ký</span>
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill">
                        <i class="bi bi-people"></i>
                    </span>
                </div>
                <div class="h3 fw-bold text-white mb-1"><%= totalStudents %></div>
                <div class="small text-secondary">
                    <strong class="text-info"><%= totalEnrollments %></strong> lượt ghi danh khóa học
                </div>
            </div>
        </div>

        <!-- Courses Card -->
        <div class="col-6 col-md-6 col-xl-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm h-100">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-secondary small fw-medium">Khóa Học Đang Mở</span>
                    <span class="badge bg-info-subtle text-info border border-info-subtle rounded-pill">
                        <i class="bi bi-journal-bookmark"></i>
                    </span>
                </div>
                <div class="h3 fw-bold text-white mb-1"><%= publishedCourses %></div>
                <div class="small text-secondary">
                    <% if (pendingCourses > 0) { %>
                        <a href="${pageContext.request.contextPath}/admin/approvals" class="text-warning text-decoration-none">
                            <i class="bi bi-hourglass-split"></i> <%= pendingCourses %> khóa chờ duyệt →
                        </a>
                    <% } else { %>
                        <span class="text-success"><i class="bi bi-check2"></i> Đã duyệt toàn bộ</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Instructors Card -->
        <div class="col-12 col-md-6 col-xl-3">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-3 shadow-sm h-100">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-secondary small fw-medium">Đội Ngũ Giảng Viên</span>
                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill">
                        <i class="bi bi-person-video3"></i>
                    </span>
                </div>
                <div class="h3 fw-bold text-white mb-1"><%= totalInstructors %></div>
                <div class="small text-secondary">
                    Chuyên gia sáng tạo nội dung
                </div>
            </div>
        </div>
    </div>

    <!-- Revenue Analytics & Charts Row -->
    <div class="row g-4 mb-4">
        <!-- Monthly Revenue & Orders Chart -->
        <div class="col-12 col-xl-8">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm p-3 p-md-4 h-100">
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                    <div>
                        <h5 class="fw-bold text-white mb-1">
                            <i class="bi bi-graph-up text-success me-2"></i>Biểu đồ Doanh thu &amp; Đơn hàng theo tháng (<%= selYear %>)
                        </h5>
                        <p class="text-secondary small mb-0">Biến động doanh thu thực nhận (PAID) và tổng lượt giao dịch thành công theo từng tháng</p>
                    </div>
                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                        <i class="bi bi-broadcast me-1"></i>Thời gian thực
                    </span>
                </div>
                <div style="position: relative; height: 320px; width: 100%;">
                    <canvas id="adminRevenueChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Category Revenue Breakdown Chart -->
        <div class="col-12 col-xl-4">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm p-3 p-md-4 h-100">
                <div class="mb-3">
                    <h5 class="fw-bold text-white mb-1">
                        <i class="bi bi-pie-chart text-info me-2"></i>Cơ cấu theo Danh mục
                    </h5>
                    <p class="text-secondary small mb-0">Tỷ trọng doanh thu theo từng nhóm chủ đề</p>
                </div>
                <div style="position: relative; height: 260px; width: 100%; display: flex; align-items: center; justify-content: center;">
                    <canvas id="adminCategoryChart"></canvas>
                </div>
                <div class="text-center mt-2 small text-secondary">
                    Tổng danh mục tạo doanh thu: <strong class="text-white"><%= catRevList != null ? catRevList.size() : 0 %></strong>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content: Recent Orders & Top Courses -->
    <div class="row g-4 mb-4">
        <!-- Recent Orders (Left) -->
        <div class="col-12 col-lg-7">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden h-100">
                <div class="card-header bg-transparent border-bottom border-secondary border-opacity-25 py-3 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold text-white mb-0">
                        <i class="bi bi-receipt text-primary me-2"></i>Đơn hàng mới nhất
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="small text-primary text-decoration-none">
                        Xem tất cả đơn →
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-dark table-hover align-middle mb-0">
                        <thead class="table-secondary bg-opacity-10 text-secondary small text-uppercase">
                            <tr>
                                <th class="ps-3">Mã đơn</th>
                                <th>Học viên</th>
                                <th class="text-end">Tổng tiền</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-end pe-3">Thời gian</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (recentOrders == null || recentOrders.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-secondary">Chưa có giao dịch nào</td>
                                </tr>
                            <% } else {
                                for (Order o : recentOrders) {
                                    String st = o.getStatus() != null ? o.getStatus().toUpperCase() : "";
                                    String badgeClass = "bg-secondary";
                                    if ("PAID".equals(st)) badgeClass = "bg-success";
                                    else if ("PENDING_PAYMENT".equals(st)) badgeClass = "bg-warning text-dark";
                                    else if ("PAYMENT_REVIEW".equals(st)) badgeClass = "bg-info text-dark";
                            %>
                                <tr>
                                    <td class="ps-3 font-monospace fw-semibold text-white">#<%= o.getOrderCode() %></td>
                                    <td>
                                        <div class="text-white small fw-medium"><%= o.getStudentName() %></div>
                                        <div class="text-secondary small" style="font-size: 0.75rem;"><%= o.getStudentEmail() %></div>
                                    </td>
                                    <td class="text-end font-monospace fw-bold text-success small">
                                        <%= currency.format(o.getTotalVnd()) %> đ
                                    </td>
                                    <td class="text-center">
                                        <span class="badge <%= badgeClass %> rounded-pill px-2 py-0.5" style="font-size: 0.7rem;"><%= st %></span>
                                    </td>
                                    <td class="text-end pe-3 small text-secondary">
                                        <%= o.getCreatedAt() != null ? o.getCreatedAt().format(dtf) : "N/A" %>
                                    </td>
                                </tr>
                            <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Top Courses (Right) -->
        <div class="col-12 col-lg-5">
            <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden h-100">
                <div class="card-header bg-transparent border-bottom border-secondary border-opacity-25 py-3">
                    <h5 class="fw-bold text-white mb-0">
                        <i class="bi bi-trophy text-warning me-2"></i>Khóa học được học nhiều nhất
                    </h5>
                </div>
                <div class="p-3">
                    <% if (topCourses == null || topCourses.isEmpty()) { %>
                        <p class="text-secondary small mb-0 text-center py-4">Chưa có dữ liệu thống kê khóa học.</p>
                    <% } else { %>
                        <div class="list-group list-group-flush gap-2">
                            <% for (int i = 0; i < topCourses.size(); i++) {
                                Course tc = topCourses.get(i);
                                String thumb = (tc.getThumbnailUrl() != null && !tc.getThumbnailUrl().isBlank())
                                        ? tc.getThumbnailUrl()
                                        : "https://placehold.co/100x65/212529/ced4da?text=Course";
                            %>
                                <div class="list-group-item bg-dark-subtle border border-secondary border-opacity-25 rounded-3 d-flex align-items-center gap-3 p-2.5">
                                    <div class="fw-bold fs-5 text-secondary px-2">#<%= i + 1 %></div>
                                    <img src="<%= thumb %>" alt="thumb" class="rounded-2 object-fit-cover" style="width: 58px; height: 38px;">
                                    <div class="flex-grow-1 text-truncate">
                                        <a href="${pageContext.request.contextPath}/course?id=<%= tc.getCourseId() %>"
                                           class="fw-semibold text-white text-decoration-none small d-block text-truncate">
                                            <%= tc.getTitle() %>
                                        </a>
                                        <div class="small text-secondary" style="font-size: 0.75rem;">
                                            GV: <%= tc.getInstructorName() %>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill small">
                                            <i class="bi bi-person-check me-1"></i><%= tc.getReviewCount() %> HV
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
</main>

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
(function initAdminCharts() {
    function render() {
        if (typeof Chart === 'undefined') {
            setTimeout(render, 100);
            return;
        }
    const months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
    const revenueData = <%= mRevSb.toString() %>;
    const ordersData = <%= mOrdSb.toString() %>;

    // 1. Admin Monthly Revenue Chart
    const ctxRev = document.getElementById('adminRevenueChart');
    if (ctxRev && typeof Chart !== 'undefined') {
        new Chart(ctxRev, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [
                    {
                        type: 'line',
                        label: 'Số đơn PAID',
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
                        backgroundColor: 'rgba(25, 135, 84, 0.65)',
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
                                    return 'Số đơn: ' + context.parsed.y + ' đơn';
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

    // 2. Admin Category Revenue Chart
    const ctxCat = document.getElementById('adminCategoryChart');
    if (ctxCat && typeof Chart !== 'undefined') {
        const catLabels = <%= catNamesSb.toString() %>;
        const catData = <%= catRevsSb.toString() %>;
        
        new Chart(ctxCat, {
            type: 'doughnut',
            data: {
                labels: catLabels.length > 0 ? catLabels : ['Chưa có dữ liệu'],
                datasets: [{
                    data: catData.length > 0 ? catData : [1],
                    backgroundColor: [
                        '#0d6efd',
                        '#198754',
                        '#ffc107',
                        '#0dcaf0',
                        '#d63384',
                        '#fd7e14'
                    ],
                    borderWidth: 2,
                    borderColor: '#212529'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#adb5bd', boxWidth: 12, font: { size: 11 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const val = context.parsed;
                                return ' ' + context.label + ': ' + new Intl.NumberFormat('vi-VN').format(val) + ' đ';
                            }
                        }
                    }
                },
                cutout: '65%'
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

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
