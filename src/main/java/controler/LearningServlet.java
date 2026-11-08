/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.DiscussionDAO;
import dao.QuizDAO;
import java.util.UUID;
import dao.LearningDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LearningLesson;

@WebServlet(name = "LearningServlet", urlPatterns = {"/student/learn"})
public class LearningServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute(
                    "csrfToken",
                    UUID.randomUUID().toString()
            );
        }
        long studentId = ((Number) session.getAttribute("userId")).longValue();

        long courseId;
        long lessonId = 0;

        try {
            courseId = Long.parseLong(request.getParameter("courseId"));

            String lessonValue = request.getParameter("lessonId");

            if (lessonValue != null) {
                lessonId = Long.parseLong(lessonValue);

                if (lessonId <= 0) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Bài học không hợp lệ."
                    );
                    return;
                }
            }

            if (courseId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Khóa học không hợp lệ."
                );
                return;
            }

        } catch (NumberFormatException ex) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Mã khóa học hoặc bài học không hợp lệ."
            );
            return;
        }

        try {
            LearningDAO learningDAO = new LearningDAO();

            long enrollmentId = learningDAO.getEnrollmentId(
                    studentId, courseId
            );

            if (enrollmentId == 0) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền học khóa này."
                );
                return;
            }

            List<LearningLesson> lessons = learningDAO.getLessons(
                    courseId, enrollmentId
            );

            LearningLesson selectedLesson = null;
            int selectedIndex = -1;

            if (lessonId == 0) {
                if (lessons.isEmpty()) {
                    request.setAttribute("courseId", courseId);
                    request.setAttribute("courseTitle", learningDAO.getCourseTitle(courseId));
                    request.setAttribute("lessons", lessons);
                    request.setAttribute("pageTitle", "Nội dung khóa học");
                    request.setAttribute("activeMenu", "myCourses");

                    request.getRequestDispatcher(
                            "/WEB-INF/view/student/learning.jsp"
                    ).forward(request, response);
                    return;
                }
                selectedLesson = lessons.get(0);
                selectedIndex = 0;

                for (int i = 0; i < lessons.size(); i++) {
                    if (!lessons.get(i).isCompleted()) {
                        selectedLesson = lessons.get(i);
                        selectedIndex = i;
                        break;
                    }
                }
            } else {
                for (int i = 0; i < lessons.size(); i++) {
                    if (lessons.get(i).getId() == lessonId) {
                        selectedLesson = lessons.get(i);
                        selectedIndex = i;
                        break;
                    }
                }

                if (selectedLesson == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Không tìm thấy bài học trong khóa này."
                    );
                    return;
                }
            }

            LearningLesson previousLesson = null;
            LearningLesson nextLesson = null;

            if (selectedIndex > 0) {
                previousLesson = lessons.get(selectedIndex - 1);
            }

            if (selectedIndex >= 0 && selectedIndex < lessons.size() - 1) {
                nextLesson = lessons.get(selectedIndex + 1);
            }

            String courseTitle = learningDAO.getCourseTitle(courseId);

            request.setAttribute("courseId", courseId);
            request.setAttribute("courseTitle", courseTitle);
            request.setAttribute("lessons", lessons);
            request.setAttribute("selectedLesson", selectedLesson);
            request.setAttribute("previousLesson", previousLesson);
            request.setAttribute("nextLesson", nextLesson);
            request.setAttribute("pageTitle", courseTitle);
            request.setAttribute("activeMenu", "myCourses");
            QuizDAO quizDAO = new QuizDAO();

            request.setAttribute(
                    "quizzes",
                    quizDAO.getCourseQuizzes(studentId, courseId)
            );

            if (selectedLesson != null) {
                DiscussionDAO discussionDAO = new DiscussionDAO();

                request.setAttribute(
                        "discussionPosts",
                        discussionDAO.getPosts(studentId, selectedLesson.getId())
                );
            }

            request.getRequestDispatcher(
                    "/WEB-INF/view/student/learning.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(
                    "Không thể tải nội dung bài học.", ex
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
