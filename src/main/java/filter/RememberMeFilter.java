package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filter duy trì Cookie ghi nhớ tài khoản và Session trong 60 phút tương tác.
 * - Mỗi khi người dùng có tương tác (request), thời hạn Cookie tự động gia hạn thêm 60 phút (sliding expiration).
 * - Nếu không có tương tác nào trong 60 phút liên tục, Cookie và Session sẽ tự động hết hạn.
 */
@WebFilter(filterName = "RememberMeFilter", urlPatterns = {"/*"})
public class RememberMeFilter implements Filter {

    private static final int TIMEOUT_SECONDS = 60 * 60; // 60 phút (3600 giây)

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (request instanceof HttpServletRequest && response instanceof HttpServletResponse) {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpServletResponse res = (HttpServletResponse) response;

            String uri = req.getRequestURI();
            // Bỏ qua các file tĩnh (css, js, images) để tối ưu hiệu năng
            boolean isStatic = uri.contains("/assets/") || uri.endsWith(".css") || uri.endsWith(".js")
                    || uri.endsWith(".png") || uri.endsWith(".jpg") || uri.endsWith(".jpeg")
                    || uri.endsWith(".svg") || uri.endsWith(".ico");

            if (!isStatic) {
                HttpSession session = req.getSession(false);
                // Nếu đang đăng nhập, đặt timeout của session là 60 phút (3600 giây)
                if (session != null && session.getAttribute("userId") != null) {
                    session.setMaxInactiveInterval(TIMEOUT_SECONDS);

                    // Làm mới (sliding) Cookie ghi nhớ tài khoản thêm 60 phút nếu có
                    Cookie[] cookies = req.getCookies();
                    if (cookies != null) {
                        for (Cookie c : cookies) {
                            if ("rememberedUser".equals(c.getName())) {
                                Cookie refreshed = new Cookie("rememberedUser", c.getValue());
                                String path = req.getContextPath().isEmpty() ? "/" : req.getContextPath();
                                refreshed.setPath(path);
                                refreshed.setMaxAge(TIMEOUT_SECONDS); // 60 phút kể từ tương tác cuối
                                refreshed.setHttpOnly(true);
                                res.addCookie(refreshed);
                                break;
                            }
                        }
                    }
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
