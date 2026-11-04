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
import model.CurriculumLesson;

@WebServlet(
        name = "LessonResourceServlet",
        urlPatterns = {"/instructor/resource"}
)
public class LessonResourceServlet
        extends HttpServlet {

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

        try {

            String action
                    = request.getParameter(
                            "action"
                    );

            long lessonId
                    = Long.parseLong(
                            request.getParameter(
                                    "lessonId"
                            )
                    );

            LessonDAO lessonDAO
                    = new LessonDAO();

            CurriculumLesson lesson
                    = lessonDAO
                            .getByIdForInstructor(
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

            LessonResourceDAO dao
                    = new LessonResourceDAO();

            if ("create".equals(action)) {

                String title
                        = request.getParameter(
                                "title"
                        );

                String resourceUrl
                        = request.getParameter(
                                "resourceUrl"
                        );

                String resourceType
                        = request.getParameter(
                                "resourceType"
                        );

                if (title == null
                        || title.isBlank()
                        || resourceUrl == null
                        || resourceUrl.isBlank()
                        || !validType(resourceType)) {

                    redirect(
                            request,
                            response,
                            lessonId,
                            "error=resource"
                    );

                    return;
                }

                boolean created
                        = dao.createResource(
                                lessonId,
                                instructorId,
                                title.trim(),
                                resourceUrl.trim(),
                                resourceType
                        );

                redirect(
                        request,
                        response,
                        lessonId,
                        created
                        ? "success=resource"
                        : "error=resource"
                );

                return;
            }

            if ("delete".equals(action)) {

                long resourceId
                        = Long.parseLong(
                                request.getParameter(
                                        "resourceId"
                                )
                        );

                boolean deleted
                        = dao.deleteResource(
                                resourceId,
                                lessonId,
                                instructorId
                        );

                redirect(
                        request,
                        response,
                        lessonId,
                        deleted
                        ? "success=resource-delete"
                        : "error=resource-delete"
                );

                return;
            }

            redirect(
                    request,
                    response,
                    lessonId,
                    "error=resource"
            );

        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the xu ly resource",
                    ex
            );
        }
    }

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            long lessonId,
            String message
    ) throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/instructor/lesson?view=edit&id="
                + lessonId
                + "&"
                + message
        );
    }

    private boolean validType(
            String type
    ) {

        return "PDF".equals(type)
                || "SLIDE".equals(type)
                || "CODE".equals(type)
                || "LINK".equals(type)
                || "ZIP".equals(type)
                || "DOC".equals(type);
    }
}