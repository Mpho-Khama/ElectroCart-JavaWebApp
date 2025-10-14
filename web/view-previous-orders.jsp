<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("email") == null) {
        response.sendRedirect("signin.jsp");
        return;
    }

    int userId = (Integer) sess.getAttribute("user_id");
    String userName = (String) sess.getAttribute("userName");
    String userEmail = (String) sess.getAttribute("email");

    String orderIdParam = request.getParameter("order_id");
    int orderId = 0;

    if (orderIdParam != null && !orderIdParam.isEmpty()) {
        orderId = Integer.parseInt(orderIdParam);
    } else {
        // No order_id specified, redirect to profile or orders page
        response.sendRedirect("profile.jsp");
        return;
    }

    String orderDate = "";
    String paymentMethod = "";
    String status = "";
    String trackingCode = "";
    double totalAmount = 0.0;
    String shippingAddress = "";

    List<Map<String, Object>> orderItems = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrocart_db", "root", "")) {

            // Fetch order details
            String sqlOrder = "SELECT * FROM orders WHERE order_id = ? AND user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        orderDate = rs.getString("order_date");
                        paymentMethod = rs.getString("payment_method");
                        status = rs.getString("status");
                        trackingCode = rs.getString("tracking_code");
                        totalAmount = rs.getDouble("total_amount");
                        shippingAddress = rs.getString("shipping_address");
                    }
                }
            }

            // Fetch order items
            // Fetch order items
String sqlItems = "SELECT oi.order_item_id, oi.product_id, oi.quantity, oi.price, p.product_name "
                + "FROM order_items oi "
                + "JOIN products p ON oi.product_id = p.product_id "
                + "WHERE oi.order_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("order_item_id", rs.getInt("order_item_id"));
                        item.put("product_id", rs.getInt("product_id"));
                        item.put("product_name", rs.getString("product_name"));
                        item.put("quantity", rs.getInt("quantity"));
                        item.put("price", rs.getDouble("price"));
                        orderItems.add(item);
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Details - ElectroCart</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { background: #f4f6f9; font-family: 'Poppins', sans-serif; }
        .container { margin-top: 40px; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .order-header { border-bottom: 2px solid #eee; padding-bottom: 15px; margin-bottom: 20px; }
        .order-info div { margin-bottom: 10px; }
        table th, table td { vertical-align: middle; }
        .btn-back { margin-top: 20px; }
    </style>
</head>
<body>
<div class="container">
    <div class="order-header d-flex justify-content-between align-items-center">
        <h2>Order Details</h2>
        <a href="profile.jsp" class="btn btn-secondary btn-sm"><i class="fa fa-arrow-left"></i> Back</a>
    </div>

    <div class="order-info">
        <h5>Order ID: #<%= orderId %></h5>
        <div><strong>Customer Name:</strong> <%= userName != null ? userName : "Guest" %></div>
        <div><strong>Email:</strong> <%= userEmail != null ? userEmail : "" %></div>
        <div><strong>Order Date:</strong> <%= orderDate %></div>
        <div><strong>Payment Method:</strong> <%= paymentMethod %></div>
        <div><strong>Status:</strong> <%= status %></div>
        <div><strong>Shipping Address:</strong> <%= shippingAddress != null ? shippingAddress : "Not provided" %></div>
        <div><strong>Tracking Number:</strong> <%= trackingCode != null && !trackingCode.isEmpty() ? trackingCode : "Pending Assignment" %></div>
    </div>

    <hr>

    <h4 class="mt-4">Items in this Order</h4>
    <% if (orderItems.isEmpty()) { %>
        <p>No items found for this order.</p>
    <% } else { %>
        <table class="table table-striped mt-3">
            <thead class="table-dark">
                <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Unit Price (M)</th>
                    <th>Total (M)</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String,Object> item : orderItems) { %>
                    <tr>
                        <td><%= item.get("product_name") %></td>
                        <td><%= item.get("quantity") %></td>
                        <td><%= item.get("price") %></td>
                        <td><%= (int)item.get("quantity") * (double)item.get("price") %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>

    <div class="text-end mt-4">
        <h4>Total Amount: <strong>M<%= totalAmount %></strong></h4>
    </div>
</div>
</body>
</html>
