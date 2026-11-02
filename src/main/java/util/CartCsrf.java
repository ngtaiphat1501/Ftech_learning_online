
package util;

import jakarta.servlet.http.HttpSession;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class CartCsrf {

    private static final String TOKEN_KEY = "cartCsrfToken";

    private CartCsrf() {
    }

    public static String getOrCreate(HttpSession session) {

        synchronized (session) {

            Object existing = session.getAttribute(TOKEN_KEY);

            if (existing instanceof String) {
                return (String) existing;
            }

            byte[] bytes = new byte[32];
            new SecureRandom().nextBytes(bytes);

            String token = Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(bytes);

            session.setAttribute(TOKEN_KEY, token);

            return token;
        }
    }

    public static boolean isValid(
            HttpSession session, String submitted) {

        if (session == null || submitted == null) {
            return false;
        }

        Object expected = session.getAttribute(TOKEN_KEY);

        if (!(expected instanceof String)) {
            return false;
        }

        return MessageDigest.isEqual(
                ((String) expected).getBytes(StandardCharsets.UTF_8),
                submitted.getBytes(StandardCharsets.UTF_8)
        );
    }
}
