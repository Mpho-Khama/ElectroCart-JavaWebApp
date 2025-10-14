<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("signin.jsp");
        return;
    }
    String adminUser = (String) session.getAttribute("adminUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - ElectroCart</title>
    <link rel="stylesheet" href="css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
            <li><a href="${pageContext.request.contextPath}/LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>

        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header>
            <h1>Welcome, <%= adminUser %></h1>
        </header>

        <!-- Dashboard Cards -->
        <section class="dashboard">
    <a href="admin-products.jsp" class="card">
        <i class="fa fa-box"></i>
        <h3>Products</h3>
        <p>Manage all electronics in the store</p>
    </a>
    <a href="admin-orders.jsp" class="card">
        <i class="fa fa-clipboard-list"></i>
        <h3>Orders</h3>
        <p>Track and update order statuses</p>
    </a>
    <a href="admin-users.jsp" class="card">
        <i class="fa fa-users"></i>
        <h3>Users</h3>
        <p>View and manage registered customers</p>
    </a>
    <a href="admin-payments.jsp" class="card">
        <i class="fa fa-credit-card"></i>
        <h3>Payments</h3>
        <p>Verify and reconcile transactions</p>
    </a>
    <a href="admin-reports.jsp" class="card">
        <i class="fa fa-chart-line"></i>
        <h3>Reports</h3>
        <p>View sales and stock analytics</p>
    </a>
</section>

    </main>
</body>
</html>
