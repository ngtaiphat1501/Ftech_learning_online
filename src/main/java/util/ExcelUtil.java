package util;

import model.Category;
import model.InstructorStudentProgress;
import model.Order;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Utility for manipulating Excel files (.xlsx) using Apache POI:
 * - Export Orders & Revenue report to Excel
 * - Export Course Student progress to Excel
 * - Import Categories from Excel
 * - Generate Category import template Excel file
 */
public final class ExcelUtil {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private ExcelUtil() {
    }

    /**
     * Export Orders report to Excel (.xlsx)
     */
    public static void exportOrders(List<Order> orders, OutputStream out) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo Đơn hàng");
            sheet.setDisplayGridlines(true);

            // Cell Styles
            CellStyle titleStyle = workbook.createCellStyle();
            Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 16);
            titleFont.setColor(IndexedColors.DARK_BLUE.getIndex());
            titleStyle.setFont(titleFont);
            titleStyle.setAlignment(HorizontalAlignment.LEFT);

            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.ROYAL_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            setBorder(headerStyle);

            CellStyle dataStyle = workbook.createCellStyle();
            setBorder(dataStyle);

            CellStyle currencyStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            currencyStyle.setDataFormat(format.getFormat("#,##0 \"₫\""));
            currencyStyle.setAlignment(HorizontalAlignment.RIGHT);
            setBorder(currencyStyle);

            CellStyle centerStyle = workbook.createCellStyle();
            centerStyle.setAlignment(HorizontalAlignment.CENTER);
            setBorder(centerStyle);

            CellStyle totalStyle = workbook.createCellStyle();
            Font totalFont = workbook.createFont();
            totalFont.setBold(true);
            totalStyle.setFont(totalFont);
            totalStyle.setDataFormat(format.getFormat("#,##0 \"₫\""));
            totalStyle.setAlignment(HorizontalAlignment.RIGHT);
            totalStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            totalStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            setBorder(totalStyle);

            // Title Row
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("FTECH LMS - BÁO CÁO QUẢN LÝ ĐƠN HÀNG & DOANH THU");
            titleCell.setCellStyle(titleStyle);

            // Subtitle Row
            Row subRow = sheet.createRow(1);
            Cell subCell = subRow.createCell(0);
            subCell.setCellValue("Thời điểm xuất báo cáo: " + java.time.LocalDateTime.now().format(DATE_FMT));

            // Header Row
            String[] headers = {
                    "STT", "Mã Đơn Hàng", "Tên Học Viên", "Email", "Trạng Thái",
                    "Tạm Tính (VNĐ)", "Giảm Giá (VNĐ)", "Tổng Tiền (VNĐ)", "Phương Thức", "Ngày Tạo"
            };
            Row headerRow = sheet.createRow(3);
            headerRow.setHeightInPoints(26);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            // Data Rows
            int rowIdx = 4;
            int stt = 1;
            BigDecimal totalRevenue = BigDecimal.ZERO;

            for (Order o : orders) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(stt++);
                row.getCell(0).setCellStyle(centerStyle);

                row.createCell(1).setCellValue(o.getOrderCode() != null ? o.getOrderCode() : "N/A");
                row.getCell(1).setCellStyle(dataStyle);

                row.createCell(2).setCellValue(o.getStudentName() != null ? o.getStudentName() : "");
                row.getCell(2).setCellStyle(dataStyle);

                row.createCell(3).setCellValue(o.getStudentEmail() != null ? o.getStudentEmail() : "");
                row.getCell(3).setCellStyle(dataStyle);

                row.createCell(4).setCellValue(o.getStatus() != null ? o.getStatus() : "");
                row.getCell(4).setCellStyle(centerStyle);

                Cell subtotalCell = row.createCell(5);
                subtotalCell.setCellValue(o.getSubtotalVnd() != null ? o.getSubtotalVnd().doubleValue() : 0.0);
                subtotalCell.setCellStyle(currencyStyle);

                Cell discountCell = row.createCell(6);
                discountCell.setCellValue(o.getDiscountVnd() != null ? o.getDiscountVnd().doubleValue() : 0.0);
                discountCell.setCellStyle(currencyStyle);

                Cell totalCell = row.createCell(7);
                double totalVal = o.getTotalVnd() != null ? o.getTotalVnd().doubleValue() : 0.0;
                totalCell.setCellValue(totalVal);
                totalCell.setCellStyle(currencyStyle);

                if ("PAID".equalsIgnoreCase(o.getStatus())) {
                    totalRevenue = totalRevenue.add(o.getTotalVnd() != null ? o.getTotalVnd() : BigDecimal.ZERO);
                }

                row.createCell(8).setCellValue(o.getPaymentProvider() != null ? o.getPaymentProvider() : "VÍ LEARNORA");
                row.getCell(8).setCellStyle(centerStyle);

                row.createCell(9).setCellValue(o.getCreatedAt() != null ? o.getCreatedAt().format(DATE_FMT) : "");
                row.getCell(9).setCellStyle(centerStyle);
            }

            // Summary row
            Row summaryRow = sheet.createRow(rowIdx);
            Cell sumLabel = summaryRow.createCell(0);
            sumLabel.setCellValue("TỔNG CỘNG DOANH THU ĐÃ THU (PAID):");
            sumLabel.setCellStyle(totalStyle);

            for (int i = 1; i < 7; i++) {
                Cell empty = summaryRow.createCell(i);
                empty.setCellStyle(totalStyle);
            }
            sheet.addMergedRegion(new CellRangeAddress(rowIdx, rowIdx, 0, 6));

            Cell sumVal = summaryRow.createCell(7);
            sumVal.setCellValue(totalRevenue.doubleValue());
            sumVal.setCellStyle(totalStyle);

            Cell tail1 = summaryRow.createCell(8);
            tail1.setCellStyle(totalStyle);
            Cell tail2 = summaryRow.createCell(9);
            tail2.setCellStyle(totalStyle);

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, Math.max(sheet.getColumnWidth(i) + 1200, 3500));
            }

            workbook.write(out);
        }
    }

    /**
     * Export Course Students and Progress report to Excel (.xlsx)
     */
    public static void exportStudents(List<InstructorStudentProgress> students, String courseTitle, OutputStream out) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Học viên");
            sheet.setDisplayGridlines(true);

            CellStyle titleStyle = workbook.createCellStyle();
            Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 15);
            titleFont.setColor(IndexedColors.DARK_BLUE.getIndex());
            titleStyle.setFont(titleFont);

            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.SEA_GREEN.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            setBorder(headerStyle);

            CellStyle dataStyle = workbook.createCellStyle();
            setBorder(dataStyle);

            CellStyle centerStyle = workbook.createCellStyle();
            centerStyle.setAlignment(HorizontalAlignment.CENTER);
            setBorder(centerStyle);

            CellStyle percentStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            percentStyle.setDataFormat(format.getFormat("0.0\"%\""));
            percentStyle.setAlignment(HorizontalAlignment.RIGHT);
            setBorder(percentStyle);

            // Title
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("DANH SÁCH TIẾN ĐỘ HỌC VIÊN - KHÓA HỌC: " + (courseTitle != null ? courseTitle : ""));
            titleCell.setCellStyle(titleStyle);

            Row subRow = sheet.createRow(1);
            subRow.createCell(0).setCellValue("Xuất lúc: " + java.time.LocalDateTime.now().format(DATE_FMT));

            // Headers
            String[] headers = {
                    "STT", "Họ và Tên", "Email", "Trạng Thái Truy Cập",
                    "Tiến Độ (%)", "Bài Đã Học", "Bài Thi Đã Đạt", "Hoàn Thành Khóa", "Ngày Ghi Danh"
            };
            Row headerRow = sheet.createRow(3);
            headerRow.setHeightInPoints(24);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            // Data
            int rowIdx = 4;
            int stt = 1;
            for (InstructorStudentProgress p : students) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(stt++);
                row.getCell(0).setCellStyle(centerStyle);

                row.createCell(1).setCellValue(p.getFullName() != null ? p.getFullName() : "");
                row.getCell(1).setCellStyle(dataStyle);

                row.createCell(2).setCellValue(p.getEmail() != null ? p.getEmail() : "");
                row.getCell(2).setCellStyle(dataStyle);

                row.createCell(3).setCellValue(p.getAccessStatus() != null ? p.getAccessStatus() : "ACTIVE");
                row.getCell(3).setCellStyle(centerStyle);

                Cell progressCell = row.createCell(4);
                double pct = p.getProgressPercent() != null ? p.getProgressPercent().doubleValue() : 0.0;
                progressCell.setCellValue(pct);
                progressCell.setCellStyle(percentStyle);

                row.createCell(5).setCellValue(p.getCompletedRequiredLessons() + " / " + p.getTotalRequiredLessons());
                row.getCell(5).setCellStyle(centerStyle);

                row.createCell(6).setCellValue(p.getPassedRequiredQuizzes() + " / " + p.getTotalRequiredQuizzes());
                row.getCell(6).setCellStyle(centerStyle);

                row.createCell(7).setCellValue(p.isEligibleForCompletion() ? "ĐÃ HOÀN THÀNH" : "ĐANG HỌC");
                row.getCell(7).setCellStyle(centerStyle);

                row.createCell(8).setCellValue(p.getEnrolledAt() != null ? p.getEnrolledAt().toLocalDateTime().format(DATE_FMT) : "");
                row.getCell(8).setCellStyle(centerStyle);
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, Math.max(sheet.getColumnWidth(i) + 1200, 3500));
            }

            workbook.write(out);
        }
    }

    /**
     * Import Categories from uploaded Excel (.xlsx) file
     */
    public static List<Category> importCategories(InputStream in) throws IOException {
        List<Category> list = new ArrayList<>();
        try (Workbook workbook = new XSSFWorkbook(in)) {
            Sheet sheet = workbook.getSheetAt(0);
            if (sheet == null) return list;

            int rowCount = sheet.getLastRowNum();
            // Start from row 1 (row 0 is header)
            for (int r = 1; r <= rowCount; r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;

                String name = getCellValue(row.getCell(0));
                if (name == null || name.isBlank()) continue;

                String slug = getCellValue(row.getCell(1));
                String icon = getCellValue(row.getCell(2));
                String desc = getCellValue(row.getCell(3));
                String statusStr = getCellValue(row.getCell(4));

                boolean isActive = true;
                if (statusStr != null && (statusStr.equals("0") || statusStr.equalsIgnoreCase("false") || statusStr.equalsIgnoreCase("Khóa"))) {
                    isActive = false;
                }

                if (icon == null || icon.isBlank()) {
                    icon = "bi-folder";
                }

                Category cat = new Category(0, name.trim(), slug != null ? slug.trim() : "", icon.trim(), desc != null ? desc.trim() : "", isActive);
                list.add(cat);
            }
        }
        return list;
    }

    /**
     * Generates a template Excel file for Categories Import
     */
    public static void generateCategoryTemplate(OutputStream out) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Mau_Nhap_Danh_Muc");
            sheet.setDisplayGridlines(true);

            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            setBorder(headerStyle);

            CellStyle dataStyle = workbook.createCellStyle();
            setBorder(dataStyle);

            String[] headers = {
                    "Tên Danh Mục (*)", "Mã Slug (Để trống tự sinh)", "Icon Class Bootstrap", "Mô Tả Danh Mục", "Trạng Thái (1: Hiện, 0: Ẩn)"
            };
            Row headerRow = sheet.createRow(0);
            headerRow.setHeightInPoints(24);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            // Sample rows
            Object[][] samples = {
                    {"Điện toán đám mây & DevOps", "cloud-devops", "bi-cloud-check", "Khóa học Docker, Kubernetes, AWS, CI/CD", 1},
                    {"Trí tuệ nhân tạo & Machine Learning", "ai-machine-learning", "bi-robot", "Python, TensorFlow, Deep Learning và GenAI", 1},
                    {"Bảo mật thông tin & An ninh mạng", "cyber-security", "bi-shield-lock", "An toàn thông tin, bảo mật web, ethical hacking", 1}
            };

            int rowIdx = 1;
            for (Object[] s : samples) {
                Row row = sheet.createRow(rowIdx++);
                for (int c = 0; c < s.length; c++) {
                    Cell cell = row.createCell(c);
                    if (s[c] instanceof Number) {
                        cell.setCellValue(((Number) s[c]).intValue());
                    } else {
                        cell.setCellValue(String.valueOf(s[c]));
                    }
                    cell.setCellStyle(dataStyle);
                }
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, Math.max(sheet.getColumnWidth(i) + 1500, 4500));
            }

            workbook.write(out);
        }
    }

    private static String getCellValue(Cell cell) {
        if (cell == null) return null;
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                double num = cell.getNumericCellValue();
                if (num == Math.floor(num)) {
                    return String.valueOf((long) num);
                }
                return String.valueOf(num);
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            default:
                return null;
        }
    }

    private static void setBorder(CellStyle style) {
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
    }
}
