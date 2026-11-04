package service;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.util.regex.Pattern;

public class AuthService {

    private final UserDAO userDAO;

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public enum LoginStatus {
        SUCCESS,
        INVALID_CREDENTIALS,
        ACCOUNT_LOCKED,
        ERROR
    }

    public static class LoginResult {
        private final LoginStatus status;
        private final User user;
        private final String message;

        public LoginResult(LoginStatus status, User user, String message) {
            this.status = status;
            this.user = user;
            this.message = message;
        }

        public LoginStatus getStatus() {
            return status;
        }

        public User getUser() {
            return user;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSuccess() {
            return status == LoginStatus.SUCCESS;
        }
    }

    public enum RegisterStatus {
        SUCCESS,
        INVALID_NAME,
        INVALID_EMAIL,
        INVALID_PASSWORD,
        PASSWORD_MISMATCH,
        EMAIL_EXISTS,
        ERROR
    }

    public static class RegisterResult {
        private final RegisterStatus status;
        private final User user;
        private final String message;

        public RegisterResult(RegisterStatus status, User user, String message) {
            this.status = status;
            this.user = user;
            this.message = message;
        }

        public RegisterStatus getStatus() {
            return status;
        }

        public User getUser() {
            return user;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSuccess() {
            return status == RegisterStatus.SUCCESS;
        }
    }

    /**
     * Authenticates a user by email/username and raw password.
     */
    public LoginResult login(String emailOrUsername, String password) {
        if (emailOrUsername == null || emailOrUsername.isBlank() || password == null || password.isEmpty()) {
            return new LoginResult(LoginStatus.INVALID_CREDENTIALS, null, "Vui lòng nhập đầy đủ thông tin đăng nhập.");
        }

        try {
            User user = userDAO.findByEmail(emailOrUsername.trim());
            if (user == null) {
                return new LoginResult(LoginStatus.INVALID_CREDENTIALS, null, "Email hoặc mật khẩu không chính xác.");
            }

            if ("LOCKED".equalsIgnoreCase(user.getStatus())) {
                return new LoginResult(LoginStatus.ACCOUNT_LOCKED, null, "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
            }

            boolean passwordMatch = PasswordUtil.verifyPassword(password, user.getPasswordHash());
            if (!passwordMatch) {
                return new LoginResult(LoginStatus.INVALID_CREDENTIALS, null, "Email hoặc mật khẩu không chính xác.");
            }

            return new LoginResult(LoginStatus.SUCCESS, user, "Đăng nhập thành công.");

        } catch (SQLException ex) {
            return new LoginResult(LoginStatus.ERROR, null, "Lỗi kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
        }
    }

    /**
     * Registers a new student account.
     */
    public RegisterResult register(String fullName, String email, String password, String confirmPassword) {
        if (fullName == null || fullName.trim().length() < 2) {
            return new RegisterResult(RegisterStatus.INVALID_NAME, null, "Họ và tên phải có ít nhất 2 ký tự.");
        }

        if (email == null || email.isBlank() || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return new RegisterResult(RegisterStatus.INVALID_EMAIL, null, "Địa chỉ email không đúng định dạng.");
        }

        if (password == null || password.length() < 6) {
            return new RegisterResult(RegisterStatus.INVALID_PASSWORD, null, "Mật khẩu phải có ít nhất 6 ký tự.");
        }

        if (!password.equals(confirmPassword)) {
            return new RegisterResult(RegisterStatus.PASSWORD_MISMATCH, null, "Mật khẩu xác nhận không khớp.");
        }

        try {
            if (userDAO.existsByEmail(email.trim())) {
                return new RegisterResult(RegisterStatus.EMAIL_EXISTS, null, "Email này đã được đăng ký tài khoản.");
            }

            String passwordHash = PasswordUtil.hashPassword(password);
            User newUser = new User();
            newUser.setEmail(email.trim());
            newUser.setFullName(fullName.trim());
            newUser.setPasswordHash(passwordHash);
            newUser.setStatus("ACTIVE");

            userDAO.registerStudent(newUser);

            return new RegisterResult(RegisterStatus.SUCCESS, newUser, "Đăng ký tài khoản thành công!");

        } catch (SQLException ex) {
            return new RegisterResult(RegisterStatus.ERROR, null, "Lỗi hệ thống khi đăng ký. Vui lòng thử lại sau.");
        }
    }
}
