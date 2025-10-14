<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"ADMIN".equals(sess.getAttribute("role"))) {
        response.sendRedirect("signin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Product | ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="css/admin-dashboard.css">
    <style>
        body { font-family: Arial, sans-serif; background: #f0f2f5; }
        .main-content { padding: 20px; margin-left: 220px; }
        .add-form {
            background: #fff;
            padding: 20px;
            margin-top: 25px;
            border-radius: 8px;
            max-width: 500px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .add-form input, 
        .add-form textarea, 
        .add-form select {
            width: 100%;
            padding: 8px;
            margin-bottom: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 0.95rem;
        }
        .add-form button {
            background: #27ae60;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            border-radius: 4px;
            font-size: 1rem;
            width: 100%;
        }
        .add-form button:hover {
            background: #219150;
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<aside class="sidebar">
    <h2>ElectroCart Admin</h2>
    <ul>
        <li><a href="admin-products.jsp"><i class="fa fa-box"></i> Manage Products</a></li>
        <li><a href="admin-orders.jsp"><i class="fa fa-clipboard-list"></i> Manage Orders</a></li>
        <li><a href="admin-users.jsp"><i class="fa fa-users"></i> Manage Users</a></li>
        <li><a href="admin-payments.jsp"><i class="fa fa-credit-card"></i> Payments</a></li>
        <li><a href="admin-reports.jsp"><i class="fa fa-chart-line"></i> Reports</a></li>
        <li><a href="LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</aside>

<!-- Add Product Form -->
<main class="main-content">
    <h2>Add New Product</h2>
    <div class="add-form">
        <form action="AddProductServlet" method="post" enctype="multipart/form-data">
            <input type="text" name="name" placeholder="Product Name" required>
            <textarea name="description" placeholder="Product Description" required></textarea>

            <!-- ✅ Dropdown menu -->
            <select name="category" id="category" onchange="generateSKU()" required>
                <option value="" disabled selected>-- Select Category --</option>
                <option value="Laptops">Laptops</option>
                <option value="Desktops">Desktops</option>
                <option value="Phones">Phones</option>
                <option value="Watches">Watches</option>
                <option value="Accessories">Accessories</option>
                <option value="Cameras">Cameras</option>
                <option value="Routers">Routers</option>
                <option value="Storage Devices">Storage Devices</option>
                <option value="Audio">Audio (Earphones, Speakers)</option>
                <option value="Chargers">Chargers & Power Adapters</option>
                <option value="Others">Others</option>
            </select>

            <input type="number" step="0.01" name="price" placeholder="Price (M)" required>
            <input type="number" name="stock_qty" placeholder="Stock Quantity" required>

            <!-- Auto-filled SKU -->
            <input type="text" id="sku" name="sku" placeholder="SKU will auto-generate" readonly required>

            <input type="file" name="image" accept="image/*" required>

            <button type="submit"><i class="fa fa-plus"></i> Add Product</button>
        </form>

        <p style="color:green">${message}</p>
        <p style="color:red">${error}</p>
    </div>
</main>

<!-- ✅ Single clean script -->
<script>
    function generateSKU() {
        const category = document.getElementById("category").value;
        const skuField = document.getElementById("sku");

        if (category) {
            const prefix = category.substring(0, 3).toUpperCase(); // LAP for Laptops
            const timestamp = Date.now().toString().slice(-5);    // last 5 digits
            skuField.value = prefix + timestamp; // 👈 no dash
        } else {
            skuField.value = "";
        }
    }
</script>

</body>
</html>
