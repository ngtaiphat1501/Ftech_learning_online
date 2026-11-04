package dao;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.InstructorStudentProgress;

public class InstructorStudentDAO {

    public List<InstructorStudentProgress>
            findByCourse(
                    long courseId,
                    long instructorId
            ) throws SQLException {

        List<InstructorStudentProgress> list
                = new ArrayList<>();

        String sql
                = "SELECT "
                + "p.EnrollmentId, "
                + "p.StudentId, "
                + "p.CourseId, "
                + "u.FullName, "
                + "u.Email, "
                + "p.AccessStatus, "
                + "p.EnrolledAt, "
                + "p.CompletedAt, "
                + "p.TotalRequiredLessons, "
                + "p.CompletedRequiredLessons, "
                + "p.ProgressPercent, "
                + "p.TotalRequiredQuizzes, "
                + "p.PassedRequiredQuizzes, "
                + "p.IsEligibleForCompletion "
                + "FROM dbo.vEnrollmentProgress p "
                + "JOIN dbo.Users u "
                + "ON u.UserId = p.StudentId "
                + "JOIN dbo.Courses c "
                + "ON c.CourseId = p.CourseId "
                + "WHERE p.CourseId = ? "
                + "AND c.InstructorId = ? "
                + "ORDER BY p.EnrolledAt DESC";

        try (Connection connection
                = DBContext.getConnection();
             PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setLong(
                    1,
                    courseId
            );

            statement.setLong(
                    2,
                    instructorId
            );

            try (ResultSet result
                    = statement.executeQuery()) {

                while (result.next()) {

                    InstructorStudentProgress student
                            = new InstructorStudentProgress();

                    student.setEnrollmentId(
                            result.getLong(
                                    "EnrollmentId"
                            )
                    );

                    student.setStudentId(
                            result.getLong(
                                    "StudentId"
                            )
                    );

                    student.setCourseId(
                            result.getLong(
                                    "CourseId"
                            )
                    );

                    student.setFullName(
                            result.getString(
                                    "FullName"
                            )
                    );

                    student.setEmail(
                            result.getString(
                                    "Email"
                            )
                    );

                    student.setAccessStatus(
                            result.getString(
                                    "AccessStatus"
                            )
                    );

                    student.setEnrolledAt(
                            result.getTimestamp(
                                    "EnrolledAt"
                            )
                    );

                    student.setCompletedAt(
                            result.getTimestamp(
                                    "CompletedAt"
                            )
                    );

                    student.setTotalRequiredLessons(
                            result.getInt(
                                    "TotalRequiredLessons"
                            )
                    );

                    student.setCompletedRequiredLessons(
                            result.getInt(
                                    "CompletedRequiredLessons"
                            )
                    );

                    student.setProgressPercent(
                            result.getBigDecimal(
                                    "ProgressPercent"
                            )
                    );

                    student.setTotalRequiredQuizzes(
                            result.getInt(
                                    "TotalRequiredQuizzes"
                            )
                    );

                    student.setPassedRequiredQuizzes(
                            result.getInt(
                                    "PassedRequiredQuizzes"
                            )
                    );

                    student.setEligibleForCompletion(
                            result.getBoolean(
                                    "IsEligibleForCompletion"
                            )
                    );

                    list.add(student);
                }
            }
        }

        return list;
    }
}