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
import model.QuizQuestion;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "QuestionServlet", urlPatterns = {"/instructor/question"})
public class QuestionServlet extends HttpServlet {

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

        String quizIdStr = request.getParameter("quizId");
        if (quizIdStr == null || quizIdStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            long quizId = Long.parseLong(quizIdStr);

            // Fetch quiz
            QuizInfo quiz = quizDAO.getQuizById(conn, quizId, user.getUserId());
            if (quiz == null && user.isAdmin()) {
                // If admin, find course owner
                String sql = "SELECT c.InstructorId FROM dbo.Quizzes q JOIN dbo.Courses c ON q.CourseId = c.CourseId WHERE q.QuizId = ?";
                try (var ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, quizId);
                    try (var rs = ps.executeQuery()) {
                        if (rs.next()) {
                            quiz = quizDAO.getQuizById(conn, quizId, rs.getLong("InstructorId"));
                        }
                    }
                }
            }

            if (quiz == null) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=" + urlEncode("Không tìm thấy đề thi hoặc bạn không có quyền."));
                return;
            }

            Course course = courseDAO.getCourseDetail(conn, quiz.getCourseId());
            List<QuizQuestion> questions = quizDAO.getQuestionsByQuizId(conn, quizId, course.getInstructorId());

            request.setAttribute("quiz", quiz);
            request.setAttribute("course", course);
            request.setAttribute("questions", questions);
            request.setAttribute("activeMenu", "instructor");
            request.setAttribute("pageTitle", "Quản lý Câu hỏi: " + quiz.getTitle());

            request.getRequestDispatcher("/WEB-INF/view/instructor/questions.jsp").forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("QuestionServlet GET error", ex);
            throw new ServletException("Lỗi hệ thống khi tải danh sách câu hỏi.", ex);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=" + urlEncode("Mã đề thi không hợp lệ."));
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

        long quizId = 0;
        try {
            quizId = Long.parseLong(request.getParameter("quizId"));
        } catch (Exception ignored) {
        }

        try (Connection conn = DBContext.getConnection()) {
            long targetInstructorId = user.isAdmin() ? -1 : user.getUserId();

            if ("create".equalsIgnoreCase(action)) {
                String content = request.getParameter("content");
                String explanation = request.getParameter("explanation");
                BigDecimal points = parseBigDecimal(request.getParameter("points"), BigDecimal.ONE);
                int sortOrder = parseInt(request.getParameter("sortOrder"), 1);

                String[] rawOptions = request.getParameterValues("options");
                int correctIndex = parseInt(request.getParameter("correctOptionIndex"), 0);

                List<String> validOptions = filterOptions(rawOptions);

                if (content == null || content.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Nội dung câu hỏi không được để trống."));
                    return;
                }
                if (validOptions.size() < 2) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Phải có ít nhất 2 đáp án lựa chọn."));
                    return;
                }

                boolean ok = quizDAO.createQuestionWithOptions(conn, quizId, targetInstructorId, content, explanation, points, sortOrder, validOptions, correctIndex);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&msg=" + urlEncode("Thêm câu hỏi mới thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Không thể tạo câu hỏi."));
                }

            } else if ("edit".equalsIgnoreCase(action)) {
                long questionId = Long.parseLong(request.getParameter("questionId"));
                String content = request.getParameter("content");
                String explanation = request.getParameter("explanation");
                BigDecimal points = parseBigDecimal(request.getParameter("points"), BigDecimal.ONE);
                int sortOrder = parseInt(request.getParameter("sortOrder"), 1);

                String[] rawOptions = request.getParameterValues("options");
                int correctIndex = parseInt(request.getParameter("correctOptionIndex"), 0);

                List<String> validOptions = filterOptions(rawOptions);

                if (content == null || content.isBlank() || validOptions.size() < 2) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Nội dung hoặc đáp án không hợp lệ."));
                    return;
                }

                boolean ok = quizDAO.updateQuestionWithOptions(conn, questionId, targetInstructorId, content, explanation, points, sortOrder, validOptions, correctIndex);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&msg=" + urlEncode("Cập nhật câu hỏi và đáp án thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Không thể cập nhật câu hỏi."));
                }

            } else if ("delete".equalsIgnoreCase(action)) {
                long questionId = Long.parseLong(request.getParameter("questionId"));
                boolean ok = quizDAO.deleteQuestion(conn, questionId, targetInstructorId);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&msg=" + urlEncode("Đã xóa câu hỏi thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Không thể xóa câu hỏi."));
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId);
            }

        } catch (IllegalStateException | IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode(ex.getMessage()));
        } catch (SQLException ex) {
            getServletContext().log("QuestionServlet POST error", ex);
            response.sendRedirect(request.getContextPath() + "/instructor/question?quizId=" + quizId + "&error=" + urlEncode("Lỗi cơ sở dữ liệu: " + ex.getMessage()));
        }
    }

    private List<String> filterOptions(String[] raw) {
        List<String> list = new ArrayList<>();
        if (raw != null) {
            for (String s : raw) {
                if (s != null && !s.trim().isEmpty()) {
                    list.add(s.trim());
                }
            }
        }
        return list;
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
