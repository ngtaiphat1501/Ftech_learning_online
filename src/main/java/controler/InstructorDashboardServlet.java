package controler;

import dao.CourseDAO;
import dao.UserDAO;
import dao.WalletDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.User;
import model.WalletTransaction;

@WebServlet(name = "InstructorDashboardServlet", urlPatterns = {"/instructor/dashboard"})
public class InstructorDashboardServlet extends HttpServlet {

    private boolean checkInstructor(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
                currentUser = new UserDAO().findById(currentUserId);
                if (currentUser != null && session != null) {
                    session.setAttribute("user", currentUser);
                    session.setAttribute("fullName", currentUser.getFullName());
                    session.setAttribute("roles", currentUser.getRoles());
                }
            } catch (SQLException ignored) {
            }
        }

        if (currentUser == null || (!currentUser.isInstructor() && !currentUser.isAdmin())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Giảng viên (Instructor).");
            return false;
        }

        return true;
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkInstructor(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);

        long instructorId = ((Number) session.getAttribute("userId")).longValue();

        try {
            CourseDAO courseDAO = new CourseDAO();
            UserDAO userDAO = new UserDAO();
            WalletDAO walletDAO = new WalletDAO();

            User instructorUser = userDAO.findById(instructorId);
            List<Course> courses = courseDAO.getByInstructorId(instructorId);

            BigDecimal totalRevenue = BigDecimal.ZERO;
            int totalStudents = 0;
            int publishedCount = 0;

            if (courses != null) {
                for (Course c : courses) {
                    if (c.getRevenueVnd() != null) {
                        totalRevenue = totalRevenue.add(c.getRevenueVnd());
                    }
                    totalStudents += c.getEnrollmentCount();
                    if ("PUBLISHED".equalsIgnoreCase(c.getStatus())) {
                        publishedCount++;
                    }
                }
            }

            BigDecimal balanceVnd = BigDecimal.ZERO;
            if (instructorUser != null && instructorUser.getBalanceVnd() != null) {
                balanceVnd = instructorUser.getBalanceVnd();
            }

            int currentYear = LocalDate.now().getYear();
            List<Map<String, Object>> monthlyRevenue = courseDAO.getMonthlyRevenueByInstructor(instructorId, currentYear);
            List<Map<String, Object>> recentEnrollments = courseDAO.getRecentEnrollmentsByInstructor(instructorId, 6);
            List<Course> topCourses = courseDAO.getTopCoursesByInstructor(instructorId, 5);
            List<WalletTransaction> recentTransactions = walletDAO.getTransactionsByUserId(instructorId, 8);

            request.setAttribute("instructorUser", instructorUser);
            request.setAttribute("topCourses", topCourses);
            request.setAttribute("courses", courses);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("publishedCount", publishedCount);
            request.setAttribute("balanceVnd", balanceVnd);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("recentEnrollments", recentEnrollments);
            request.setAttribute("recentTransactions", recentTransactions);
            request.setAttribute("selectedYear", currentYear);
            request.setAttribute("pageTitle", "Tổng quan Giảng viên | Ftech Instructor Studio");

            request.getRequestDispatcher("/WEB-INF/view/instructor/dashboard.jsp").forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("Lỗi tải Instructor Dashboard", ex);
            throw new ServletException("Không thể tải Bảng điều khiển Giảng viên.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkInstructor(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);

        long instructorId = ((Number) session.getAttribute("userId")).longValue();
        String action = request.getParameter("action");

        if ("withdraw".equalsIgnoreCase(action)) {
            String method = request.getParameter("method");
            String bankName = request.getParameter("bankName");
            String accountNo = request.getParameter("accountNo");
            String accountHolder = request.getParameter("accountHolder");
            String amountStr = request.getParameter("amount");

            BigDecimal amount = BigDecimal.ZERO;
            try {
                if (amountStr != null) {
                    amount = new BigDecimal(amountStr.trim().replaceAll("[,.]", ""));
                }
            } catch (Exception ignored) {}

            if (amount.compareTo(BigDecimal.valueOf(10000)) < 0) {
                response.sendRedirect(request.getContextPath() + "/instructor/dashboard?error=" + urlEncode("Số tiền rút tối thiểu là 10.000 đ."));
                return;
            }

            if (accountNo == null || accountNo.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/instructor/dashboard?error=" + urlEncode("Vui lòng nhập số tài khoản hoặc số điện thoại MoMo."));
                return;
            }

            if (accountHolder == null || accountHolder.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/instructor/dashboard?error=" + urlEncode("Vui lòng nhập tên chủ tài khoản nhận tiền."));
                return;
            }

            String destInfo = "BANK".equalsIgnoreCase(method)
                    ? ((bankName != null && !bankName.isBlank()) ? bankName : "Ngân hàng") + " - STK: " + accountNo
                    : "MoMo - SĐT: " + accountNo;

            try {
                WalletDAO walletDAO = new WalletDAO();
                boolean ok = walletDAO.withdraw(instructorId, amount, method != null ? method.toUpperCase() : "BANK",
                        bankName, accountNo.trim(), accountHolder.trim().toUpperCase(), "Giảng viên rút doanh thu về " + destInfo);
                if (ok) {
                    UserDAO userDAO = new UserDAO();
                    User updatedUser = userDAO.findById(instructorId);
                    if (updatedUser != null) {
                        session.setAttribute("user", updatedUser);
                    }
                    NumberFormat cur = NumberFormat.getIntegerInstance(new Locale("vi", "VN"));
                    response.sendRedirect(request.getContextPath() + "/instructor/dashboard?msg=" + urlEncode("Rút doanh thu thành công " + cur.format(amount) + " đ về " + destInfo + "!"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/instructor/dashboard?error=" + urlEncode("Số dư khả dụng không đủ để thực hiện rút tiền."));
                }
                return;
            } catch (SQLException ex) {
                getServletContext().log("Lỗi rút tiền giảng viên", ex);
                response.sendRedirect(request.getContextPath() + "/instructor/dashboard?error=" + urlEncode("Lỗi hệ thống khi xử lý yêu cầu rút tiền."));
                return;
            }
        }

        doGet(request, response);
    }

    private String urlEncode(String val) {
        if (val == null) return "";
        return URLEncoder.encode(val, StandardCharsets.UTF_8);
    }
}
