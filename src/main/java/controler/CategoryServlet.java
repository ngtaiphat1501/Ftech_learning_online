package controler;

import dao.CategoryDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "CategoryServlet", urlPatterns = {"/admin/category", "/admin/categories"})
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
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

        try {
            List<Category> categories = categoryDAO.getAllForAdmin();
            request.setAttribute("categories", categories);
            request.setAttribute("activeMenu", "admin");
            request.setAttribute("adminTab", "categories");
            request.setAttribute("pageTitle", "Quản lý danh mục khóa học - Admin Ftech");

            request.getRequestDispatcher("/WEB-INF/view/admin/categories.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("CategoryServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải danh mục.", ex);
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
                case "create": {
                    String name = request.getParameter("name");
                    String slug = request.getParameter("slug");
                    String iconClass = request.getParameter("iconClass");
                    String description = request.getParameter("description");
                    boolean isActive = "1".equals(request.getParameter("isActive")) || "true".equalsIgnoreCase(request.getParameter("isActive"));

                    if (name == null || name.isBlank()) {
                        response.sendRedirect(request.getContextPath() + "/admin/category?error=" + urlEncode("Tên danh mục không được để trống."));
                        return;
                    }

                    Category cat = new Category(0, name.trim(), slug, iconClass, description, isActive);
                    categoryDAO.create(cat);
                    response.sendRedirect(request.getContextPath() + "/admin/category?msg=" + urlEncode("Thêm danh mục mới thành công!"));
                    break;
                }

                case "edit": {
                    long id = Long.parseLong(request.getParameter("id"));
                    String name = request.getParameter("name");
                    String slug = request.getParameter("slug");
                    String iconClass = request.getParameter("iconClass");
                    String description = request.getParameter("description");
                    boolean isActive = "1".equals(request.getParameter("isActive")) || "true".equalsIgnoreCase(request.getParameter("isActive"));

                    if (name == null || name.isBlank()) {
                        response.sendRedirect(request.getContextPath() + "/admin/category?error=" + urlEncode("Tên danh mục không được để trống."));
                        return;
                    }

                    Category cat = new Category(id, name.trim(), slug, iconClass, description, isActive);
                    categoryDAO.update(cat);
                    response.sendRedirect(request.getContextPath() + "/admin/category?msg=" + urlEncode("Cập nhật danh mục thành công!"));
                    break;
                }

                case "delete": {
                    long id = Long.parseLong(request.getParameter("id"));
                    if (categoryDAO.hasCourses(id)) {
                        response.sendRedirect(request.getContextPath() + "/admin/category?error=" + urlEncode("Không thể xóa danh mục vì đang có khóa học tham chiếu. Hãy đổi danh mục cho các khóa học trước!"));
                        return;
                    }

                    categoryDAO.delete(id);
                    response.sendRedirect(request.getContextPath() + "/admin/category?msg=" + urlEncode("Đã xóa danh mục thành công!"));
                    break;
                }

                default:
                    response.sendRedirect(request.getContextPath() + "/admin/category");
                    break;
            }

        } catch (SQLException ex) {
            getServletContext().log("CategoryServlet error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/category?error=" + urlEncode("Lỗi thao tác danh mục: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/category?error=" + urlEncode("ID danh mục không hợp lệ."));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
