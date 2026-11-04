package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.LessonResource;

public class LessonResourceDAO {

    public List<LessonResource> getByLesson(
            long lessonId,
            long instructorId
    ) throws SQLException {

        List<LessonResource> list
                = new ArrayList<>();

        String sql
                = "SELECT "
                + "lr.ResourceId, "
                + "lr.LessonId, "
                + "lr.Title, "
                + "lr.ResourceUrl, "
                + "lr.ResourceType "
                + "FROM dbo.LessonResources lr "
                + "JOIN dbo.Lessons l "
                + "ON l.LessonId = lr.LessonId "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE lr.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "ORDER BY lr.ResourceId";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(
                    1,
                    lessonId
            );

            statement.setLong(
                    2,
                    instructorId
            );

            try (ResultSet result
                    = statement.executeQuery()) {

                while (result.next()) {

                    LessonResource resource
                            = new LessonResource();

                    resource.setResourceId(
                            result.getLong(
                                    "ResourceId"
                            )
                    );

                    resource.setLessonId(
                            result.getLong(
                                    "LessonId"
                            )
                    );

                    resource.setTitle(
                            result.getString(
                                    "Title"
                            )
                    );

                    resource.setResourceUrl(
                            result.getString(
                                    "ResourceUrl"
                            )
                    );

                    resource.setResourceType(
                            result.getString(
                                    "ResourceType"
                            )
                    );

                    list.add(resource);
                }
            }
        }

        return list;
    }

    public boolean createResource(
            long lessonId,
            long instructorId,
            String title,
            String resourceUrl,
            String resourceType
    ) throws SQLException {

        String sql
                = "INSERT INTO dbo.LessonResources "
                + "(LessonId, Title, ResourceUrl, ResourceType) "
                + "SELECT l.LessonId, ?, ?, ? "
                + "FROM dbo.Lessons l "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE l.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(
                    1,
                    title
            );

            statement.setString(
                    2,
                    resourceUrl
            );

            statement.setString(
                    3,
                    resourceType
            );

            statement.setLong(
                    4,
                    lessonId
            );

            statement.setLong(
                    5,
                    instructorId
            );

            return statement.executeUpdate() > 0;
        }
    }

    public boolean deleteResource(
            long resourceId,
            long lessonId,
            long instructorId
    ) throws SQLException {

        String sql
                = "DELETE lr "
                + "FROM dbo.LessonResources lr "
                + "JOIN dbo.Lessons l "
                + "ON l.LessonId = lr.LessonId "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = l.CourseId "
                + "WHERE lr.ResourceId = ? "
                + "AND lr.LessonId = ? "
                + "AND c.InstructorId = ? "
                + "AND c.Status = 'DRAFT'";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(
                    1,
                    resourceId
            );

            statement.setLong(
                    2,
                    lessonId
            );

            statement.setLong(
                    3,
                    instructorId
            );

            return statement.executeUpdate() > 0;
        }
    }
}