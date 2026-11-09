package dao;

import config.DBContext;
import model.*;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public Coupon findCouponByCode(Connection conn, String code) throws SQLException {
        if (code == null || code.isBlank()) {
            return null;
        }
        String sql = "SELECT CouponId, Code, Description, DiscountPercent, MaxDiscountVnd, "
                   + "MinOrderVnd, UsageLimit, UsedCount, IsActive, ExpiresAt, CreatedAt "
                   + "FROM dbo.Coupons "
                   + "WHERE Code = ? AND IsActive = 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Coupon coupon = new Coupon();
                    coupon.setCouponId(rs.getLong("CouponId"));
                    coupon.setCode(rs.getString("Code"));
                    coupon.setDescription(rs.getString("Description"));
                    coupon.setDiscountPercent(rs.getInt("DiscountPercent"));
                    coupon.setMaxDiscountVnd(rs.getBigDecimal("MaxDiscountVnd"));
                    coupon.setMinOrderVnd(rs.getBigDecimal("MinOrderVnd"));
                    coupon.setUsageLimit(rs.getInt("UsageLimit"));
                    coupon.setUsedCount(rs.getInt("UsedCount"));
                    coupon.setActive(rs.getBoolean("IsActive"));
                    Timestamp exp = rs.getTimestamp("ExpiresAt");
                    if (exp != null) {
                        coupon.setExpiresAt(exp.toLocalDateTime());
                    }
                    return coupon;
                }
            }
        }
        return null;
    }

    public Order createOrderWithItemsAndAttempt(Connection conn, Order order, List<OrderItem> items, String merchantRef) throws SQLException {
        String insertOrderSql = "INSERT INTO dbo.Orders (OrderCode, StudentId, Status, Currency, "
                              + "SubtotalVnd, DiscountVnd, TotalVnd, CouponCode, PolicyVersion, IdempotencyKey, ExpiresAt) "
                              + "OUTPUT INSERTED.OrderId "
                              + "VALUES (?, ?, 'PENDING_PAYMENT', 'VND', ?, ?, ?, ?, ?, ?, DATEADD(MINUTE, 30, SYSUTCDATETIME()))";

        long orderId;
        try (PreparedStatement ps = conn.prepareStatement(insertOrderSql)) {
            ps.setString(1, order.getOrderCode());
            ps.setLong(2, order.getStudentId());
            ps.setBigDecimal(3, order.getSubtotalVnd());
            ps.setBigDecimal(4, order.getDiscountVnd());
            ps.setBigDecimal(5, order.getTotalVnd());
            if (order.getCouponCode() != null && !order.getCouponCode().isBlank()) {
                ps.setString(6, order.getCouponCode());
            } else {
                ps.setNull(6, Types.VARCHAR);
            }
            ps.setString(7, order.getPolicyVersion() != null ? order.getPolicyVersion() : "v2026.1");
            ps.setString(8, order.getIdempotencyKey());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderId = rs.getLong(1);
                    order.setOrderId(orderId);
                } else {
                    throw new SQLException("Failed to create Order: no generated ID returned.");
                }
            }
        }

        String insertItemSql = "INSERT INTO dbo.OrderItems (OrderId, CourseId, CourseTitleSnapshot, "
                             + "UnitPriceVnd, DiscountVnd, PayableVnd) "
                             + "OUTPUT INSERTED.OrderItemId "
                             + "VALUES (?, ?, ?, ?, ?, ?)";

        for (OrderItem item : items) {
            item.setOrderId(orderId);
            try (PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {
                psItem.setLong(1, orderId);
                psItem.setLong(2, item.getCourseId());
                psItem.setString(3, item.getCourseTitleSnapshot());
                psItem.setBigDecimal(4, item.getUnitPriceVnd());
                psItem.setBigDecimal(5, item.getDiscountVnd());
                psItem.setBigDecimal(6, item.getPayableVnd());
                try (ResultSet rs = psItem.executeQuery()) {
                    if (rs.next()) {
                        item.setOrderItemId(rs.getLong(1));
                    }
                }
            }
        }

        String insertAttemptSql = "INSERT INTO dbo.PaymentAttempts (OrderId, MerchantReference, Provider, AmountVnd, Currency, Status) "
                                + "OUTPUT INSERTED.PaymentAttemptId "
                                + "VALUES (?, ?, 'ACCOUNT_BALANCE', ?, 'VND', 'CREATED')";

        try (PreparedStatement psAtt = conn.prepareStatement(insertAttemptSql)) {
            psAtt.setLong(1, orderId);
            psAtt.setString(2, merchantRef);
            psAtt.setBigDecimal(3, order.getTotalVnd());
            psAtt.executeQuery();
        }

        order.setItems(items);
        return order;
    }

    /**
     * Executes the complete checkout payment within transaction:
     * 1. Deducts user balance.
     * 2. Marks Order as PAID and sets PaidAt.
     * 3. Marks PaymentAttempt as SUCCEEDED.
     * 4. Enrolls student into all purchased courses (ACTIVE, ORDER_PURCHASE).
     * 5. Logs EnrollmentAccessEvents (GRANTED).
     * 6. Deletes items from CartItems.
     * 7. Updates Coupon used count if applicable.
     */
    public boolean completeOrderPayment(Connection conn, long orderId, long studentId, BigDecimal totalVnd, String couponCode) throws SQLException {
        // 1. Deduct balance with row check
        String deductSql = "UPDATE dbo.Users SET BalanceVnd = BalanceVnd - ? "
                         + "WHERE UserId = ? AND BalanceVnd >= ?";
        try (PreparedStatement ps = conn.prepareStatement(deductSql)) {
            ps.setBigDecimal(1, totalVnd);
            ps.setLong(2, studentId);
            ps.setBigDecimal(3, totalVnd);
            int rows = ps.executeUpdate();
            if (rows != 1) {
                return false; // Insufficient balance or user not found
            }
        }

        // 2. Mark Order as PAID
        String updateOrderSql = "UPDATE dbo.Orders "
                              + "SET Status = 'PAID', PaidAt = SYSUTCDATETIME() "
                              + "WHERE OrderId = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
            ps.setLong(1, orderId);
            ps.executeUpdate();
        }

        // 3. Mark PaymentAttempt as SUCCEEDED
        String updateAttemptSql = "UPDATE dbo.PaymentAttempts "
                                + "SET Status = 'SUCCEEDED', LastVerifiedAt = SYSUTCDATETIME() "
                                + "WHERE OrderId = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateAttemptSql)) {
            ps.setLong(1, orderId);
            ps.executeUpdate();
        }

        // 4. Retrieve order items to enroll & credit 80% instructor payout
        String selectItemsSql = "SELECT oi.OrderItemId, oi.CourseId, oi.PayableVnd, oi.CourseTitleSnapshot, "
                              + "c.InstructorId, o.OrderCode "
                              + "FROM dbo.OrderItems oi "
                              + "JOIN dbo.Courses c ON c.CourseId = oi.CourseId "
                              + "JOIN dbo.Orders o ON o.OrderId = oi.OrderId "
                              + "WHERE oi.OrderId = ?";
        WalletDAO walletDAO = new WalletDAO();
        class OrderItemPurchaseInfo {
            long orderItemId;
            long courseId;
            BigDecimal payableVnd;
            String courseTitle;
            long instructorId;
            String orderCode;
        }
        List<OrderItemPurchaseInfo> itemInfos = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(selectItemsSql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItemPurchaseInfo info = new OrderItemPurchaseInfo();
                    info.orderItemId = rs.getLong("OrderItemId");
                    info.courseId = rs.getLong("CourseId");
                    info.payableVnd = rs.getBigDecimal("PayableVnd");
                    info.courseTitle = rs.getString("CourseTitleSnapshot");
                    info.instructorId = rs.getLong("InstructorId");
                    info.orderCode = rs.getString("OrderCode");
                    itemInfos.add(info);
                }
            }
        }

        for (OrderItemPurchaseInfo info : itemInfos) {
            long orderItemId = info.orderItemId;
            long courseId = info.courseId;

            // Upsert Enrollment
            String upsertEnrollmentSql =
                    "IF EXISTS (SELECT 1 FROM dbo.Enrollments WHERE StudentId = ? AND CourseId = ?) "
                  + "BEGIN "
                  + "    UPDATE dbo.Enrollments "
                  + "    SET AccessStatus = 'ACTIVE', SourceType = 'ORDER_PURCHASE', CurrentOrderItemId = ?, EnrolledAt = SYSUTCDATETIME() "
                  + "    WHERE StudentId = ? AND CourseId = ?; "
                  + "END "
                  + "ELSE "
                  + "BEGIN "
                  + "    INSERT INTO dbo.Enrollments (StudentId, CourseId, AccessStatus, SourceType, CurrentOrderItemId) "
                  + "    VALUES (?, ?, 'ACTIVE', 'ORDER_PURCHASE', ?); "
                  + "END";

            try (PreparedStatement psEnroll = conn.prepareStatement(upsertEnrollmentSql)) {
                psEnroll.setLong(1, studentId);
                psEnroll.setLong(2, courseId);
                psEnroll.setLong(3, orderItemId);
                psEnroll.setLong(4, studentId);
                psEnroll.setLong(5, courseId);
                psEnroll.setLong(6, studentId);
                psEnroll.setLong(7, courseId);
                psEnroll.setLong(8, orderItemId);
                psEnroll.executeUpdate();
            }

            // Log EnrollmentAccessEvent
            String logEventSql =
                    "INSERT INTO dbo.EnrollmentAccessEvents (EnrollmentId, SourceOrderItemId, EventType, ActorId, Reason) "
                  + "VALUES ((SELECT EnrollmentId FROM dbo.Enrollments WHERE StudentId = ? AND CourseId = ?), ?, 'GRANTED', ?, N'Kích hoạt khóa học thành công sau khi thanh toán đơn hàng.');";

            try (PreparedStatement psLog = conn.prepareStatement(logEventSql)) {
                psLog.setLong(1, studentId);
                psLog.setLong(2, courseId);
                psLog.setLong(3, orderItemId);
                psLog.setLong(4, studentId);
                psLog.executeUpdate();
            }

            // Delete purchased course from student's CartItems
            String deleteCartItemSql =
                    "DELETE ci FROM dbo.CartItems ci "
                  + "INNER JOIN dbo.Carts c ON ci.CartId = c.CartId "
                  + "WHERE c.StudentId = ? AND ci.CourseId = ?";

            try (PreparedStatement psDel = conn.prepareStatement(deleteCartItemSql)) {
                psDel.setLong(1, studentId);
                psDel.setLong(2, courseId);
                psDel.executeUpdate();
            }

            // Credit 80% revenue share to the course Instructor
            if (info.instructorId > 0 && info.payableVnd != null && info.payableVnd.compareTo(BigDecimal.ZERO) > 0) {
                walletDAO.creditInstructorPayout(conn, info.instructorId, info.payableVnd, info.courseTitle, info.orderCode);
            }
        }

        // 5. Update coupon usage limit if applicable
        if (couponCode != null && !couponCode.isBlank()) {
            String updateCouponSql = "UPDATE dbo.Coupons SET UsedCount = UsedCount + 1 WHERE Code = ?";
            try (PreparedStatement psC = conn.prepareStatement(updateCouponSql)) {
                psC.setString(1, couponCode.trim().toUpperCase());
                psC.executeUpdate();
            }
        }

        return true;
    }

    public Order findOrderByCode(Connection conn, String orderCode, long studentId) throws SQLException {
        String sql = "SELECT OrderId, OrderCode, StudentId, Status, Currency, SubtotalVnd, "
                   + "DiscountVnd, TotalVnd, CouponCode, PolicyVersion, IdempotencyKey, "
                   + "CreatedAt, ExpiresAt, PaidAt "
                   + "FROM dbo.Orders "
                   + "WHERE OrderCode = ? AND StudentId = ?";

        Order order = null;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ps.setLong(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = new Order();
                    order.setOrderId(rs.getLong("OrderId"));
                    order.setOrderCode(rs.getString("OrderCode"));
                    order.setStudentId(rs.getLong("StudentId"));
                    order.setStatus(rs.getString("Status"));
                    order.setCurrency(rs.getString("Currency"));
                    order.setSubtotalVnd(rs.getBigDecimal("SubtotalVnd"));
                    order.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                    order.setTotalVnd(rs.getBigDecimal("TotalVnd"));
                    order.setCouponCode(rs.getString("CouponCode"));
                    order.setPolicyVersion(rs.getString("PolicyVersion"));
                    order.setIdempotencyKey(rs.getString("IdempotencyKey"));
                    Timestamp cAt = rs.getTimestamp("CreatedAt");
                    if (cAt != null) order.setCreatedAt(cAt.toLocalDateTime());
                    Timestamp exp = rs.getTimestamp("ExpiresAt");
                    if (exp != null) order.setExpiresAt(exp.toLocalDateTime());
                    Timestamp pAt = rs.getTimestamp("PaidAt");
                    if (pAt != null) order.setPaidAt(pAt.toLocalDateTime());
                }
            }
        }

        if (order != null) {
            String itemSql = "SELECT oi.OrderItemId, oi.OrderId, oi.CourseId, oi.CourseTitleSnapshot, "
                           + "oi.UnitPriceVnd, oi.DiscountVnd, oi.PayableVnd, "
                           + "c.ThumbnailUrl, u.FullName AS InstructorName "
                           + "FROM dbo.OrderItems oi "
                           + "INNER JOIN dbo.Courses c ON oi.CourseId = c.CourseId "
                           + "INNER JOIN dbo.Users u ON c.InstructorId = u.UserId "
                           + "WHERE oi.OrderId = ?";
            try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                psItem.setLong(1, order.getOrderId());
                try (ResultSet rs = psItem.executeQuery()) {
                    while (rs.next()) {
                        OrderItem item = new OrderItem();
                        item.setOrderItemId(rs.getLong("OrderItemId"));
                        item.setOrderId(rs.getLong("OrderId"));
                        item.setCourseId(rs.getLong("CourseId"));
                        item.setCourseTitleSnapshot(rs.getString("CourseTitleSnapshot"));
                        item.setUnitPriceVnd(rs.getBigDecimal("UnitPriceVnd"));
                        item.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                        item.setPayableVnd(rs.getBigDecimal("PayableVnd"));
                        item.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                        item.setInstructorName(rs.getString("InstructorName"));
                        order.addItem(item);
                    }
                }
            }
        }
        return order;
    }

    public List<Order> getOrdersByStudentId(Connection conn, long studentId, String statusFilter) throws SQLException {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.OrderId, o.OrderCode, o.StudentId, o.Status, o.Currency, o.SubtotalVnd, ")
           .append("o.DiscountVnd, o.TotalVnd, o.CouponCode, o.PolicyVersion, o.IdempotencyKey, ")
           .append("o.CreatedAt, o.ExpiresAt, o.PaidAt, ")
           .append("pa.Provider, pa.MerchantReference ")
           .append("FROM dbo.Orders o ")
           .append("LEFT JOIN (")
           .append("   SELECT OrderId, Provider, MerchantReference, ROW_NUMBER() OVER(PARTITION BY OrderId ORDER BY PaymentAttemptId DESC) as rn ")
           .append("   FROM dbo.PaymentAttempts")
           .append(") pa ON o.OrderId = pa.OrderId AND pa.rn = 1 ")
           .append("WHERE o.StudentId = ? ");

        boolean hasFilter = statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter);
        if (hasFilter) {
            sql.append("AND o.Status = ? ");
        }
        sql.append("ORDER BY o.CreatedAt DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, studentId);
            if (hasFilter) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getLong("OrderId"));
                    order.setOrderCode(rs.getString("OrderCode"));
                    order.setStudentId(rs.getLong("StudentId"));
                    order.setStatus(rs.getString("Status"));
                    order.setCurrency(rs.getString("Currency"));
                    order.setSubtotalVnd(rs.getBigDecimal("SubtotalVnd"));
                    order.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                    order.setTotalVnd(rs.getBigDecimal("TotalVnd"));
                    order.setCouponCode(rs.getString("CouponCode"));
                    order.setPolicyVersion(rs.getString("PolicyVersion"));
                    order.setIdempotencyKey(rs.getString("IdempotencyKey"));
                    order.setPaymentProvider(rs.getString("Provider"));
                    order.setPaymentMerchantRef(rs.getString("MerchantReference"));

                    Timestamp cAt = rs.getTimestamp("CreatedAt");
                    if (cAt != null) order.setCreatedAt(cAt.toLocalDateTime());
                    Timestamp exp = rs.getTimestamp("ExpiresAt");
                    if (exp != null) order.setExpiresAt(exp.toLocalDateTime());
                    Timestamp pAt = rs.getTimestamp("PaidAt");
                    if (pAt != null) order.setPaidAt(pAt.toLocalDateTime());

                    orders.add(order);
                }
            }
        }

        // Populate items for each order
        if (!orders.isEmpty()) {
            String itemSql = "SELECT oi.OrderItemId, oi.OrderId, oi.CourseId, oi.CourseTitleSnapshot, "
                           + "oi.UnitPriceVnd, oi.DiscountVnd, oi.PayableVnd, "
                           + "c.ThumbnailUrl, u.FullName AS InstructorName "
                           + "FROM dbo.OrderItems oi "
                           + "INNER JOIN dbo.Courses c ON oi.CourseId = c.CourseId "
                           + "INNER JOIN dbo.Users u ON c.InstructorId = u.UserId "
                           + "WHERE oi.OrderId = ? "
                           + "ORDER BY oi.OrderItemId ASC";

            try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                for (Order order : orders) {
                    psItem.setLong(1, order.getOrderId());
                    try (ResultSet rs = psItem.executeQuery()) {
                        while (rs.next()) {
                            OrderItem item = new OrderItem();
                            item.setOrderItemId(rs.getLong("OrderItemId"));
                            item.setOrderId(rs.getLong("OrderId"));
                            item.setCourseId(rs.getLong("CourseId"));
                            item.setCourseTitleSnapshot(rs.getString("CourseTitleSnapshot"));
                            item.setUnitPriceVnd(rs.getBigDecimal("UnitPriceVnd"));
                            item.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                            item.setPayableVnd(rs.getBigDecimal("PayableVnd"));
                            item.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                            item.setInstructorName(rs.getString("InstructorName"));
                            order.addItem(item);
                        }
                    }
                }
            }
        }

        return orders;
    }

    public Order getOrderDetail(Connection conn, long orderId, long studentId) throws SQLException {
        String sql = "SELECT o.OrderId, o.OrderCode, o.StudentId, o.Status, o.Currency, o.SubtotalVnd, "
                   + "o.DiscountVnd, o.TotalVnd, o.CouponCode, o.PolicyVersion, o.IdempotencyKey, "
                   + "o.CreatedAt, o.ExpiresAt, o.PaidAt, "
                   + "pa.Provider, pa.MerchantReference "
                   + "FROM dbo.Orders o "
                   + "LEFT JOIN ("
                   + "   SELECT OrderId, Provider, MerchantReference, ROW_NUMBER() OVER(PARTITION BY OrderId ORDER BY PaymentAttemptId DESC) as rn "
                   + "   FROM dbo.PaymentAttempts"
                   + ") pa ON o.OrderId = pa.OrderId AND pa.rn = 1 "
                   + "WHERE o.OrderId = ? AND o.StudentId = ?";

        Order order = null;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            ps.setLong(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = new Order();
                    order.setOrderId(rs.getLong("OrderId"));
                    order.setOrderCode(rs.getString("OrderCode"));
                    order.setStudentId(rs.getLong("StudentId"));
                    order.setStatus(rs.getString("Status"));
                    order.setCurrency(rs.getString("Currency"));
                    order.setSubtotalVnd(rs.getBigDecimal("SubtotalVnd"));
                    order.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                    order.setTotalVnd(rs.getBigDecimal("TotalVnd"));
                    order.setCouponCode(rs.getString("CouponCode"));
                    order.setPolicyVersion(rs.getString("PolicyVersion"));
                    order.setIdempotencyKey(rs.getString("IdempotencyKey"));
                    order.setPaymentProvider(rs.getString("Provider"));
                    order.setPaymentMerchantRef(rs.getString("MerchantReference"));

                    Timestamp cAt = rs.getTimestamp("CreatedAt");
                    if (cAt != null) order.setCreatedAt(cAt.toLocalDateTime());
                    Timestamp exp = rs.getTimestamp("ExpiresAt");
                    if (exp != null) order.setExpiresAt(exp.toLocalDateTime());
                    Timestamp pAt = rs.getTimestamp("PaidAt");
                    if (pAt != null) order.setPaidAt(pAt.toLocalDateTime());
                }
            }
        }

        if (order != null) {
            String itemSql = "SELECT oi.OrderItemId, oi.OrderId, oi.CourseId, oi.CourseTitleSnapshot, "
                           + "oi.UnitPriceVnd, oi.DiscountVnd, oi.PayableVnd, "
                           + "c.ThumbnailUrl, u.FullName AS InstructorName "
                           + "FROM dbo.OrderItems oi "
                           + "INNER JOIN dbo.Courses c ON oi.CourseId = c.CourseId "
                           + "INNER JOIN dbo.Users u ON c.InstructorId = u.UserId "
                           + "WHERE oi.OrderId = ? "
                           + "ORDER BY oi.OrderItemId ASC";
            try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                psItem.setLong(1, order.getOrderId());
                try (ResultSet rs = psItem.executeQuery()) {
                    while (rs.next()) {
                        OrderItem item = new OrderItem();
                        item.setOrderItemId(rs.getLong("OrderItemId"));
                        item.setOrderId(rs.getLong("OrderId"));
                        item.setCourseId(rs.getLong("CourseId"));
                        item.setCourseTitleSnapshot(rs.getString("CourseTitleSnapshot"));
                        item.setUnitPriceVnd(rs.getBigDecimal("UnitPriceVnd"));
                        item.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                        item.setPayableVnd(rs.getBigDecimal("PayableVnd"));
                        item.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                        item.setInstructorName(rs.getString("InstructorName"));
                        order.addItem(item);
                    }
                }
            }
        }
        return order;
    }

    public boolean cancelOrder(Connection conn, long orderId, long studentId) throws SQLException {
        String sql = "UPDATE dbo.Orders "
                   + "SET Status = 'CANCELLED' "
                   + "WHERE OrderId = ? AND StudentId = ? AND Status = 'PENDING_PAYMENT'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            ps.setLong(2, studentId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Order> getAllOrdersForAdmin(Connection conn, String statusFilter, String searchKeyword) throws SQLException {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.OrderId, o.OrderCode, o.StudentId, o.Status, o.Currency, o.SubtotalVnd, ")
           .append("o.DiscountVnd, o.TotalVnd, o.CouponCode, o.PolicyVersion, o.IdempotencyKey, ")
           .append("o.CreatedAt, o.ExpiresAt, o.PaidAt, ")
           .append("u.FullName AS StudentName, u.Email AS StudentEmail, ")
           .append("pa.Provider, pa.MerchantReference ")
           .append("FROM dbo.Orders o ")
           .append("INNER JOIN dbo.Users u ON o.StudentId = u.UserId ")
           .append("LEFT JOIN (")
           .append("   SELECT OrderId, Provider, MerchantReference, ROW_NUMBER() OVER(PARTITION BY OrderId ORDER BY PaymentAttemptId DESC) as rn ")
           .append("   FROM dbo.PaymentAttempts")
           .append(") pa ON o.OrderId = pa.OrderId AND pa.rn = 1 ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
            conditions.add("o.Status = ?");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (searchKeyword != null && !searchKeyword.isBlank()) {
            conditions.add("(o.OrderCode LIKE ? OR u.FullName LIKE ? OR u.Email LIKE ?)");
            String kw = "%" + searchKeyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY o.CreatedAt DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getLong("OrderId"));
                    order.setOrderCode(rs.getString("OrderCode"));
                    order.setStudentId(rs.getLong("StudentId"));
                    order.setStudentName(rs.getString("StudentName"));
                    order.setStudentEmail(rs.getString("StudentEmail"));
                    order.setStatus(rs.getString("Status"));
                    order.setCurrency(rs.getString("Currency"));
                    order.setSubtotalVnd(rs.getBigDecimal("SubtotalVnd"));
                    order.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                    order.setTotalVnd(rs.getBigDecimal("TotalVnd"));
                    order.setCouponCode(rs.getString("CouponCode"));
                    order.setPolicyVersion(rs.getString("PolicyVersion"));
                    order.setIdempotencyKey(rs.getString("IdempotencyKey"));
                    order.setPaymentProvider(rs.getString("Provider"));
                    order.setPaymentMerchantRef(rs.getString("MerchantReference"));

                    Timestamp cAt = rs.getTimestamp("CreatedAt");
                    if (cAt != null) order.setCreatedAt(cAt.toLocalDateTime());
                    Timestamp exp = rs.getTimestamp("ExpiresAt");
                    if (exp != null) order.setExpiresAt(exp.toLocalDateTime());
                    Timestamp pAt = rs.getTimestamp("PaidAt");
                    if (pAt != null) order.setPaidAt(pAt.toLocalDateTime());

                    orders.add(order);
                }
            }
        }

        // Populate items
        if (!orders.isEmpty()) {
            String itemSql = "SELECT oi.OrderItemId, oi.OrderId, oi.CourseId, oi.CourseTitleSnapshot, "
                           + "oi.UnitPriceVnd, oi.DiscountVnd, oi.PayableVnd, "
                           + "c.ThumbnailUrl, u.FullName AS InstructorName "
                           + "FROM dbo.OrderItems oi "
                           + "INNER JOIN dbo.Courses c ON oi.CourseId = c.CourseId "
                           + "INNER JOIN dbo.Users u ON c.InstructorId = u.UserId "
                           + "WHERE oi.OrderId = ? "
                           + "ORDER BY oi.OrderItemId ASC";

            try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                for (Order order : orders) {
                    psItem.setLong(1, order.getOrderId());
                    try (ResultSet rs = psItem.executeQuery()) {
                        while (rs.next()) {
                            OrderItem item = new OrderItem();
                            item.setOrderItemId(rs.getLong("OrderItemId"));
                            item.setOrderId(rs.getLong("OrderId"));
                            item.setCourseId(rs.getLong("CourseId"));
                            item.setCourseTitleSnapshot(rs.getString("CourseTitleSnapshot"));
                            item.setUnitPriceVnd(rs.getBigDecimal("UnitPriceVnd"));
                            item.setDiscountVnd(rs.getBigDecimal("DiscountVnd"));
                            item.setPayableVnd(rs.getBigDecimal("PayableVnd"));
                            item.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                            item.setInstructorName(rs.getString("InstructorName"));
                            order.addItem(item);
                        }
                    }
                }
            }
        }

        return orders;
    }

    public boolean reconcileOrder(Connection conn, long orderId, String targetStatus, String note) throws SQLException {
        // Find order
        String querySql = "SELECT OrderId, OrderCode, StudentId, Status, CouponCode FROM dbo.Orders WHERE OrderId = ?";
        long studentId = 0;
        String currentStatus = "";
        String couponCode = null;

        try (PreparedStatement ps = conn.prepareStatement(querySql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    studentId = rs.getLong("StudentId");
                    currentStatus = rs.getString("Status");
                    couponCode = rs.getString("CouponCode");
                } else {
                    return false;
                }
            }
        }

        if ("PAID".equalsIgnoreCase(targetStatus)) {
            // Update order status to PAID
            String updateOrderSql = "UPDATE dbo.Orders SET Status = 'PAID', PaidAt = COALESCE(PaidAt, SYSUTCDATETIME()) WHERE OrderId = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setLong(1, orderId);
                ps.executeUpdate();
            }

            // Update PaymentAttempts
            String updateAttemptSql = "UPDATE dbo.PaymentAttempts SET Status = 'SUCCEEDED', LastVerifiedAt = SYSUTCDATETIME() WHERE OrderId = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateAttemptSql)) {
                ps.setLong(1, orderId);
                ps.executeUpdate();
            }

            // Grant enrollments for all items
            String selectItemsSql = "SELECT OrderItemId, CourseId FROM dbo.OrderItems WHERE OrderId = ?";
            List<long[]> itemPairs = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(selectItemsSql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        itemPairs.add(new long[]{rs.getLong("OrderItemId"), rs.getLong("CourseId")});
                    }
                }
            }

            for (long[] pair : itemPairs) {
                long orderItemId = pair[0];
                long courseId = pair[1];

                String upsertEnrollmentSql =
                        "IF EXISTS (SELECT 1 FROM dbo.Enrollments WHERE StudentId = ? AND CourseId = ?) "
                      + "BEGIN "
                      + "    UPDATE dbo.Enrollments "
                      + "    SET AccessStatus = 'ACTIVE', SourceType = 'ORDER_PURCHASE', CurrentOrderItemId = ?, EnrolledAt = SYSUTCDATETIME() "
                      + "    WHERE StudentId = ? AND CourseId = ?; "
                      + "END "
                      + "ELSE "
                      + "BEGIN "
                      + "    INSERT INTO dbo.Enrollments (StudentId, CourseId, AccessStatus, SourceType, CurrentOrderItemId) "
                      + "    VALUES (?, ?, 'ACTIVE', 'ORDER_PURCHASE', ?); "
                      + "END";

                try (PreparedStatement psEnroll = conn.prepareStatement(upsertEnrollmentSql)) {
                    psEnroll.setLong(1, studentId);
                    psEnroll.setLong(2, courseId);
                    psEnroll.setLong(3, orderItemId);
                    psEnroll.setLong(4, studentId);
                    psEnroll.setLong(5, courseId);
                    psEnroll.setLong(6, studentId);
                    psEnroll.setLong(7, courseId);
                    psEnroll.setLong(8, orderItemId);
                    psEnroll.executeUpdate();
                }

                String logEventSql =
                        "INSERT INTO dbo.EnrollmentAccessEvents (EnrollmentId, SourceOrderItemId, EventType, ActorId, Reason) "
                      + "VALUES ((SELECT EnrollmentId FROM dbo.Enrollments WHERE StudentId = ? AND CourseId = ?), ?, 'GRANTED', ?, ?);";

                try (PreparedStatement psLog = conn.prepareStatement(logEventSql)) {
                    psLog.setLong(1, studentId);
                    psLog.setLong(2, courseId);
                    psLog.setLong(3, orderItemId);
                    psLog.setLong(4, studentId);
                    psLog.setString(5, (note != null && !note.isBlank()) ? ("Đối soát Admin: " + note) : "Admin đối soát thanh toán thành công (PAID)");
                    psLog.executeUpdate();
                }

                String deleteCartItemSql =
                        "DELETE ci FROM dbo.CartItems ci "
                      + "INNER JOIN dbo.Carts c ON ci.CartId = c.CartId "
                      + "WHERE c.StudentId = ? AND ci.CourseId = ?";

                try (PreparedStatement psDel = conn.prepareStatement(deleteCartItemSql)) {
                    psDel.setLong(1, studentId);
                    psDel.setLong(2, courseId);
                    psDel.executeUpdate();
                }
            }

            if (couponCode != null && !couponCode.isBlank()) {
                String updateCouponSql = "UPDATE dbo.Coupons SET UsedCount = UsedCount + 1 WHERE Code = ?";
                try (PreparedStatement psC = conn.prepareStatement(updateCouponSql)) {
                    psC.setString(1, couponCode.trim().toUpperCase());
                    psC.executeUpdate();
                }
            }
            return true;
        } else {
            // Update to specified status (e.g. PAYMENT_REVIEW or CANCELLED)
            String updateSql = "UPDATE dbo.Orders SET Status = ? WHERE OrderId = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, targetStatus);
                ps.setLong(2, orderId);
                return ps.executeUpdate() > 0;
            }
        }
    }
}
