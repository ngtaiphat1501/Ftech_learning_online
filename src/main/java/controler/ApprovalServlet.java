package controler;

import config.DBContext;
import dao.ApprovalDAO;
import dao.CourseDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Chapter;
import model.Course;
import model.CourseApprovalEvent;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ApprovalServlet", urlPatterns = {
        "/admin/approvals",
        "/admin/approval",
        "/admin/course/approve",
        "/admin/course/reject"
})
public class ApprovalServlet extends HttpServlet {

    private final ApprovalDAO approvalDAO = new ApprovalDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final UserDAO userDAO = new UserDAO();

    private User getAuthenticatedAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Phê duyệt khóa học (Admin).");
            return null;
        }
        return currentUser;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = getAuthenticatedAdmin(request, response);
        if (admin == null) return;

        String path = request.getServletPath();

        try (Connection conn = DBContext.getConnection()) {
            if ("/admin/approval".equalsIgnoreCase(path)) {
                // View detail of a specific course for approval
                String idParam = request.getParameter("courseId");
                if (idParam == null || idParam.isBlank()) {
                    idParam = request.getParameter("id");
                }
                if (idParam == null || idParam.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals");
                    return;
                }

                long courseId = Long.parseLong(idParam);
                Course course = courseDAO.getCourseDetail(conn, courseId);
                if (course == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Không tìm thấy khóa học cần duyệt."));
                    return;
                }

                List<Chapter> chapters = courseDAO.getCourseChaptersWithLessons(conn, courseId);
                List<CourseApprovalEvent> history = approvalDAO.getApprovalHistory(conn, courseId);

                request.setAttribute("course", course);
                request.setAttribute("chapters", chapters);
                request.setAttribute("history", history);
                request.setAttribute("activeMenu", "admin");
                request.setAttribute("adminTab", "approvals");
                request.setAttribute("pageTitle", "Chi tiết duyệt khóa học: " + course.getTitle());

                request.getRequestDispatcher("/WEB-INF/view/admin/approval-detail.jsp").forward(request, response);

            } else {
                String status = request.getParameter("status");
                if (status == null || status.isBlank()) {
                    status = "PENDING_APPROVAL";
                }
                List<Course> filteredCourses = approvalDAO.getCoursesByStatus(conn, status);
                Map<String, Integer> statusCounts = approvalDAO.getCourseStatusCounts(conn);

                request.setAttribute("courses", filteredCourses);
                request.setAttribute("selectedStatus", status);
                request.setAttribute("statusCounts", statusCounts);
                request.setAttribute("activeMenu", "admin");
                request.setAttribute("adminTab", "approvals");
                request.setAttribute("pageTitle", "Duyệt & Quản lý khóa học - Admin Ftech");

                request.getRequestDispatcher("/WEB-INF/view/admin/approvals.jsp").forward(request, response);
            }

        } catch (SQLException ex) {
            getServletContext().log("ApprovalServlet GET error", ex);
            throw new ServletException("Lỗi hệ thống khi tải dữ liệu phê duyệt.", ex);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Mã khóa học không hợp lệ."));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = getAuthenticatedAdmin(request, response);
        if (admin == null) return;

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        try (Connection conn = DBContext.getConnection()) {
            long courseId = Long.parseLong(request.getParameter("courseId"));

            if ("/admin/course/approve".equalsIgnoreCase(path)) {
                String note = request.getParameter("note");
                boolean success = approvalDAO.approveCourse(conn, courseId, admin.getUserId(), note);

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals?msg=" + urlEncode("Phê duyệt và xuất bản khóa học thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Khóa học không ở trạng thái chờ duyệt hoặc không tồn tại."));
                }

            } else if ("/admin/course/reject".equalsIgnoreCase(path)) {
                String reason = request.getParameter("reason");
                if (reason == null || reason.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/admin/approval?courseId=" + courseId + "&error=" + urlEncode("Lý do từ chối là bắt buộc."));
                    return;
                }

                boolean success = approvalDAO.rejectCourse(conn, courseId, admin.getUserId(), reason);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals?msg=" + urlEncode("Đã từ chối khóa học và chuyển về trạng thái DRAFT kèm lý do gửi giảng viên."));
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Khóa học không ở trạng thái chờ duyệt hoặc không tồn tại."));
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/approvals");
            }

        } catch (SQLException ex) {
            getServletContext().log("ApprovalServlet POST error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Lỗi xử lý duyệt khóa: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/approvals?error=" + urlEncode("Mã khóa học không hợp lệ."));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
