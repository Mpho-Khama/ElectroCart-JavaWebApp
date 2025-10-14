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

                String sql = "SELECT * FROM users WHERE email = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    String role = rs.getString("role");
                    String name = rs.getString("name"); // fetch name from DB

                    if (BCrypt.checkpw(password, hashedPassword)) {
                        // Create session and store attributes
                        HttpSession session = request.getSession(true);
                        session.setAttribute("user_id", rs.getInt("user_id"));
                        session.setAttribute("userName", name);  // store name for both admin & user
                        session.setAttribute("email", email);
                        session.setAttribute("role", role);

                        // Optional: keep old adminUser key for backward compatibility
                        if ("ADMIN".equalsIgnoreCase(role)) {
                            session.setAttribute("adminUser", name);
                            response.sendRedirect("admin-dashboard.jsp");
                        } else {
                            response.sendRedirect("profile.jsp");
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
