package controller;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter("/admin-dashboard.jsp")
public class AdminFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        if (session != null && "ADMIN".equals(session.getAttribute("role"))) {
            chain.doFilter(request, response); // allow access
        } else {
            res.sendRedirect("signin.jsp"); // redirect non-admins
        }
    }
}
