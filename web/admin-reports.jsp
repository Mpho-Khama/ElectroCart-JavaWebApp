<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Reports - ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; margin:0; background:#f0f2f5; }
        header { display:flex; justify-content: space-between; align-items:center; padding:10px 20px; background:#333; color:#fff; }
        header h1 { margin:0; }
        nav a { color:#fff; margin-right:15px; text-decoration:none; }
        h2, h3 { margin:20px; }
        table { width:90%; margin:20px auto; border-collapse:collapse; background:#fff; }
        th, td { padding:10px; border:1px solid #ccc; text-align:left; vertical-align:top; }
        th { background:#333; color:#fff; }
        .low-stock { color:red; font-weight:bold; }
    </style>
</head>
<body>

<header>
    <h1>ElectroCart Admin</h1>
    <nav>
        <a href="admin-dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a>
        <a href="admin-products.jsp"><i class="fas fa-boxes"></i> Products</a>
        <a href="admin-reports.jsp"><i class="fas fa-chart-line"></i> Reports</a>
        <a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<h2>Sales & Inventory Summary</h2>

<%
    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {

            // Total orders
            int totalOrders = 0;
            try (Statement stmt1 = conn.createStatement();
                 ResultSet rsOrders = stmt1.executeQuery("SELECT COUNT(*) AS total_orders FROM orders")) {
                if (rsOrders.next()) totalOrders = rsOrders.getInt("total_orders");
            }

            // Total revenue (completed orders)
            double totalRevenue = 0;
            try (Statement stmt2 = conn.createStatement();
                 ResultSet rsRevenue = stmt2.executeQuery("SELECT SUM(total_amount) AS total_revenue FROM orders WHERE status='Completed'")) {
                if (rsRevenue.next()) totalRevenue = rsRevenue.getDouble("total_revenue");
            }

            // Low stock alerts (stock_qty < 5)
            try (Statement stmt3 = conn.createStatement();
                 ResultSet rsLowStock = stmt3.executeQuery("SELECT name, stock_qty FROM products WHERE stock_qty < 5")) {
%>
<table>
    <tr><th>Total Orders</th><td><%= totalOrders %></td></tr>
    <tr><th>Total Revenue (M)</th><td>M <%= totalRevenue %></td></tr>
</table>

<h3 style="text-align:center;">Low Stock Alerts</h3>
<table>
    <tr><th>Product Name</th><th>Quantity Left</th></tr>
<%
        boolean hasLowStock = false;
        while (rsLowStock.next()) {
            hasLowStock = true;
%>
    <tr>
        <td><%= rsLowStock.getString("name") %></td>
        <td class="low-stock"><%= rsLowStock.getInt("stock_qty") %></td>
    </tr>
<%
        }
        if (!hasLowStock) {
%>
    <tr><td colspan="2" style="text-align:center;">No low stock products!</td></tr>
<%
        }
%>
</table>
<%
            }

            // Detailed Orders Report
%>
<h3 style="margin:20px; text-align:center;">Detailed Orders Report</h3>
<table>
    <tr>
        <th>Order ID</th>
        <th>User ID</th>
        <th>Order Date</th>
        <th>Status</th>
        <th>Total Amount (M)</th>
        <th>Items</th>
    </tr>
<%
            try (Statement stmtOrders = conn.createStatement();
                 ResultSet rsAllOrders = stmtOrders.executeQuery("SELECT * FROM orders ORDER BY order_date DESC")) {

                while (rsAllOrders.next()) {
                    int orderId = rsAllOrders.getInt("order_id");
                    Integer uid = rsAllOrders.getInt("user_id");
                    String status = rsAllOrders.getString("status");
                    double total = rsAllOrders.getDouble("total_amount");
                    Timestamp orderDate = rsAllOrders.getTimestamp("order_date");

                    // Get items for this order
                    StringBuilder itemsList = new StringBuilder();
                    try (PreparedStatement psItems = conn.prepareStatement(
                            "SELECT p.name, oi.quantity FROM order_items oi " +
                            "JOIN products p ON oi.product_id = p.product_id " +
                            "WHERE oi.order_id = ?")) {
                        psItems.setInt(1, orderId);
                        try (ResultSet rsItems = psItems.executeQuery()) {
                            while (rsItems.next()) {
                                String productName = rsItems.getString("name");
                                int qty = rsItems.getInt("quantity");
                                itemsList.append(productName).append(" (x").append(qty).append(")<br>");
                            }
                        }
                    }
%>
    <tr>
        <td><%= orderId %></td>
        <td><%= uid %></td>
        <td><%= orderDate %></td>
        <td><%= status %></td>
        <td>M <%= total %></td>
        <td><%= itemsList.toString() %></td>
    </tr>
<%
                }
            } catch (Exception e) {
%>
    <tr><td colspan="6" style="color:red;">Error loading detailed orders: <%= e.getMessage() %></td></tr>
<%
            }

        }
    } catch (Exception e) {
%>
<p style="color:red; text-align:center;">Database connection error: <%= e.getMessage() %></p>
<%
    }
%>
</table>

</body>
</html>
