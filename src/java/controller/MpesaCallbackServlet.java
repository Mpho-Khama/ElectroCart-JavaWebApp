package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/MpesaCallbackServlet")
public class MpesaCallbackServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Read the callback JSON body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        try {
            // ✅ Parse JSON callback data
            JSONObject callbackData = new JSONObject(sb.toString());
            String reference = callbackData.getString("reference"); // e.g. ORDER-123
            String status = callbackData.getString("status");       // SUCCESS / FAILED

            int orderId = Integer.parseInt(reference.split("-")[1]);

            if ("SUCCESS".equalsIgnoreCase(status)) {
                markOrderPaid(orderId);
                sendConfirmationEmail(orderId);
            } else {
                markOrderFailed(orderId);
            }

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void markOrderPaid(int orderId) {
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/electrocart_db", "root", "")) {

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET status='Paid', payment_method='M-PESA' WHERE order_id=?"
            );
            ps.setInt(1, orderId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void markOrderFailed(int orderId) {
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/electrocart_db", "root", "")) {

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET status='Payment Failed' WHERE order_id=?"
            );
            ps.setInt(1, orderId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void sendConfirmationEmail(int orderId) {
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/electrocart_db", "root", "")) {

            PreparedStatement ps = conn.prepareStatement(
                "SELECT u.email, o.tracking_code, o.total_amount " +
                "FROM users u JOIN orders o ON u.user_id = o.user_id " +
                "WHERE o.order_id = ?"
            );
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String email = rs.getString("email");
                String trackingCode = rs.getString("tracking_code");
                double totalAmount = rs.getDouble("total_amount");

                EmailUtil.sendOrderConfirmation(email, orderId, trackingCode, totalAmount);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
