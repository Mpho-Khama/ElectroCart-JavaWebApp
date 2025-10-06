package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure driver loads
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

                // Check if email already exists
                PreparedStatement psCheck = conn.prepareStatement("SELECT * FROM users WHERE email=?");
                psCheck.setString(1, email);
                ResultSet rs = psCheck.executeQuery();

                if (rs.next()) {
                    request.setAttribute("error", "Email already registered!");
                    request.getRequestDispatcher("signup.jsp").forward(request, response);
                    return;
                }

                // Hash the password
                String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

                // Insert new user
                String sqlInsert = "INSERT INTO users (name, email, phone, address, password, role) VALUES (?, ?, ?, ?, ?, 'USER')";
                PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
                psInsert.setString(1, name);
                psInsert.setString(2, email);
                psInsert.setString(3, phone);
                psInsert.setString(4, address);
                psInsert.setString(5, hashedPassword);
                psInsert.executeUpdate();

                response.sendRedirect("signin.jsp"); // redirect to login

            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }
}
