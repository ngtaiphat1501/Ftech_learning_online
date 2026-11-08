package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Course;
import model.Chapter;
import model.Lesson;
import model.CourseReview;
import java.util.Map;
import java.util.LinkedHashMap;

public class CourseDAO {

    public List<Course> getList(String keyword,
            long categoryId,
            String pricingType) throws SQLException {

        List<Course> list = new ArrayList<>();

        String sql = "SELECT c.CourseId, c.Title, c.ThumbnailUrl, "
                + "c.PricingType, c.ListPriceVnd, c.SalePriceVnd, "
                + "c.EstimatedHours, u.FullName AS InstructorName, "
                + "ca.Name AS CategoryName, "
                + "COALESCE(rv.AverageRating, 0) AS AverageRating, "
                + "COALESCE(rv.ReviewCount, 0) AS ReviewCount, "
                + "(SELECT COUNT(*) FROM Lessons l "
                + "WHERE l.CourseId = c.CourseId) AS LessonCount "
                + "FROM Courses c "
                + "JOIN Users u ON c.InstructorId = u.UserId "
                + "JOIN Categories ca ON c.CategoryId = ca.CategoryId "
                + "LEFT JOIN (SELECT e.CourseId, "
                + "AVG(CAST(r.Rating AS decimal(10, 4))) AS AverageRating, "
                + "COUNT_BIG(*) AS ReviewCount "
                + "FROM dbo.CourseReviews r "
                + "JOIN dbo.Enrollments e ON e.EnrollmentId = r.EnrollmentId "
                + "WHERE r.IsHidden = 0 "
                + "GROUP BY e.CourseId) rv ON rv.CourseId = c.CourseId "
                + "WHERE c.Status = 'PUBLISHED' "
                + "AND ca.IsActive = 1 "
                + "AND c.Title LIKE ? "
                + "AND (? = 0 OR c.CategoryId = ?) "
                + "AND (? = '' OR c.PricingType = ?) "
                + "ORDER BY c.PublishedAt DESC, c.CourseId DESC";

        try (
                Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, "%" + keyword + "%");
            statement.setLong(2, categoryId);
            statement.setLong(3, categoryId);
            statement.setString(4, pricingType);
            statement.setString(5, pricingType);

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    Course course = new Course();

                    course.setId(
                            result.getLong("CourseId")
                    );

                    course.setTitle(
                            result.getString("Title")
                    );

                    course.setThumbnailUrl(
                            result.getString("ThumbnailUrl")
                    );

                    course.setInstructorName(
                            result.getString("InstructorName")
                    );

                    course.setCategoryName(
                            result.getString("CategoryName")
                    );

                    course.setPricingType(
                            result.getString("PricingType")
                    );

                    course.setListPrice(
                            result.getBigDecimal("ListPriceVnd")
                    );

                    course.setSalePrice(
                            result.getBigDecimal("SalePriceVnd")
                    );

                    course.setEstimatedHours(
                            result.getBigDecimal("EstimatedHours")
                    );

                    course.setLessonCount(
                            result.getInt("LessonCount")
                    );

                    course.setAverageRating(
                            result.getDouble("AverageRating")
                    );

                    course.setReviewCount(
                            result.getLong("ReviewCount")
                    );

                    list.add(course);
                }
            }
        }

        return list;
    }

    public boolean createCourse(Course course) throws SQLException {

        String sql = "INSERT INTO Courses "
                + "(CategoryId, InstructorId, Slug, Title, Description, "
                + "PricingType, ListPriceVnd, SalePriceVnd, Status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, course.getCategoryId());
            statement.setLong(2, course.getInstructorId());
            statement.setString(3, course.getSlug());
            statement.setString(4, course.getTitle());
            statement.setString(5, course.getDescription());
            statement.setString(6, course.getPricingType());
            statement.setBigDecimal(7, course.getListPrice());
            statement.setBigDecimal(8, course.getSalePrice());
            statement.setString(9, course.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    public List<Course> getByInstructorId(long instructorId)
            throws SQLException {

        List<Course> list = new ArrayList<>();

        String sql = "SELECT c.CourseId, c.Title, c.ThumbnailUrl, "
                + "c.PricingType, c.ListPriceVnd, c.SalePriceVnd, "
                + "c.EstimatedHours, c.Status, "
                + "u.FullName AS InstructorName, "
                + "ca.Name AS CategoryName, "
                + "(SELECT COUNT(*) FROM Lessons l "
                + "WHERE l.CourseId = c.CourseId) AS LessonCount, "
                + "(SELECT COUNT(*) FROM dbo.Enrollments e "
                + "WHERE e.CourseId = c.CourseId) AS EnrollmentCount, "
                + "ISNULL((SELECT SUM(oi.PayableVnd) FROM dbo.OrderItems oi JOIN dbo.Orders o ON o.OrderId = oi.OrderId AND o.Status = 'PAID' WHERE oi.CourseId = c.CourseId), 0) AS RevenueVnd "
                + "FROM Courses c "
                + "JOIN Users u ON c.InstructorId = u.UserId "
                + "JOIN Categories ca ON c.CategoryId = ca.CategoryId "
                + "WHERE c.InstructorId = ? "
                + "ORDER BY c.UpdatedAt DESC, c.CourseId DESC";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, instructorId);

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    Course course = new Course();

                    course.setId(result.getLong("CourseId"));
                    course.setTitle(result.getString("Title"));
                    course.setThumbnailUrl(result.getString("ThumbnailUrl"));
                    course.setInstructorName(result.getString("InstructorName"));
                    course.setCategoryName(result.getString("CategoryName"));
                    course.setPricingType(result.getString("PricingType"));
                    course.setListPrice(result.getBigDecimal("ListPriceVnd"));
                    course.setSalePrice(result.getBigDecimal("SalePriceVnd"));
                    course.setEstimatedHours(result.getBigDecimal("EstimatedHours"));
                    course.setLessonCount(result.getInt("LessonCount"));
                    course.setStatus(result.getString("Status"));
                    course.setEnrollmentCount(result.getInt("EnrollmentCount"));
                    course.setRevenueVnd(result.getBigDecimal("RevenueVnd"));

                    list.add(course);
                }
            }
        }

        return list;
    }

    public Course getByIdForInstructor(long courseId, long instructorId)
            throws SQLException {

        String sql = "SELECT CourseId, InstructorId, CategoryId, "
                + "Slug, Title, Description, PricingType, "
                + "ListPriceVnd, SalePriceVnd, Status "
                + "FROM dbo.Courses "
                + "WHERE CourseId = ? AND InstructorId = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);
            statement.setLong(2, instructorId);

            try (ResultSet result = statement.executeQuery()) {

                if (result.next()) {

                    Course course = new Course();

                    course.setId(result.getLong("CourseId"));
                    course.setInstructorId(result.getLong("InstructorId"));
                    course.setCategoryId(result.getLong("CategoryId"));
                    course.setSlug(result.getString("Slug"));
                    course.setTitle(result.getString("Title"));
                    course.setDescription(result.getString("Description"));
                    course.setPricingType(result.getString("PricingType"));
                    course.setListPrice(result.getBigDecimal("ListPriceVnd"));
                    course.setSalePrice(result.getBigDecimal("SalePriceVnd"));
                    course.setStatus(result.getString("Status"));

                    return course;
                }
            }
        }

        return null;
    }

    public boolean updateCourse(Course course)
            throws SQLException {

        String sql = "UPDATE dbo.Courses "
                + "SET CategoryId = ?, "
                + "Slug = ?, "
                + "Title = ?, "
                + "Description = ?, "
                + "PricingType = ?, "
                + "ListPriceVnd = ?, "
                + "SalePriceVnd = ? "
                + "WHERE CourseId = ? "
                + "AND InstructorId = ? "
                + "AND Status = 'DRAFT'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, course.getCategoryId());
            statement.setString(2, course.getSlug());
            statement.setString(3, course.getTitle());
            statement.setString(4, course.getDescription());
            statement.setString(5, course.getPricingType());
            statement.setBigDecimal(6, course.getListPrice());

            if (course.getSalePrice() == null) {
                statement.setNull(7, java.sql.Types.DECIMAL);
            } else {
                statement.setBigDecimal(7, course.getSalePrice());
            }

            statement.setLong(8, course.getId());
            statement.setLong(9, course.getInstructorId());

            return statement.executeUpdate() == 1;
        }
    }

    public boolean archiveCourse(long courseId, long instructorId)
            throws SQLException {

        String sql = "UPDATE dbo.Courses "
                + "SET Status = 'ARCHIVED' "
                + "WHERE CourseId = ? "
                + "AND InstructorId = ? "
                + "AND Status = 'PUBLISHED'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);
            statement.setLong(2, instructorId);

            return statement.executeUpdate() == 1;
        }
    }

    public boolean reopenCourse(long courseId, long instructorId)
            throws SQLException {

        String sql = "UPDATE dbo.Courses "
                + "SET Status = 'DRAFT' "
                + "WHERE CourseId = ? "
                + "AND InstructorId = ? "
                + "AND Status = 'PUBLISHED' "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM dbo.Enrollments e "
                + "WHERE e.CourseId = dbo.Courses.CourseId"
                + ")";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, courseId);
            statement.setLong(2, instructorId);

            return statement.executeUpdate() == 1;
        }
    }

    public int submitForApproval(
            long courseId,
            long instructorId
    ) throws SQLException {

        String checkCourseSql
                = "SELECT Status "
                + "FROM dbo.Courses WITH (UPDLOCK) "
                + "WHERE CourseId = ? "
                + "AND InstructorId = ?";

        String checkContentSql
                = "SELECT "
                + "(SELECT COUNT(*) "
                + " FROM dbo.Chapters "
                + " WHERE CourseId = ?) AS ChapterCount, "
                + "(SELECT COUNT(*) "
                + " FROM dbo.Lessons "
                + " WHERE CourseId = ?) AS LessonCount";

        String updateSql
                = "UPDATE dbo.Courses "
                + "SET Status = 'PENDING_APPROVAL', "
                + "RejectionReason = NULL, "
                + "UpdatedAt = SYSUTCDATETIME() "
                + "WHERE CourseId = ? "
                + "AND InstructorId = ? "
                + "AND Status = 'DRAFT'";

        String eventSql
                = "INSERT INTO dbo.CourseApprovalEvents "
                + "(CourseId, ActorId, Action, "
                + "FromStatus, ToStatus, Note) "
                + "VALUES (?, ?, 'SUBMIT', "
                + "'DRAFT', 'PENDING_APPROVAL', ?)";

        try (Connection connection = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                String status;

                try (PreparedStatement statement
                        = connection.prepareStatement(
                                checkCourseSql
                        )) {

                            statement.setLong(1, courseId);
                            statement.setLong(2, instructorId);

                            try (ResultSet result
                                    = statement.executeQuery()) {

                                if (!result.next()) {

                                    connection.rollback();
                                    return 0;
                                }

                                status = result.getString("Status");
                            }
                        }

                        if (!"DRAFT".equals(status)) {

                            connection.rollback();
                            return 0;
                        }

                        int chapterCount;
                        int lessonCount;

                        try (PreparedStatement statement
                                = connection.prepareStatement(
                                        checkContentSql
                                )) {

                                    statement.setLong(1, courseId);
                                    statement.setLong(2, courseId);

                                    try (ResultSet result
                                            = statement.executeQuery()) {

                                        result.next();

                                        chapterCount
                                                = result.getInt(
                                                        "ChapterCount"
                                                );

                                        lessonCount
                                                = result.getInt(
                                                        "LessonCount"
                                                );
                                    }
                                }

                                if (chapterCount < 1
                                        || lessonCount < 1) {

                                    connection.rollback();

                                    return -1;
                                }

                                try (PreparedStatement statement
                                        = connection.prepareStatement(
                                                updateSql
                                        )) {

                                            statement.setLong(1, courseId);
                                            statement.setLong(2, instructorId);

                                            if (statement.executeUpdate() != 1) {

                                                connection.rollback();
                                                return 0;
                                            }
                                        }

                                        try (PreparedStatement statement
                                                = connection.prepareStatement(
                                                        eventSql
                                                )) {

                                                    statement.setLong(1, courseId);
                                                    statement.setLong(2, instructorId);

                                                    statement.setString(
                                                            3,
                                                            "Instructor gui khoa hoc de duyet"
                                                    );

                                                    statement.executeUpdate();
                                                }

                                                connection.commit();

                                                return 1;

            } catch (SQLException ex) {

                connection.rollback();
                throw ex;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    public Course getCourseDetail(long courseId) throws SQLException {
        String sql = "SELECT c.CourseId, c.CategoryId, c.InstructorId, c.Slug, c.Title, c.Subtitle, "
                + "c.Description, c.LearningObjectives, c.Requirements, c.TargetAudience, "
                + "c.ThumbnailUrl, c.IntroVideoUrl, c.Level, c.Language, c.EstimatedHours, "
                + "c.PricingType, c.ListPriceVnd, c.SalePriceVnd, c.Status, "
                + "u.FullName AS InstructorName, u.Headline AS InstructorHeadline, "
                + "u.Bio AS InstructorBio, u.AvatarUrl AS InstructorAvatar, "
                + "ca.Name AS CategoryName, "
                + "(SELECT COUNT(*) FROM dbo.Chapters ch WHERE ch.CourseId = c.CourseId) AS ModuleCount, "
                + "(SELECT COUNT(*) FROM dbo.Lessons l WHERE l.CourseId = c.CourseId) AS LessonCount, "
                + "(SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount "
                + "FROM dbo.Courses c "
                + "JOIN dbo.Users u ON c.InstructorId = u.UserId "
                + "JOIN dbo.Categories ca ON c.CategoryId = ca.CategoryId "
                + "WHERE c.CourseId = ?";

        Course course = null;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    course = new Course();
                    course.setId(rs.getLong("CourseId"));
                    course.setCategoryId(rs.getLong("CategoryId"));
                    course.setInstructorId(rs.getLong("InstructorId"));
                    course.setSlug(rs.getString("Slug"));
                    course.setTitle(rs.getString("Title"));
                    course.setSubtitle(rs.getString("Subtitle"));
                    course.setDescription(rs.getString("Description"));
                    course.setLearningObjectives(rs.getString("LearningObjectives"));
                    course.setRequirements(rs.getString("Requirements"));
                    course.setTargetAudience(rs.getString("TargetAudience"));
                    course.setThumbnailUrl(rs.getString("ThumbnailUrl"));
                    course.setIntroVideoUrl(rs.getString("IntroVideoUrl"));
                    course.setLevel(rs.getString("Level"));
                    course.setLanguage(rs.getString("Language"));
                    course.setEstimatedHours(rs.getBigDecimal("EstimatedHours"));
                    course.setPricingType(rs.getString("PricingType"));
                    course.setListPrice(rs.getBigDecimal("ListPriceVnd"));
                    course.setSalePrice(rs.getBigDecimal("SalePriceVnd"));
                    course.setStatus(rs.getString("Status"));

                    course.setInstructorName(rs.getString("InstructorName"));
                    course.setInstructorHeadline(rs.getString("InstructorHeadline"));
                    course.setInstructorBio(rs.getString("InstructorBio"));
                    course.setInstructorAvatar(rs.getString("InstructorAvatar"));
                    course.setCategoryName(rs.getString("CategoryName"));
                    course.setModuleCount(rs.getInt("ModuleCount"));
                    course.setLessonCount(rs.getInt("LessonCount"));
                    course.setLearnerCount(rs.getInt("LearnerCount"));
                }
            }
        }

        if (course != null) {
            loadRatingSummary(course);
            course.setChapters(getCourseChaptersWithLessons(courseId));
        }

        return course;
    }

    private void loadRatingSummary(Course course) throws SQLException {
        String sql = "SELECT COALESCE(AVG(CAST(r.Rating AS FLOAT)), 0.0) AS AvgRating, "
                + "COUNT(r.Rating) AS TotalRatings "
                + "FROM dbo.CourseReviews r "
                + "JOIN dbo.Enrollments e ON r.EnrollmentId = e.EnrollmentId "
                + "WHERE e.CourseId = ? AND r.IsHidden = 0";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, course.getId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("TotalRatings");
                    course.setTotalRatings(total);
                    course.setAverageRating(total > 0 ? (Math.round(rs.getDouble("AvgRating") * 10.0) / 10.0) : 0.0);
                }
            }
        }
    }

    public List<Chapter> getCourseChaptersWithLessons(long courseId) throws SQLException {
        Map<Long, Chapter> chapterMap = new LinkedHashMap<>();

        String sql = "SELECT ch.ChapterId, ch.CourseId, ch.Title AS ChapterTitle, ch.Description AS ChapterDesc, ch.SortOrder AS ChapterOrder, "
                + "l.LessonId, l.Title AS LessonTitle, l.VideoUrl, l.DurationSeconds, l.SortOrder AS LessonOrder, "
                + "l.IsPreview, l.IsRequired "
                + "FROM dbo.Chapters ch "
                + "LEFT JOIN dbo.Lessons l ON ch.ChapterId = l.ChapterId "
                + "WHERE ch.CourseId = ? "
                + "ORDER BY ch.SortOrder ASC, l.SortOrder ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long chapterId = rs.getLong("ChapterId");
                    Chapter chapter = chapterMap.get(chapterId);
                    if (chapter == null) {
                        chapter = new Chapter(
                                chapterId,
                                rs.getLong("CourseId"),
                                rs.getString("ChapterTitle"),
                                rs.getString("ChapterDesc"),
                                rs.getInt("ChapterOrder")
                        );
                        chapterMap.put(chapterId, chapter);
                    }

                    long lessonId = rs.getLong("LessonId");
                    if (lessonId > 0) {
                        Lesson lesson = new Lesson(
                                lessonId,
                                chapterId,
                                courseId,
                                rs.getString("LessonTitle"),
                                rs.getString("VideoUrl"),
                                (Integer) rs.getObject("DurationSeconds"),
                                rs.getInt("LessonOrder"),
                                rs.getBoolean("IsPreview"),
                                rs.getBoolean("IsRequired")
                        );
                        chapter.addLesson(lesson);
                    }
                }
            }
        }

        return new ArrayList<>(chapterMap.values());
    }

    public List<CourseReview> getCourseReviews(long courseId) throws SQLException {
        List<CourseReview> reviews = new ArrayList<>();
        String sql = "SELECT r.EnrollmentId, r.Rating, r.Comment, r.CreatedAt, "
                + "u.FullName AS StudentName, u.AvatarUrl AS StudentAvatar "
                + "FROM dbo.CourseReviews r "
                + "JOIN dbo.Enrollments e ON r.EnrollmentId = e.EnrollmentId "
                + "JOIN dbo.Users u ON e.StudentId = u.UserId "
                + "WHERE e.CourseId = ? AND r.IsHidden = 0 "
                + "ORDER BY r.CreatedAt DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourseReview review = new CourseReview(
                            rs.getLong("EnrollmentId"),
                            rs.getInt("Rating"),
                            rs.getString("Comment"),
                            rs.getTimestamp("CreatedAt"),
                            rs.getString("StudentName"),
                            rs.getString("StudentAvatar")
                    );
                    reviews.add(review);
                }
            }
        }
        return reviews;
    }

    public boolean isUserEnrolled(long userId, long courseId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.Enrollments WHERE StudentId = ? AND CourseId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean isCourseInUserCart(long userId, long courseId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.CartItems ci "
                + "JOIN dbo.Carts c ON ci.CartId = c.CartId "
                + "WHERE c.StudentId = ? AND ci.CourseId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Course getCourseDetail(Connection conn, long courseId) throws SQLException {
        return getCourseDetail(courseId);
    }

    public List<Chapter> getCourseChaptersWithLessons(Connection conn, long courseId) throws SQLException {
        return getCourseChaptersWithLessons(courseId);
    }

    public List<Map<String, Object>> getMonthlyRevenueByInstructor(long instructorId, int year) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT MONTH(o.CreatedAt) AS [Month], "
                   + "       COALESCE(SUM(oi.PayableVnd), 0) AS Revenue, "
                   + "       COUNT(DISTINCT oi.OrderItemId) AS TotalSold "
                   + "FROM dbo.OrderItems oi "
                   + "JOIN dbo.Orders o ON o.OrderId = oi.OrderId AND o.Status = 'PAID' "
                   + "JOIN dbo.Courses c ON c.CourseId = oi.CourseId "
                   + "WHERE c.InstructorId = ? AND YEAR(o.CreatedAt) = ? "
                   + "GROUP BY MONTH(o.CreatedAt) "
                   + "ORDER BY [Month]";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, instructorId);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new java.util.HashMap<>();
                    map.put("month", rs.getInt("Month"));
                    map.put("revenue", rs.getBigDecimal("Revenue"));
                    map.put("totalSold", rs.getInt("TotalSold"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public List<Map<String, Object>> getRecentEnrollmentsByInstructor(long instructorId, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) e.EnrollmentId, e.CourseId, c.Title AS CourseTitle, "
                   + "       u.FullName AS StudentName, u.Email AS StudentEmail, "
                   + "       e.EnrolledAt, e.AccessStatus "
                   + "FROM dbo.Enrollments e "
                   + "JOIN dbo.Courses c ON c.CourseId = e.CourseId "
                   + "JOIN dbo.Users u ON u.UserId = e.StudentId "
                   + "WHERE c.InstructorId = ? "
                   + "ORDER BY e.EnrolledAt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setLong(2, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new java.util.HashMap<>();
                    map.put("courseId", rs.getLong("CourseId"));
                    map.put("courseTitle", rs.getString("CourseTitle"));
                    map.put("studentName", rs.getString("StudentName"));
                    map.put("studentEmail", rs.getString("StudentEmail"));
                    map.put("enrolledAt", rs.getTimestamp("EnrolledAt"));
                    map.put("accessStatus", rs.getString("AccessStatus"));
                    list.add(map);
                }
            }
        }
        return list;
    }

}
