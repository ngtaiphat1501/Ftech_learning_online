package dao;

import config.DBContext;
import model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> getList() throws SQLException {
        List<Category> list = new ArrayList<>();

        String sql = "SELECT CategoryId, Name, Slug, IconClass, Description, IsActive "
                + "FROM dbo.Categories "
                + "WHERE IsActive = 1 "
                + "ORDER BY CategoryId";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                Category category = new Category();
                category.setId(result.getLong("CategoryId"));
                category.setName(result.getString("Name"));
                category.setSlug(result.getString("Slug"));
                category.setIconClass(result.getString("IconClass"));
                category.setDescription(result.getString("Description"));
                category.setActive(result.getBoolean("IsActive"));
                list.add(category);
            }
        }

        return list;
    }

    public List<Category> getAllForAdmin() throws SQLException {
        List<Category> list = new ArrayList<>();

        String sql = "SELECT c.CategoryId, c.Name, c.Slug, c.IconClass, c.Description, c.IsActive, "
                + "(SELECT COUNT(*) FROM dbo.Courses WHERE CategoryId = c.CategoryId) AS CourseCount "
                + "FROM dbo.Categories c "
                + "ORDER BY c.CategoryId ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getLong("CategoryId"));
                cat.setName(rs.getString("Name"));
                cat.setSlug(rs.getString("Slug"));
                cat.setIconClass(rs.getString("IconClass"));
                cat.setDescription(rs.getString("Description"));
                cat.setActive(rs.getBoolean("IsActive"));
                cat.setCourseCount(rs.getInt("CourseCount"));
                list.add(cat);
            }
        }
        return list;
    }

    public Category getById(long id) throws SQLException {
        String sql = "SELECT CategoryId, Name, Slug, IconClass, Description, IsActive, "
                + "(SELECT COUNT(*) FROM dbo.Courses WHERE CategoryId = c.CategoryId) AS CourseCount "
                + "FROM dbo.Categories c WHERE CategoryId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category cat = new Category();
                    cat.setId(rs.getLong("CategoryId"));
                    cat.setName(rs.getString("Name"));
                    cat.setSlug(rs.getString("Slug"));
                    cat.setIconClass(rs.getString("IconClass"));
                    cat.setDescription(rs.getString("Description"));
                    cat.setActive(rs.getBoolean("IsActive"));
                    cat.setCourseCount(rs.getInt("CourseCount"));
                    return cat;
                }
            }
        }
        return null;
    }

    public boolean create(Category cat) throws SQLException {
        String sql = "INSERT INTO dbo.Categories (Name, Slug, IconClass, Description, IsActive) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cat.getName().trim());
            ps.setString(2, cat.getSlug() != null && !cat.getSlug().isBlank() ? cat.getSlug().trim() : generateSlug(cat.getName()));
            ps.setString(3, cat.getIconClass());
            ps.setString(4, cat.getDescription());
            ps.setBoolean(5, cat.isActive());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean update(Category cat) throws SQLException {
        String sql = "UPDATE dbo.Categories SET Name = ?, Slug = ?, IconClass = ?, Description = ?, IsActive = ? WHERE CategoryId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cat.getName().trim());
            ps.setString(2, cat.getSlug() != null && !cat.getSlug().isBlank() ? cat.getSlug().trim() : generateSlug(cat.getName()));
            ps.setString(3, cat.getIconClass());
            ps.setString(4, cat.getDescription());
            ps.setBoolean(5, cat.isActive());
            ps.setLong(6, cat.getId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean hasCourses(long categoryId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.Courses WHERE CategoryId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean delete(long categoryId) throws SQLException {
        // Enforce referential integrity per project assignment: không xóa dây chuyền nếu đang có khóa học tham chiếu
        if (hasCourses(categoryId)) {
            throw new SQLException("Không thể xóa danh mục vì đang có khóa học tham chiếu. Hãy chuyển khóa học sang danh mục khác trước!");
        }

        String sql = "DELETE FROM dbo.Categories WHERE CategoryId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    private String generateSlug(String input) {
        if (input == null) return "";
        String normalized = java.text.Normalizer.normalize(input, java.text.Normalizer.Form.NFD);
        String slug = normalized.replaceAll("\\p{M}", "");
        slug = slug.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("^-+|-+$", "");
        return slug;
    }
}
