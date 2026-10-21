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

        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");

        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu không hợp lệ. Hãy tải lại trang học."
            );
            return;
        }

        String action = request.getParameter("action");

        if (!"save".equals(action) && !"complete".equals(action)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Thao tác không hợp lệ."
            );
            return;
        }

        long studentId = ((Number) session.getAttribute("userId")).longValue();

        long courseId;
        long lessonId;
        int position;

        try {
            courseId = Long.parseLong(request.getParameter("courseId"));
            lessonId = Long.parseLong(request.getParameter("lessonId"));
            position = Integer.parseInt(request.getParameter("position"));

            if (courseId <= 0 || lessonId <= 0 || position < 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Dữ liệu tiến độ không hợp lệ."
                );
                return;
            }

        } catch (NumberFormatException ex) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Mã khóa học, bài học hoặc vị trí xem không hợp lệ."
            );
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
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền cập nhật tiến độ bài này."
                );
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
