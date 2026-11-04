package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ApprovalCourse;

public class ApprovalDAO {

    public boolean isAdmin(
            long userId
    ) throws SQLException {

        String sql
                = "SELECT 1 "
                + "FROM dbo.UserRoles "
                + "WHERE UserId = ? "
                + "AND RoleCode = 'ADMIN'";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(
                    1,
                    userId
            );

            try (ResultSet result
                    = statement.executeQuery()) {

                return result.next();
            }
        }
    }


    public List<ApprovalCourse>
            findPendingApprovals()
            throws SQLException {

        List<ApprovalCourse> list
                = new ArrayList<>();

        String sql
                = "SELECT "
                + "c.CourseId, "
                + "c.InstructorId, "
                + "c.Title, "
                + "u.FullName AS InstructorName, "
                + "u.Email AS InstructorEmail, "
                + "c.PricingType, "
                + "c.ListPriceVnd, "
                + "c.SalePriceVnd, "
                + "c.ProposedPriceVnd, "
                + "c.Status, "
                + "c.UpdatedAt, "
                + "submitEvent.CreatedAt "
                + "AS SubmittedAt "
                + "FROM dbo.Courses c "
                + "JOIN dbo.Users u "
                + "ON u.UserId = c.InstructorId "
                + "OUTER APPLY ( "
                + "SELECT TOP 1 "
                + "ca.CreatedAt "
                + "FROM dbo.CourseApprovalEvents ca "
                + "WHERE ca.CourseId = c.CourseId "
                + "AND ca.Action = 'SUBMIT' "
                + "ORDER BY ca.EventId DESC "
                + ") submitEvent "
                + "WHERE c.Status = "
                + "'PENDING_APPROVAL' "
                + "ORDER BY "
                + "ISNULL("
                + "submitEvent.CreatedAt, "
                + "c.UpdatedAt"
                + ") ASC, "
                + "c.CourseId ASC";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql);
             ResultSet result
                = statement.executeQuery()) {

            while (result.next()) {

                ApprovalCourse course
                        = new ApprovalCourse();

                course.setCourseId(
                        result.getLong(
                                "CourseId"
                        )
                );

                course.setInstructorId(
                        result.getLong(
                                "InstructorId"
                        )
                );

                course.setTitle(
                        result.getString(
                                "Title"
                        )
                );

                course.setInstructorName(
                        result.getString(
                                "InstructorName"
                        )
                );

                course.setInstructorEmail(
                        result.getString(
                                "InstructorEmail"
                        )
                );

                course.setPricingType(
                        result.getString(
                                "PricingType"
                        )
                );

                course.setListPriceVnd(
                        result.getBigDecimal(
                                "ListPriceVnd"
                        )
                );

                course.setSalePriceVnd(
                        result.getBigDecimal(
                                "SalePriceVnd"
                        )
                );

                course.setProposedPriceVnd(
                        result.getBigDecimal(
                                "ProposedPriceVnd"
                        )
                );

                course.setStatus(
                        result.getString(
                                "Status"
                        )
                );

                course.setSubmittedAt(
                        result.getTimestamp(
                                "SubmittedAt"
                        )
                );

                course.setUpdatedAt(
                        result.getTimestamp(
                                "UpdatedAt"
                        )
                );

                list.add(course);
            }
        }

        return list;
    }
}