package controler;

import config.DBContext;
import dao.OrderDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;
import util.ExcelUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders", "/admin/order", "/admin/payment/reconcile", "/admin/orders/export"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
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

        String statusFilter = request.getParameter("status");
        String search = request.getParameter("q");
        String action = request.getParameter("action");
        String servletPath = request.getServletPath();

        // Bonus: Excel Export
        if ("export".equalsIgnoreCase(action) || "/admin/orders/export".equalsIgnoreCase(servletPath)) {
            try (Connection conn = DBContext.getConnection()) {
                List<Order> orders = orderDAO.getAllOrdersForAdmin(conn, statusFilter, search);
                response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                response.setHeader("Content-Disposition", "attachment; filename=\"Ftech_Orders_" + System.currentTimeMillis() + ".xlsx\"");
                ExcelUtil.exportOrders(orders, response.getOutputStream());
                return;
            } catch (SQLException ex) {
                getServletContext().log("Excel export error", ex);
                throw new ServletException("Lỗi hệ thống khi xuất file Excel đơn hàng.", ex);
            }
        }

        try (Connection conn = DBContext.getConnection()) {
            List<Order> orders = orderDAO.getAllOrdersForAdmin(conn, statusFilter, search);
            request.setAttribute("orders", orders);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("search", search);
            request.setAttribute("activeMenu", "admin");
            request.setAttribute("adminTab", "orders");
            request.setAttribute("pageTitle", "Quản lý đơn hàng & Đối soát - Admin Ftech");

            request.getRequestDispatcher("/WEB-INF/view/admin/orders.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("AdminOrderServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải danh sách đơn hàng.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        // Check if route is reconcile
        boolean isReconcile = "/admin/payment/reconcile".equalsIgnoreCase(servletPath) || "reconcile".equalsIgnoreCase(action);

        try (Connection conn = DBContext.getConnection()) {
            if (isReconcile) {
                long orderId = Long.parseLong(request.getParameter("orderId"));
                String targetStatus = request.getParameter("targetStatus");
                if (targetStatus == null || targetStatus.isBlank()) {
                    targetStatus = "PAID";
                }
                String note = request.getParameter("note");

                boolean ok = orderDAO.reconcileOrder(conn, orderId, targetStatus.trim().toUpperCase(), note);
                if (ok) {
                    String msg = "PAID".equalsIgnoreCase(targetStatus)
                            ? "Đối soát thành công! Đã kích hoạt quyền học và chuyển đơn sang PAID."
                            : "Đã cập nhật trạng thái đơn sang: " + targetStatus;
                    response.sendRedirect(request.getContextPath() + "/admin/orders?msg=" + urlEncode(msg));
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/orders?error=" + urlEncode("Không tìm thấy đơn hàng cần đối soát."));
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders");
            }

        } catch (SQLException ex) {
            getServletContext().log("AdminOrderServlet error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=" + urlEncode("Lỗi đối soát đơn hàng: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=" + urlEncode("Mã đơn hàng không hợp lệ."));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
