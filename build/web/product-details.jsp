<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String productIdParam = request.getParameter("id");
    if (productIdParam == null) {
        response.sendRedirect("categories.jsp?error=No product selected");
        return;
    }

    int productId = Integer.parseInt(productIdParam);

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";

    String name = "";
    String description = "";
    String category = "";
    double price = 0.0;
    int stockQty = 0;
    String sku = "";
    String imageUrl = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
            String sql = "SELECT * FROM products WHERE product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        name = rs.getString("name");
                        description = rs.getString("description");
                        category = rs.getString("category");
                        price = rs.getDouble("price");
                        stockQty = rs.getInt("stock_qty");
                        sku = rs.getString("sku");
                        imageUrl = rs.getString("image_url");
                    } else {
                        response.sendRedirect("categories.jsp?error=Product not found");
                        return;
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("categories.jsp?error=" + e.getMessage());
        return;
    }

    // Fix image path if necessary (in case only filename is stored)
    if (imageUrl != null && !imageUrl.startsWith("http") && !imageUrl.startsWith("uploads/")) {
        imageUrl = "uploads/" + imageUrl;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= name %> | ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: #f0f2f5;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 1100px;
            margin: 40px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            display: flex;
            padding: 30px;
            gap: 30px;
        }

        .product-image {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .product-image img {
            width: 100%;
            max-width: 450px;
            height: auto;
            border-radius: 10px;
            object-fit: cover;
            border: 1px solid #ddd;
        }

        .details {
            flex: 1;
        }

        .details h2 {
            margin-top: 0;
            font-size: 2rem;
            color: #333;
        }

        .category, .sku, .stock {
            color: #777;
            font-size: 0.95rem;
        }

        .price {
            font-size: 1.8rem;
            color: #e67e22;
            margin: 15px 0;
        }

        .description {
            margin-top: 15px;
            line-height: 1.6;
            color: #444;
        }

        .btn {
            background: #3498db;
            color: #fff;
            padding: 12px 18px;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            cursor: pointer;
            margin-top: 20px;
            transition: background 0.3s;
        }

        .btn:hover {
            background: #2176bd;
        }

        .btn:disabled {
            background: gray;
            cursor: not-allowed;
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                text-align: center;
            }

            .product-image img {
                max-width: 100%;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="product-image">
        <img src="<%= imageUrl %>" alt="<%= name %>" onerror="this.src='images/no-image.png';">
    </div>

    <div class="details">
        <h2><%= name %></h2>
        <p class="category"><strong>Category:</strong> <%= category %></p>
        <p class="sku"><strong>SKU:</strong> <%= sku %></p>
        <p class="price">M <%= String.format("%.2f", price) %></p>
        <p class="description"><%= description %></p>

        <p class="stock">
            <% if (stockQty > 0) { %>
                ✅ In stock (<%= stockQty %> available)
            <% } else { %>
                ❌ <span style="color:red;">Out of Stock</span>
            <% } %>
        </p>

        <form action="AddToCartServlet" method="post">
            <input type="hidden" name="product_id" value="<%= productId %>">
            <button type="submit" class="btn" <%= stockQty == 0 ? "disabled" : "" %>>
                <i class="fa fa-shopping-cart"></i> Add to Cart
            </button>
        </form>
    </div>
</div>

</body>
</html>
