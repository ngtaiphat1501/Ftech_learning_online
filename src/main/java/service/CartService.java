
package service;

import config.DBContext;
import dao.CartDAO;
import model.CartItem;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class CartService {

    private final CartDAO cartDAO = new CartDAO();

    public enum Result {
        ADDED,
        REMOVED,
        ALREADY_IN_CART,
        ALREADY_ENROLLED,
        NOT_IN_CART,
        COURSE_NOT_FOUND,
        NOT_PUBLISHED,
        NOT_PAID,
        FORBIDDEN,
        OWN_COURSE,
        INVALID_INPUT
    }

    // 1. XEM GIỎ HÀNG
    public List<CartItem> getCartItems(long studentId)
            throws SQLException {

        if (studentId <= 0) {
            throw new IllegalArgumentException(
                    "StudentId khong hop le");
        }

        try (Connection conn = DBContext.getConnection()) {

            if (!cartDAO.isActiveStudent(conn, studentId)) {
                throw new SecurityException(
                        "Khong co quyen STUDENT");
            }

            return cartDAO.getCartItems(conn, studentId);
        }
    }

    // 2. THÊM KHÓA HỌC VÀO GIỎ
    public Result addCourse(long studentId, long courseId)
            throws SQLException {

        if (studentId <= 0 || courseId <= 0) {
            return Result.INVALID_INPUT;
        }

        try (Connection conn = DBContext.beginTransaction()) {

            try {
                Result result;

                // Kiểm tra tài khoản học viên
                if (!cartDAO.isActiveStudent(conn, studentId)) {
                    result = Result.FORBIDDEN;

                } else {
                    // Lấy trạng thái và loại khóa học
                    String[] course =
                            cartDAO.getCourseInfo(conn, courseId);

                    if (course == null) {
                        result = Result.COURSE_NOT_FOUND;

                    } else if (!"PUBLISHED".equals(course[0])) {
                        result = Result.NOT_PUBLISHED;

                    } else if (!"PAID".equals(course[1])) {
                        result = Result.NOT_PAID;

                    } else if (course.length > 2 && course[2] != null && Long.parseLong(course[2]) == studentId) {
                        result = Result.OWN_COURSE;

                    } else if (cartDAO.hasEnrollment(
                            conn, studentId, courseId)) {
                        result = Result.ALREADY_ENROLLED;

                    } else {

                        // Tìm giỏ hàng hiện tại
                        Long cartId =
                                cartDAO.findCartIdForUpdate(
                                        conn, studentId);

                        // Nếu chưa có thì tạo giỏ
                        if (cartId == null) {
                            cartId = cartDAO.createCart(
                                    conn, studentId);
                        }

                        // Kiểm tra khóa đã có trong giỏ chưa
                        if (cartDAO.isCourseInCart(
                                conn, cartId, courseId)) {

                            result = Result.ALREADY_IN_CART;

                        } else {
                            // Thêm khóa học vào giỏ
                            cartDAO.addToCart(
                                    conn, cartId, courseId);

                            result = Result.ADDED;
                        }
                    }
                }

                conn.commit();
                return result;

            } catch (SQLException | RuntimeException ex) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    ex.addSuppressed(rollbackError);
                }
                throw ex;
            }
        }
    }

    // 3. XÓA KHÓA HỌC KHỎI GIỎ
    public Result removeCourse(long studentId, long courseId)
            throws SQLException {

        if (studentId <= 0 || courseId <= 0) {
            return Result.INVALID_INPUT;
        }

        try (Connection conn = DBContext.beginTransaction()) {

            try {
                Result result;

                if (!cartDAO.isActiveStudent(conn, studentId)) {
                    result = Result.FORBIDDEN;

                } else {
                    boolean removed =
                            cartDAO.removeFromCart(
                                    conn, studentId, courseId);

                    result = removed
                            ? Result.REMOVED
                            : Result.NOT_IN_CART;
                }

                conn.commit();
                return result;

            } catch (SQLException | RuntimeException ex) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    ex.addSuppressed(rollbackError);
                }
                throw ex;
            }
        }
    }
}
