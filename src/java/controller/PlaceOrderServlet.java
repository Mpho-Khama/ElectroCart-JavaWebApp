package controller;

import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "PlaceOrderServlet", urlPatterns = {"/PlaceOrderServlet"})
public class PlaceOrderServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        // 1️⃣ Get cart and validate
        HashMap<Integer, Integer> cart = (HashMap<Integer, Integer>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("cart.jsp?error=Cart+is+empty");
            return;
        }

        // 2️⃣ Get form parameters
        String paymentMethod = request.getParameter("payment_method");
        double totalAmount = Double.parseDouble(request.getParameter("total_amount"));
        String userIdParam = request.getParameter("user_id");
        Integer userId = (userIdParam == null || userIdParam.isEmpty()) ? null : Integer.parseInt(userIdParam);

        // 3️⃣ Load MySQL Driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL Driver not found", e);
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            conn.setAutoCommit(false); // start transaction

            // 4️⃣ Generate tracking code
            String trackingCode = "TRK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            // 5️⃣ Insert order
            String orderSql = "INSERT INTO orders (user_id, order_date, status, total_amount, payment_method, tracking_code) VALUES (?, ?, ?, ?, ?, ?)";
            int orderId;

            try (PreparedStatement psOrder = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                if (userId != null) psOrder.setInt(1, userId);
                else psOrder.setNull(1, Types.INTEGER);

                psOrder.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                psOrder.setString(3, "Pending");
                psOrder.setDouble(4, totalAmount);
                psOrder.setString(5, paymentMethod);
                psOrder.setString(6, trackingCode);

                int affectedRows = psOrder.executeUpdate();
                if (affectedRows == 0) throw new SQLException("Creating order failed, no rows affected.");

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                    else throw new SQLException("Creating order failed, no ID obtained.");
                }
            }

            // 6️⃣ Insert order items
            String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psItem = conn.prepareStatement(itemSql);
                 PreparedStatement psProduct = conn.prepareStatement("SELECT price FROM products WHERE product_id=?")) {

                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    int productId = entry.getKey();
                    int quantity = entry.getValue();

                    psProduct.setInt(1, productId);
                    try (ResultSet rsProduct = psProduct.executeQuery()) {
                        if (rsProduct.next()) {
                            double price = rsProduct.getDouble("price");
                            psItem.setInt(1, orderId);
                            psItem.setInt(2, productId);
                            psItem.setInt(3, quantity);
                            psItem.setDouble(4, price);
                            psItem.addBatch();
                        }
                    }
                }
                psItem.executeBatch();
            }

            conn.commit(); // commit transaction
            session.removeAttribute("cart"); // clear cart

            // 7️⃣ Send confirmation email if exists
            String userEmail = (String) session.getAttribute("email");
            if (userEmail != null && !userEmail.isEmpty()) {
                try {
                    EmailUtil.sendOrderConfirmation(userEmail, orderId, trackingCode, totalAmount);
                } catch (MessagingException me) {
                    me.printStackTrace();
                    System.err.println("⚠️ Failed to send confirmation email: " + me.getMessage());
                }
            }

            // 8️⃣ ✅ Always redirect to checkout-success.jsp
            response.sendRedirect("checkout-success.jsp?order_id=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();
            // Safe redirect without writing to response
            response.sendRedirect("checkout.jsp?error=Something+went+wrong+while+placing+your+order.");
        }
    }
}
