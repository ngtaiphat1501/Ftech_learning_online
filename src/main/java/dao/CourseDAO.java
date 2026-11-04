package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Course;

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
                + "WHERE e.CourseId = c.CourseId) AS EnrollmentCount "
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

                    course.setAverageRating(result.getDouble("AverageRating"));
                    course.setReviewCount(result.getLong("ReviewCount"));

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
}
