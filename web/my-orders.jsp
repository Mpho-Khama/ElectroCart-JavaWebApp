<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, jakarta.servlet.http.HttpSession" %>

<%
    
    Integer userId = (Integer) session.getAttribute("user_id");

    if (userId == null) {
        response.sendRedirect("signin.jsp");
        return;
    }

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Orders | ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background:#f0f2f5; padding:20px; }
        table { width:90%; margin:20px auto; border-collapse: collapse; background:#fff; }
        th, td { padding:10px; border:1px solid #ccc; text-align:center; }
        th { background:#333; color:#fff; }
        h2 { text-align:center; margin-top:20px; }
        .view-btn { padding:5px 8px; background:#3498db; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    </style>
</head>
<body>

<h2>My Orders</h2>

<table>
    <thead>
        <tr>
            <th>Order ID</th>
            <th>Order Date</th>
            <th>Status</th>
            <th>Total Amount (M)</th>
            <th>Payment Method</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

                String sql = "SELECT order_id, order_date, status, total_amount, payment_method " +
                             "FROM orders WHERE user_id = ? ORDER BY order_date DESC";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, userId);
                rs = ps.executeQuery();

                while(rs.next()) {
                    int orderId = rs.getInt("order_id");
                    Timestamp orderDate = rs.getTimestamp("order_date");
                    String status = rs.getString("status");
                    double total = rs.getDouble("total_amount");
                    String payment = rs.getString("payment_method");
        %>
        <tr>
            <td><%= orderId %></td>
            <td><%= orderDate %></td>
            <td><%= status %></td>
            <td>M <%= total %></td>
            <td><%= payment %></td>
            <td>
                <form action="ViewUserOrderServlet" method="get" style="display:inline;">
                    <input type="hidden" name="order_id" value="<%= orderId %>">
                    <button type="submit" class="view-btn"><i class="fa fa-eye"></i> View</button>
                </form>
            </td>
        </tr>
        <%
                }
            } catch(Exception e) {
                out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
                if(conn != null) conn.close();
            }
        %>
    </tbody>
</table>

</body>
</html>
