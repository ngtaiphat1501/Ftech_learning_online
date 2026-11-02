package controler;

import config.DBContext;
import dao.OrderDAO;
import model.Order;
import util.CartCsrf;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "OrderServlet", urlPatterns = {"/student/orders", "/student/order", "/student/order/cancel"})
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    private Long getStudentId(HttpSession session) {
        if (session == null) return null;
        Object val = session.getAttribute("userId");
        if (val instanceof Number) {
            long id = ((Number) val).longValue();
            return id > 0 ? id : null;
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return;
        }

        String path = request.getServletPath();

        try (Connection conn = DBContext.getConnection()) {

            if ("/student/order".equals(path)) {
                // View Single Order Detail
                String idParam = request.getParameter("id");
                String codeParam = request.getParameter("code");

                Order order = null;
                if (idParam != null && !idParam.isBlank()) {
                    try {
                        long orderId = Long.parseLong(idParam.trim());
                        order = orderDAO.getOrderDetail(conn, orderId, studentId);
                    } catch (NumberFormatException ignored) {}
                } else if (codeParam != null && !codeParam.isBlank()) {
                    order = orderDAO.findOrderByCode(conn, codeParam.trim(), studentId);
                }

                if (order == null) {
                    response.sendRedirect(request.getContextPath() + "/student/orders");
                    return;
                }

                request.setAttribute("order", order);
                request.setAttribute("pageTitle", "Chi tiết đơn hàng #" + order.getOrderCode() + " - Ftech");
                request.setAttribute("csrfToken", CartCsrf.getOrCreate(session));

                request.getRequestDispatcher("/WEB-INF/view/student/order-detail.jsp")
                        .forward(request, response);
                return;
            }

            // Default: /student/orders (Order History List)
            String status = request.getParameter("status");
            if (status == null || status.isBlank()) {
                status = "ALL";
            }

            List<Order> orders = orderDAO.getOrdersByStudentId(conn, studentId, status);

            String sessionMessage = (String) session.getAttribute("orderMessage");
            if (sessionMessage != null) {
                request.setAttribute("orderMessage", sessionMessage);
                session.removeAttribute("orderMessage");
            }

            request.setAttribute("orders", orders);
            request.setAttribute("currentStatus", status.toUpperCase());
            request.setAttribute("csrfToken", CartCsrf.getOrCreate(session));
            request.setAttribute("pageTitle", "Lịch sử đơn hàng - Ftech");

            request.getRequestDispatcher("/WEB-INF/view/student/orders.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("OrderServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải lịch sử đơn hàng.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return;
        }

        if (!CartCsrf.isValid(session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token không hợp lệ.");
            return;
        }

        String path = request.getServletPath();

        if ("/student/order/cancel".equals(path)) {
            String idStr = request.getParameter("orderId");
            if (idStr != null && !idStr.isBlank()) {
                try {
                    long orderId = Long.parseLong(idStr.trim());
                    try (Connection conn = DBContext.getConnection()) {
                        boolean cancelled = orderDAO.cancelOrder(conn, orderId, studentId);
                        if (cancelled) {
                            session.setAttribute("orderMessage", "Đã hủy đơn hàng thành công.");
                        } else {
                            session.setAttribute("orderMessage", "Không thể hủy đơn hàng này (chỉ được hủy đơn chưa thanh toán).");
                        }
                    }
                } catch (NumberFormatException | SQLException ex) {
                    getServletContext().log("Cancel order error", ex);
                    session.setAttribute("orderMessage", "Lỗi khi xử lý hủy đơn hàng.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/student/orders");
        }
    }
}
