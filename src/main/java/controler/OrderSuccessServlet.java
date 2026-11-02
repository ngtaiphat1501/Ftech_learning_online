package controler;

import model.Order;
import service.CheckoutService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "OrderSuccessServlet", urlPatterns = {"/student/order-success"})
public class OrderSuccessServlet extends HttpServlet {

    private final CheckoutService checkoutService = new CheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long studentId = null;
        if (session != null) {
            Object val = session.getAttribute("userId");
            if (val instanceof Number) {
                studentId = ((Number) val).longValue();
            }
        }

        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return;
        }

        String orderCode = request.getParameter("orderCode");
        if (orderCode == null || orderCode.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            Order order = checkoutService.getOrderDetails(orderCode.trim(), studentId);

            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            request.setAttribute("order", order);
            request.setAttribute("pageTitle", "Thanh toán thành công - " + order.getOrderCode());

            request.getRequestDispatcher("/WEB-INF/view/student/order-success.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("OrderSuccessServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải hóa đơn thanh toán.", ex);
        }
    }
}
