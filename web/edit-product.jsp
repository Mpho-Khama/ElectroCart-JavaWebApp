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
    <title>Edit Product | ElectroCart</title>
    <link rel="stylesheet" href="css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background: #f0f2f5; }
        .main-content { padding: 20px; margin-left: 220px; }
        .edit-form {
            background: #fff;
            padding: 20px;
            margin-top: 25px;
            border-radius: 8px;
            max-width: 500px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .edit-form input, 
        .edit-form textarea, 
        .edit-form select {
            width: 100%;
            padding: 8px;
            margin-bottom: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .edit-form button {
            background: #27ae60;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            border-radius: 4px;
            width: 100%;
        }
        .edit-form button:hover { background: #219150; }
        .image-preview img { max-width: 100%; border-radius: 4px; }
    </style>
</head>
<body>
<aside class="sidebar">
    <h2>ElectroCart Admin</h2>
    <ul>
        <li><a href="admin-products.jsp" class="active"><i class="fa fa-box"></i> Manage Products</a></li>
        <li><a href="LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</aside>

<main class="main-content">
    <h2>Edit Product</h2>
    <div class="edit-form">
        <form action="${pageContext.request.contextPath}/EditProductServlet" method="post" enctype="multipart/form-data">
            <input type="hidden" name="productID" value="${productID}">
            <input type="text" name="name" value="${name}" placeholder="Product Name" required>
            <textarea name="description">${description}</textarea>
    
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
            <input type="number" name="price" value="${price}" step="0.01" required>
            <input type="number" name="stock_qty" value="${stock_qty}" required>
            <input type="text" name="sku" value="${sku}" readonly>
            <div class="image-preview">
                <img src="uploads/${image_url}" alt="Product Image">
            </div>
            <input type="file" name="image" accept="image/*">
            <button type="submit"><i class="fa fa-save"></i> Save Changes</button>
        </form>
    </div>
</main>
</body>
</html>
