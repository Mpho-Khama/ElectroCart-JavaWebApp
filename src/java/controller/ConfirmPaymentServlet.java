package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

@WebServlet(name = "ConfirmPaymentServlet", urlPatterns = {"/ConfirmPaymentServlet"})
public class ConfirmPaymentServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String paymentIdParam = request.getParameter("payment_id");
        if (paymentIdParam == null || paymentIdParam.isEmpty()) {
            response.sendRedirect("admin-payments.jsp?error=Invalid+payment+ID");
            return;
        }

        int paymentId = Integer.parseInt(paymentIdParam);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL Driver not found", e);
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            conn.setAutoCommit(false);

            // 1️⃣ Update payment status to Confirmed
            String updatePaymentSql = "UPDATE payments SET status='Confirmed' WHERE payment_id=?";
            try (PreparedStatement ps = conn.prepareStatement(updatePaymentSql)) {
                ps.setInt(1, paymentId);
                ps.executeUpdate();
            }

            // 2️⃣ Optionally, update corresponding order status to Completed
            String updateOrderSql = "UPDATE orders o " +
                    "JOIN payments p ON o.order_id = p.order_id " +
                    "SET o.status='Completed' " +
                    "WHERE p.payment_id=?";
            try (PreparedStatement psOrder = conn.prepareStatement(updateOrderSql)) {
                psOrder.setInt(1, paymentId);
                psOrder.executeUpdate();
            }

            conn.commit();

            // Redirect back to payments page with success message
            response.sendRedirect("admin-payments.jsp?success=Payment+confirmed");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-payments.jsp?error=Failed+to+confirm+payment");
        }
    }
}
