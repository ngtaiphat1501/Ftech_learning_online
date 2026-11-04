package util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

/**
 * Utility for hashing and verifying passwords using PBKDF2-HMAC-SHA256,
 * matching the database format: pbkdf2_sha256$<iterations>$<saltBase64>$<hashBase64>
 */
public final class PasswordUtil {

    private static final String ALGORITHM_PREFIX = "pbkdf2_sha256";
    private static final int DEFAULT_ITERATIONS = 600000;
    private static final int KEY_LENGTH_BITS = 256;
    private static final int SALT_BYTES = 16;

    private PasswordUtil() {
    }

    /**
     * Hashes a raw password with PBKDF2-HMAC-SHA256 and a random salt.
     *
     * @param rawPassword the plain text password
     * @return encoded string format: pbkdf2_sha256$600000$saltBase64$hashBase64
     */
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null || rawPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }

        byte[] salt = new byte[SALT_BYTES];
        new SecureRandom().nextBytes(salt);

        byte[] hash = pbkdf2(rawPassword.toCharArray(), salt, DEFAULT_ITERATIONS, KEY_LENGTH_BITS);

        String saltBase64 = Base64.getEncoder().encodeToString(salt);
        String hashBase64 = Base64.getEncoder().encodeToString(hash);

        return String.format("%s$%d$%s$%s", ALGORITHM_PREFIX, DEFAULT_ITERATIONS, saltBase64, hashBase64);
    }

    /**
     * Verifies a raw password against the stored database hash.
     *
     * @param rawPassword the plain text password from login input
     * @param storedHash  the encoded hash from database
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null || storedHash.isEmpty()) {
            return false;
        }

        // Stored format: pbkdf2_sha256$600000$saltBase64$hashBase64
        String[] parts = storedHash.split("\\$");
        if (parts.length == 4 && ALGORITHM_PREFIX.equalsIgnoreCase(parts[0])) {
            try {
                int iterations = Integer.parseInt(parts[1]);
                byte[] salt = Base64.getDecoder().decode(parts[2]);
                byte[] expectedHash = Base64.getDecoder().decode(parts[3]);

                byte[] actualHash = pbkdf2(rawPassword.toCharArray(), salt, iterations, expectedHash.length * 8);

                return MessageDigest.isEqual(actualHash, expectedHash);
            } catch (Exception ex) {
                return false;
            }
        }

        // Fallback for development if plain text or raw comparison was used
        return MessageDigest.isEqual(
                rawPassword.getBytes(StandardCharsets.UTF_8),
                storedHash.getBytes(StandardCharsets.UTF_8)
        );
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLengthBits) {
        try {
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLengthBits);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("PBKDF2WithHmacSHA256 is not available", e);
        }
    }
}
