/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;

/**
 *
 * @author ACER
 */
public class CartDAO {

    // tìm CartId theo StudentId 

    public Long findCartIdByStudentId(Connection conn, long studentId) throws SQLException {

        String sql = "SELECT CartId FROM dbo.Carts "
                + "WHERE StudentId = ?";

        try (PreparedStatement ps
                = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong("CartId");
                }

                return null;
            }
        }
    }
        // tạo giỏ hàng mới cho học viên , quy ước nếu học viên chưa có giỏ hàng thì tạo mới, nếu đã có thì trả về CartId hiện tại

    public long createCart(Connection conn, long studentId)
            throws SQLException {
                // lệnh dbo.Carts nghĩa là bảng Carts trong cơ sở dữ liệu, 
                // StudentId là khóa ngoại liên kết với bảng Users (học viên).
                //  Câu lệnh SQL này sẽ chèn một bản ghi mới vào bảng Carts với StudentId 
                // được cung cấp và trả về CartId của bản ghi vừa được chèn.
                // xem kĩ lại về lệnh sql , này chưa test đang đợi spint 3 

        String sql = "INSERT INTO dbo.Carts (StudentId) "
                + "OUTPUT INSERTED.CartId "
                + "VALUES (?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong("CartId");
                }

                throw new SQLException("Cannot create cart");
            }
        }
    }

    public void addToCart(Connection conn, long cartId, long courseId)
            throws SQLException {

        String sql
                = "INSERT INTO dbo.CartItems (CartId, CourseId) "
                + "VALUES (?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, cartId);
            ps.setLong(2, courseId);

            int rows = ps.executeUpdate();

            if (rows != 1) {
                throw new SQLException("Cannot add course to cart");
            }
        }
    }
            // Lấy danh sách các khóa học trong giỏ hàng của học viên
    public List<CartItem> getCartItems(
            Connection conn, long studentId)
            throws SQLException {

        List<CartItem> items = new ArrayList<>();

                // Câu lệnh SQL này sẽ truy vấn các khóa học trong giỏ hàng của học viên dựa trên StudentId.
                // Nó sẽ kết hợp ba bảng: Carts, CartItems và Courses để lấy thông
                // tin chi tiết về các khóa học trong giỏ hàng, 
                // bao gồm CartItemId, CourseId, Title, ThumbnailUrl, Status và CurrentPriceVnd (giá hiện tại của khóa học).
                // Kết quả sẽ được sắp xếp theo thời gian thêm vào giỏ hàng (AddedAt) và CartItemId giảm dần.
                
        String sql
                = "SELECT ci.CartItemId, ci.CourseId, "
                + "cr.Title, cr.ThumbnailUrl, cr.Status, "
                + "cr.ListPriceVnd, "
                + "COALESCE(cr.SalePriceVnd, cr.ListPriceVnd) AS CurrentPriceVnd "
                + "FROM dbo.Carts c "
                + "INNER JOIN dbo.CartItems ci "
                + "ON c.CartId = ci.CartId "
                + "INNER JOIN dbo.Courses cr "
                + "ON ci.CourseId = cr.CourseId "
                + "WHERE c.StudentId = ? "
                + "ORDER BY ci.AddedAt DESC, ci.CartItemId DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    CartItem item = new CartItem(
                            rs.getLong("CartItemId"),
                            rs.getLong("CourseId"),
                            rs.getString("Title"),
                            rs.getString("ThumbnailUrl"),
                            rs.getString("Status"),
                            rs.getBigDecimal("CurrentPriceVnd"),
                            rs.getBigDecimal("ListPriceVnd")
                    );

                    items.add(item);
                }
            }
        }

        return items;
    }

    public boolean removeFromCart(Connection conn, long studentId, long courseId)throws SQLException {

        String sql
                = "DELETE ci "
                + "FROM dbo.CartItems ci "
                + "INNER JOIN dbo.Carts c "
                + "ON ci.CartId = c.CartId "
                + "WHERE c.StudentId = ? "
                + "AND ci.CourseId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);
            ps.setLong(2, courseId);

            int rows = ps.executeUpdate();

            return rows > 0;
        }
    }
    
    // Kiểm tra học viên hợp lệ
    public boolean isActiveStudent(
            Connection conn, long studentId)
            throws SQLException {

        String sql =
                "SELECT 1 FROM dbo.Users u "
                + "JOIN dbo.UserRoles ur "
                + "ON u.UserId = ur.UserId "
                + "WHERE u.UserId = ? "
                + "AND u.Status = 'ACTIVE' "
                + "AND ur.RoleCode = 'STUDENT'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Lấy thông tin loại và trạng thái khóa học
    public String[] getCourseInfo(
            Connection conn, long courseId)
            throws SQLException {

        String sql =
                "SELECT Status, PricingType, CAST(InstructorId AS VARCHAR) AS InstructorId "
                + "FROM dbo.Courses WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE CourseId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                return new String[]{
                    rs.getString("Status"),
                    rs.getString("PricingType"),
                    rs.getString("InstructorId")
                };
            }
        }
    }

    // Kiểm tra đã có Enrollment chưa
    public boolean hasEnrollment(
            Connection conn, long studentId, long courseId)
            throws SQLException {
                // Câu lệnh SQL này sẽ kiểm tra xem học viên đã đăng ký khóa học hay chưa bằng cách truy vấn bảng Enrollments.
                // Nó sẽ sử dụng khóa ngoại StudentId và CourseId để xác định xem có bản
                //  ghi nào tồn tại trong bảng Enrollments hay không. Nếu có, phương thức sẽ trả về true, ngược lại trả về false.
                // WITH (UPDLOCK, HOLDLOCK) là các hint trong SQL Server để khóa dòng dữ liệu trong quá trình truy vấn, nhằm tránh xung đột khi nhiều transaction cùng truy cập dữ liệu.
                // UPDLOCK: Khóa dòng dữ liệu để ngăn chặn các transaction khác cập nhật hoặc xóa dòng dữ liệu này trong khi transaction hiện tại đang thực hiện.
                // HOLDLOCK: Giữ khóa cho đến khi transaction hiện tại kết thúc, thay vì
                // chỉ giữ khóa trong suốt thời gian truy vấn. Điều này giúp đảm bảo rằng dữ liệu không bị thay đổi bởi các transaction khác trong khi transaction hiện tại đang thực hiện.
                
        String sql =
                "SELECT 1 "
                + "FROM dbo.Enrollments WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE StudentId = ? AND CourseId = ? AND AccessStatus = 'ACTIVE'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Tìm giỏ hàng và khóa dòng trong transaction
    public Long findCartIdForUpdate(
            Connection conn, long studentId)
            throws SQLException {

        String sql =
                "SELECT CartId "
                + "FROM dbo.Carts WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE StudentId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong("CartId") : null;
            }
        }
    }

    // Đếm số lượng khóa học trong giỏ hàng
    public int getCartCount(Connection conn, long studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.CartItems ci "
                + "INNER JOIN dbo.Carts c ON ci.CartId = c.CartId "
                + "WHERE c.StudentId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // Kiểm tra khóa học đã nằm trong giỏ chưa
    public boolean isCourseInCart(
            Connection conn, long cartId, long courseId)
            throws SQLException {

        String sql =
                "SELECT 1 "
                + "FROM dbo.CartItems WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE CartId = ? AND CourseId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

}
