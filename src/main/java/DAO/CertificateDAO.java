package dao;

import config.DBContext;
import model.Certificate;

import java.sql.*;
import java.time.LocalDateTime;

public class CertificateDAO {

    /**
     * Finds or auto-issues a Certificate for a student in a specific course.
     */
    public Certificate getOrCreateCertificate(long studentId, long courseId) throws SQLException {
        String findExistingSql = "SELECT c.CertificateId, c.EnrollmentId, c.CertificateCode, c.Status, c.IssuedAt, c.VerificationUrl, "
                + "u.FullName AS StudentName, co.Title AS CourseTitle, inst.FullName AS InstructorName "
                + "FROM dbo.Certificates c "
                + "JOIN dbo.Enrollments e ON e.EnrollmentId = c.EnrollmentId "
                + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                + "JOIN dbo.Courses co ON co.CourseId = e.CourseId "
                + "JOIN dbo.Users inst ON inst.UserId = co.InstructorId "
                + "WHERE e.StudentId = ? AND e.CourseId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(findExistingSql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCertificate(rs);
                }
            }
        }

        // Check if student has an active enrollment
        String enrollmentSql = "SELECT e.EnrollmentId, u.FullName AS StudentName, co.Title AS CourseTitle, inst.FullName AS InstructorName "
                + "FROM dbo.Enrollments e "
                + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                + "JOIN dbo.Courses co ON co.CourseId = e.CourseId "
                + "JOIN dbo.Users inst ON inst.UserId = co.InstructorId "
                + "WHERE e.StudentId = ? AND e.CourseId = ? AND e.AccessStatus = 'ACTIVE'";

        long enrollmentId = 0;
        String studentName = "";
        String courseTitle = "";
        String instructorName = "";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(enrollmentSql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    enrollmentId = rs.getLong("EnrollmentId");
                    studentName = rs.getString("StudentName");
                    courseTitle = rs.getString("CourseTitle");
                    instructorName = rs.getString("InstructorName");
                } else {
                    return null; // Not enrolled
                }
            }
        }

        // Issue new certificate in Certificates table
        int currentYear = LocalDateTime.now().getYear();
        String code = "LN-" + currentYear + "-CERT-" + String.format("%04d", courseId) + String.format("%04d", studentId);
        String verificationUrl = "/student/certificate?code=" + code;

        String insertSql = "INSERT INTO dbo.Certificates (EnrollmentId, CertificateCode, Status, IssuedAt, VerificationUrl) "
                + "VALUES (?, ?, 'VALID', SYSUTCDATETIME(), ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, enrollmentId);
            ps.setString(2, code);
            ps.setString(3, verificationUrl);
            ps.executeUpdate();

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                long certId = generatedKeys.next() ? generatedKeys.getLong(1) : 0;
                return new Certificate(
                        certId,
                        enrollmentId,
                        code,
                        studentName,
                        courseTitle,
                        instructorName,
                        "VALID",
                        LocalDateTime.now(),
                        verificationUrl
                );
            }
        } catch (SQLException ex) {
            // If duplicate key, fetch existing
            return getCertificateByCode(code);
        }
    }

    /**
     * Looks up a Certificate by its unique CertificateCode for public verification.
     */
    public Certificate getCertificateByCode(String code) throws SQLException {
        if (code == null || code.isBlank()) return null;

        String sql = "SELECT c.CertificateId, c.EnrollmentId, c.CertificateCode, c.Status, c.IssuedAt, c.VerificationUrl, "
                + "u.FullName AS StudentName, co.Title AS CourseTitle, inst.FullName AS InstructorName "
                + "FROM dbo.Certificates c "
                + "JOIN dbo.Enrollments e ON e.EnrollmentId = c.EnrollmentId "
                + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                + "JOIN dbo.Courses co ON co.CourseId = e.CourseId "
                + "JOIN dbo.Users inst ON inst.UserId = co.InstructorId "
                + "WHERE c.CertificateCode = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCertificate(rs);
                }
            }
        }
        return null;
    }

    private Certificate mapCertificate(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("IssuedAt");
        LocalDateTime issuedAt = ts != null ? ts.toLocalDateTime() : LocalDateTime.now();

        return new Certificate(
                rs.getLong("CertificateId"),
                rs.getLong("EnrollmentId"),
                rs.getString("CertificateCode"),
                rs.getString("StudentName"),
                rs.getString("CourseTitle"),
                rs.getString("InstructorName"),
                rs.getString("Status"),
                issuedAt,
                rs.getString("VerificationUrl")
        );
    }
}
