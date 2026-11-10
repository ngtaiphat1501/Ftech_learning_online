package controler;

import config.DBContext;
import dao.AdminDashboardDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.Order;
import model.User;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard", "/admin"})
public class AdminDashboardServlet extends HttpServlet {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
    private final UserDAO userDAO = new UserDAO();

    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Long currentUserId = null;
        User currentUser = null;
        if (session != null) {
            Object uid = session.getAttribute("userId");
            if (uid instanceof Number) {
                currentUserId = ((Number) uid).longValue();
            }
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUserId == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return false;
        }

        if (currentUser == null) {
            try {
                currentUser = userDAO.findById(currentUserId);
                if (currentUser != null && session != null) {
                    session.setAttribute("user", currentUser);
                    session.setAttribute("fullName", currentUser.getFullName());
                    session.setAttribute("roles", currentUser.getRoles());
                }
            } catch (SQLException ignored) {
            }
        }

        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị viên (Admin).");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdmin(request, response)) return;

        try (Connection conn = DBContext.getConnection()) {
            Map<String, Object> stats = dashboardDAO.getDashboardStats(conn);
            List<Order> recentOrders = dashboardDAO.getRecentOrders(conn, 6);
            List<Course> topCourses = dashboardDAO.getTopEnrolledCourses(conn, 5);

            int currentYear = java.time.LocalDate.now().getYear();
            List<Map<String, Object>> monthlyRevenue = dashboardDAO.getMonthlyRevenue(conn, currentYear);
            List<Map<String, Object>> categoryRevenue = dashboardDAO.getCategoryRevenue(conn);
            Map<String, Integer> orderStatusDistribution = dashboardDAO.getOrderStatusDistribution(conn);

            request.setAttribute("stats", stats);
            request.setAttribute("recentOrders", recentOrders);
            request.setAttribute("topCourses", topCourses);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("categoryRevenue", categoryRevenue);
            request.setAttribute("orderStatusDistribution", orderStatusDistribution);
            request.setAttribute("selectedYear", currentYear);
            request.setAttribute("activeMenu", "admin");
            request.setAttribute("adminTab", "dashboard");
            request.setAttribute("pageTitle", "Tổng quan Quản trị - Ftech LMS");

            request.getRequestDispatcher("/WEB-INF/view/admin/dashboard.jsp").forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("AdminDashboardServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải dữ liệu bảng điều khiển.", ex);
        }
    }
}
