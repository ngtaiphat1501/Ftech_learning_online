package controler;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AuthService;
import service.AuthService.RegisterResult;

import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Redirect to homepage with query to automatically show Sign Up modal
        response.sendRedirect(request.getContextPath() + "/?authModal=signup");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String redirectUrl = request.getParameter("redirectUrl");

        RegisterResult result = authService.register(fullName, email, password, confirmPassword);

        HttpSession session = request.getSession(true);

        if (result.isSuccess()) {
            session.removeAttribute("registerError");
            session.removeAttribute("regFullName");
            session.removeAttribute("regEmail");

            session.setAttribute("loginSuccess", "Đăng ký thành công! Hãy đăng nhập để bắt đầu học tập.");
            session.setAttribute("loginEmail", email != null ? email.trim() : "");

            String target = resolveRedirectUrl(redirectUrl, request.getContextPath());
            if (target.contains("?")) {
                target += "&authModal=signin";
            } else {
                target += "?authModal=signin";
            }
            response.sendRedirect(target);

        } else {
            session.setAttribute("registerError", result.getMessage());
            session.setAttribute("regFullName", fullName != null ? fullName.trim() : "");
            session.setAttribute("regEmail", email != null ? email.trim() : "");

            String target = resolveRedirectUrl(redirectUrl, request.getContextPath());
            if (target.contains("?")) {
                target += "&authModal=signup";
            } else {
                target += "?authModal=signup";
            }
            response.sendRedirect(target);
        }
    }

    private String resolveRedirectUrl(String redirectUrl, String contextPath) {
        if (redirectUrl != null && !redirectUrl.isBlank()) {
            String trimmed = redirectUrl.trim();
            if (trimmed.startsWith(contextPath + "/") || trimmed.startsWith("/")) {
                return trimmed;
            }
        }
        return contextPath + "/";
    }
}
