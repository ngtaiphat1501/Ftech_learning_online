/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controler;

import dao.DiscussionDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name="DiscussionServlet",urlPatterns={"/discussion"})
public class DiscussionServlet extends HttpServlet {
    private long positiveId(String value) {
        long id=Long.parseLong(value);
        if(id<=0) throw new IllegalArgumentException("Mã không hợp lệ.");
        return id;
    }
    @Override
    protected void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException,IOException {
        HttpSession session=request.getSession(false);
        if(session==null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath()+"/login");return;
        }
        long userId=((Number)session.getAttribute("userId")).longValue();
        if(session.getAttribute("csrfToken")==null) session.setAttribute("csrfToken",UUID.randomUUID().toString());
        try {
            long lessonId=positiveId(request.getParameter("lessonId"));
            DiscussionDAO dao=new DiscussionDAO();
            long courseId=dao.getCourseId(userId,lessonId);
            response.sendRedirect(request.getContextPath()+"/student/learn?courseId="+courseId
                    +"&lessonId="+lessonId+"#lesson-discussion");
        } catch(SecurityException ex) {response.sendError(403,ex.getMessage());
        } catch(IllegalArgumentException ex) {response.sendError(400,ex instanceof NumberFormatException?"Mã hoặc dữ liệu không hợp lệ.":ex.getMessage());
        } catch(SQLException ex) {throw new ServletException("Không thể xử lý dữ liệu.",ex);}
    }

    @Override
    protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException,IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session=request.getSession(false);
        if(session==null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath()+"/login");return;
        }
        long userId=((Number)session.getAttribute("userId")).longValue();
        String token=(String)session.getAttribute("csrfToken");
        if(token==null || !token.equals(request.getParameter("csrfToken"))) {
            response.sendError(403,"Yêu cầu không hợp lệ. Hãy tải lại trang.");return;
        }
        try {
            long lessonId=positiveId(request.getParameter("lessonId"));
            DiscussionDAO dao=new DiscussionDAO();
            String action=request.getParameter("action");
            if("create".equals(action)) {
                String parent=request.getParameter("parentPostId");
                long parentId=parent==null || parent.isBlank()?0:positiveId(parent);
                dao.create(userId,lessonId,parentId,request.getParameter("body"));
            } else if("delete".equals(action)) {
                dao.delete(userId,lessonId,positiveId(request.getParameter("postId")));
            } else {response.sendError(400,"Thao tác không hợp lệ.");return;}
            long courseId=dao.getCourseId(userId,lessonId);
            response.sendRedirect(request.getContextPath()+"/student/learn?courseId="+courseId
                    +"&lessonId="+lessonId+"&discussionSaved=1#lesson-discussion");
        } catch(SecurityException ex) {response.sendError(403,ex.getMessage());
        } catch(IllegalArgumentException ex) {response.sendError(400,ex instanceof NumberFormatException?"Mã hoặc dữ liệu không hợp lệ.":ex.getMessage());
        } catch(SQLException ex) {throw new ServletException("Không thể xử lý dữ liệu.",ex);}
    }
}
