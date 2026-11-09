
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class EnrollmentDAO {

    // 1. Kiểm tra tài khoản có quyền STUDENT và ACTIVE
    public boolean isStudent(Connection conn, long userId)
            throws SQLException {

        String sql =
                "SELECT 1 "
                + "FROM dbo.Users u "
                + "INNER JOIN dbo.UserRoles ur "
                + "ON u.UserId = ur.UserId "
                + "WHERE u.UserId = ? "
                + "AND u.Status = 'ACTIVE' "
                + "AND ur.RoleCode IN ('STUDENT', 'INSTRUCTOR')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // 2. Lấy trạng thái và loại giá của khóa học
    public String[] getCourse(Connection conn, long courseId)
            throws SQLException {

        String sql =
                "SELECT Status, PricingType "
                + "FROM dbo.Courses WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE CourseId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return new String[]{
                        rs.getString("Status"),
                        rs.getString("PricingType")
                    };
                }

                return null;
            }
        }
    }

    // 3. Kiểm tra học viên đã đăng ký khóa học chưa
    public String getAccessStatus(
            Connection conn, long studentId, long courseId)
            throws SQLException {

        String sql =
                "SELECT AccessStatus "
                + "FROM dbo.Enrollments WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE StudentId = ? AND CourseId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);
            ps.setLong(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getString("AccessStatus");
                }

                return null;
            }
        }
    }

    // 4. Đăng ký khóa học miễn phí
    public long insertEnrollment(
            Connection conn, long studentId, long courseId)
            throws SQLException {

        String sql =
                "INSERT INTO dbo.Enrollments "
                + "(StudentId, CourseId, AccessStatus, SourceType) "
                + "OUTPUT INSERTED.EnrollmentId "
                + "VALUES (?, ?, 'ACTIVE', 'FREE_ENROLL')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, studentId);
            ps.setLong(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong(1);
                }

                throw new SQLException("Khong tao duoc Enrollment");
            }
        }
    }

    // 5. Ghi lịch sử cấp quyền học
    public void insertAccessEvent(
            Connection conn, long enrollmentId, long studentId)
            throws SQLException {

        String sql =
                "INSERT INTO dbo.EnrollmentAccessEvents "
                + "(EnrollmentId, EventType, ActorId, Reason) "
                + "VALUES (?, 'GRANTED', ?, "
                + "N'Dang ky khoa hoc mien phi')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, enrollmentId);
            ps.setLong(2, studentId);

            ps.executeUpdate();
        }
    }
    
    
public String[] getPreviewData(
        Connection conn,
        long studentId,
        long courseId) throws SQLException {

    String sql =
            "SELECT c.Title, c.Status, c.PricingType, "
            + "e.AccessStatus "
            + "FROM dbo.Courses c "
            + "LEFT JOIN dbo.Enrollments e "
            + "ON e.CourseId = c.CourseId "
            + "AND e.StudentId = ? "
            + "WHERE c.CourseId = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setLong(1, studentId);
        ps.setLong(2, courseId);

        try (ResultSet rs = ps.executeQuery()) {

            if (!rs.next()) {
                return null;
            }

            return new String[]{
                rs.getString("Title"),
                rs.getString("Status"),
                rs.getString("PricingType"),
                rs.getString("AccessStatus")
            };
        }
    }
}

    
    
}
