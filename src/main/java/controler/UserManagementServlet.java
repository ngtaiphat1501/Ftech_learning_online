package controler;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "UserManagementServlet", urlPatterns = {"/admin/users", "/admin/user"})
public class UserManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
            return false;
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
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị viên (Admin).");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdmin(request, response)) return;

        String search = request.getParameter("q");
        String roleFilter = request.getParameter("role");
        String statusFilter = request.getParameter("status");

        try {
            List<User> users = userDAO.getAllUsersForAdmin(search, roleFilter, statusFilter);
            request.setAttribute("users", users);
            request.setAttribute("search", search);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("activeMenu", "admin");
            request.setAttribute("adminTab", "users");
            request.setAttribute("pageTitle", "Quản lý người dùng & Phân quyền - Admin Ftech");

            request.getRequestDispatcher("/WEB-INF/view/admin/users.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("UserManagementServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải danh sách người dùng.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action.toLowerCase()) {
                case "roles": {
                    long targetUserId = Long.parseLong(request.getParameter("userId"));
                    String[] rolesArr = request.getParameterValues("roles");
                    List<String> newRoles = new ArrayList<>();
                    if (rolesArr != null) {
                        for (String r : rolesArr) {
                            if (r != null && !r.isBlank()) {
                                newRoles.add(r.trim().toUpperCase());
                            }
                        }
                    }

                    // Enforce at least 1 role
                    if (newRoles.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/admin/users?error=" + urlEncode("Người dùng phải có ít nhất một vai trò!"));
                        return;
                    }

                    userDAO.updateUserRoles(targetUserId, newRoles);

                    // Per spec: cập nhật quyền session nếu đang đổi chính mình
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        Object uidObj = session.getAttribute("userId");
                        if (uidObj instanceof Number && ((Number) uidObj).longValue() == targetUserId) {
                            User currentUser = (User) session.getAttribute("user");
                            if (currentUser != null) {
                                currentUser.setRoles(newRoles);
                                session.setAttribute("user", currentUser);
                            }
                            session.setAttribute("roles", newRoles);
                        }
                    }

                    response.sendRedirect(request.getContextPath() + "/admin/users?msg=" + urlEncode("Cập nhật vai trò người dùng thành công!"));
                    break;
                }

                case "status": {
                    long targetUserId = Long.parseLong(request.getParameter("userId"));
                    String newStatus = request.getParameter("status");
                    if (!"ACTIVE".equalsIgnoreCase(newStatus) && !"LOCKED".equalsIgnoreCase(newStatus)) {
                        response.sendRedirect(request.getContextPath() + "/admin/users?error=" + urlEncode("Trạng thái không hợp lệ."));
                        return;
                    }

                    // Prevent locking self
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        Object uidObj = session.getAttribute("userId");
                        if (uidObj instanceof Number && ((Number) uidObj).longValue() == targetUserId && "LOCKED".equalsIgnoreCase(newStatus)) {
                            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + urlEncode("Bạn không thể tự khóa tài khoản Admin của chính mình!"));
                            return;
                        }
                    }

                    userDAO.updateUserStatus(targetUserId, newStatus);
                    response.sendRedirect(request.getContextPath() + "/admin/users?msg=" + urlEncode("Đã cập nhật trạng thái tài khoản thành: " + newStatus));
                    break;
                }

                default:
                    response.sendRedirect(request.getContextPath() + "/admin/users");
                    break;
            }

        } catch (SQLException ex) {
            getServletContext().log("UserManagementServlet error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + urlEncode("Lỗi cơ sở dữ liệu: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + urlEncode("ID người dùng không hợp lệ."));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
