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
        response.sendRedirect("profile.jsp");
        return;
    }

    String orderDate = "";
    String paymentMethod = "";
    String status = "";
    String trackingCode = "";
    double totalAmount = 0.0;

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
                    }
                }
            }

            // Fetch order items with image
            String sqlItems = "SELECT oi.order_item_id, oi.product_id, oi.quantity, oi.price, p.product_name, p.image_path "
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
                        item.put("image_path", rs.getString("image_path"));
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
        body {
            background: #f4f6f9;
            font-family: 'Poppins', sans-serif;
        }
        .container {
            margin-top: 40px;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .order-header {
            border-bottom: 2px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .order-info div {
            margin-bottom: 8px;
        }
        .product-card {
            border: 1px solid #eaeaea;
            border-radius: 10px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: #fff;
        }
        .product-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.12);
            transform: translateY(-4px);
        }
        .product-img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .card-body {
            padding: 15px;
        }
        .card-body h5 {
            font-size: 1.1rem;
            font-weight: 600;
        }
        .card-body p {
            margin: 3px 0;
        }
        .text-end h4 {
            font-weight: 700;
        }
        @media (max-width: 768px) {
            .container {
                margin: 20px;
                padding: 20px;
            }
            .product-img {
                height: 180px;
            }
        }
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
        <div><strong>Tracking Number:</strong> <%= trackingCode != null && !trackingCode.isEmpty() ? trackingCode : "Pending Assignment" %></div>
    </div>

    <hr>

    <h4 class="mt-4 mb-3">Items in this Order</h4>

    <% if (orderItems.isEmpty()) { %>
        <p>No items found for this order.</p>
    <% } else { %>
        <div class="row g-4">
            <% for (Map<String,Object> item : orderItems) { %>
                <div class="col-12 col-sm-6 col-lg-4">
                    <div class="product-card">
                        <%
                            String imgPath = (String) item.get("image_path");
                            if (imgPath == null || imgPath.isEmpty()) {
                                imgPath = "images/no-image.png"; // fallback image
                            }
                        %>
                        <img src="<%= imgPath %>" alt="Product Image" class="product-img">
                        <div class="card-body">
                            <h5><%= item.get("product_name") %></h5>
                            <p>Quantity: <%= item.get("quantity") %></p>
                            <p>Unit Price: M<%= item.get("price") %></p>
                            <h6 class="text-success fw-bold">Total: M<%= (int)item.get("quantity") * (double)item.get("price") %></h6>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>

    <div class="text-end mt-4">
        <h4>Total Amount: <strong>M<%= totalAmount %></strong></h4>
    </div>
</div>
</body>
</html>
