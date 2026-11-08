package controler;

import config.DBContext;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.PasswordUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private Long getAuthenticatedUserId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return null;
        }

        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/?authModal=signin");
            return null;
        }
        return ((Number) uid).longValue();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getAuthenticatedUserId(request, response);
        if (userId == null) return;

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
                return;
            }

            // Count enrolled courses
            int enrolledCount = 0;
            int completedCount = 0;
            String statsSql = "SELECT COUNT(*) AS EnrolledTotal, "
                            + "       SUM(CASE WHEN CompletedAt IS NOT NULL THEN 1 ELSE 0 END) AS CompletedTotal "
                            + "FROM dbo.Enrollments "
                            + "WHERE StudentId = ? AND AccessStatus = 'ACTIVE'";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(statsSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        enrolledCount = rs.getInt("EnrolledTotal");
                        completedCount = rs.getInt("CompletedTotal");
                    }
                }
            } catch (SQLException ignored) {
            }

            request.setAttribute("userProfile", user);
            request.setAttribute("enrolledCount", enrolledCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("activeMenu", "profile");
            request.setAttribute("pageTitle", "Hồ sơ cá nhân - Learnora LMS");

            request.getRequestDispatcher("/WEB-INF/view/student/profile.jsp").forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("ProfileServlet GET error", ex);
            throw new ServletException("Lỗi hệ thống khi tải thông tin hồ sơ.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getAuthenticatedUserId(request, response);
        if (userId == null) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "update_profile";

        try {
            User currentUser = userDAO.findById(userId);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
                return;
            }

            if ("change_password".equalsIgnoreCase(action)) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (currentPassword == null || newPassword == null || confirmPassword == null) {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Vui lòng điền đầy đủ các trường mật khẩu."));
                    return;
                }

                if (!newPassword.equals(confirmPassword)) {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Mật khẩu xác nhận không khớp với mật khẩu mới."));
                    return;
                }

                if (newPassword.length() < 6) {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Mật khẩu mới phải có ít nhất 6 ký tự."));
                    return;
                }

                // Verify current password
                boolean passValid = PasswordUtil.verifyPassword(currentPassword, currentUser.getPasswordHash());
                if (!passValid) {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Mật khẩu hiện tại không chính xác."));
                    return;
                }

                // Hash & update
                String newHash = PasswordUtil.hashPassword(newPassword);
                boolean ok = userDAO.updatePassword(userId, newHash);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/profile?msg=" + urlEncode("Đổi mật khẩu thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Không thể cập nhật mật khẩu. Vui lòng thử lại."));
                }

            } else {
                // update_profile
                String fullName = request.getParameter("fullName");
                String headline = request.getParameter("headline");
                String bio = request.getParameter("bio");
                String avatarUrl = request.getParameter("avatarUrl");

                if (fullName == null || fullName.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Họ và tên không được để trống."));
                    return;
                }

                boolean ok = userDAO.updateProfile(userId, fullName, headline, bio, avatarUrl);
                if (ok) {
                    // Update session attributes for instant reflected UI
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        session.setAttribute("fullName", fullName.trim());
                        currentUser.setFullName(fullName.trim());
                        currentUser.setHeadline(headline != null ? headline.trim() : null);
                        currentUser.setBio(bio != null ? bio.trim() : null);
                        currentUser.setAvatarUrl(avatarUrl != null ? avatarUrl.trim() : null);
                        session.setAttribute("user", currentUser);
                    }

                    response.sendRedirect(request.getContextPath() + "/profile?msg=" + urlEncode("Cập nhật thông tin hồ sơ thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Không thể cập nhật hồ sơ. Vui lòng thử lại."));
                }
            }

        } catch (SQLException ex) {
            getServletContext().log("ProfileServlet POST error", ex);
            response.sendRedirect(request.getContextPath() + "/profile?error=" + urlEncode("Lỗi hệ thống: " + ex.getMessage()));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
