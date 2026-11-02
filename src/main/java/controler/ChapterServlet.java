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
import model.Course;

@WebServlet(
        name = "ChapterServlet",
        urlPatterns = {"/instructor/chapter"}
)
public class ChapterServlet extends HttpServlet {

    @Override
    protected void doPost(
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

        String action
                = request.getParameter("action");

        try {

            if ("create".equals(action)) {

                createChapter(
                        request,
                        response,
                        instructorId
                );

                return;
            }

            if ("edit".equals(action)) {

                editChapter(
                        request,
                        response,
                        instructorId
                );

                return;
            }
            if ("delete".equals(action)) {

                deleteChapter(
                        request,
                        response,
                        instructorId
                );

                return;
            }
            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the xu ly chapter",
                    ex
            );
        }
    }

    private void createChapter(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long courseId
                = Long.parseLong(
                        request.getParameter("courseId")
                );

        String title
                = request.getParameter("title");

        String description
                = request.getParameter("description");

        if (title == null || title.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=title"
            );

            return;
        }

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

        if (!"DRAFT".equals(course.getStatus())) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=status"
            );

            return;
        }

        ChapterDAO chapterDAO
                = new ChapterDAO();

        chapterDAO.createChapter(
                courseId,
                title.trim(),
                description == null
                        ? null
                        : description.trim()
        );

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + courseId
                + "&success=chapter"
        );
    }

    private void editChapter(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long courseId
                = Long.parseLong(
                        request.getParameter("courseId")
                );

        long chapterId
                = Long.parseLong(
                        request.getParameter("chapterId")
                );

        int sortOrder
                = Integer.parseInt(
                        request.getParameter("sortOrder")
                );

        String title
                = request.getParameter("title");

        String description
                = request.getParameter("description");

        if (title == null || title.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=chapter-edit"
            );

            return;
        }

        ChapterDAO chapterDAO
                = new ChapterDAO();

        boolean updated
                = chapterDAO.updateChapter(
                        chapterId,
                        courseId,
                        instructorId,
                        title.trim(),
                        description == null
                                ? null
                                : description.trim(),
                        sortOrder
                );

        if (!updated) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=chapter-edit"
            );

            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + courseId
                + "&success=chapter-edit"
        );
    }

    private void deleteChapter(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long courseId
                = Long.parseLong(
                        request.getParameter("courseId")
                );

        long chapterId
                = Long.parseLong(
                        request.getParameter("chapterId")
                );

        ChapterDAO chapterDAO
                = new ChapterDAO();

        boolean deleted
                = chapterDAO.deleteChapter(
                        chapterId,
                        courseId,
                        instructorId
                );

        if (!deleted) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=chapter-delete"
            );

            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + courseId
                + "&success=chapter-delete"
        );
    }
}
