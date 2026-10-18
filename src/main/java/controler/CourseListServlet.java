/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.CategoryDAO;
import dao.CourseDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CourseListServlet", urlPatterns = {"/courses"})
public class CourseListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String categoryValue = request.getParameter("categoryId");
        String pricingType = request.getParameter("pricingType");

        if (keyword == null) {
            keyword = "";
        }

        keyword = keyword.trim();

        if (pricingType == null) {
            pricingType = "";
        }

        if (!pricingType.isEmpty()
                && !"FREE".equals(pricingType)
                && !"PAID".equals(pricingType)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Học phí không hợp lệ."
            );
            return;
        }

        long categoryId = 0;

        if (categoryValue != null && !categoryValue.isEmpty()) {
            try {
                categoryId = Long.parseLong(categoryValue);

                if (categoryId < 0) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Danh mục không hợp lệ."
                    );
                    return;
                }
            } catch (NumberFormatException ex) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Danh mục không hợp lệ."
                );
                return;
            }
        }

        try {
            CourseDAO courseDAO = new CourseDAO();
            CategoryDAO categoryDAO = new CategoryDAO();

            request.setAttribute(
                    "list",
                    courseDAO.getList(keyword, categoryId, pricingType)
            );

            request.setAttribute("categories", categoryDAO.getList());
            request.setAttribute("keyword", keyword);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("pricingType", pricingType);
            request.setAttribute("pageTitle", "Khám phá khóa học");
            request.setAttribute("activeMenu", "courses");

            request.getRequestDispatcher(
                    "/WEB-INF/view/public/courses.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(
                    "Không thể tải danh sách khóa học.", ex
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}