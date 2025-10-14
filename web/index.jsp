<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ElectroCart - Online Electronics Store</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" integrity="sha512-mzVQ3Z3cFzF9euhmGdNRkK5+GeG8bZnM69D9W+RqVxQZQ/qV9QF9+qV5XZ4xI7KZ3SbqFjNnRkX0i4ozXp+jQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin:0;
            background:#f0f2f5;
        }
        header {
            display:flex;
            justify-content: space-between;
            align-items:center;
            padding:10px 20px;
            background:#333;
            color:#fff;
        }
        header h1 { margin:0; }
        nav a {
            color:#fff;
            margin-right:15px;
            text-decoration:none;
            position: relative;
        }
        .cart-count {
            position: absolute;
            top: -8px;
            right: -10px;
            background: #e74c3c;
            color: #fff;
            border-radius: 50%;
            padding: 2px 6px;
            font-size: 0.8rem;
        }
        .auth-buttons a {
            color:#fff;
            margin-left:10px;
            text-decoration:none;
        }
        .search-bar {
            display:flex;
            justify-content:center;
            margin:20px;
        }
        .search-bar input {
            width:50%;
            padding:8px;
            border-radius:4px 0 0 4px;
            border:1px solid #ccc;
        }
        .search-bar button {
            padding:8px 15px;
            border:none;
            background:#27ae60;
            color:#fff;
            border-radius:0 4px 4px 0;
            cursor:pointer;
        }
        .product-grid {
            display:flex;
            flex-wrap:wrap;
            justify-content:center;
            gap:20px;
            margin:20px;
        }
        .product-card {
            width:220px;
            background:#fff;
            padding:15px;
            border-radius:8px;
            box-shadow:0 2px 8px rgba(0,0,0,0.1);
            text-align:center;
            position:relative;
        }
        .product-card img {
            width:100%;
            height:150px;
            object-fit:cover;
            border-radius:6px;
        }
        .product-card h3 {
            margin:10px 0 5px 0;
            font-size:1.1rem;
        }
        .product-card p {
            font-size:0.9rem;
            color:#555;
        }
        .price {
            font-weight:bold;
            margin:10px 0;
        }
        .product-card a {
            text-decoration:none;
            color:#3498db;
            font-size:0.9rem;
            margin-right:5px;
        }
        .success-msg {
            position: fixed;
            top: 10px;
            right: 10px;
            background: #27ae60;
            color: #fff;
            padding: 10px 15px;
            border-radius: 5px;
            display: none;
            z-index: 9999;
        }
        footer {
            text-align:center;
            padding:15px;
            background:#333;
            color:#fff;
            margin-top:30px;
        }
        button { cursor:pointer; }
    </style>
    <script>
        function addToCart(productId) {
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "AddToCartServlet", true);
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhr.onload = function () {
                if (xhr.status === 200) {
                    const msg = document.getElementById("success-msg");
                    msg.innerText = "Item added to cart!";
                    msg.style.display = "block";
                    setTimeout(() => { msg.style.display = "none"; }, 2000);
                    const cartCount = document.getElementById("cart-count");
                    cartCount.innerText = xhr.responseText;
                } else {
                    alert("Failed to add item to cart!");
                }
            };
            xhr.send("product_id=" + productId + "&quantity=1");
        }
    </script>
</head>
<body>

<div id="success-msg" class="success-msg"></div>

<header>
    <h1>ElectroCart</h1>
    <nav>
        
        <a href="index.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="about-us.jsp"><i class="fas fa-info-circle"></i> About Us</a>
        <a href="categories.jsp"><i class="fas fa-th-large"></i> Categories</a>
        <a href="cart.jsp"><i class="fas fa-shopping-cart"></i> Cart <span id="cart-count" class="cart-count">0</span></a>
        <a href="profile.jsp"><i class="fas fa-user"></i> Me</a>
        <a href="track-order.jsp"><i class="fas fa-truck"></i> Track Order</a>
    </nav>
    <div class="auth-buttons">
        <a href="signin.jsp">Sign In</a>
        

    </div>
</header>

<!-- ✅ FIXED SEARCH FORM -->
<form action="index.jsp" method="get" class="search-bar">
    <input type="text" name="search" placeholder="Search for electronics..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
    <button type="submit"><i class="fas fa-search"></i></button>
</form>

<h2 style="margin: 15px;">Featured Products</h2>
<div class="product-grid">
    <%
        String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
        String dbUser = "root";
        String dbPass = "";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String searchQuery = request.getParameter("search");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                ps = conn.prepareStatement("SELECT * FROM products WHERE name LIKE ? OR description LIKE ? ORDER BY created_at DESC");
                ps.setString(1, "%" + searchQuery + "%");
                ps.setString(2, "%" + searchQuery + "%");
            } else {
                ps = conn.prepareStatement("SELECT * FROM products ORDER BY created_at DESC");
            }

            rs = ps.executeQuery();

            boolean hasResults = false;
            while (rs.next()) {
                hasResults = true;
                int id = rs.getInt("product_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                String imageUrl = rs.getString("image_url");
                double price = rs.getDouble("price");
    %>
    <div class="product-card">
        <img src="uploads/<%= imageUrl%>" alt="<%= name%>">
        <h3><%= name%></h3>
        <p><%= description.length() > 50 ? description.substring(0, 50) + "..." : description%></p>
        <div class="price">M <%= price%></div>
        <div>
            <a href="product-details.jsp?id=<%= id%>"><i class="fas fa-eye"></i> View</a>
            <button onclick="addToCart(<%= id%>)" style="background:#27ae60; color:#fff; border:none; padding:6px 10px; border-radius:4px; margin-left:5px;">
                <i class="fas fa-cart-plus"></i> Add to Cart
            </button>
        </div>
    </div>
    <%
            }

            if (!hasResults) {
                out.println("<p style='text-align:center; color:#555;'>No products found.</p>");
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading products: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    %>
</div>

<footer>
    <p>&copy; 2025 ElectroCart. All Rights Reserved.</p>
</footer>

</body>
</html>
