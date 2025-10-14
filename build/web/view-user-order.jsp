<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.format.DateTimeFormatter"%>
<%
    String orderIdParam = request.getParameter("order_id");
    if (orderIdParam == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    int orderId = Integer.parseInt(orderIdParam);

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";

    String userName = "Guest";
    String paymentMethod = "";
    String orderDateStr = "";
    double totalAmount = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // Fetch order info
        String queryOrder = "SELECT user_id, payment_method, order_date FROM orders WHERE order_id=?";
        PreparedStatement psOrder = conn.prepareStatement(queryOrder);
        psOrder.setInt(1, orderId);
        ResultSet rsOrder = psOrder.executeQuery();
        int userId = 0;
        if(rsOrder.next()) {
            userId = rsOrder.getInt("user_id");
            paymentMethod = rsOrder.getString("payment_method");
            Timestamp orderDate = rsOrder.getTimestamp("order_date");
            orderDateStr = orderDate.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }
        rsOrder.close();
        psOrder.close();

        // If the order was placed by a registered user, fetch their username
        if(userId != 0) {
            String queryUser = "SELECT username FROM users WHERE user_id=?";
            PreparedStatement psUser = conn.prepareStatement(queryUser);
            psUser.setInt(1, userId);
            ResultSet rsUser = psUser.executeQuery();
            if(rsUser.next()) userName = rsUser.getString("username");
            rsUser.close();
            psUser.close();
        }

        // Fetch order items
        String queryItems = "SELECT oi.quantity, oi.price, p.name FROM order_items oi " +
                            "JOIN products p ON oi.product_id = p.product_id WHERE oi.order_id=?";
        PreparedStatement psItems = conn.prepareStatement(queryItems);
        psItems.setInt(1, orderId);
        ResultSet rsItems = psItems.executeQuery();

        while(rsItems.next()) {
            int qty = rsItems.getInt("quantity");
            double price = rsItems.getDouble("price");
            totalAmount += price * qty;
        }

        rsItems.close();
        psItems.close();
        conn.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Order - ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background:#f0f2f5; margin:0; text-align:center; }
        main { margin:40px auto; background:#fff; padding:30px; width:60%; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.1); }
        table { width:100%; margin-top:20px; border-collapse: collapse; }
        th, td { padding:10px; border:1px solid #ccc; text-align:center; }
        th { background:#333; color:#fff; }
        a.button { display:inline-block; margin-top:20px; padding:10px 15px; background:#27ae60; color:#fff; text-decoration:none; border-radius:5px; }
    </style>
</head>
<body>
<main>
    <h1>Order Details</h1>
    <p>Order ID: <strong>#<%= orderId %></strong></p>
    <p>Customer: <strong><%= userName %></strong></p>
    <p>Order Date: <strong><%= orderDateStr %></strong></p>
    <p>Payment Method: <strong><%= paymentMethod %></strong></p>

    <h3>Items</h3>
    <table>
        <tr>
            <th>Product</th>
            <th>Quantity</th>
            <th>Price (M)</th>
            <th>Subtotal (M)</th>
        </tr>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                String query = "SELECT oi.quantity, oi.price, p.name FROM order_items oi " +
                               "JOIN products p ON oi.product_id = p.product_id WHERE oi.order_id=?";
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    String pname = rs.getString("name");
                    int qty = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    double subtotal = price * qty;
        %>
        <tr>
            <td><%= pname %></td>
            <td><%= qty %></td>
            <td>M <%= price %></td>
            <td>M <%= subtotal %></td>
        </tr>
        <%
                }
                rs.close();
                ps.close();
                conn.close();
            } catch(Exception e) {
                out.println("<tr><td colspan='4' style='color:red;'>Error: "+e.getMessage()+"</td></tr>");
            }
        %>
        <tr>
            <td colspan="3" style="text-align:right;"><strong>Total:</strong></td>
            <td><strong>M <%= totalAmount %></strong></td>
        </tr>
    </table>

    <a href="index.jsp" class="button"><i class="fas fa-home"></i> Continue Shopping</a>
</main>
</body>
</html>
