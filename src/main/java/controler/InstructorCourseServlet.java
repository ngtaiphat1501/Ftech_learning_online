package controler;

import dao.CategoryDAO;
import dao.CourseDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import model.Category;
import model.Course;

@WebServlet(
        name = "InstructorCourseServlet",
        urlPatterns = {
            "/instructor/courses",
            "/instructor/course"
        }
)
public class InstructorCourseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long instructorId
                = ((Number) session.getAttribute("userId")).longValue();

        String view = request.getParameter("view");

        try {
            CourseDAO dao = new CourseDAO();

            if ("create".equals(view)) {

                request.setAttribute(
                        "categories",
                        new CategoryDAO().getList()
                );

                request.getRequestDispatcher(
                        "/WEB-INF/view/instructor/create.jsp"
                ).forward(request, response);

                return;
            }
            if ("edit".equals(view)) {

                String idText = request.getParameter("id");

                if (idText == null || idText.isBlank()) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST
                    );
                    return;
                }

                long courseId = Long.parseLong(idText);

                Course course
                        = dao.getByIdForInstructor(
                                courseId,
                                instructorId
                        );

                if (course == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND
                    );
                    return;
                }

                if (!"DRAFT".equals(course.getStatus())) {
                    response.sendError(
                            HttpServletResponse.SC_CONFLICT,
                            "Chi khoa hoc DRAFT moi duoc sua"
                    );
                    return;
                }

                request.setAttribute(
                        "course",
                        course
                );

                request.setAttribute(
                        "categories",
                        new CategoryDAO().getList()
                );

                request.getRequestDispatcher(
                        "/WEB-INF/view/instructor/edit.jsp"
                ).forward(request, response);

                return;
            }

            List<Course> courses
                    = dao.getByInstructorId(instructorId);

            BigDecimal totalRevenue = BigDecimal.ZERO;
            int totalStudents = 0;
            int publishedCount = 0;

            if (courses != null) {
                for (Course c : courses) {
                    if (c.getRevenueVnd() != null) {
                        totalRevenue = totalRevenue.add(c.getRevenueVnd());
                    }
                    totalStudents += c.getEnrollmentCount();
                    if ("PUBLISHED".equalsIgnoreCase(c.getStatus())) {
                        publishedCount++;
                    }
                }
            }

            BigDecimal balanceVnd = BigDecimal.ZERO;
            try {
                dao.UserDAO userDAO = new dao.UserDAO();
                model.User instructorUser = userDAO.findById(instructorId);
                if (instructorUser != null && instructorUser.getBalanceVnd() != null) {
                    balanceVnd = instructorUser.getBalanceVnd();
                }
            } catch (Exception ignored) {
            }

            request.setAttribute("courses", courses);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("publishedCount", publishedCount);
            request.setAttribute("balanceVnd", balanceVnd);

            request.getRequestDispatcher(
                    "/WEB-INF/view/instructor/courses.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the tai khoa hoc",
                    ex
            );

        } catch (NumberFormatException ex) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long instructorId
                = ((Number) session.getAttribute("userId")).longValue();

        String action = request.getParameter("action");

        try {

            CourseDAO dao = new CourseDAO();

            if ("create".equals(action)) {

                String categoryIdText
                        = request.getParameter("categoryId");

                String slug
                        = request.getParameter("slug");

                String title
                        = request.getParameter("title");

                String description
                        = request.getParameter("description");

                String pricingType
                        = request.getParameter("pricingType");

                String listPriceText
                        = request.getParameter("listPriceVnd");

                String salePriceText
                        = request.getParameter("salePriceVnd");

                if (categoryIdText == null
                        || categoryIdText.isBlank()
                        || slug == null
                        || slug.isBlank()
                        || title == null
                        || title.isBlank()
                        || description == null
                        || description.isBlank()
                        || pricingType == null
                        || pricingType.isBlank()) {

                    throw new IllegalArgumentException(
                            "Vui long nhap day du thong tin"
                    );
                }

                long categoryId
                        = Long.parseLong(categoryIdText);

                Category category
                        = new CategoryDAO().getById(categoryId);

                if (category == null || !category.isActive()) {
                    throw new IllegalArgumentException(
                            "Danh muc khong ton tai hoac da bi an"
                    );
                }

                BigDecimal listPrice;

                if ("FREE".equals(pricingType)) {
                    listPrice = BigDecimal.ZERO;
                } else {

                    if (listPriceText == null
                            || listPriceText.isBlank()) {

                        throw new IllegalArgumentException(
                                "Vui long nhap gia khoa hoc"
                        );
                    }

                    listPrice
                            = new BigDecimal(listPriceText);
                }

                BigDecimal salePrice = null;

                if (salePriceText != null
                        && !salePriceText.isBlank()) {

                    salePrice
                            = new BigDecimal(salePriceText);
                }

                Course course = new Course();

                course.setInstructorId(instructorId);
                course.setCategoryId(categoryId);
                course.setSlug(slug);
                course.setTitle(title);
                course.setDescription(description);
                course.setPricingType(pricingType);
                course.setListPrice(listPrice);
                course.setSalePrice(salePrice);
                course.setStatus("DRAFT");

                dao.createCourse(course);

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }
            if ("edit".equals(action)) {

                String courseIdText
                        = request.getParameter("courseId");

                String categoryIdText
                        = request.getParameter("categoryId");

                String slug
                        = request.getParameter("slug");

                String title
                        = request.getParameter("title");

                String description
                        = request.getParameter("description");

                String pricingType
                        = request.getParameter("pricingType");

                String listPriceText
                        = request.getParameter("listPriceVnd");

                String salePriceText
                        = request.getParameter("salePriceVnd");

                if (courseIdText == null
                        || courseIdText.isBlank()
                        || categoryIdText == null
                        || categoryIdText.isBlank()
                        || slug == null
                        || slug.isBlank()
                        || title == null
                        || title.isBlank()
                        || description == null
                        || description.isBlank()
                        || pricingType == null
                        || pricingType.isBlank()) {

                    throw new IllegalArgumentException(
                            "Vui long nhap day du thong tin"
                    );
                }

                if (!"FREE".equals(pricingType)
                        && !"PAID".equals(pricingType)) {

                    throw new IllegalArgumentException(
                            "Hinh thuc gia khong hop le"
                    );
                }

                long courseId
                        = Long.parseLong(courseIdText);

                long categoryId
                        = Long.parseLong(categoryIdText);

                Category category
                        = new CategoryDAO().getById(categoryId);

                if (category == null || !category.isActive()) {
                    throw new IllegalArgumentException(
                            "Danh muc khong ton tai hoac da bi an"
                    );
                }

                BigDecimal listPrice;

                BigDecimal salePrice = null;

                if ("FREE".equals(pricingType)) {

                    listPrice = BigDecimal.ZERO;

                } else {

                    if (listPriceText == null
                            || listPriceText.isBlank()) {

                        throw new IllegalArgumentException(
                                "Vui long nhap gia khoa hoc"
                        );
                    }

                    listPrice
                            = new BigDecimal(listPriceText);

                    if (listPrice.compareTo(
                            BigDecimal.ZERO
                    ) <= 0) {

                        throw new IllegalArgumentException(
                                "Gia khoa hoc phai lon hon 0"
                        );
                    }

                    if (salePriceText != null
                            && !salePriceText.isBlank()) {

                        salePrice
                                = new BigDecimal(salePriceText);

                        if (salePrice.compareTo(
                                BigDecimal.ZERO
                        ) < 0
                                || salePrice.compareTo(
                                        listPrice
                                ) > 0) {

                            throw new IllegalArgumentException(
                                    "Gia uu dai khong hop le"
                            );
                        }
                    }
                }

                Course course
                        = new Course();

                course.setId(courseId);
                course.setInstructorId(instructorId);
                course.setCategoryId(categoryId);
                course.setSlug(slug);
                course.setTitle(title);
                course.setDescription(description);
                course.setPricingType(pricingType);
                course.setListPrice(listPrice);
                course.setSalePrice(salePrice);

                boolean updated
                        = dao.updateCourse(course);

                if (!updated) {

                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Khong the sua khoa hoc nay"
                    );

                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }
            if ("archive".equals(action)) {

                String courseIdText
                        = request.getParameter("courseId");

                if (courseIdText == null
                        || courseIdText.isBlank()) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST
                    );

                    return;
                }

                long courseId
                        = Long.parseLong(courseIdText);

                boolean archived
                        = dao.archiveCourse(
                                courseId,
                                instructorId
                        );

                if (!archived) {

                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Khong the luu tru khoa hoc nay"
                    );

                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }
            if ("reopen".equals(action)) {

                String courseIdText
                        = request.getParameter("courseId");

                if (courseIdText == null
                        || courseIdText.isBlank()) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST
                    );

                    return;
                }

                long courseId
                        = Long.parseLong(courseIdText);

                boolean reopened
                        = dao.reopenCourse(
                                courseId,
                                instructorId
                        );

                if (!reopened) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/instructor/courses?error=reopen"
                    );

                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/instructor/courses"
                );

                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/instructor/courses"
            );

        } catch (SQLException ex) {

            throw new ServletException(
                    "Khong the xu ly khoa hoc",
                    ex
            );

        } catch (NumberFormatException ex) {

            throw new ServletException(
                    "Du lieu so khong hop le",
                    ex
            );

        } catch (IllegalArgumentException ex) {

            request.setAttribute(
                    "error",
                    ex.getMessage()
            );

            try {
                request.setAttribute(
                        "categories",
                        new CategoryDAO().getList()
                );
            } catch (SQLException sqlEx) {
                throw new ServletException(
                        "Khong the tai danh muc",
                        sqlEx
                );
            }

            request.getRequestDispatcher(
                    "/WEB-INF/view/instructor/create.jsp"
            ).forward(request, response);
        }
    }
}
