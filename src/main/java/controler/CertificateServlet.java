package controler;

import dao.CertificateDAO;
import model.Certificate;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CertificateServlet", urlPatterns = {"/student/certificate", "/certificate"})
public class CertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long currentUserId = null;
        if (session != null && session.getAttribute("userId") instanceof Number) {
            currentUserId = ((Number) session.getAttribute("userId")).longValue();
        }

        String codeParam = request.getParameter("code");
        String courseIdParam = request.getParameter("courseId");

        try {
            Certificate cert = null;

            if (codeParam != null && !codeParam.isBlank()) {
                cert = certificateDAO.getCertificateByCode(codeParam.trim());
                if (cert == null) {
                    request.setAttribute("pageTitle", "Không tìm thấy chứng chỉ - Learnora");
                    request.setAttribute("jakarta.servlet.error.message", "Mã chứng chỉ không tồn tại hoặc không hợp lệ.");
                    request.getRequestDispatcher("/WEB-INF/view/error/404.jsp").forward(request, response);
                    return;
                }
            } else if (courseIdParam != null && !courseIdParam.isBlank()) {
                if (currentUserId == null) {
                    response.sendRedirect(request.getContextPath() + "/?authModal=signin");
                    return;
                }
                long courseId = Long.parseLong(courseIdParam.trim());
                cert = certificateDAO.getOrCreateCertificate(currentUserId, courseId);
                if (cert == null) {
                    request.setAttribute("pageTitle", "Chưa hoàn thành khóa học - Learnora");
                    request.setAttribute("jakarta.servlet.error.message",
                            "Bạn chưa hoàn thành khóa học này. Vui lòng hoàn thành 100% tất cả bài học và vượt qua các bài kiểm tra bắt buộc để nhận chứng chỉ tốt nghiệp.");
                    request.getRequestDispatcher("/WEB-INF/view/error/403.jsp").forward(request, response);
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/student/courses");
                return;
            }

            request.setAttribute("cert", cert);
            request.setAttribute("pageTitle", "Chứng chỉ hoàn thành: " + cert.getCourseTitle() + " - " + cert.getCertificateCode());
            request.getRequestDispatcher("/WEB-INF/view/student/certificate.jsp").forward(request, response);

        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số khóa học không hợp lệ.");
        } catch (SQLException ex) {
            getServletContext().log("CertificateServlet error", ex);
            throw new ServletException("Lỗi hệ thống khi tải chứng chỉ.", ex);
        }
    }
}
