package controler;

import config.DBContext;
import dao.CourseDAO;
import dao.InstructorQuizDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.QuizInfo;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "InstructorQuizServlet", urlPatterns = {"/instructor/quiz"})
public class InstructorQuizServlet extends HttpServlet {

    private final InstructorQuizDAO quizDAO = new InstructorQuizDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final UserDAO userDAO = new UserDAO();

    private User getAuthenticatedInstructor(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Long currentUserId = null;
        User currentUser = null;
        if (session != null) {
            Object uid = session.getAttribute("userId");
            if (uid instanceof Number) {
                currentUserId = ((Number) uid).longValue();
            }
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUserId == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return null;
        }

        if (currentUser == null) {
            try {
                currentUser = userDAO.findById(currentUserId);
                if (currentUser != null && session != null) {
                    session.setAttribute("user", currentUser);
                    session.setAttribute("fullName", currentUser.getFullName());
                    session.setAttribute("roles", currentUser.getRoles());
                }
            } catch (SQLException ignored) {
            }
        }

        if (currentUser == null || (!currentUser.isInstructor() && !currentUser.isAdmin())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Giảng viên (Instructor).");
            return null;
        }
        return currentUser;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getAuthenticatedInstructor(request, response);
        if (user == null) return;

        String courseIdStr = request.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            long courseId = Long.parseLong(courseIdStr);

            // Ownership check (Admins can view too)
            Course course = courseDAO.getCourseDetail(conn, courseId);
            if (course == null || (!user.isAdmin() && course.getInstructorId() != user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=" + urlEncode("Bạn không sở hữu khóa học này."));
                return;
            }

            List<QuizInfo> quizzes = quizDAO.getQuizzesByCourseId(conn, courseId, course.getInstructorId());

            request.setAttribute("course", course);
            request.setAttribute("quizzes", quizzes);
            request.setAttribute("activeMenu", "instructor");
            request.setAttribute("pageTitle", "Quản lý Đề kiểm tra - " + course.getTitle());

            request.getRequestDispatcher("/WEB-INF/view/instructor/quizzes.jsp").forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("InstructorQuizServlet GET error", ex);
            throw new ServletException("Lỗi hệ thống khi tải danh sách đề kiểm tra.", ex);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=" + urlEncode("Mã khóa học không hợp lệ."));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getAuthenticatedInstructor(request, response);
        if (user == null) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        long courseId = 0;
        try {
            courseId = Long.parseLong(request.getParameter("courseId"));
        } catch (Exception ignored) {
        }

        try (Connection conn = DBContext.getConnection()) {
            long targetInstructorId = user.isAdmin() ? -1 : user.getUserId();

            if ("create".equalsIgnoreCase(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int duration = parseInt(request.getParameter("durationMinutes"), 20);
                int maxAttempts = parseInt(request.getParameter("maxAttempts"), 3);
                BigDecimal passingScore = parseBigDecimal(request.getParameter("passingScore"), new BigDecimal("70.00"));
                boolean isRequired = "on".equalsIgnoreCase(request.getParameter("isRequired")) || "true".equalsIgnoreCase(request.getParameter("isRequired"));
                int sortOrder = parseInt(request.getParameter("sortOrder"), 1);

                if (title == null || title.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode("Tiêu đề đề thi không được để trống."));
                    return;
                }

                boolean ok = quizDAO.createQuiz(conn, courseId, targetInstructorId, title, description, duration, maxAttempts, passingScore, isRequired, sortOrder);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&msg=" + urlEncode("Tạo đề kiểm tra mới thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode("Không thể tạo đề kiểm tra."));
                }

            } else if ("edit".equalsIgnoreCase(action)) {
                long quizId = Long.parseLong(request.getParameter("quizId"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int duration = parseInt(request.getParameter("durationMinutes"), 20);
                int maxAttempts = parseInt(request.getParameter("maxAttempts"), 3);
                BigDecimal passingScore = parseBigDecimal(request.getParameter("passingScore"), new BigDecimal("70.00"));
                boolean isRequired = "on".equalsIgnoreCase(request.getParameter("isRequired")) || "true".equalsIgnoreCase(request.getParameter("isRequired"));
                int sortOrder = parseInt(request.getParameter("sortOrder"), 1);

                boolean ok = quizDAO.updateQuiz(conn, quizId, targetInstructorId, title, description, duration, maxAttempts, passingScore, isRequired, sortOrder);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&msg=" + urlEncode("Cập nhật thông tin đề kiểm tra thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode("Cập nhật thất bại."));
                }

            } else if ("delete".equalsIgnoreCase(action)) {
                long quizId = Long.parseLong(request.getParameter("quizId"));
                boolean ok = quizDAO.deleteQuiz(conn, quizId, targetInstructorId);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&msg=" + urlEncode("Đã xóa đề kiểm tra thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode("Không thể xóa đề kiểm tra."));
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
            }

        } catch (IllegalStateException ex) {
            response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode(ex.getMessage()));
        } catch (SQLException ex) {
            getServletContext().log("InstructorQuizServlet POST error", ex);
            response.sendRedirect(request.getContextPath() + "/instructor/quiz?courseId=" + courseId + "&error=" + urlEncode("Lỗi hệ thống: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=" + urlEncode("Dữ liệu đầu vào không hợp lệ."));
        }
    }

    private int parseInt(String val, int def) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return def;
        }
    }

    private BigDecimal parseBigDecimal(String val, BigDecimal def) {
        try {
            if (val == null || val.isBlank()) return def;
            return new BigDecimal(val.trim().replace(',', '.'));
        } catch (Exception e) {
            return def;
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
