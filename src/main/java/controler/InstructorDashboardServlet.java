package controler;

import dao.CourseDAO;
import dao.UserDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.User;

@WebServlet(name = "InstructorDashboardServlet", urlPatterns = {"/instructor/dashboard"})
public class InstructorDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long instructorId = ((Number) session.getAttribute("userId")).longValue();

        try {
            CourseDAO courseDAO = new CourseDAO();
            UserDAO userDAO = new UserDAO();

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

            request.setAttribute("instructorUser", instructorUser);
            request.setAttribute("courses", courses);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("publishedCount", publishedCount);
            request.setAttribute("balanceVnd", balanceVnd);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("recentEnrollments", recentEnrollments);
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
        doGet(request, response);
    }
}
