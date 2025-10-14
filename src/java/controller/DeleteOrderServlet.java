package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteOrderServlet")
public class DeleteOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("order_id");
        int orderId = Integer.parseInt(orderIdStr);

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String sql = "DELETE FROM orders WHERE order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    response.sendRedirect("admin-orders.jsp?success=Order deleted successfully");
                } else {
                    response.sendRedirect("admin-orders.jsp?error=Order not found");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-orders.jsp?error=" + e.getMessage());
        }
    }
}
