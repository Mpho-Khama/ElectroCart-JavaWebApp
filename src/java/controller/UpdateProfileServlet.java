package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("signin.jsp");
            return;
        }

        String currentEmail = (String) session.getAttribute("email");
        String newName = request.getParameter("name").trim();
        String newEmail = request.getParameter("email").trim();
        String newPassword = request.getParameter("password").trim();

        if (newName.isEmpty() || newEmail.isEmpty()) {
            session.setAttribute("profileError", "Name and Email cannot be empty");
            response.sendRedirect("profile.jsp");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

                // Check if the new email is already used by another user
                if (!newEmail.equalsIgnoreCase(currentEmail)) {
                    String checkSql = "SELECT * FROM users WHERE email = ?";
                    PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                    checkStmt.setString(1, newEmail);
                    ResultSet rs = checkStmt.executeQuery();
                    if (rs.next()) {
                        session.setAttribute("profileError", "Email is already in use");
                        response.sendRedirect("profile.jsp");
                        return;
                    }
                }

                // Update query
                String updateSql;
                if (newPassword.isEmpty()) {
                    // Update only name and email
                    updateSql = "UPDATE users SET name = ?, email = ? WHERE email = ?";
                } else {
                    // Hash the new password
                    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
                    updateSql = "UPDATE users SET name = ?, email = ?, password = ? WHERE email = ?";
                }

                PreparedStatement updateStmt = conn.prepareStatement(updateSql);

                if (newPassword.isEmpty()) {
                    updateStmt.setString(1, newName);
                    updateStmt.setString(2, newEmail);
                    updateStmt.setString(3, currentEmail);
                } else {
                    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
                    updateStmt.setString(1, newName);
                    updateStmt.setString(2, newEmail);
                    updateStmt.setString(3, hashedPassword);
                    updateStmt.setString(4, currentEmail);
                }

                int updatedRows = updateStmt.executeUpdate();
                if (updatedRows > 0) {
                    // Update session attributes
                    session.setAttribute("userName", newName);
                    session.setAttribute("email", newEmail);
                    session.setAttribute("profileSuccess", "Profile updated successfully");
                } else {
                    session.setAttribute("profileError", "Failed to update profile");
                }

                response.sendRedirect("profile.jsp");

            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("profileError", "Database error: " + e.getMessage());
            response.sendRedirect("profile.jsp");
        }
    }
}
