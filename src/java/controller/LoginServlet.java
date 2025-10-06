package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

                String sql = "SELECT * FROM users WHERE email=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String hashedPassword = rs.getString("password");

                    if (BCrypt.checkpw(password, hashedPassword)) {
                        String role = rs.getString("role");

                        HttpSession session = request.getSession();
                        session.setAttribute("email", email);
                        session.setAttribute("role", role);

                        if ("ADMIN".equals(role)) {
                            response.sendRedirect("admin-dashboard.jsp");
                        } else {
                            response.sendRedirect("index.jsp");
                        }
                    } else {
                        request.setAttribute("error", "Invalid email or password");
                        request.getRequestDispatcher("signin.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Invalid email or password");
                    request.getRequestDispatcher("signin.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Database connection problem: " + e.getMessage());
        }
    }
}
