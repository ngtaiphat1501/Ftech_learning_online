package controler;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AuthService;
import service.AuthService.LoginResult;

import java.io.IOException;
import java.util.concurrent.ThreadLocalRandom;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        if (session.getAttribute("userId") != null) {
            response.sendRedirect(
                    request.getContextPath() + "/"
            );
            return;
        }

        ensureCaptcha(session);

        response.sendRedirect(
                request.getContextPath()
                + "/?authModal=signin"
        );
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String emailOrUsername
                = request.getParameter("emailOrUsername");

        String password
                = request.getParameter("password");

        String captchaInput
                = request.getParameter("captchaInput");

        String redirectUrl
                = request.getParameter("redirectUrl");

        HttpSession session
                = request.getSession(true);

        /*
         * Kiểm tra CAPTCHA trước khi gọi AuthService.
         */
        if (!checkCaptcha(session, captchaInput)) {

            session.setAttribute(
                    "loginError",
                    "CAPTCHA không đúng. Vui lòng thử lại."
            );

            session.setAttribute(
                    "loginEmail",
                    emailOrUsername != null
                    ? emailOrUsername.trim()
                    : ""
            );

            // Sai CAPTCHA -> tạo phép tính mới
            generateCaptcha(session);

            redirectToSignIn(
                    request,
                    response,
                    redirectUrl
            );

            return;
        }

        /*
         * CAPTCHA đúng mới kiểm tra tài khoản.
         */
        LoginResult result
                = authService.login(
                        emailOrUsername,
                        password
                );

        if (result.isSuccess()) {

            User user = result.getUser();

            // Prevent session fixation
            request.changeSessionId();

            session.setAttribute(
                    "userId",
                    user.getUserId()
            );

            session.setAttribute(
                    "user",
                    user
            );

            session.setAttribute(
                    "fullName",
                    user.getFullName()
            );

            session.setAttribute(
                    "roles",
                    user.getRoles()
            );

            session.removeAttribute("loginError");
            session.removeAttribute("registerError");
            session.removeAttribute("loginEmail");

            // Cookies: Remember Me (PRJ301 Evaluation Criteria)
            String rememberMe = request.getParameter("rememberMe");
            String cookiePath = request.getContextPath().isEmpty() ? "/" : request.getContextPath();
            if ("true".equalsIgnoreCase(rememberMe) || "on".equalsIgnoreCase(rememberMe) || "1".equals(rememberMe)) {
                jakarta.servlet.http.Cookie userCookie = new jakarta.servlet.http.Cookie("rememberedUser", java.net.URLEncoder.encode(user.getEmail(), java.nio.charset.StandardCharsets.UTF_8));
                userCookie.setMaxAge(60 * 60); // 60 phút (3600 giây) nếu không có tương tác
                session.setMaxInactiveInterval(60 * 60);
                userCookie.setPath(cookiePath);
                userCookie.setHttpOnly(true);
                response.addCookie(userCookie);
            } else {
                jakarta.servlet.http.Cookie userCookie = new jakarta.servlet.http.Cookie("rememberedUser", "");
                userCookie.setMaxAge(0);
                userCookie.setPath(cookiePath);
                response.addCookie(userCookie);
            }

            // Không cần CAPTCHA nữa sau khi login
            clearCaptcha(session);

            String target
                    = resolveRedirectUrl(
                            redirectUrl,
                            request.getContextPath()
                    );

            response.sendRedirect(target);

        } else {

            session.setAttribute(
                    "loginError",
                    result.getMessage()
            );

            session.setAttribute(
                    "loginEmail",
                    emailOrUsername != null
                    ? emailOrUsername.trim()
                    : ""
            );

            /*
             * Password/email sai thì cũng tạo CAPTCHA mới.
             */
            generateCaptcha(session);

            redirectToSignIn(
                    request,
                    response,
                    redirectUrl
            );
        }
    }

    private boolean checkCaptcha(
            HttpSession session,
            String captchaInput) {

        Object answerObject
                = session.getAttribute(
                        "loginCaptchaAnswer"
                );

        if (answerObject == null
                || captchaInput == null
                || captchaInput.isBlank()) {

            return false;
        }

        try {

            int userAnswer
                    = Integer.parseInt(
                            captchaInput.trim()
                    );

            int correctAnswer
                    = ((Number) answerObject)
                            .intValue();

            return userAnswer == correctAnswer;

        } catch (NumberFormatException ex) {

            return false;
        }
    }

    private void ensureCaptcha(
            HttpSession session) {

        if (session.getAttribute(
                "loginCaptchaAnswer"
        ) == null) {

            generateCaptcha(session);
        }
    }

    private void generateCaptcha(
            HttpSession session) {

        int a = ThreadLocalRandom
                .current()
                .nextInt(1, 10);

        int b = ThreadLocalRandom
                .current()
                .nextInt(1, 10);

        session.setAttribute(
                "loginCaptchaA",
                a
        );

        session.setAttribute(
                "loginCaptchaB",
                b
        );

        session.setAttribute(
                "loginCaptchaAnswer",
                a + b
        );
    }

    private void clearCaptcha(
            HttpSession session) {

        session.removeAttribute(
                "loginCaptchaA"
        );

        session.removeAttribute(
                "loginCaptchaB"
        );

        session.removeAttribute(
                "loginCaptchaAnswer"
        );
    }

    private void redirectToSignIn(
            HttpServletRequest request,
            HttpServletResponse response,
            String redirectUrl)
            throws IOException {

        String target
                = resolveRedirectUrl(
                        redirectUrl,
                        request.getContextPath()
                );

        if (target.contains("?")) {

            target += "&authModal=signin";

        } else {

            target += "?authModal=signin";
        }

        response.sendRedirect(target);
    }

    private String resolveRedirectUrl(
            String redirectUrl,
            String contextPath) {

        if (redirectUrl != null
                && !redirectUrl.isBlank()) {

            String trimmed
                    = redirectUrl.trim();

            // Prevent open redirect attacks
            if (trimmed.startsWith(
                    contextPath + "/"
            ) || trimmed.startsWith("/")) {

                return trimmed;
            }
        }

        return contextPath + "/";
    }
}