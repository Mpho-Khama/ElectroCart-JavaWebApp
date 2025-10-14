<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, jakarta.servlet.http.HttpSession"%>
<%@ page import="java.sql.*" %>
<%

    HashMap<Integer, Integer> cart = (HashMap<Integer, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ElectroCart - Your Cart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; margin:0; background:#f0f2f5; }
        header { display:flex; justify-content: space-between; align-items:center; padding:10px 20px; background:#333; color:#fff; }
        header h1 { margin:0; }
        nav a { color:#fff; margin-right:15px; text-decoration:none; }
        table { width:90%; margin:20px auto; border-collapse: collapse; background:#fff; }
        th, td { padding:10px; border:1px solid #ccc; text-align:center; }
        th { background:#333; color:#fff; }
        img { width:70px; height:70px; object-fit:cover; border-radius:4px; }
        .remove-btn { background:#e74c3c; color:#fff; border:none; padding:5px 10px; cursor:pointer; border-radius:4px; }
        .success-msg { text-align:center; color:green; margin-top:10px; }
        .checkout-btn { padding:10px 20px; background:#27ae60; color:#fff; border:none; border-radius:5px; font-size:1rem; cursor:pointer; }
    </style>
    <script>
        function removeFromCart(productId) {
            if (!confirm("Remove this item from cart?")) return;
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "RemoveFromCartServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onload = function() {
                if (xhr.status === 200) {
                    document.getElementById("cart-msg").innerText = "Item removed successfully!";
                    document.getElementById("cart-container").innerHTML = xhr.responseText;
                } else {
                    alert("Failed to remove item.");
                }
            };
            xhr.send("product_id=" + productId);
        }
    </script>
</head>
<body>

<header>
    <h1>ElectroCart</h1>
    <nav>
        <a href="index.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="categories.jsp"><i class="fas fa-th-large"></i> Categories</a>
        <a href="cart.jsp"><i class="fas fa-shopping-cart"></i> Cart</a>
    </nav>
</header>

<div class="success-msg" id="cart-msg"></div>

<div id="cart-container">
<%
    if (cart.isEmpty()) {
%>
    <p style="text-align:center; margin-top:20px;">Your cart is empty.</p>
<%
    } else {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            String query = "SELECT * FROM products WHERE product_id = ?";
%>
    <table>
        <tr>
            <th>Image</th>
            <th>Name</th>
            <th>Price (M)</th>
            <th>Quantity</th>
            <th>Subtotal (M)</th>
            <th>Action</th>
        </tr>
<%
            double total = 0;
            PreparedStatement ps = conn.prepareStatement(query);
            for (Map.Entry<Integer,Integer> entry : cart.entrySet()) {
                int productId = entry.getKey();
                int quantity = entry.getValue();
                ps.setInt(1, productId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String name = rs.getString("name");
                    String imageUrl = rs.getString("image_url");
                    double price = rs.getDouble("price");
                    double subtotal = price * quantity;
                    total += subtotal;
%>
        <tr>
            <td><img src="uploads/<%= imageUrl %>" alt="<%= name %>"></td>
            <td><%= name %></td>
            <td>M <%= price %></td>
            <td><%= quantity %></td>
            <td>M <%= subtotal %></td>
            <td><button class="remove-btn" onclick="removeFromCart(<%= productId %>)">Remove</button></td>
        </tr>
<%
                }
                rs.close();
            }
            ps.close();
            conn.close();
%>
        <tr>
            <td colspan="4" style="text-align:right;"><strong>Total:</strong></td>
            <td colspan="2"><strong>M <%= total %></strong></td>
        </tr>
    </table>

    <!-- Checkout Button -->
    <div style="text-align:center; margin:20px 0;">
        <form action="checkout.jsp" method="get">
            <input type="hidden" name="total_amount" value="<%= total %>">
            <button type="submit" class="checkout-btn">
                <i class="fas fa-credit-card"></i> Proceed to Checkout
            </button>
        </form>
    </div>
<%
        } catch(Exception e) {
            out.println("<p style='color:red; text-align:center;'>Error loading cart: " + e.getMessage() + "</p>");
        }
    }
%>
</div>

</body>
</html>
