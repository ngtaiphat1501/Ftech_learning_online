package dao;

import config.DBContext;
import model.Certificate;

import java.sql.*;
import java.time.LocalDateTime;

public class CertificateDAO {

    /**
     * Finds or auto-issues a Certificate for a student in a specific course ONLY IF the course is completed.
     */
    public Certificate getOrCreateCertificate(long studentId, long courseId) throws SQLException {
        // 1. Verify if the student is enrolled and has COMPLETED the course
        String checkCompletionSql = "SELECT e.EnrollmentId, e.CompletedAt, u.FullName AS StudentName, "
                + "co.Title AS CourseTitle, inst.FullName AS InstructorName, "
                + "ISNULL(p.IsEligibleForCompletion, 0) AS IsEligible "
                + "FROM dbo.Enrollments e "
                + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                + "JOIN dbo.Courses co ON co.CourseId = e.CourseId "
                + "JOIN dbo.Users inst ON inst.UserId = co.InstructorId "
                + "LEFT JOIN dbo.vEnrollmentProgress p ON p.EnrollmentId = e.EnrollmentId "
                + "WHERE e.StudentId = ? AND e.CourseId = ? AND e.AccessStatus = 'ACTIVE'";

        long enrollmentId = 0;
        String studentName = "";
        String courseTitle = "";
        String instructorName = "";
        boolean isCompleted = false;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkCompletionSql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    enrollmentId = rs.getLong("EnrollmentId");
                    studentName = rs.getString("StudentName");
                    courseTitle = rs.getString("CourseTitle");
                    instructorName = rs.getString("InstructorName");
                    boolean completedAtNotNull = rs.getTimestamp("CompletedAt") != null;
                    boolean isEligible = rs.getBoolean("IsEligible");
                    isCompleted = completedAtNotNull || isEligible;
                } else {
                    return null; // Not enrolled or not active
                }
            }
        }

        // If the course is not completed, no certificate is granted
        if (!isCompleted) {
            return null;
        }

        // If eligible but CompletedAt is null, mark CompletedAt now
        String updateCompletedSql = "UPDATE dbo.Enrollments SET CompletedAt = SYSUTCDATETIME() "
                + "WHERE EnrollmentId = ? AND CompletedAt IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateCompletedSql)) {
            ps.setLong(1, enrollmentId);
            ps.executeUpdate();
        }

        // 2. Check if a certificate already exists for this enrollment
        String findExistingSql = "SELECT c.CertificateId, c.EnrollmentId, c.CertificateCode, c.Status, c.IssuedAt, c.VerificationUrl, "
                + "u.FullName AS StudentName, co.Title AS CourseTitle, inst.FullName AS InstructorName "
                + "FROM dbo.Certificates c "
                + "JOIN dbo.Enrollments e ON e.EnrollmentId = c.EnrollmentId "
                + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                + "JOIN dbo.Courses co ON co.CourseId = e.CourseId "
                + "JOIN dbo.Users inst ON inst.UserId = co.InstructorId "
                + "WHERE c.EnrollmentId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(findExistingSql)) {
            ps.setLong(1, enrollmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCertificate(rs);
                }
            }
        }

        // 3. Issue new certificate in Certificates table
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
