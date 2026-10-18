/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.QuizDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.QuizInfo;
import model.QuizAttemptData;

@WebServlet(name = "QuizAttemptServlet", urlPatterns = {
    "/student/quiz", "/student/quiz/start", "/student/quiz/attempt",
    "/student/quiz/save", "/student/quiz/submit", "/student/quiz/result"
})
public class QuizAttemptServlet extends HttpServlet {

    private long positiveId(String value) {
        long id = Long.parseLong(value);
        if (id <= 0) {
            throw new IllegalArgumentException("Mã đề hoặc lượt thi không hợp lệ.");
        }
        return id;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
        }
        long studentId = ((Number) session.getAttribute("userId")).longValue();
        String path = request.getServletPath();

        try {
            QuizDAO dao = new QuizDAO();
            request.setAttribute("activeMenu", "myCourses");
            if ("/student/quiz".equals(path)) {
                QuizInfo quiz = dao.getInfo(studentId, positiveId(request.getParameter("quizId")));
                boolean canStart = quiz.getActiveAttemptId() == 0
                        && quiz.isLessonsCompleted()
                        && quiz.getQuestionCount() > 0 && quiz.getUsedAttempts() < quiz.getMaxAttempts();
                request.setAttribute("quiz", quiz);
                request.setAttribute("canStart", canStart);
                request.setAttribute("pageTitle", "Thông tin bài kiểm tra");
                request.getRequestDispatcher("/WEB-INF/view/student/quiz-info.jsp").forward(request, response);
            } else if ("/student/quiz/attempt".equals(path)
                    || "/student/quiz/result".equals(path)) {
                QuizAttemptData attempt = dao.getAttempt(studentId, positiveId(request.getParameter("attemptId")));
                if ("FINISHED".equals(attempt.getStatus()) && !"/student/quiz/result".equals(path)) {
                    response.sendRedirect(request.getContextPath()
                            + "/student/quiz/result?attemptId=" + attempt.getAttemptId());
                    return;
                }
                if (!"FINISHED".equals(attempt.getStatus()) && "/student/quiz/result".equals(path)) {
                    response.sendRedirect(request.getContextPath()
                            + "/student/quiz/attempt?attemptId=" + attempt.getAttemptId());
                    return;
                }
                request.setAttribute("attempt", attempt);
                request.setAttribute("pageTitle", attempt.getTitle());
                String view = "FINISHED".equals(attempt.getStatus()) ? "quiz-result.jsp" : "quiz-attempt.jsp";
                request.getRequestDispatcher("/WEB-INF/view/student/" + view).forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (SecurityException ex) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, ex.getMessage());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đề hoặc lượt thi không hợp lệ.");
        } catch (SQLException ex) {
            throw new ServletException("Không thể tải bài kiểm tra.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String token = (String) session.getAttribute("csrfToken");
        if (token == null || !token.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Yêu cầu không hợp lệ. Hãy tải lại trang.");
            return;
        }

        long studentId = ((Number) session.getAttribute("userId")).longValue();
        String path = request.getServletPath();

        try {
            QuizDAO dao = new QuizDAO();
            if ("/student/quiz/start".equals(path)) {
                long quizId = positiveId(request.getParameter("quizId"));
                long attemptId = dao.start(studentId, quizId);
                response.sendRedirect(request.getContextPath() + "/student/quiz/attempt?attemptId=" + attemptId);
            } else if ("/student/quiz/save".equals(path) || "/student/quiz/submit".equals(path)) {
                long attemptId = positiveId(request.getParameter("attemptId"));
                Map<Long, Long> answers = new HashMap<>();
                for (Map.Entry<String, String[]> parameter : request.getParameterMap().entrySet()) {
                    if (parameter.getKey().startsWith("answer_")) {
                        if (parameter.getValue().length != 1) {
                            throw new IllegalArgumentException("Một câu chỉ được chọn một đáp án.");
                        }
                        long questionId = positiveId(parameter.getKey().substring(7));
                        long optionId = positiveId(parameter.getValue()[0]);
                        answers.put(questionId, optionId);
                    }
                }
                boolean finished = dao.save(studentId, attemptId, answers,
                        "/student/quiz/submit".equals(path));
                response.sendRedirect(request.getContextPath()
                        + (finished ? "/student/quiz/result?attemptId=" : "/student/quiz/attempt?attemptId=")
                        + attemptId + (finished ? "" : "&saved=1"));
            } else {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (SecurityException ex) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, ex.getMessage());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    ex instanceof NumberFormatException ? "Mã đề, câu hỏi hoặc đáp án không hợp lệ." : ex.getMessage());
        } catch (SQLException ex) {
            throw new ServletException("Không thể lưu hoặc chấm bài kiểm tra.", ex);
        }
    }
}
