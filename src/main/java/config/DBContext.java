/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package config;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.regex.Pattern;
/**
 *
 * @author ACER
 */
public class DBContext {
        private static final String DEFAULT_URL =
            "jdbc:sqlserver://localhost:1433;databaseName=LearnoraDemoDB;encrypt=true;trustServerCertificate=true";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "sa12345";

    private static final String DB_URL;
    private static final String DB_USER;
    private static final String DB_PASSWORD;
    private static volatile boolean schemaChecked = false;
    private static final Pattern GO_BATCH_SPLITTER = Pattern.compile("^\\s*GO\\s*$", Pattern.MULTILINE | Pattern.CASE_INSENSITIVE);

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException ex) {
            throw new ExceptionInInitializerError("Microsoft SQL Server JDBC Driver not found: " + ex.getMessage());
        }

        Properties props = new Properties();
        try (InputStream in = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (IOException ignored) {
        }

        DB_URL = resolveSetting("LEARNORA_DB_URL", props.getProperty("db.url"), DEFAULT_URL);
        DB_USER = resolveSetting("LEARNORA_DB_USER", props.getProperty("db.user"), DEFAULT_USER);
        DB_PASSWORD = resolveSetting("LEARNORA_DB_PASSWORD", props.getProperty("db.password"), DEFAULT_PASSWORD);
    }

    private DBContext() {
    }

    private static String resolveSetting(String envKey, String propValue, String defaultValue) {
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.isBlank()) {
            return envVal.trim();
        }
        String sysProp = System.getProperty(envKey);
        if (sysProp != null && !sysProp.isBlank()) {
            return sysProp.trim();
        }
        if (propValue != null && !propValue.isBlank()) {
            return propValue.trim();
        }
        return defaultValue;
    }

    public static Connection getConnection() throws SQLException {
        if (!schemaChecked) {
            synchronized (DBContext.class) {
                if (!schemaChecked) {
                    ensureDatabaseAndSchemaReady();
                    schemaChecked = true;
                }
            }
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    /**
     * Automatically creates LearnoraDemoDB if missing and upgrades any older 18-table or v1 schema
     * using /sql/init_learnora.sql so the application never fails with "Invalid column/object name".
     */
    private static void ensureDatabaseAndSchemaReady() {
        try {
            Connection conn;
            try {
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            } catch (SQLException ex) {
                // If database LearnoraDemoDB does not exist yet, connect to master and create it
                String masterUrl = DB_URL.replaceAll("(?i)databaseName=[^;]+", "databaseName=master");
                try (Connection masterConn = DriverManager.getConnection(masterUrl, DB_USER, DB_PASSWORD);
                     Statement st = masterConn.createStatement()) {
                    st.execute("IF DB_ID(N'LearnoraDemoDB') IS NULL CREATE DATABASE [LearnoraDemoDB]");
                }
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            }

            try (Connection c = conn) {
                boolean ready = false;
                String checkSql = "SELECT CASE "
                        + "WHEN OBJECT_ID(N'dbo.Carts', N'U') IS NULL THEN 0 "
                        + "WHEN OBJECT_ID(N'dbo.CartItems', N'U') IS NULL THEN 0 "
                        + "WHEN OBJECT_ID(N'dbo.OrderItems', N'U') IS NULL THEN 0 "
                        + "WHEN OBJECT_ID(N'dbo.PaymentAttempts', N'U') IS NULL THEN 0 "
                        + "WHEN OBJECT_ID(N'dbo.Refunds', N'U') IS NULL THEN 0 "
                        + "WHEN COL_LENGTH(N'dbo.Courses', N'PricingType') IS NULL THEN 0 "
                        + "WHEN COL_LENGTH(N'dbo.Courses', N'Slug') IS NULL THEN 0 "
                        + "WHEN COL_LENGTH(N'dbo.Enrollments', N'AccessStatus') IS NULL THEN 0 "
                        + "WHEN OBJECT_ID(N'dbo.vCourseStatistics', N'V') IS NULL THEN 0 "
                        + "ELSE 1 END";
                try (Statement st = c.createStatement();
                     ResultSet rs = st.executeQuery(checkSql)) {
                    if (rs.next()) {
                        ready = (rs.getInt(1) == 1);
                    }
                } catch (SQLException ignored) {
                    ready = false;
                }

                if (!ready) {
                    runClasspathSqlInit(c);
                }
            }
        } catch (Exception ignored) {
            // Do not block class loading if SQL Server is offline during static analysis
        }
    }

    private static void runClasspathSqlInit(Connection conn) throws IOException, SQLException {
        try (InputStream in = DBContext.class.getClassLoader().getResourceAsStream("sql/init_learnora.sql")) {
            if (in == null) {
                return;
            }
            String fullSql = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            // Drop all existing foreign keys first so outdated tables from older versions can be dropped cleanly
            String dropAllFks =
                    "DECLARE @sql NVARCHAR(MAX) = N''; "
                  + "SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id)) "
                  + "             + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' "
                  + "FROM sys.foreign_keys; "
                  + "IF LEN(@sql) > 0 EXEC sp_executesql @sql;";
            try (Statement st = conn.createStatement()) {
                st.execute(dropAllFks);
            }

            String[] batches = GO_BATCH_SPLITTER.split(fullSql);
            for (String batch : batches) {
                String trimmed = batch.trim();
                if (trimmed.isEmpty()) {
                    continue;
                }
                try (Statement st = conn.createStatement()) {
                    st.execute(trimmed);
                }
            }
        }
    }

    public static Connection beginTransaction() throws SQLException {
        Connection conn = getConnection();
        conn.setAutoCommit(false);
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET XACT_ABORT ON");
        } catch (SQLException ex) {
            closeQuietly(conn);
            throw ex;
        }
        return conn;
    }

    public static void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.getAutoCommit()) {
                    conn.rollback();
                }
            } catch (SQLException ignored) {
            }
        }
    }

    public static void closeQuietly(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception ignored) {
            }
        }
    }
}
