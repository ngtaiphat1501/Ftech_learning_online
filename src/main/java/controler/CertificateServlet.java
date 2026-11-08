package controler;

import dao.CertificateDAO;
import model.Certificate;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CertificateServlet", urlPatterns = {"/certificate", "/student/certificate"})
public class CertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");
        String enrollmentIdParam = request.getParameter("enrollmentId");

        try {
            Certificate certificate = null;

            if (code != null && !code.isBlank()) {
                certificate = certificateDAO.getCertificateByCode(code.trim());
            }

            // Fallback: If logged in and enrollmentId or courseId is given, check/issue
            if (certificate == null && enrollmentIdParam != null && !enrollmentIdParam.isBlank()) {
                HttpSession session = request.getSession(false);
                if (session != null && session.getAttribute("userId") instanceof Number) {
                    try {
                        long eid = Long.parseLong(enrollmentIdParam.trim());
                        certificate = certificateDAO.issueCertificateIfEligible(eid, 0, request.getContextPath());
                    } catch (NumberFormatException ignored) {
                    }
                }
            }

            if (certificate == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thông tin chứng chỉ hoặc mã xác thực không hợp lệ.");
                return;
            }

            request.setAttribute("certificate", certificate);
            request.setAttribute("pageTitle", "Chứng chỉ hoàn thành: " + certificate.getCourseTitle());
            request.setAttribute("activeMenu", "myCourses");

            request.getRequestDispatcher("/WEB-INF/view/student/certificate.jsp").forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException("Lỗi hệ thống khi tải chứng chỉ.", ex);
        }
    }
}
