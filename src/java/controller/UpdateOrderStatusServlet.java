package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import controller.EmailUtil;
import jakarta.mail.MessagingException;

@WebServlet(name = "UpdateOrderStatusServlet", urlPatterns = {"/UpdateOrderStatusServlet"})
public class UpdateOrderStatusServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("order_id"));
        String newStatus = request.getParameter("status");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            // ✅ Get user's email & tracking code first
            String email = null;
            String trackingCode = null;
            String emailQuery = "SELECT u.email, o.tracking_code FROM orders o JOIN users u ON o.user_id = u.user_id WHERE o.order_id=?";

            try (PreparedStatement ps = conn.prepareStatement(emailQuery)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        email = rs.getString("email");
                        trackingCode = rs.getString("tracking_code");
                    }
                }
            }

            // ✅ Update status
            String updateSql = "UPDATE orders SET status=? WHERE order_id=?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, orderId);
                ps.executeUpdate();
            }

            // ✅ Send email notification if email exists
            if (email != null) {
                try {
                    EmailUtil.sendStatusUpdate(email, orderId, newStatus, trackingCode);
                } catch (MessagingException me) {
                    me.printStackTrace();
                    System.err.println("⚠️ Failed to send status update email: " + me.getMessage());
                }
            }

            response.sendRedirect("admin-orders.jsp?message=Order+status+updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-orders.jsp?error=" + e.getMessage());
        }
    }
}
