package controler;

import dao.ChapterDAO;
import dao.CourseDAO;
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
import model.CurriculumChapter;

@WebServlet(
        name = "CurriculumServlet",
        urlPatterns = {
            "/instructor/curriculum"
        }
)
public class CurriculumServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {

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

        String courseIdText
                = request.getParameter("courseId");

        if (courseIdText == null
                || courseIdText.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

            return;
        }

        try {

            long courseId
                    = Long.parseLong(courseIdText);

            CourseDAO courseDAO
                    = new CourseDAO();

            Course course
                    = courseDAO.getByIdForInstructor(
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

            ChapterDAO chapterDAO
                    = new ChapterDAO();

            List<CurriculumChapter> chapters
                    = chapterDAO.getCurriculum(
                            courseId
                    );

            request.setAttribute(
                    "course",
                    course
            );

            request.setAttribute(
                    "chapters",
                    chapters
            );

            request.getRequestDispatcher(
                    "/WEB-INF/view/instructor/curriculum.jsp"
            ).forward(request, response);

        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the tai noi dung khoa hoc",
                    ex
            );
        }
    }
}