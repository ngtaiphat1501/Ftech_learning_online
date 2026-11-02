package controler;

import dao.CourseDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(
        name = "CourseSubmissionServlet",
        urlPatterns = {"/instructor/course/submit"}
)
public class CourseSubmissionServlet
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

            String courseIdText
                    = request.getParameter(
                            "courseId"
                    );


            if (courseIdText == null
                    || courseIdText.isBlank()) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }


            long courseId
                    = Long.parseLong(
                            courseIdText
                    );


            CourseDAO dao
                    = new CourseDAO();


            int result
                    = dao.submitForApproval(
                            courseId,
                            instructorId
                    );


            if (result == -1) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                        + "?error=submit-content"
                );

                return;
            }


            if (result == 0) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                        + "?error=submit"
                );

                return;
            }


            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
                    + "?success=submit"
            );


        } catch (NumberFormatException ex) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );


        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the gui khoa hoc de duyet",
                    ex
            );
        }
    }
}