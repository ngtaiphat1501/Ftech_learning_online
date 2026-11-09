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
     * Gets user balance directly from database using provided connection.
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
     * Gets user balance directly from database (auto-managed connection).
     */
    public BigDecimal getUserBalance(long userId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return getUserBalance(conn, userId);
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
                    String rc = rs.getString("RoleCode");
                    if (rc != null) {
                        roles.add(rc.trim());
                    }
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

    public List<User> getAllUsersForAdmin(String search, String roleFilter, String statusFilter) throws SQLException {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT u.UserId, u.Email, u.PasswordHash, u.FullName, u.Headline, u.Bio, u.AvatarUrl, u.Status, u.BalanceVnd ")
           .append("FROM dbo.Users u ");

        boolean hasRole = roleFilter != null && !roleFilter.isBlank() && !"ALL".equalsIgnoreCase(roleFilter);
        if (hasRole) {
            sql.append("INNER JOIN dbo.UserRoles ur ON u.UserId = ur.UserId AND ur.RoleCode = ? ");
        }

        List<Object> params = new ArrayList<>();
        if (hasRole) {
            params.add(roleFilter.trim().toUpperCase());
        }

        List<String> conditions = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            conditions.add("(u.Email LIKE ? OR u.FullName LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }
        if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
            conditions.add("u.Status = ?");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY u.UserId ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User user = mapUser(rs);
                    user.setRoles(getRolesByUserId(conn, user.getUserId()));
                    list.add(user);
                }
            }
        }
        return list;
    }

    public boolean updateUserRoles(long userId, List<String> newRoles) throws SQLException {
        Connection conn = null;
        try {
            conn = DBContext.beginTransaction();

            // 1. Remove old roles
            String deleteSql = "DELETE FROM dbo.UserRoles WHERE UserId = ?";
            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setLong(1, userId);
                psDel.executeUpdate();
            }

            // 2. Insert new roles
            if (newRoles != null && !newRoles.isEmpty()) {
                String insertSql = "INSERT INTO dbo.UserRoles (UserId, RoleCode) VALUES (?, ?)";
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    for (String role : newRoles) {
                        if (role != null && !role.isBlank()) {
                            psIns.setLong(1, userId);
                            psIns.setString(2, role.trim().toUpperCase());
                            psIns.addBatch();
                        }
                    }
                    psIns.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            if (conn != null) conn.rollback();
            throw ex;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean updateUserStatus(long userId, String status) throws SQLException {
        String sql = "UPDATE dbo.Users SET Status = ? WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateProfile(long userId, String fullName, String headline, String bio, String avatarUrl) throws SQLException {
        String sql = "UPDATE dbo.Users "
                   + "SET FullName = ?, Headline = ?, Bio = ?, AvatarUrl = ?, UpdatedAt = SYSUTCDATETIME() "
                   + "WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName != null ? fullName.trim() : "");
            ps.setString(2, headline != null ? headline.trim() : null);
            ps.setString(3, bio != null ? bio.trim() : null);
            ps.setString(4, avatarUrl != null ? avatarUrl.trim() : null);
            ps.setLong(5, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePassword(long userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE dbo.Users SET PasswordHash = ?, UpdatedAt = SYSUTCDATETIME() WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
}
