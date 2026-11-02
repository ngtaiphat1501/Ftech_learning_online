package controler;

import dao.CartDAO;
import model.CartItem;
import service.CartService;
import service.CartService.Result;
import util.CartCsrf;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "CartServlet", urlPatterns = {"/student/cart"})
public class CartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    // Lấy học viên đang đăng nhập từ Session
    private Long getStudentId(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("userId");
        if (!(value instanceof Number)) {
            return null;
        }

        long id = ((Number) value).longValue();
        return id > 0 ? id : null;
    }

    // Đọc CourseId từ Request
    private Long getCourseId(HttpServletRequest request) {
        try {
            long id = Long.parseLong(request.getParameter("courseId"));
            return id > 0 ? id : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    // GET: Xem giỏ hàng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        if (studentId == null) {
            String view = request.getParameter("view");
            if ("drawer".equals(view)) {
                response.sendError(401, "Vui long dang nhap");
            } else {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            }
            return;
        }

        try {
            // Lấy các khóa học trong giỏ
            List<CartItem> items = cartService.getCartItems(studentId);

            // Tính toán tổng tiền, giá gốc và số tiền tiết kiệm
            BigDecimal total = BigDecimal.ZERO;
            BigDecimal listTotal = BigDecimal.ZERO;

            for (CartItem item : items) {
                if (item.getCurrentPriceVnd() != null) {
                    total = total.add(item.getCurrentPriceVnd());
                }
                BigDecimal lp = item.getListPriceVnd() != null ? item.getListPriceVnd() : item.getCurrentPriceVnd();
                if (lp != null) {
                    listTotal = listTotal.add(lp);
                }
            }

            BigDecimal totalSavings = BigDecimal.ZERO;
            int totalDiscountPercent = 0;
            if (listTotal.compareTo(total) > 0) {
                totalSavings = listTotal.subtract(total);
                if (listTotal.compareTo(BigDecimal.ZERO) > 0) {
                    totalDiscountPercent = totalSavings.multiply(BigDecimal.valueOf(100))
                            .divide(listTotal, 0, RoundingMode.HALF_UP).intValue();
                }
            }

            // Lấy thông báo flash từ session
            String message = (String) session.getAttribute("cartFlash");
            session.removeAttribute("cartFlash");

            // Cập nhật số lượng giỏ hàng vào session để header hiển thị đúng ngay lập tức
            session.setAttribute("cartCount", items.size());

            // Truyền dữ liệu cho JSP
            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", total);
            request.setAttribute("listTotal", listTotal);
            request.setAttribute("totalSavings", totalSavings);
            request.setAttribute("totalDiscountPercent", totalDiscountPercent);
            request.setAttribute("cartCount", items.size());
            request.setAttribute("message", message);
            request.setAttribute("pageTitle", "Giỏ hàng - Ftech");
            request.setAttribute("csrfToken", CartCsrf.getOrCreate(session));

            String view = request.getParameter("view");

            if ("drawer".equals(view)) {
                // Trả về nội dung giỏ hàng cho Drawer
                request.getRequestDispatcher("/WEB-INF/view/student/cart-drawer-data.jsp")
                        .forward(request, response);
            } else {
                // Trang giỏ hàng đầy đủ
                request.getRequestDispatcher("/WEB-INF/view/student/cart.jsp")
                        .forward(request, response);
            }

        } catch (SecurityException ex) {
            response.sendError(403, "Khong co quyen STUDENT");
        } catch (SQLException ex) {
            getServletContext().log("Cart GET failed", ex);
            response.sendError(500, "Khong the tai gio hang");
        }
    }

    // POST: Thêm hoặc xóa khóa học
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Long studentId = getStudentId(session);

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "json".equalsIgnoreCase(request.getParameter("format"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (studentId == null) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Vui lòng đăng nhập để thao tác giỏ hàng.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            }
            return;
        }

        // Kiểm tra CSRF token
        if (!CartCsrf.isValid(session, request.getParameter("csrfToken"))) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Phiên làm việc đã hết hạn hoặc CSRF không hợp lệ.\"}");
            } else {
                response.sendError(403, "CSRF token khong hop le");
            }
            return;
        }

        String action = request.getParameter("action");
        if (!"add".equals(action) && !"remove".equals(action)) {
            response.sendError(400, "Action khong hop le");
            return;
        }

        Long courseId = getCourseId(request);
        if (courseId == null) {
            response.sendError(400, "CourseId khong hop le");
            return;
        }

        try {
            Result result;
            if ("add".equals(action)) {
                result = cartService.addCourse(studentId, courseId);
            } else {
                result = cartService.removeCourse(studentId, courseId);
            }

            if (result == Result.FORBIDDEN) {
                response.sendError(403, "Khong co quyen");
                return;
            }

            if (result == Result.INVALID_INPUT) {
                response.sendError(400, "Du lieu khong hop le");
                return;
            }

            int newCount = cartService.getCartItems(studentId).size();
            session.setAttribute("cartCount", newCount);

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                boolean success = (result == Result.ADDED || result == Result.REMOVED);
                response.getWriter().write(String.format(
                        "{\"success\": %b, \"result\": \"%s\", \"message\": \"%s\", \"cartCount\": %d}",
                        success, result.name(), getMessage(result), newCount
                ));
                return;
            }

            // Non-AJAX fallback: Lưu thông báo & redirect
            session.setAttribute("cartFlash", getMessage(result));
            response.sendRedirect(request.getContextPath() + "/student/cart");

        } catch (SQLException ex) {
            getServletContext().log("Cart POST failed", ex);
            if (ex.getErrorCode() == 2601 || ex.getErrorCode() == 2627) {
                response.sendError(409, "Du lieu da thay doi, vui long thu lai");
            } else {
                response.sendError(500, "Loi khi cap nhat gio hang");
            }
        }
    }

    // Chuyển kết quả Service thành thông báo
    private String getMessage(Result result) {
        switch (result) {
            case ADDED:
                return "Đã thêm khóa học vào giỏ hàng.";
            case REMOVED:
                return "Đã xóa khóa học khỏi giỏ hàng.";
            case ALREADY_IN_CART:
                return "Khóa học đã có trong giỏ hàng.";
            case ALREADY_ENROLLED:
                return "Bạn đã đăng ký khóa học này.";
            case NOT_IN_CART:
                return "Khóa học không có trong giỏ hàng.";
            case COURSE_NOT_FOUND:
                return "Không tìm thấy khóa học.";
            case NOT_PUBLISHED:
                return "Khóa học chưa được xuất bản.";
            case NOT_PAID:
                return "Khóa học này là khóa miễn phí.";
            default:
                return "Không thể thực hiện yêu cầu.";
        }
    }
}
