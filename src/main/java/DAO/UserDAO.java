package dao;

import config.DBContext;
import model.User;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User findByEmail(String email) throws SQLException {
        if (email == null || email.isBlank()) {
            return null;
        }

        String sqlUser = "SELECT UserId, Email, PasswordHash, FullName, Headline, Bio, AvatarUrl, Status, BalanceVnd "
                       + "FROM dbo.Users "
                       + "WHERE NormalizedEmail = LOWER(LTRIM(RTRIM(?)))";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUser)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    user.setRoles(getRolesByUserId(conn, user.getUserId()));
                    return user;
                }
            }
        }
        return null;
    }

    public User findById(long userId) throws SQLException {
        String sqlUser = "SELECT UserId, Email, PasswordHash, FullName, Headline, Bio, AvatarUrl, Status, BalanceVnd "
                       + "FROM dbo.Users "
                       + "WHERE UserId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUser)) {

            ps.setLong(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    user.setRoles(getRolesByUserId(conn, user.getUserId()));
                    return user;
                }
            }
        }
        return null;
    }

    public boolean existsByEmail(String email) throws SQLException {
        if (email == null || email.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM dbo.Users WHERE NormalizedEmail = LOWER(LTRIM(RTRIM(?)))";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long registerStudent(User user) throws SQLException {
        String insertUserSql = "INSERT INTO dbo.Users (Email, PasswordHash, FullName, Status, BalanceVnd) "
                             + "VALUES (?, ?, ?, 'ACTIVE', 0)";
        String insertRoleSql = "INSERT INTO dbo.UserRoles (UserId, RoleCode) VALUES (?, 'STUDENT')";

        Connection conn = null;
        try {
            conn = DBContext.beginTransaction();

            long newUserId;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getEmail().trim());
                psUser.setString(2, user.getPasswordHash());
                psUser.setString(3, user.getFullName().trim());
                psUser.executeUpdate();

                try (ResultSet rs = psUser.getGeneratedKeys()) {
                    if (rs.next()) {
                        newUserId = rs.getLong(1);
                    } else {
                        throw new SQLException("Failed to retrieve generated UserId.");
                    }
                }
            }

            try (PreparedStatement psRole = conn.prepareStatement(insertRoleSql)) {
                psRole.setLong(1, newUserId);
                psRole.executeUpdate();
            }

            conn.commit();
            user.setUserId(newUserId);
            user.setBalanceVnd(BigDecimal.ZERO);
            user.addRole("STUDENT");
            return newUserId;

        } catch (SQLException ex) {
            DBContext.rollbackQuietly(conn);
            throw ex;
        } finally {
            DBContext.closeQuietly(conn);
        }
    }

    /**
     * Gets user balance directly from database.
     */
    public BigDecimal getUserBalance(Connection conn, long userId) throws SQLException {
        String sql = "SELECT BalanceVnd FROM dbo.Users WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal bal = rs.getBigDecimal("BalanceVnd");
                    return bal != null ? bal : BigDecimal.ZERO;
                }
                return BigDecimal.ZERO;
            }
        }
    }

    /**
     * Deducts user balance within transaction. Returns true if successful, false if insufficient.
     */
    public boolean deductUserBalance(Connection conn, long userId, BigDecimal amount) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return true;
        }
        String sql = "UPDATE dbo.Users SET BalanceVnd = BalanceVnd - ? "
                   + "WHERE UserId = ? AND BalanceVnd >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setLong(2, userId);
            ps.setBigDecimal(3, amount);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    /**
     * Tops up user balance within transaction.
     */
    public boolean topUpUserBalance(Connection conn, long userId, BigDecimal amount) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Users SET BalanceVnd = BalanceVnd + ? WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setLong(2, userId);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    private List<String> getRolesByUserId(Connection conn, long userId) throws SQLException {
        List<String> roles = new ArrayList<>();
        String sql = "SELECT RoleCode FROM dbo.UserRoles WHERE UserId = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(rs.getString("RoleCode"));
                }
            }
        }
        return roles;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getLong("UserId"));
        user.setEmail(rs.getString("Email"));
        user.setPasswordHash(rs.getString("PasswordHash"));
        user.setFullName(rs.getString("FullName"));
        user.setHeadline(rs.getString("Headline"));
        user.setBio(rs.getString("Bio"));
        user.setAvatarUrl(rs.getString("AvatarUrl"));
        user.setStatus(rs.getString("Status"));
        BigDecimal bal = rs.getBigDecimal("BalanceVnd");
        user.setBalanceVnd(bal != null ? bal : BigDecimal.ZERO);
        return user;
    }
}
