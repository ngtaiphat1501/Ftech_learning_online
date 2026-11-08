package controler;

import dao.ModerationDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CourseReview;
import model.DiscussionPost;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ModerationServlet", urlPatterns = {"/admin/moderation"})
public class ModerationServlet extends HttpServlet {

    private final ModerationDAO moderationDAO = new ModerationDAO();
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

        String tab = request.getParameter("tab");
        if (tab == null || (!"discussions".equalsIgnoreCase(tab) && !"reviews".equalsIgnoreCase(tab))) {
            tab = "reviews";
        }

        String filter = request.getParameter("filter");
        String search = request.getParameter("q");

        try {
            if ("discussions".equalsIgnoreCase(tab)) {
                List<DiscussionPost> posts = moderationDAO.getDiscussionsForAdmin(filter, search);
                request.setAttribute("discussions", posts);
            } else {
                List<CourseReview> reviews = moderationDAO.getReviewsForAdmin(filter, search);
                request.setAttribute("reviews", reviews);
            }

            request.setAttribute("activeTab", tab);
            request.setAttribute("filter", filter);
            request.setAttribute("search", search);
            request.setAttribute("activeMenu", "admin");
            request.setAttribute("adminTab", "moderation");
            request.setAttribute("pageTitle", "Kiểm duyệt nội dung - Admin Ftech");

            request.getRequestDispatcher("/WEB-INF/view/admin/moderation.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("ModerationServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải dữ liệu kiểm duyệt.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String type = request.getParameter("type");
        String idStr = request.getParameter("id");
        String tab = request.getParameter("tab");
        if (tab == null) tab = "reviews";

        if (action == null || type == null || idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=" + tab);
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            boolean isHide = "hide".equalsIgnoreCase(action);

            if ("discussion".equalsIgnoreCase(type)) {
                moderationDAO.setDiscussionHidden(id, isHide);
                String msg = isHide ? "Đã ẩn bài thảo luận vi phạm!" : "Đã khôi phục hiển thị bài thảo luận!";
                response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=discussions&msg=" + urlEncode(msg));
            } else if ("review".equalsIgnoreCase(type)) {
                moderationDAO.setReviewHidden(id, isHide);
                String msg = isHide ? "Đã ẩn đánh giá vi phạm!" : "Đã khôi phục hiển thị đánh giá!";
                response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=reviews&msg=" + urlEncode(msg));
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=" + tab);
            }

        } catch (SQLException ex) {
            getServletContext().log("ModerationServlet error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=" + tab + "&error=" + urlEncode("Lỗi kiểm duyệt: " + ex.getMessage()));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/moderation?tab=" + tab + "&error=" + urlEncode("ID không hợp lệ."));
        }
    }

    private String urlEncode(String val) {
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
