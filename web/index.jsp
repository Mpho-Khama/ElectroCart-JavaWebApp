<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ElectroCart - Online Electronics Store</title>
   
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
   
    <link rel="stylesheet" href="style.css">
</head>
<body>

<header>
    <h1>ElectroCart</h1>
    <nav>
        <a href="shop.jsp"><i class="fas fa-store"></i> Shop</a>
        <a href="categories.jsp"><i class="fas fa-th-large"></i> Categories</a>
        <a href="cart.jsp"><i class="fas fa-shopping-cart"></i> Cart</a>
        <a href="profile.jsp"><i class="fas fa-user"></i> Me</a>
    </nav>
    <div class="auth-buttons">
        <a href="signin.jsp">Sign In</a>
        <a href="signup.jsp">Sign Up</a>
    </div>
</header>

<div class="search-bar">
    <input type="text" placeholder="Search for electronics...">
    <button><i class="fas fa-search"></i></button>
</div>

<section class="categories">
    <div class="category-card">
         <img src="images/laptop.jpg">
        <span>Laptops</span>
    </div>
    <div class="category-card">
        <img src="images/phone.jpg" alt="Phones">
        <span>Phones</span>
    </div>
    <div class="category-card">
       <img src="images/accessories.jpg">
        <span>Accessories</span>
    </div>
    <div class="category-card">
        <img src="images/camera.jpg">
        <span>Cameras</span>
    </div>
    <div class="category-card">
        <img src="images/storage.jpg">
        <span>Storage</span>
    </div>
    <div class="category-card">
        <img src="images/router.jpg">
        <span>Routers</span>
    </div>
</section>

<footer>
    <p>&copy; 2025 ElectroCart. All Rights Reserved.</p>
</footer>

</body>
</html>
