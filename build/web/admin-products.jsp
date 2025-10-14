<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"ADMIN".equals(sess.getAttribute("role"))) {
        response.sendRedirect("signin.jsp");
        return;
    }

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String search = request.getParameter("search");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Manage Products | ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="css/admin-dashboard.css">
    <style>
        body { font-family: Arial, sans-serif; }
        .main-content { padding: 20px; margin-left: 220px; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        table, th, td { border: 1px solid #ccc; }
        th {
            background: #333;
            color: white;
            padding: 8px;
            text-align: left;
        }
        td { padding: 8px; }
        img.product-img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 6px;
        }
        .actions button {
            padding: 5px 8px;
            border: none;
            margin-right: 5px;
            cursor: pointer;
            border-radius: 4px;
        }
        .edit-btn { background: #3498db; color: white; }
        .delete-btn { background: #e74c3c; color: white; }
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }
        .add-btn {
            background: #27ae60;
            color: #fff;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        .add-btn i { margin-right: 5px; }

        /* ✅ Search box */
        .search-form {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .search-form input[type="text"] {
            padding: 6px 10px;
            border-radius: 4px;
            border: 1px solid #ccc;
            width: 200px;
        }
        .search-form button {
            background: #2980b9;
            color: #fff;
            border: none;
            padding: 7px 12px;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-form button:hover {
            background: #2471a3;
        }

        /* ✅ Alerts */
        .alert {
            padding: 12px 15px;
            margin-top: 15px;
            border-radius: 6px;
            font-weight: 500;
        }
        .alert-success {
            background-color: #eafaf1;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }
        .alert-error {
            background-color: #fdecea;
            color: #c62828;
            border: 1px solid #f5c6cb;
        }
        .alert i {
            margin-right: 8px;
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<aside class="sidebar">
    <h2>ElectroCart Admin</h2>
    <ul>
        <li><a href="admin-products.jsp" class="active"><i class="fa fa-box"></i> Manage Products</a></li>
        <li><a href="admin-orders.jsp"><i class="fa fa-clipboard-list"></i> Manage Orders</a></li>
        <li><a href="admin-users.jsp"><i class="fa fa-users"></i> Manage Users</a></li>
        <li><a href="admin-payments.jsp"><i class="fa fa-credit-card"></i> Payments</a></li>
        <li><a href="admin-reports.jsp"><i class="fa fa-chart-line"></i> Reports</a></li>
        <li><a href="LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</aside>

<!-- Main Content -->
<main class="main-content">
    <div class="top-bar">
        <h2>Product Management</h2>

        <div class="search-form">
            <form method="get" action="admin-products.jsp">
                <input type="text" name="search" placeholder="Search by name or category" value="<%= (search != null ? search : "") %>">
                <button type="submit"><i class="fa fa-search"></i> Search</button>
            </form>
            <a href="add-product.jsp" class="add-btn"><i class="fa fa-plus"></i> Add Product</a>
        </div>
    </div>

    <!-- ✅ Alerts -->
    <% if (success != null) { %>
        <div class="alert alert-success"><i class="fa fa-check-circle"></i> <%= success %></div>
    <% } else if (error != null) { %>
        <div class="alert alert-error"><i class="fa fa-exclamation-triangle"></i> <%= error %></div>
    <% } %>

    <!-- Product Table -->
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Image</th>
                <th>Name</th>
                <th>Description</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock Qty</th>
                <th>SKU</th>
                <th>Created</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

                String sql = "SELECT * FROM products";
                if (search != null && !search.trim().isEmpty()) {
                    sql += " WHERE name LIKE ? OR category LIKE ?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, "%" + search + "%");
                    ps.setString(2, "%" + search + "%");
                } else {
                    sql += " ORDER BY created_at DESC";
                    ps = conn.prepareStatement(sql);
                }

                rs = ps.executeQuery();

                boolean hasResults = false;
                while (rs.next()) {
                    hasResults = true;
        %>
            <tr>
                <td><%= rs.getInt("product_id") %></td>
                <td>
                    <% String imageUrl = rs.getString("image_url"); %>
                    <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
                        <img src="uploads/<%= imageUrl %>" alt="<%= rs.getString("name") %>" class="product-img">
                    <% } else { %>
                        <span>No image</span>
                    <% } %>
                </td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("description") %></td>
                <td><%= rs.getString("category") %></td>
                <td>M <%= rs.getDouble("price") %></td>
                <td><%= rs.getInt("stock_qty") %></td>
                <td><%= rs.getString("sku") %></td>
                <td><%= rs.getTimestamp("created_at") %></td>
                <td class="actions">
                    <form action="EditProductServlet" method="get" style="display:inline;">
                        <input type="hidden" name="id" value="<%= rs.getInt("product_id") %>">
                        <button type="submit" class="edit-btn"><i class="fa fa-edit"></i></button>
                    </form>
                    <form action="DeleteProductServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete this product?');">
                        <input type="hidden" name="id" value="<%= rs.getInt("product_id") %>">
                        <button type="submit" class="delete-btn"><i class="fa fa-trash"></i></button>
                    </form>
                </td>
            </tr>
        <%
                }
                if (!hasResults) {
                    out.println("<tr><td colspan='10' style='text-align:center;color:gray;'>No products found.</td></tr>");
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='10' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        %>
        </tbody>
    </table>
</main>
</body>
</html>
