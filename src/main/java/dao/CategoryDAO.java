/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDAO {

    public List<Category> getList() throws SQLException {
        List<Category> list = new ArrayList<>();

        String sql = "SELECT CategoryId, Name "
                + "FROM Categories "
                + "WHERE IsActive = 1 "
                + "ORDER BY CategoryId";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                Category category = new Category(
                        result.getLong("CategoryId"),
                        result.getString("Name")
                );

                list.add(category);
            }
        }

        return list;
    }
}