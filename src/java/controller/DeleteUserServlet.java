package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection details
    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("user_id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("admin-users.jsp?error=Missing+user+ID");
            return;
        }

        try {
            int userId = Integer.parseInt(idStr);
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                String sql = "DELETE FROM users WHERE user_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect("admin-users.jsp?message=User+deleted+successfully");
                    } else {
                        response.sendRedirect("admin-users.jsp?error=User+not+found");
                    }
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-users.jsp?error=Invalid+user+ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-users.jsp?error=Database+error");
        }
    }
}
