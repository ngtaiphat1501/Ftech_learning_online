
package service;

import dao.EnrollmentDAO;
import config.DBContext;
import java.sql.Connection;
import java.sql.SQLException;

public class EnrollmentService {

    private final EnrollmentDAO enrollmentDAO =
            new EnrollmentDAO();

    public enum Result {
        SUCCESS,
        ALREADY_ENROLLED,
        ACCESS_RESTRICTED,
        COURSE_NOT_FOUND,
        NOT_PUBLISHED,
        PAID_COURSE,
        FORBIDDEN
    }

    public Result enroll(long studentId, long courseId)
            throws SQLException {

        try (Connection conn = DBContext.beginTransaction()) {

            try {
                Result result;

                // 1. Kiểm tra thông tin đầu vào
                if (studentId <= 0) {
                    result = Result.FORBIDDEN;

                } else if (courseId <= 0) {
                    result = Result.COURSE_NOT_FOUND;

                // 2. Kiểm tra quyền STUDENT
                } else if (!enrollmentDAO.isStudent(conn, studentId)) {
                    result = Result.FORBIDDEN;

                } else {

                    // 3. Kiểm tra khóa học
                    String[] course =
                            enrollmentDAO.getCourse(conn, courseId);

                    if (course == null) {
                        result = Result.COURSE_NOT_FOUND;

                    } else if (!"PUBLISHED".equals(course[0])) {
                        result = Result.NOT_PUBLISHED;

                    } else if (!"FREE".equals(course[1])) {
                        result = Result.PAID_COURSE;

                    } else {

                        // 4. Kiểm tra đã đăng ký chưa
                        String access =
                                enrollmentDAO.getAccessStatus(
                                        conn, studentId, courseId);

                        if ("ACTIVE".equals(access)) {
                            result = Result.ALREADY_ENROLLED;

                        } else if (access != null) {
                            result = Result.ACCESS_RESTRICTED;

                        } else {

                            // 5. Tạo Enrollment
                            long enrollmentId =
                                    enrollmentDAO.insertEnrollment(
                                            conn, studentId, courseId);

                            // 6. Ghi lịch sử cấp quyền
                            enrollmentDAO.insertAccessEvent(
                                    conn, enrollmentId, studentId);

                            result = Result.SUCCESS;
                        }
                    }
                }

                // 7. Xác nhận transaction
                conn.commit();
                return result;

            } catch (SQLException | RuntimeException ex) {
                conn.rollback();
                throw ex;
            }
        }
        
        
    }
    
    
    // Các trạng thái khi xem trước đăng ký
    public enum PreviewStatus {
        AVAILABLE,
        ALREADY_ENROLLED,
        ACCESS_RESTRICTED,
        COURSE_NOT_FOUND,
        NOT_PUBLISHED,
        PAID_COURSE,
        FORBIDDEN
    }

    // Kết quả kiểm tra trước khi đăng ký
    public static class Preview {

        private final String title;
        private final PreviewStatus status;

        public Preview(String title, PreviewStatus status) {
            this.title = title;
            this.status = status;
        }

        public String getTitle() {
            return title;
        }

        public PreviewStatus getStatus() {
            return status;
        }

        public boolean isCanEnroll() {
            return status == PreviewStatus.AVAILABLE;
        }

        public String getStatusMessage() {

            switch (status) {

                case AVAILABLE:
                    return "Khóa học miễn phí. Bạn có thể đăng ký.";

                case ALREADY_ENROLLED:
                    return "Bạn đã đăng ký khóa học này.";

                case ACCESS_RESTRICTED:
                    return "Quyền học của bạn đang bị hạn chế.";

                case COURSE_NOT_FOUND:
                    return "Không tìm thấy khóa học.";

                case NOT_PUBLISHED:
                    return "Khóa học chưa được công khai.";

                case PAID_COURSE:
                    return "Khóa học có phí. Vui lòng thanh toán.";

                case FORBIDDEN:
                    return "Tài khoản không có quyền STUDENT.";

                default:
                    return "Không thể đăng ký khóa học.";
            }
        }
    }

    // Kiểm tra thông tin trước khi hiển thị trang đăng ký
    public Preview preview(long studentId, long courseId)
            throws SQLException {

        if (studentId <= 0) {
            return new Preview(null, PreviewStatus.FORBIDDEN);
        }

        if (courseId <= 0) {
            return new Preview(null, PreviewStatus.COURSE_NOT_FOUND);
        }

        try (Connection conn = DBContext.getConnection()) {

            // 1. Kiểm tra quyền học viên
            if (!enrollmentDAO.isStudent(conn, studentId)) {
                return new Preview(null, PreviewStatus.FORBIDDEN);
            }

            // 2. Lấy dữ liệu khóa học
            String[] data = enrollmentDAO.getPreviewData(
                    conn, studentId, courseId
            );

            if (data == null) {
                return new Preview(
                        null, PreviewStatus.COURSE_NOT_FOUND
                );
            }

            String title = data[0];
            String courseStatus = data[1];
            String pricingType = data[2];
            String accessStatus = data[3];

            // 3. Kiểm tra trạng thái xuất bản
            if (!"PUBLISHED".equals(courseStatus)) {
                return new Preview(
                        title, PreviewStatus.NOT_PUBLISHED
                );
            }

            // 4. Kiểm tra loại giá
            if (!"FREE".equals(pricingType)) {
                return new Preview(
                        title, PreviewStatus.PAID_COURSE
                );
            }

            // 5. Kiểm tra đăng ký hiện tại
            if ("ACTIVE".equals(accessStatus)) {
                return new Preview(
                        title, PreviewStatus.ALREADY_ENROLLED
                );
            }

            if (accessStatus != null) {
                return new Preview(
                        title, PreviewStatus.ACCESS_RESTRICTED
                );
            }

            // 6. Được phép đăng ký miễn phí
            return new Preview(
                    title, PreviewStatus.AVAILABLE
            );
        }
    }

}
