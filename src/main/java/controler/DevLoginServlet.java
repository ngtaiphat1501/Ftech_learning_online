
package controler;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/dev/login")
public class DevLoginServlet extends HttpServlet {

    // UserId test - phải tồn tại trong SQL Server
    private static final long TEST_USER_ID = 2L;

    // GIẢ ĐĂNG NHẬP
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String ip = request.getRemoteAddr();

        if (!isLocalhost(ip)) {
            response.sendError(403);
            return;
        }

        HttpSession session = request.getSession(true);

        request.changeSessionId();

        session.setAttribute("userId", TEST_USER_ID);

        response.sendRedirect(
                request.getContextPath() + "/"
        );
    }

    // KIỂM TRA SESSION
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        if (!isLocalhost(request.getRemoteAddr())) {
            response.sendError(403);
            return;
        }

        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        // Chỉ lấy session cũ, không tạo mới
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.getWriter().println(
                    "FAIL: Chua co HttpSession"
            );
            return;
        }

        Object userId = session.getAttribute("userId");

        if (userId == null) {
            response.getWriter().println(
                    "FAIL: Chua dang nhap"
            );
            return;
        }

        response.getWriter().println(
                "PASS: Mock Login thanh cong"
        );

        response.getWriter().println(
                "Session userId = " + userId
        );
    }

    private boolean isLocalhost(String ip) {
        return "127.0.0.1".equals(ip)
                || "::1".equals(ip)
                || "0:0:0:0:0:0:0:1".equals(ip);
    }
}
