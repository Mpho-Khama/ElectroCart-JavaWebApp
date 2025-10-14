package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/EditUserServlet")
public class EditUserServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("user_id"));
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE user_id = ?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                request.setAttribute("user_id", rs.getInt("user_id"));
                request.setAttribute("name", rs.getString("name"));
                request.setAttribute("email", rs.getString("email"));
                request.setAttribute("phone", rs.getString("phone"));
                request.setAttribute("role", rs.getString("role"));
                request.setAttribute("address", rs.getString("address"));
                request.getRequestDispatcher("edit-user.jsp").forward(request, response);
            } else {
                response.sendRedirect("admin-users.jsp?error=User+not+found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-users.jsp?error=" + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("user_id"));
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        String address = request.getParameter("address");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String sql = "UPDATE users SET name=?, email=?, phone=?, role=?, address=? WHERE user_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, role);
            ps.setString(5, address);
            ps.setInt(6, userId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("admin-users.jsp?success=User+updated+successfully");
            } else {
                response.sendRedirect("admin-users.jsp?error=Failed+to+update+user");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-users.jsp?error=" + e.getMessage());
        }
    }
}
