/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.CourseDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.List;
import model.Course;

/**
 *
 * @author TUF GAMING
 */
@WebServlet(name = "InstructorDashboardServlet", urlPatterns = {"/instructor/dashboard"})
public class InstructorDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            CourseDAO dao = new CourseDAO();
             List<Course> courses = dao.getList("", 2L, "");

            request.setAttribute("courses", courses);

            request.getRequestDispatcher(
                "/WEB-INF/view/instructor/dashboard.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log(
                "Loi tai Instructor Dashboard", ex
            );

            throw new ServletException(
                "Khong the tai Instructor Dashboard", ex
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
