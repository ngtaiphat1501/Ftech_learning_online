package dao;

import config.DBContext;
import model.WalletTransaction;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class WalletDAO {

    private static volatile boolean tableReady = false;

    public WalletDAO() {
        ensureTable();
    }

    private void ensureTable() {
        if (tableReady) return;
        synchronized (WalletDAO.class) {
            if (tableReady) return;
            String checkSql = "IF OBJECT_ID(N'dbo.WalletTransactions', N'U') IS NULL "
                            + "BEGIN "
                            + "    CREATE TABLE dbo.WalletTransactions ( "
                            + "        TransactionId BIGINT IDENTITY(1,1) PRIMARY KEY, "
                            + "        UserId BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId), "
                            + "        Type VARCHAR(20) NOT NULL, "
                            + "        Amount DECIMAL(18,2) NOT NULL, "
                            + "        Method VARCHAR(50) NOT NULL, "
                            + "        Status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS', "
                            + "        BankName NVARCHAR(100) NULL, "
                            + "        AccountNumber VARCHAR(50) NULL, "
                            + "        AccountHolder NVARCHAR(100) NULL, "
                            + "        Description NVARCHAR(255) NULL, "
                            + "        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() "
                            + "    ); "
                            + "END";
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {
                st.execute(checkSql);
                tableReady = true;
            } catch (SQLException ex) {
                // Ignore if DB is not ready during tests, will retry on first transaction
            }
        }
    }

    /**
     * Top-up balance for a user and log transaction.
     */
    public boolean topUp(long userId, BigDecimal amount, String method, String description) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }
        ensureTable();

        Connection conn = null;
        try {
            conn = DBContext.beginTransaction();

            // 1. Update user balance
            String updateBal = "UPDATE dbo.Users SET BalanceVnd = BalanceVnd + ? WHERE UserId = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateBal)) {
                ps.setBigDecimal(1, amount);
                ps.setLong(2, userId);
                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Log transaction
            String logSql = "INSERT INTO dbo.WalletTransactions (UserId, Type, Amount, Method, Status, Description, CreatedAt) "
                          + "VALUES (?, 'TOPUP', ?, ?, 'SUCCESS', ?, SYSUTCDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setLong(1, userId);
                ps.setBigDecimal(2, amount);
                ps.setString(3, method != null ? method : "VIETQR");
                ps.setString(4, description != null ? description : "Nạp tiền vào tài khoản");
                ps.executeUpdate();
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

    /**
     * Withdraw balance from a user wallet and log transaction.
     */
    public boolean withdraw(long userId, BigDecimal amount, String method,
                            String bankName, String accountNo, String accountHolder,
                            String description) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }
        ensureTable();

        Connection conn = null;
        try {
            conn = DBContext.beginTransaction();

            // 1. Deduct user balance (atomic check: BalanceVnd >= amount)
            String deductSql = "UPDATE dbo.Users SET BalanceVnd = BalanceVnd - ? WHERE UserId = ? AND BalanceVnd >= ?";
            try (PreparedStatement ps = conn.prepareStatement(deductSql)) {
                ps.setBigDecimal(1, amount);
                ps.setLong(2, userId);
                ps.setBigDecimal(3, amount);
                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    return false; // Insufficient balance
                }
            }

            // 2. Log withdrawal transaction
            String logSql = "INSERT INTO dbo.WalletTransactions (UserId, Type, Amount, Method, Status, BankName, AccountNumber, AccountHolder, Description, CreatedAt) "
                          + "VALUES (?, 'WITHDRAW', ?, ?, 'SUCCESS', ?, ?, ?, ?, SYSUTCDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setLong(1, userId);
                ps.setBigDecimal(2, amount);
                ps.setString(3, method != null ? method : "BANK");
                ps.setString(4, bankName);
                ps.setString(5, accountNo);
                ps.setString(6, accountHolder);
                ps.setString(7, description != null ? description : "Rút tiền về tài khoản ngân hàng/MoMo");
                ps.executeUpdate();
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

    /**
     * Simply logs a wallet transaction (used by checkout topup_and_pay).
     */
    public boolean logTransaction(long userId, String type, BigDecimal amount, String method, String status, String description) {
        ensureTable();
        String logSql = "INSERT INTO dbo.WalletTransactions (UserId, Type, Amount, Method, Status, Description, CreatedAt) "
                      + "VALUES (?, ?, ?, ?, ?, ?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(logSql)) {
            ps.setLong(1, userId);
            ps.setString(2, type != null ? type : "TOPUP");
            ps.setBigDecimal(3, amount != null ? amount : BigDecimal.ZERO);
            ps.setString(4, method != null ? method : "VIETQR");
            ps.setString(5, status != null ? status : "SUCCESS");
            ps.setString(6, description != null ? description : "Giao dịch ví");
            return ps.executeUpdate() > 0;
        } catch (SQLException ignored) {
            return false;
        }
    }

    /**
     * Retrieve recent transaction history for a user.
     */
    public List<WalletTransaction> getTransactionsByUserId(long userId, int limit) throws SQLException {
        ensureTable();
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT TOP (?) TransactionId, UserId, Type, Amount, Method, Status, BankName, AccountNumber, AccountHolder, Description, CreatedAt "
                   + "FROM dbo.WalletTransactions "
                   + "WHERE UserId = ? "
                   + "ORDER BY CreatedAt DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 20);
            ps.setLong(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WalletTransaction tx = new WalletTransaction();
                    tx.setTransactionId(rs.getLong("TransactionId"));
                    tx.setUserId(rs.getLong("UserId"));
                    tx.setType(rs.getString("Type"));
                    tx.setAmount(rs.getBigDecimal("Amount"));
                    tx.setMethod(rs.getString("Method"));
                    tx.setStatus(rs.getString("Status"));
                    tx.setBankName(rs.getString("BankName"));
                    tx.setAccountNumber(rs.getString("AccountNumber"));
                    tx.setAccountHolder(rs.getString("AccountHolder"));
                    tx.setDescription(rs.getString("Description"));
                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        tx.setCreatedAt(ts.toLocalDateTime());
                    }
                    list.add(tx);
                }
            }
        } catch (SQLException ex) {
            // If table does not exist yet, return empty list safely
            return list;
        }
        return list;
    }
}
