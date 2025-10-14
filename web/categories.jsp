<%-- 
    Document   : categories
    Created on : 7 Oct 2025, 07:26:28
    Author     : Mpho Khama
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Browse Categories - ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; margin:0; background:#f0f2f5; }
        header { display:flex; justify-content: space-between; align-items:center; padding:10px 20px; background:#333; color:#fff; }
        header h1 { margin:0; }
        nav a { color:#fff; margin-right:15px; text-decoration:none; position: relative; }
        .cart-count { position: absolute; top: -8px; right: -10px; background: #e74c3c; color: #fff; border-radius: 50%; padding: 2px 6px; font-size: 0.8rem; }
        .filters { display:flex; justify-content:space-between; flex-wrap:wrap; margin:20px; background:#fff; padding:15px; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.1); }
        .filters form { display:flex; gap:10px; flex-wrap:wrap; }
        .filters select, .filters input[type="number"], .filters input[type="text"] {
            padding:8px;
            border:1px solid #ccc;
            border-radius:4px;
        }
        .filters button { background:#27ae60; color:#fff; border:none; padding:8px 15px; border-radius:4px; cursor:pointer; }
        .product-grid { display:flex; flex-wrap:wrap; justify-content:center; gap:20px; margin:20px; }
        .product-card { width:220px; background:#fff; padding:15px; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.1); text-align:center; }
        .product-card img { width:100%; height:150px; object-fit:cover; border-radius:6px; }
        .product-card h3 { margin:10px 0 5px 0; font-size:1.1rem; }
        .product-card p { font-size:0.9rem; color:#555; }
        .price { font-weight:bold; margin:10px 0; }
        .product-card a { text-decoration:none; color:#3498db; font-size:0.9rem; margin-right:5px; }
        footer { text-align:center; padding:15px; background:#333; color:#fff; margin-top:30px; }

        /* Pagination */
        .pagination { text-align:center; margin:20px 0; }
        .pagination a {
            display:inline-block;
            margin:0 5px;
            padding:6px 12px;
            border:1px solid #ccc;
            border-radius:4px;
            background:#fff;
            text-decoration:none;
            color:#333;
        }
        .pagination a.active {
            background:#27ae60;
            color:#fff;
            border-color:#27ae60;
        }
        .pagination a.disabled {
            color:#999;
            pointer-events:none;
            background:#eee;
        }
    </style>

    <script>
        function addToCart(productId) {
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "AddToCartServlet", true);
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhr.onload = function() {
                if (xhr.status === 200) {
                    const cartCount = document.getElementById("cart-count");
                    cartCount.innerText = xhr.responseText;
                    alert("Item added to cart!");
                } else {
                    alert("Failed to add item to cart!");
                }
            };
            xhr.send("product_id=" + productId + "&quantity=1");
        }
    </script>
</head>
<body>

<header>
    <h1>ElectroCart</h1>
    <nav>
        <a href="index.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="categories.jsp"><i class="fas fa-th-large"></i> Categories</a>
        <a href="cart.jsp"><i class="fas fa-shopping-cart"></i> Cart <span id="cart-count" class="cart-count">0</span></a>
        <a href="profile.jsp"><i class="fas fa-user"></i> Me</a>
    </nav>
</header>

<!-- FILTER & SEARCH SECTION -->
<div class="filters">
    <form method="get" action="categories.jsp">
        <select name="category">
            <option value="">All Categories</option>
            <%
                String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
                String dbUser = "root";
                String dbPass = "";

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    Statement catStmt = conn.createStatement();
                    ResultSet catRs = catStmt.executeQuery("SELECT DISTINCT category FROM products ORDER BY category ASC");

                    while (catRs.next()) {
                        String cat = catRs.getString("category");
            %>
                        <option value="<%= cat %>" <%= (cat.equals(request.getParameter("category")) ? "selected" : "") %>><%= cat %></option>
            <%
                    }
                    catRs.close();
                    catStmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option disabled>Error loading categories</option>");
                }
            %>
        </select>

        <input type="number" name="minPrice" placeholder="Min Price" step="0.01" value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : "" %>">
        <input type="number" name="maxPrice" placeholder="Max Price" step="0.01" value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : "" %>">
        <input type="text" name="brand" placeholder="Brand" value="<%= request.getParameter("brand") != null ? request.getParameter("brand") : "" %>">
        <select name="sort">
            <option value="">Sort By</option>
            <option value="price_asc" <%= "price_asc".equals(request.getParameter("sort")) ? "selected" : "" %>>Price: Low to High</option>
            <option value="price_desc" <%= "price_desc".equals(request.getParameter("sort")) ? "selected" : "" %>>Price: High to Low</option>
            <option value="newest" <%= "newest".equals(request.getParameter("sort")) ? "selected" : "" %>>Newest</option>
        </select>
        <button type="submit"><i class="fas fa-filter"></i> Apply</button>
    </form>
</div>

<!-- PRODUCT LISTING WITH PAGINATION -->
<div class="product-grid">
<%
    String category = request.getParameter("category");
    String minPrice = request.getParameter("minPrice");
    String maxPrice = request.getParameter("maxPrice");
    String brand = request.getParameter("brand");
    String sort = request.getParameter("sort");

    // Pagination variables
    int productsPerPage = 8;
    int currentPage = 1;
    if (request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    int start = (currentPage - 1) * productsPerPage;

    StringBuilder baseQuery = new StringBuilder("FROM products WHERE 1=1");
    if (category != null && !category.isEmpty()) baseQuery.append(" AND category = '").append(category).append("'");
    if (minPrice != null && !minPrice.isEmpty()) baseQuery.append(" AND price >= ").append(minPrice);
    if (maxPrice != null && !maxPrice.isEmpty()) baseQuery.append(" AND price <= ").append(maxPrice);
    if (brand != null && !brand.isEmpty()) baseQuery.append(" AND brand LIKE '%").append(brand).append("%'");

    StringBuilder sortQuery = new StringBuilder();
    if (sort != null) {
        switch(sort) {
            case "price_asc": sortQuery.append(" ORDER BY price ASC"); break;
            case "price_desc": sortQuery.append(" ORDER BY price DESC"); break;
            case "newest": sortQuery.append(" ORDER BY created_at DESC"); break;
        }
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // Count total products
        Statement countStmt = conn.createStatement();
        ResultSet countRs = countStmt.executeQuery("SELECT COUNT(*) " + baseQuery.toString());
        countRs.next();
        int totalProducts = countRs.getInt(1);
        int totalPages = (int) Math.ceil(totalProducts / (double) productsPerPage);
        countRs.close();
        countStmt.close();

        // Fetch products for current page
        Statement stmt = conn.createStatement();
        String finalQuery = "SELECT * " + baseQuery.toString() + sortQuery.toString() +
                            " LIMIT " + start + ", " + productsPerPage;
        ResultSet rs = stmt.executeQuery(finalQuery);

        while (rs.next()) {
            int id = rs.getInt("product_id");
            String name = rs.getString("name");
            String description = rs.getString("description");
            String imageUrl = rs.getString("image_url");
            double price = rs.getDouble("price");
%>
    <div class="product-card">
        <img src="uploads/<%= imageUrl %>" alt="<%= name %>">
        <h3><%= name %></h3>
        <p><%= description.length() > 50 ? description.substring(0, 50) + "..." : description %></p>
        <div class="price">M <%= price %></div>
        <div>
            <a href="product-details.jsp?id=<%= id %>"><i class="fas fa-eye"></i> View</a>
            <button onclick="addToCart(<%= id %>)" style="background:#27ae60; color:#fff; border:none; padding:6px 10px; border-radius:4px; margin-left:5px;">
                <i class="fas fa-cart-plus"></i> Add
            </button>
        </div>
    </div>
<%
        }
        rs.close();
        stmt.close();
        conn.close();

        // Pagination controls
        if (totalPages > 1) {
            StringBuilder pageUrl = new StringBuilder("categories.jsp?");
            Enumeration<String> params = request.getParameterNames();
            while (params.hasMoreElements()) {
                String p = params.nextElement();
                if (!p.equals("page")) {
                    pageUrl.append(p).append("=").append(request.getParameter(p)).append("&");
                }
            }
%>
</div>

<div class="pagination">
    <a href="<%= pageUrl.toString() %>page=<%= currentPage - 1 %>" class="<%= (currentPage == 1 ? "disabled" : "") %>">Prev</a>
    <%
        for (int i = 1; i <= totalPages; i++) {
    %>
        <a href="<%= pageUrl.toString() %>page=<%= i %>" class="<%= (i == currentPage ? "active" : "") %>"><%= i %></a>
    <%
        }
    %>
    <a href="<%= pageUrl.toString() %>page=<%= currentPage + 1 %>" class="<%= (currentPage == totalPages ? "disabled" : "") %>">Next</a>
</div>
<%
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

<footer>
    <p>&copy; 2025 ElectroCart. All Rights Reserved.</p>
</footer>

</body>
</html>
