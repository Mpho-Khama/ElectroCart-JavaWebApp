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

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin - Manage Users & Refunds | ElectroCart</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="css/admin-dashboard.css">
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f6f9;
            }
            .main-content {
                padding: 20px;
                margin-left: 220px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
                background: white;
            }
            table, th, td {
                border: 1px solid #ccc;
            }
            th {
                background: #333;
                color: white;
                padding: 8px;
                text-align: left;
            }
            td {
                padding: 8px;
            }
            .actions button {
                padding: 5px 8px;
                border: none;
                margin-right: 5px;
                cursor: pointer;
                border-radius: 4px;
            }
            .edit-btn {
                background: #3498db;
                color: white;
            }
            .delete-btn {
                background: #e74c3c;
                color: white;
            }
            .refund-btn {
                background: #f39c12;
                color: white;
            }
            .top-bar {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
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
            .sidebar {
                width: 220px;
                background: #222;
                color: #fff;
                position: fixed;
                top: 0;
                left: 0;
                height: 100%;
                padding-top: 20px;
            }
            .sidebar h2 {
                text-align: center;
                color: #f1f1f1;
            }
            .sidebar ul {
                list-style: none;
                padding: 0;
            }
            .sidebar ul li {
                margin: 10px 0;
            }
            .sidebar ul li a {
                color: #fff;
                text-decoration: none;
                display: block;
                padding: 10px 15px;
                transition: background 0.3s;
            }
            .sidebar ul li a:hover, .sidebar ul li a.active {
                background: #3498db;
            }
            .add-btn {
                background: #28a745;
                color: white;
                padding: 8px 12px;
                border-radius: 4px;
                text-decoration: none;
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
                <li><a href="admin-users.jsp" class="active"><i class="fa fa-users"></i> Manage Users</a></li>
                <li><a href="admin-payments.jsp"><i class="fa fa-credit-card"></i> Payments</a></li>
                <li><a href="admin-reports.jsp"><i class="fa fa-chart-line"></i> Reports</a></li>
                <li><a href="LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <div class="top-bar">
                <h2>User Management</h2>
                <a href="signup.jsp" class="add-btn"><i class="fa fa-plus"></i> Add User</a>
            </div>

            <% if (success != null) {%>
            <div class="alert alert-success"><i class="fa fa-check-circle"></i> <%= success%></div>
            <% } else if (error != null) {%>
            <div class="alert alert-error"><i class="fa fa-exclamation-triangle"></i> <%= error%></div>
            <% } %>

            <!-- Users Table -->
            <table>
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT user_id, name, email, role, created_at FROM users ORDER BY created_at DESC");

                            while (rs.next()) {
                                int userId = rs.getInt("user_id");
                                String name = rs.getString("name");
                                String email = rs.getString("email");
                                String role = rs.getString("role");
                                Timestamp created = rs.getTimestamp("created_at");
                    %>
                    <tr>
                        <td><%= userId%></td>
                        <td><%= name%></td>
                        <td><%= email%></td>
                        <td><%= role%></td>
                        <td><%= created%></td>
                        <td class="actions">
                            <form action="EditUserServlet" method="get" style="display:inline;">
                                <input type="hidden" name="user_id" value="<%= userId%>">
                                <button type="submit" class="edit-btn"><i class="fa fa-edit"></i></button>
                            </form>
                            <form action="DeleteUserServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete this user?');">
                                <input type="hidden" name="user_id" value="<%= userId%>">
                                <button type="submit" class="delete-btn">
                                    <i class="fa fa-trash"></i>
                                </button>
                            </form>

                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) {
                                rs.close();
                            }
                            if (stmt != null) {
                                stmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        }
                    %>
                </tbody>
            </table>

            <!-- Refund Table -->
            <h2 class="mt-5">Refund Requests</h2>
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Status</th>
                        <th>Total Amount</th>
                        <th>Payment Method</th>
                        <th>Tracking Code</th>
                        <th>Order Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT order_id, user_id, status, total_amount, payment_method, tracking_code, order_date FROM orders WHERE status='Paid' ORDER BY order_date DESC");

                            while (rs.next()) {
                                int orderId = rs.getInt("order_id");
                                int userId = rs.getInt("user_id");
                                String statusVal = rs.getString("status");
                                double total = rs.getDouble("total_amount");
                                String payment = rs.getString("payment_method");
                                String tracking = rs.getString("tracking_code");
                                Timestamp orderDate = rs.getTimestamp("order_date");
                    %>
                    <tr>
                        <td><%= orderId%></td>
                        <td><%= userId%></td>
                        <td><%= statusVal%></td>
                        <td>M <%= total%></td>
                        <td><%= payment%></td>
                        <td><%= tracking%></td>
                        <td><%= orderDate%></td>
                        <td class="actions">
                            <form action="ProcessRefundServlet" method="post" style="display:inline;" onsubmit="return confirm('Refund this order?');">
                                <input type="hidden" name="order_id" value="<%= orderId%>">
                                <button type="submit" class="refund-btn"><i class="fa fa-undo"></i></button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) {
                                rs.close();
                            }
                            if (stmt != null) {
                                stmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        }
                    %>
                </tbody>
            </table>
        </main>
    </body>
</html>
