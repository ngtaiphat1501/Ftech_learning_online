/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
 /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.StudentCourseDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StudentCourseServlet",
        urlPatterns = {"/student/courses"})
public class StudentCourseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        Object sessionUserId = session.getAttribute("userId");

        if (!(sessionUserId instanceof Number)) {
            session.invalidate();

            response.sendRedirect(
        request.getContextPath() + "/login"
);
            return;
        }

        long studentId = ((Number) sessionUserId).longValue();

        try {
            StudentCourseDAO studentCourseDAO = new StudentCourseDAO();

            request.setAttribute(
                    "list",
                    studentCourseDAO.getList(studentId)
            );

            request.setAttribute("pageTitle", "Khóa học của tôi");
            request.setAttribute("activeMenu", "myCourses");

            request.getRequestDispatcher(
                    "/WEB-INF/view/student/courses.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(
                    "Không thể tải khóa học của bạn.", ex
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
