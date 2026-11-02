package controler;

import dao.ApprovalDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.ApprovalCourse;

@WebServlet(
        name = "ApprovalServlet",
        urlPatterns = {"/admin/approvals"}
)
public class ApprovalServlet
        extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("userId")
                == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        long userId
                = ((Number) session
                        .getAttribute("userId"))
                        .longValue();

        try {

            ApprovalDAO dao
                    = new ApprovalDAO();

            if (!dao.isAdmin(userId)) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/"
                );

                return;
            }

            List<ApprovalCourse> courses
                    = dao.findPendingApprovals();

            request.setAttribute(
                    "courses",
                    courses
            );

            request.getRequestDispatcher(
                    "/WEB-INF/view/admin/approvals.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the tai danh sach khoa cho duyet",
                    ex
            );
        }
    }
}