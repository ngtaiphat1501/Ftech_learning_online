package dao;

import config.DBContext;
import model.Certificate;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.HashMap;
import java.util.Map;

public class CertificateDAO {

    public Certificate issueCertificateIfEligible(long enrollmentId, long courseId, String contextPath) throws SQLException {
        String checkSql = "SELECT e.EnrollmentId, e.CompletedAt, e.CourseId FROM Enrollments e "
                + "WHERE e.EnrollmentId = ? AND e.CompletedAt IS NOT NULL";

        try (Connection conn = DBContext.getConnection()) {
            boolean isCompleted = false;
            long actualCourseId = courseId;

            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, enrollmentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        isCompleted = true;
                        actualCourseId = rs.getLong("CourseId");
                    }
                }
            }

            if (!isCompleted) {
                return null;
            }

            // Check if certificate already exists
            Certificate existing = getByEnrollmentId(conn, enrollmentId);
            if (existing != null) {
                return existing;
            }

            // Generate unique certificate code
            int currentYear = Year.now().getValue();
            String code = String.format("LN-%d-C%d-%05d", currentYear, actualCourseId, enrollmentId);
            String verifyUrl = "/certificate?code=" + code;

            String insertSql = "INSERT INTO Certificates (EnrollmentId, CertificateCode, Status, IssuedAt, VerificationUrl) "
                    + "VALUES (?, ?, 'VALID', SYSUTCDATETIME(), ?)";

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, enrollmentId);
                ps.setString(2, code);
                ps.setString(3, verifyUrl);
                ps.executeUpdate();
            }

            return getByEnrollmentId(conn, enrollmentId);
        }
    }

    private Certificate getByEnrollmentId(Connection conn, long enrollmentId) throws SQLException {
        String sql = "SELECT cert.CertificateId, cert.EnrollmentId, cert.CertificateCode, cert.Status, "
                + "cert.IssuedAt, cert.VerificationUrl, e.StudentId, u.FullName AS StudentName, u.Email AS StudentEmail, "
                + "c.CourseId, c.Title AS CourseTitle, inst.FullName AS InstructorName, e.CompletedAt "
                + "FROM Certificates cert "
                + "JOIN Enrollments e ON cert.EnrollmentId = e.EnrollmentId "
                + "JOIN Users u ON e.StudentId = u.UserId "
                + "JOIN Courses c ON e.CourseId = c.CourseId "
                + "JOIN Users inst ON c.InstructorId = inst.UserId "
                + "WHERE cert.EnrollmentId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, enrollmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCertificate(rs);
                }
            }
        }
        return null;
    }

    public Certificate getCertificateByCode(String code) throws SQLException {
        if (code == null || code.isBlank()) {
            return null;
        }

        String sql = "SELECT cert.CertificateId, cert.EnrollmentId, cert.CertificateCode, cert.Status, "
                + "cert.IssuedAt, cert.VerificationUrl, e.StudentId, u.FullName AS StudentName, u.Email AS StudentEmail, "
                + "c.CourseId, c.Title AS CourseTitle, inst.FullName AS InstructorName, e.CompletedAt "
                + "FROM Certificates cert "
                + "JOIN Enrollments e ON cert.EnrollmentId = e.EnrollmentId "
                + "JOIN Users u ON e.StudentId = u.UserId "
                + "JOIN Courses c ON e.CourseId = c.CourseId "
                + "JOIN Users inst ON c.InstructorId = inst.UserId "
                + "WHERE cert.CertificateCode = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCertificate(rs);
                }
            }
        }
        return null;
    }

    public Map<Long, String> getCertificateCodesForStudent(long studentId) throws SQLException {
        Map<Long, String> map = new HashMap<>();
        String sql = "SELECT e.CourseId, cert.CertificateCode "
                + "FROM Certificates cert "
                + "JOIN Enrollments e ON cert.EnrollmentId = e.EnrollmentId "
                + "WHERE e.StudentId = ? AND cert.Status = 'VALID'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getLong("CourseId"), rs.getString("CertificateCode"));
                }
            }
        }
        return map;
    }

    private Certificate mapResultSetToCertificate(ResultSet rs) throws SQLException {
        Certificate cert = new Certificate();
        cert.setCertificateId(rs.getLong("CertificateId"));
        cert.setEnrollmentId(rs.getLong("EnrollmentId"));
        cert.setCertificateCode(rs.getString("CertificateCode"));
        cert.setStatus(rs.getString("Status"));
        cert.setIssuedAt(rs.getTimestamp("IssuedAt"));
        cert.setVerificationUrl(rs.getString("VerificationUrl"));
        cert.setStudentId(rs.getLong("StudentId"));
        cert.setStudentName(rs.getString("StudentName"));
        cert.setStudentEmail(rs.getString("StudentEmail"));
        cert.setCourseId(rs.getLong("CourseId"));
        cert.setCourseTitle(rs.getString("CourseTitle"));
        cert.setInstructorName(rs.getString("InstructorName"));
        cert.setCompletedAt(rs.getTimestamp("CompletedAt"));
        return cert;
    }
}
