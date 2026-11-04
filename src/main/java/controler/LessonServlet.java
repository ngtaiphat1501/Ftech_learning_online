package controler;

import dao.LessonDAO;
import dao.LessonResourceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.CurriculumLesson;
import model.LessonResource;

@WebServlet(
        name = "LessonServlet",
        urlPatterns = {"/instructor/lesson"}
)
public class LessonServlet extends HttpServlet {

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

        String view
                = request.getParameter("view");

        if (!"edit".equals(view)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

            return;
        }

        try {

            long lessonId
                    = Long.parseLong(
                            request.getParameter("id")
                    );

            LessonDAO lessonDAO
                    = new LessonDAO();

            CurriculumLesson lesson
                    = lessonDAO.getByIdForInstructor(
                            lessonId,
                            instructorId
                    );

            if (lesson == null) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }

            LessonResourceDAO resourceDAO
                    = new LessonResourceDAO();

            List<LessonResource> resources
                    = resourceDAO.getByLesson(
                            lessonId,
                            instructorId
                    );

            request.setAttribute(
                    "lesson",
                    lesson
            );

            request.setAttribute(
                    "resources",
                    resources
            );

            request.getRequestDispatcher(
                    "/WEB-INF/view/instructor/editLesson.jsp"
            ).forward(request, response);

        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the tai lesson",
                    ex
            );
        }
    }

    @Override
    protected void doPost(
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

        String action
                = request.getParameter("action");

        try {

            if ("create".equals(action)) {

                createLesson(
                        request,
                        response,
                        instructorId
                );

                return;
            }

            if ("edit".equals(action)) {

                editLesson(
                        request,
                        response,
                        instructorId
                );

                return;
            }

            if ("delete".equals(action)) {

                deleteLesson(
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
                    "Khong the xu ly lesson",
                    ex
            );
        }
    }

    private void createLesson(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long courseId
                = Long.parseLong(
                        request.getParameter(
                                "courseId"
                        )
                );

        long chapterId
                = Long.parseLong(
                        request.getParameter(
                                "chapterId"
                        )
                );

        String title
                = request.getParameter("title");

        String content
                = request.getParameter("content");

        String videoUrl
                = request.getParameter("videoUrl");

        String durationText
                = request.getParameter(
                        "durationSeconds"
                );

        if (title == null
                || title.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/curriculum?courseId="
                    + courseId
                    + "&error=lesson-title"
            );

            return;
        }

        Integer durationSeconds = null;

        if (durationText != null
                && !durationText.isBlank()) {

            durationSeconds
                    = Integer.parseInt(
                            durationText
                    );

            if (durationSeconds < 0) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/curriculum?courseId="
                        + courseId
                        + "&error=lesson-duration"
                );

                return;
            }
        }

        boolean preview
                = request.getParameter(
                        "isPreview"
                ) != null;

        boolean required
                = request.getParameter(
                        "isRequired"
                ) != null;

        LessonDAO dao
                = new LessonDAO();

        boolean created
                = dao.createLesson(
                        chapterId,
                        courseId,
                        instructorId,
                        title.trim(),
                        emptyToNull(content),
                        emptyToNull(videoUrl),
                        durationSeconds,
                        preview,
                        required
                );

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + courseId
                + (created
                ? "&success=lesson-create"
                : "&error=lesson-create")
        );
    }

    private void editLesson(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long lessonId
                = Long.parseLong(
                        request.getParameter(
                                "lessonId"
                        )
                );

        LessonDAO dao
                = new LessonDAO();

        CurriculumLesson oldLesson
                = dao.getByIdForInstructor(
                        lessonId,
                        instructorId
                );

        if (oldLesson == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

            return;
        }

        String title
                = request.getParameter("title");

        String content
                = request.getParameter("content");

        String videoUrl
                = request.getParameter("videoUrl");

        String durationText
                = request.getParameter(
                        "durationSeconds"
                );

        int sortOrder
                = Integer.parseInt(
                        request.getParameter(
                                "sortOrder"
                        )
                );

        if (title == null
                || title.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/lesson?view=edit&id="
                    + lessonId
                    + "&error=title"
            );

            return;
        }

        Integer durationSeconds = null;

        if (durationText != null
                && !durationText.isBlank()) {

            durationSeconds
                    = Integer.parseInt(
                            durationText
                    );

            if (durationSeconds < 0) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/lesson?view=edit&id="
                        + lessonId
                        + "&error=duration"
                );

                return;
            }
        }

        boolean preview
                = request.getParameter(
                        "isPreview"
                ) != null;

        boolean required
                = request.getParameter(
                        "isRequired"
                ) != null;

        boolean updated
                = dao.updateLesson(
                        lessonId,
                        instructorId,
                        title.trim(),
                        emptyToNull(content),
                        emptyToNull(videoUrl),
                        durationSeconds,
                        preview,
                        required,
                        sortOrder
                );

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + oldLesson.getCourseId()
                + (updated
                ? "&success=lesson-edit"
                : "&error=lesson-edit")
        );
    }

    private void deleteLesson(
            HttpServletRequest request,
            HttpServletResponse response,
            long instructorId
    ) throws SQLException, IOException {

        long lessonId
                = Long.parseLong(
                        request.getParameter(
                                "lessonId"
                        )
                );

        LessonDAO dao
                = new LessonDAO();

        CurriculumLesson lesson
                = dao.getByIdForInstructor(
                        lessonId,
                        instructorId
                );

        if (lesson == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

            return;
        }

        long courseId
                = lesson.getCourseId();

        boolean deleted
                = dao.deleteLesson(
                        lessonId,
                        instructorId
                );

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/curriculum?courseId="
                + courseId
                + (deleted
                ? "&success=lesson-delete"
                : "&error=lesson-delete")
        );
    }

    private String emptyToNull(
            String value
    ) {

        if (value == null
                || value.isBlank()) {

            return null;
        }

        return value.trim();
    }
}