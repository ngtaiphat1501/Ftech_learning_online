package controler;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Lesson;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "PreviewServlet", urlPatterns = {"/preview"})
public class PreviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("lessonId");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        long lessonId;
        try {
            lessonId = Long.parseLong(idParam.trim());
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        String sql = "SELECT l.LessonId, l.ChapterId, l.CourseId, l.Title, l.Content, l.VideoUrl, "
                + "l.DurationSeconds, l.SortOrder, l.IsPreview, l.IsRequired, "
                + "c.Title AS CourseTitle, ch.Title AS ChapterTitle "
                + "FROM dbo.Lessons l "
                + "JOIN dbo.Courses c ON l.CourseId = c.CourseId "
                + "JOIN dbo.Chapters ch ON l.ChapterId = ch.ChapterId "
                + "WHERE l.LessonId = ? AND l.IsPreview = 1 AND c.Status = 'PUBLISHED'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, lessonId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Lesson lesson = new Lesson(
                            rs.getLong("LessonId"),
                            rs.getLong("ChapterId"),
                            rs.getLong("CourseId"),
                            rs.getString("Title"),
                            rs.getString("VideoUrl"),
                            (Integer) rs.getObject("DurationSeconds"),
                            rs.getInt("SortOrder"),
                            rs.getBoolean("IsPreview"),
                            rs.getBoolean("IsRequired")
                    );
                    lesson.setContent(rs.getString("Content"));

                    request.setAttribute("lesson", lesson);
                    request.setAttribute("courseTitle", rs.getString("CourseTitle"));
                    request.setAttribute("chapterTitle", rs.getString("ChapterTitle"));
                    request.setAttribute("pageTitle", "Học thử: " + lesson.getTitle() + " - Ftech");

                    request.getRequestDispatcher("/WEB-INF/view/public/preview.jsp")
                            .forward(request, response);
                    return;
                }
            }

            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Bài học thử không tồn tại hoặc chưa được mở xem trước.");

        } catch (SQLException ex) {
            getServletContext().log("PreviewServlet error", ex);
            throw new ServletException("Lỗi khi tải bài học thử.", ex);
        }
    }
}
