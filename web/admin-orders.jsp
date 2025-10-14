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

    // Status options
    String[] statuses = {"Processing", "Shipped", "Delivered", "Cancelled"};
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin - Manage Orders | ElectroCart</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="css/admin-dashboard.css">
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f0f2f5;
            }
            .main-content {
                padding: 20px;
                margin-left: 220px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
                background: #fff;
            }
            table, th, td {
                border: 1px solid #ccc;
            }
            th {
                background: #333;
                color: white;
                padding: 8px;
            }
            td {
                padding: 8px;
                vertical-align: middle;
            }
            .actions button {
                padding: 5px 8px;
                border: none;
                margin-right: 5px;
                cursor: pointer;
                border-radius: 4px;
                font-size: 0.85rem;
            }
            .view-btn {
                background: #3498db;
                color: #fff;
            }
            .status-btn {
                background: #27ae60;
                color: #fff;
            }
            .delete-btn {
                background: #e74c3c;
                color: #fff;
            }
            select.status-dropdown {
                padding: 4px 6px;
                border-radius: 4px;
                border: 1px solid #ccc;
                font-size: 0.85rem;
            }
            form.status-form {
                display: inline;
                margin: 0;
            }
        </style>
    </head>
    <body>

        <aside class="sidebar">
            <h2>ElectroCart Admin</h2>
            <ul>
                <li><a href="admin-products.jsp"><i class="fa fa-box"></i> Manage Products</a></li>
                <li><a href="admin-orders.jsp" class="active"><i class="fa fa-clipboard-list"></i> Manage Orders</a></li>
                <li><a href="admin-users.jsp"><i class="fa fa-users"></i> Manage Users</a></li>
                <li><a href="admin-payments.jsp"><i class="fa fa-credit-card"></i> Payments</a></li>
                <li><a href="admin-reports.jsp"><i class="fa fa-chart-line"></i> Reports</a></li>
                <li><a href="LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>

        <main class="main-content">
            <h2>Order Management</h2>

            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Order Date</th>
                        <th>Status</th>
                        <th>Total Amount (M)</th>
                        <th>Payment Method</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT * FROM orders ORDER BY order_date DESC");

                            while (rs.next()) {
                                int orderId = rs.getInt("order_id");
                                int userId = rs.getInt("user_id");
                                Timestamp orderDate = rs.getTimestamp("order_date");
                                String status = rs.getString("status");
                                double total = rs.getDouble("total_amount");
                                String payment = rs.getString("payment_method");
                    %>
                    <tr>
                        <td><%= orderId%></td>
                        <td><%= userId%></td>
                        <td><%= orderDate%></td>
                        <td>
                            <form class="status-form" action="UpdateOrderStatusServlet" method="post">
                                <input type="hidden" name="order_id" value="<%= orderId%>">
                                <select name="status" class="status-dropdown" style="background-color:
                                        <%= status.equals("Processing") ? "#f1c40f"
                                                : status.equals("Processing") ? "#f1c40f"
                                                : status.equals("Shipped") ? "#3498db"
                                                : status.equals("Delivered") ? "#2ecc71"
                    : status.equals("Cancelled") ? "#e74c3c" : "#fff"%>; color: white;"
                                        onchange="this.form.submit()">
                                    <%
                                        for (String s : statuses) {
                                            String selected = s.equals(status) ? "selected" : "";
                                    %>
                                    <option value="<%= s%>" <%= selected%>><%= s%></option>
                                    <%
                                        }
                                    %>
                                </select>
                            </form>
                        </td>

                        <td>M <%= total%></td>
                        <td><%= payment%></td>
                        <td class="actions">
                            <form action="ViewOrderServlet" method="get" style="display:inline;">
                                <input type="hidden" name="order_id" value="<%= orderId%>">
                                <button type="submit" class="view-btn"><i class="fa fa-eye"></i></button>
                            </form>
                            <form action="DeleteOrderServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete this order?');">
                                <input type="hidden" name="order_id" value="<%= orderId%>">
                                <button type="submit" class="delete-btn"><i class="fa fa-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
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
