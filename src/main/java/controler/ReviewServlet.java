/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.ReviewDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name="ReviewServlet",urlPatterns={"/student/review"})
public class ReviewServlet extends HttpServlet {
    private long positiveId(String value) {
        long id=Long.parseLong(value);
        if(id<=0) throw new IllegalArgumentException("Mã không hợp lệ.");
        return id;
    }
    @Override
    protected void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException,IOException {
        response.sendError(405);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "json".equalsIgnoreCase(request.getParameter("format"));

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Vui lòng đăng nhập để gửi đánh giá.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long userId = ((Number) session.getAttribute("userId")).longValue();
        String token = (String) session.getAttribute("csrfToken");
        String reqToken = request.getParameter("csrfToken");

        if (token == null || !token.equals(reqToken)) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Phiên làm việc đã hết hạn hoặc CSRF không hợp lệ.\"}");
                return;
            }
            response.sendError(403, "Yêu cầu không hợp lệ. Hãy tải lại trang.");
            return;
        }

        try {
            long courseId = positiveId(request.getParameter("courseId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            new ReviewDAO().save(userId, courseId, rating, request.getParameter("comment"));

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Cảm ơn bạn đã gửi đánh giá!\"}");
                return;
            }

            String redirectUrl = request.getParameter("redirectUrl");
            if (redirectUrl != null && !redirectUrl.isBlank()) {
                response.sendRedirect(redirectUrl);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/student/courses?reviewSaved=1#course-" + courseId);
        } catch (SecurityException ex) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                String safeMsg = ex.getMessage() != null ? ex.getMessage().replace("\"", "'") : "";
                response.getWriter().write("{\"success\": false, \"message\": \"" + safeMsg + "\"}");
                return;
            }
            response.sendError(403, ex.getMessage());
        } catch (IllegalArgumentException ex) {
            String msg = (ex instanceof NumberFormatException) ? "Mã hoặc dữ liệu không hợp lệ." : ex.getMessage();
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                String safeMsg = msg.replace("\"", "'");
                response.getWriter().write("{\"success\": false, \"message\": \"" + safeMsg + "\"}");
                return;
            }
            response.sendError(400, msg);
        } catch (SQLException ex) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể lưu đánh giá do lỗi hệ thống.\"}");
                return;
            }
            throw new ServletException("Không thể xử lý dữ liệu.", ex);
        }
    }
}

