/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.ProgressDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ProgressServlet",
        urlPatterns = {"/student/progress"})
public class ProgressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");

        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"CSRF\",\"message\":\"Phiên làm việc đã hết hạn. Vui lòng tải lại trang.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/student/courses?error=" + java.net.URLEncoder.encode("Phiên làm việc đã hết hạn. Vui lòng tải lại trang.", java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        String action = request.getParameter("action");

        if (!"save".equals(action) && !"complete".equals(action)) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"InvalidAction\",\"message\":\"Thao tác không hợp lệ.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/student/courses");
            return;
        }

        long studentId = ((Number) session.getAttribute("userId")).longValue();

        long courseId = 0;
        long lessonId = 0;
        int position = 0;

        try {
            courseId = Long.parseLong(request.getParameter("courseId"));
            lessonId = Long.parseLong(request.getParameter("lessonId"));
            position = Integer.parseInt(request.getParameter("position"));

            if (courseId <= 0 || lessonId <= 0 || position < 0) {
                if (isAjax) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"error\":\"InvalidData\",\"message\":\"Dữ liệu tiến độ không hợp lệ.\"}");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/student/courses");
                return;
            }

        } catch (NumberFormatException ex) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"InvalidFormat\",\"message\":\"Mã khóa học hoặc bài học không hợp lệ.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/student/courses");
            return;
        }

        try {
            ProgressDAO progressDAO = new ProgressDAO();

            boolean saved = progressDAO.saveProgress(
                    studentId,
                    courseId,
                    lessonId,
                    position,
                    "complete".equals(action)
            );

            if (!saved) {
                String forbiddenMsg = "Bạn không có quyền cập nhật tiến độ bài này (Tiến độ chỉ áp dụng cho học viên đã ghi danh).";
                if (isAjax) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"error\":\"Forbidden\",\"message\":\"" + forbiddenMsg + "\"}");
                    return;
                }
                response.sendRedirect(
                        request.getContextPath()
                        + "/student/learn?courseId=" + courseId
                        + "&lessonId=" + lessonId
                        + "&error=" + java.net.URLEncoder.encode(forbiddenMsg, java.nio.charset.StandardCharsets.UTF_8)
                );
                return;
            }

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"position\":" + position + ",\"message\":\"Cập nhật tiến độ thành công.\"}");
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/student/learn?courseId=" + courseId
                    + "&lessonId=" + lessonId
                    + "&saved=1"
            );

        } catch (SQLException ex) {
            throw new ServletException(
                    "Không thể lưu tiến độ học tập.", ex
            );
        }
    }
}
