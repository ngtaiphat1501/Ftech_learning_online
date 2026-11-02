package controler;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import service.EnrollmentService;
import service.EnrollmentService.Result;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;

@WebServlet(name = "EnrollmentServlet",
        urlPatterns = {"/student/enroll"})
public class EnrollmentServlet extends HttpServlet {

    private final EnrollmentService service = new EnrollmentService();

    private static final String CSRF_KEY = "enrollmentCsrf";
    private static final String FLASH_KEY = "enrollmentMessage";

    // Lấy ID người dùng từ Session sau khi Login
    private Long getStudentId(HttpSession session) {

        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("userId");

        if (!(value instanceof Number)) {
            return null;
        }

        long id = ((Number) value).longValue();

        return id > 0 ? id : null;
    }

    // Đọc và kiểm tra CourseId từ request
    private Long getCourseId(HttpServletRequest request) {

        try {
            long id = Long.parseLong(
                    request.getParameter("courseId"));

            return id > 0 ? id : null;

        } catch (NumberFormatException ex) {
            return null;
        }
    }

    // Tạo CSRF token và lưu trong Session
    private String getCsrfToken(HttpSession session) {

        String token
                = (String) session.getAttribute(CSRF_KEY);

        if (token == null) {
            byte[] random = new byte[32];
            new SecureRandom().nextBytes(random);

            token = Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(random);

            session.setAttribute(CSRF_KEY, token);
        }

        return token;
    }

    // Kiểm tra CSRF token khi POST
    private boolean isValidCsrf(
            HttpServletRequest request,
            HttpSession session) {

        if (session == null) {
            return false;
        }

        String expected
                = (String) session.getAttribute(CSRF_KEY);

        String submitted
                = request.getParameter("csrfToken");

        if (expected == null || submitted == null) {
            return false;
        }

        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                submitted.getBytes(StandardCharsets.UTF_8)
        );
    }

    // GET: Hiển thị trang xác nhận đăng ký
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);

        Long studentId = getStudentId(session);

        if (studentId == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui long dang nhap"
            );
            return;
        }

        // 2. Kiểm tra CourseId
        Long courseId = getCourseId(request);

        if (courseId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "CourseId khong hop le"
            );
            return;
        }

        try {
            // 3. Gọi Service lấy thông tin khóa học
            EnrollmentService.Preview preview
                    = service.preview(studentId, courseId);

            // 4. Kiểm tra khóa học không tồn tại
            if (preview.getStatus()
                    == EnrollmentService.PreviewStatus.COURSE_NOT_FOUND) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Khong tim thay khoa hoc"
                );
                return;
            }

            // 5. Kiểm tra quyền STUDENT
            if (preview.getStatus()
                    == EnrollmentService.PreviewStatus.FORBIDDEN) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Khong co quyen STUDENT"
                );
                return;
            }

            // 6. Lấy CSRF Token
            String csrfToken = getCsrfToken(session);

            // 7. Đọc thông báo từ lần POST trước
            String resultMessage
                    = (String) session.getAttribute(FLASH_KEY);

            session.removeAttribute(FLASH_KEY);

            // 8. Truyền dữ liệu sang JSP
            request.setAttribute("courseId", courseId);

            request.setAttribute(
                    "safeTitle",
                    escapeHtml(preview.getTitle())
            );

            request.setAttribute(
                    "statusMessage",
                    preview.getStatusMessage()
            );

            request.setAttribute(
                    "canEnroll",
                    preview.isCanEnroll()
            );

            request.setAttribute(
                    "csrfToken",
                    csrfToken
            );

            request.setAttribute(
                    "resultMessage",
                    resultMessage
            );

            // 9. Hiển thị JSP
            request.getRequestDispatcher(
                    "/WEB-INF/view/student/enroll-confirm.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {

            getServletContext().log(
                    "Loi tai thong tin dang ky khoa hoc", ex
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Khong the tai thong tin khoa hoc"
            );
        }
    }

    // POST: Thực hiện đăng ký khóa học
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // 1. Kiểm tra đăng nhập
        Long studentId = getStudentId(session);

        if (studentId == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui long dang nhap");
            return;
        }

        // 2. Kiểm tra CourseId
        Long courseId = getCourseId(request);

        if (courseId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "CourseId khong hop le");
            return;
        }

        // 3. Kiểm tra CSRF
        if (!isValidCsrf(request, session)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "CSRF token khong hop le");
            return;
        }

        try {
            // 4. Gọi Service xử lý đăng ký
            Result result
                    = service.enroll(studentId, courseId);

            // 5. Xử lý kết quả
            String message;

            switch (result) {

                case SUCCESS:
                    message = "Dang ky thanh cong!";
                    break;

                case ALREADY_ENROLLED:
                    message = "Ban da dang ky khoa hoc nay.";
                    break;

                case ACCESS_RESTRICTED:
                    message = "Quyen hoc dang bi han che.";
                    break;

                case COURSE_NOT_FOUND:
                    message = "Khong tim thay khoa hoc.";
                    break;

                case NOT_PUBLISHED:
                    message = "Khoa hoc chua duoc xuat ban.";
                    break;

                case PAID_COURSE:
                    message = "Khoa hoc nay can thanh toan.";
                    break;

                case FORBIDDEN:
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Khong co quyen STUDENT");
                    return;

                default:
                    response.sendError(
                            HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    return;
            }

            // 6. Lưu thông báo vào Session
            session.setAttribute(FLASH_KEY, message);

            // 7. Redirect về trang xác nhận/kết quả
            response.sendRedirect(
                    request.getContextPath()
                    + "/student/enroll?courseId="
                    + courseId
            );

        } catch (SQLException ex) {

            getServletContext().log(
                    "Loi dang ky khoa hoc", ex);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Khong the dang ky khoa hoc");
        }
    }
    
    
private String escapeHtml(String value) {

    if (value == null) {
        return "";
    }

    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}

}
