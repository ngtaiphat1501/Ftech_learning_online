package controler;

import dao.CourseDAO;
import dao.InstructorStudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.Course;
import model.InstructorStudentProgress;

@WebServlet(
        name = "InstructorStudentServlet",
        urlPatterns = {"/instructor/students"}
)
public class InstructorStudentServlet
        extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("userId")
                == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        long instructorId
                = ((Number) session
                        .getAttribute("userId"))
                        .longValue();

        try {

            long courseId
                    = Long.parseLong(
                            request.getParameter(
                                    "courseId"
                            )
                    );

            CourseDAO courseDAO
                    = new CourseDAO();

            Course course
                    = courseDAO
                            .getByIdForInstructor(
                                    courseId,
                                    instructorId
                            );

            if (course == null) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }

            InstructorStudentDAO studentDAO
                    = new InstructorStudentDAO();

            List<InstructorStudentProgress> students
                    = studentDAO.findByCourse(
                            courseId,
                            instructorId
                    );

            request.setAttribute(
                    "course",
                    course
            );

            request.setAttribute(
                    "students",
                    students
            );

            request.getRequestDispatcher(
                    "/WEB-INF/view/instructor/students.jsp"
            ).forward(request, response);

        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the tai danh sach hoc vien",
                    ex
            );
        }
    }
}