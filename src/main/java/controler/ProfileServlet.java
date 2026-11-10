package controler;

import config.DBContext;
import dao.UserDAO;
import dao.WalletDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.WalletTransaction;
import util.PasswordUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/student/wallet"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final WalletDAO walletDAO = new WalletDAO();

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

            // Sync user object in session with fresh DB data (especially BalanceVnd)
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.setAttribute("user", user);
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

            // Load wallet transactions
            List<WalletTransaction> transactions = walletDAO.getTransactionsByUserId(userId, 50);

            String activeTab = request.getParameter("tab");
            if (activeTab == null || activeTab.isBlank()) {
                if (request.getServletPath().contains("wallet")) {
                    activeTab = "wallet";
                } else {
                    activeTab = "info";
                }
            }

            request.setAttribute("userProfile", user);
            request.setAttribute("enrolledCount", enrolledCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("walletTransactions", transactions);
            request.setAttribute("activeTab", activeTab);
            request.setAttribute("activeMenu", "profile");
            request.setAttribute("pageTitle", "Hồ sơ cá nhân & Ví - Ftech LMS");

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

        NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
        currency.setMaximumFractionDigits(0);

        try {
            User currentUser = userDAO.findById(userId);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/?authModal=signin");
                return;
            }

            if ("topup".equalsIgnoreCase(action)) {
                String amountStr = request.getParameter("amount");
                String method = request.getParameter("method");
                if (method == null || method.isBlank()) {
                    method = "VIETQR";
                }

                BigDecimal amount = BigDecimal.ZERO;
                try {
                    if (amountStr != null) {
                        amountStr = amountStr.replaceAll("[^0-9]", "");
                        amount = new BigDecimal(amountStr);
                    }
                } catch (Exception ignored) {}

                if (amount.compareTo(BigDecimal.valueOf(10000)) < 0) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Số tiền nạp tối thiểu là 10.000đ."));
                    return;
                }

                String methodLabel = "VIETQR".equalsIgnoreCase(method) ? "VietQR (Ngân hàng)" : "Ví MoMo";
                boolean ok = walletDAO.topUp(userId, amount, method.toUpperCase(), "Nạp tiền vào ví qua " + methodLabel);
                if (ok) {
                    User updatedUser = userDAO.findById(userId);
                    HttpSession session = request.getSession(false);
                    if (session != null) session.setAttribute("user", updatedUser);
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&msg=" + urlEncode("Nạp thành công " + currency.format(amount) + "đ vào ví Ftech!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Không thể thực hiện nạp tiền. Vui lòng thử lại."));
                }

            } else if ("withdraw".equalsIgnoreCase(action)) {
                String amountStr = request.getParameter("amount");
                String method = request.getParameter("method");
                String bankName = request.getParameter("bankName");
                String accountNo = request.getParameter("accountNo");
                String accountHolder = request.getParameter("accountHolder");

                if (method == null || method.isBlank()) {
                    method = "BANK";
                }

                BigDecimal amount = BigDecimal.ZERO;
                try {
                    if (amountStr != null) {
                        amountStr = amountStr.replaceAll("[^0-9]", "");
                        amount = new BigDecimal(amountStr);
                    }
                } catch (Exception ignored) {}

                if (amount.compareTo(BigDecimal.valueOf(20000)) < 0) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Số tiền rút tối thiểu là 20.000đ."));
                    return;
                }

                BigDecimal currentBal = userDAO.getUserBalance(userId);
                if (currentBal.compareTo(amount) < 0) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Số dư ví không đủ (hiện có: " + currency.format(currentBal) + "đ)."));
                    return;
                }

                if (accountNo == null || accountNo.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Vui lòng nhập số tài khoản hoặc số điện thoại nhận tiền."));
                    return;
                }

                if (accountHolder == null || accountHolder.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Vui lòng nhập tên người nhận tiền."));
                    return;
                }

                String destInfo = "BANK".equalsIgnoreCase(method) 
                        ? (bankName != null ? bankName : "Ngân hàng") + " - STK: " + accountNo
                        : "MoMo - SĐT: " + accountNo;

                boolean ok = walletDAO.withdraw(userId, amount, method.toUpperCase(), bankName, accountNo.trim(), accountHolder.trim().toUpperCase(), "Rút tiền về " + destInfo);
                if (ok) {
                    User updatedUser = userDAO.findById(userId);
                    HttpSession session = request.getSession(false);
                    if (session != null) session.setAttribute("user", updatedUser);
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&msg=" + urlEncode("Rút tiền thành công " + currency.format(amount) + "đ về " + destInfo + "!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=wallet&error=" + urlEncode("Giao dịch rút tiền không thành công. Vui lòng kiểm tra lại số dư."));
                }

            } else if ("change_password".equalsIgnoreCase(action)) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (currentPassword == null || newPassword == null || confirmPassword == null) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=" + urlEncode("Vui lòng điền đầy đủ các trường mật khẩu."));
                    return;
                }

                if (!newPassword.equals(confirmPassword)) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=" + urlEncode("Mật khẩu xác nhận không khớp với mật khẩu mới."));
                    return;
                }

                if (newPassword.length() < 6) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=" + urlEncode("Mật khẩu mới phải có ít nhất 6 ký tự."));
                    return;
                }

                // Verify current password
                boolean passValid = PasswordUtil.verifyPassword(currentPassword, currentUser.getPasswordHash());
                if (!passValid) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=" + urlEncode("Mật khẩu hiện tại không chính xác."));
                    return;
                }

                // Hash & update
                String newHash = PasswordUtil.hashPassword(newPassword);
                boolean ok = userDAO.updatePassword(userId, newHash);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&msg=" + urlEncode("Đổi mật khẩu thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=" + urlEncode("Không thể cập nhật mật khẩu. Vui lòng thử lại."));
                }

            } else {
                // update_profile
                String fullName = request.getParameter("fullName");
                String headline = request.getParameter("headline");
                String bio = request.getParameter("bio");
                String avatarUrl = request.getParameter("avatarUrl");

                if (fullName == null || fullName.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=info&error=" + urlEncode("Họ và tên không được để trống."));
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

                    response.sendRedirect(request.getContextPath() + "/profile?tab=info&msg=" + urlEncode("Cập nhật thông tin hồ sơ thành công!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile?tab=info&error=" + urlEncode("Không thể cập nhật hồ sơ. Vui lòng thử lại."));
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
