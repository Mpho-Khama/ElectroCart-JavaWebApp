package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("admin-products.jsp?error=Missing+product+ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                String sql = "DELETE FROM products WHERE product_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect("admin-products.jsp?success=Product+deleted+successfully");
                    } else {
                        response.sendRedirect("admin-products.jsp?error=Product+not+found");
                    }
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-products.jsp?error=Invalid+product+ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-products.jsp?error=" + e.getMessage());
        }
    }
}
