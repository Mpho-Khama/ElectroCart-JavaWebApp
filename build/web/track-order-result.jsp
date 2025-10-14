<%@ page import="java.sql.ResultSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Order Details</title>
    <style>
        /* General body styling */
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f6fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        /* Container for order details */
        .order-container {
            background-color: #fff;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            width: 400px;
        }

        h2 {
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }

        p {
            font-size: 16px;
            margin: 10px 0;
            color: #555;
        }

        p strong {
            color: #333;
        }

        .not-found {
            text-align: center;
            color: red;
            font-weight: bold;
            font-size: 18px;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: #007bff;
            font-weight: bold;
            transition: color 0.3s;
        }

        a:hover {
            color: #0056b3;
        }

        /* Responsive for small screens */
        @media (max-width: 450px) {
            .order-container {
                width: 90%;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
<div class="order-container">
<%
    ResultSet order = (ResultSet) request.getAttribute("order");
    if(order != null) {
%>
    <h2>Order Details</h2>
    <p><strong>Order ID:</strong> <%= order.getInt("order_id") %></p>
    <p><strong>User ID:</strong> <%= order.getInt("user_id") != 0 ? order.getInt("user_id") : "Guest" %></p>
    <p><strong>Order Date:</strong> <%= order.getTimestamp("order_date") %></p>
    <p><strong>Status:</strong> <%= order.getString("status") != null ? order.getString("status") : "Pending" %></p>
    <p><strong>Total Amount:</strong> $<%= order.getBigDecimal("total_amount") %></p>
    <p><strong>Payment Method:</strong> <%= order.getString("payment_method") != null ? order.getString("payment_method") : "Not Set" %></p>
    <p><strong>Tracking Code:</strong> <%= order.getString("tracking_code") %></p>
<%
    } else {
%>
    <p class="not-found">Order not found.</p>
<%
    }
%>
    <a href="track-order.jsp">Track Another Order</a>
</div>
</body>
</html>
