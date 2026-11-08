package controler;

import dao.CourseDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.CourseReview;
import model.User;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "CourseDetailServlet", urlPatterns = {"/course", "/course/"})
public class CourseDetailServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            idParam = request.getParameter("courseId");
        }

        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        long courseId;
        try {
            courseId = Long.parseLong(idParam.trim());
            if (courseId <= 0) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            Course course = courseDAO.getCourseDetail(courseId);

            if (course == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khóa học không tồn tại.");
                return;
            }

            HttpSession session = request.getSession(false);
            Long currentUserId = null;
            User currentUser = null;
            if (session != null) {
                Object uid = session.getAttribute("userId");
                if (uid instanceof Number) {
                    currentUserId = ((Number) uid).longValue();
                }
                currentUser = (User) session.getAttribute("user");
                if (session.getAttribute("csrfToken") == null) {
                    session.setAttribute("csrfToken", java.util.UUID.randomUUID().toString());
                }
                request.setAttribute("csrfToken", session.getAttribute("csrfToken"));
            }

            // Only published courses or visible to owner/admin
            boolean isStaff = (currentUser != null && (currentUser.isAdmin() || (currentUser.getUserId() != null && currentUser.getUserId().longValue() == course.getInstructorId())));
            if (!"PUBLISHED".equalsIgnoreCase(course.getStatus()) && !isStaff) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khóa học chưa được công khai.");
                return;
            }

            boolean isEnrolled = false;
            boolean isInCart = false;

            if (currentUserId != null) {
                isEnrolled = courseDAO.isUserEnrolled(currentUserId, courseId);
                isInCart = courseDAO.isCourseInUserCart(currentUserId, courseId);
            }

            List<CourseReview> reviews = courseDAO.getCourseReviews(courseId);

            request.setAttribute("course", course);
            request.setAttribute("isEnrolled", isEnrolled);
            request.setAttribute("isInCart", isInCart);
            request.setAttribute("reviews", reviews);
            request.setAttribute("pageTitle", course.getTitle() + " - Ftech");
            request.setAttribute("activeMenu", "courses");

            request.getRequestDispatcher("/WEB-INF/view/public/course-detail.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("CourseDetailServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải chi tiết khóa học.", ex);
        }
    }
}
