<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Payments | ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background:#f5f6fa; margin:0; }
        header { background:#2c3e50; color:#fff; padding:15px 20px; display:flex; justify-content:space-between; align-items:center; }
        header h1 { margin:0; font-size:1.4rem; }
        nav a { color:#fff; margin-right:15px; text-decoration:none; }
        .container { padding:20px; }
        h2 { margin-bottom:15px; }
        table { width:100%; border-collapse:collapse; background:#fff; box-shadow:0 2px 6px rgba(0,0,0,0.1); }
        th, td { padding:10px; border-bottom:1px solid #ddd; text-align:left; }
        th { background:#34495e; color:#fff; }
        tr:hover { background:#f1f1f1; }
        .btn-confirm { background:#27ae60; color:#fff; padding:6px 10px; border:none; border-radius:4px; cursor:pointer; }
        .btn-confirm:hover { background:#219150; }
        .status { padding:5px 10px; border-radius:4px; color:#fff; font-weight:bold; }
        .status.pending { background:#e67e22; }
        .status.confirmed { background:#27ae60; }
        .msg { margin:10px 0; padding:10px; border-radius:5px; }
        .msg.success { background:#27ae60; color:#fff; }
        .msg.error { background:#e74c3c; color:#fff; }
        footer { text-align:center; padding:15px; background:#2c3e50; color:#fff; margin-top:30px; }
    </style>
</head>
<body>

<header>
    <h1>Admin Dashboard - Payments</h1>
    <nav>
        <a href="admin-dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a>
        <a href="admin-reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a>
        <a href="admin-payments.jsp"><i class="fas fa-credit-card"></i> Payments</a>
        <a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<div class="container">
    <h2>Payment Records</h2>

    <% 
        String successMsg = request.getParameter("success");
        String errorMsg = request.getParameter("error");
        if (successMsg != null) {
    %>
        <div class="msg success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
    <% } else if (errorMsg != null) { %>
        <div class="msg error"><i class="fas fa-exclamation-triangle"></i> <%= errorMsg %></div>
    <% } %>

    <table>
        <thead>
            <tr>
                <th>Payment ID</th>
                <th>Order ID</th>
                <th>Amount (M)</th>
                <th>Method</th>
                <th>Status</th>
                <th>Transaction Code</th>
                <th>Created At</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <%
            String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
            String dbUser = "root";
            String dbPass = "";

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM payments ORDER BY created_at DESC");

                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
                    int paymentId = rs.getInt("payment_id");
                    int orderId = rs.getInt("order_id");
                    double amount = rs.getDouble("amount");
                    String method = rs.getString("method");
                    String status = rs.getString("status");
                    String transactionCode = rs.getString("transaction_code");
                    Timestamp createdAt = rs.getTimestamp("created_at");
        %>
            <tr>
                <td><%= paymentId %></td>
                <td><%= orderId %></td>
                <td><%= amount %></td>
                <td><%= method %></td>
                <td><span class="status <%= status != null && status.equalsIgnoreCase("Confirmed") ? "confirmed" : "pending" %>"><%= status %></span></td>
                <td><%= transactionCode != null ? transactionCode : "-" %></td>
                <td><%= createdAt %></td>
                <td>
                    <% if (status != null && status.equalsIgnoreCase("Pending")) { %>
                        <a href="ConfirmPaymentServlet?payment_id=<%= paymentId %>">
                            <button class="btn-confirm"><i class="fas fa-check"></i> Confirm</button>
                        </a>
                    <% } else { %>
                        <span style="color:#27ae60; font-weight:bold;">✓ Confirmed</span>
                    <% } %>
                </td>
            </tr>
        <%
                }
                if (!hasData) {
                    out.println("<tr><td colspan='8' style='text-align:center;'>No payments found.</td></tr>");
                }
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<tr><td colspan='8' style='color:red;'>Error loading payments: " + e.getMessage() + "</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>

<footer>
    <p>&copy; 2025 ElectroCart | Admin Payments Management</p>
</footer>

</body>
</html>
