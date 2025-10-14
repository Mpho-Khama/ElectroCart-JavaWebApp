<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.HttpSession" %>
<%
    // --- Session Check ---
    
    if (session == null || session.getAttribute("email") == null) {
        response.sendRedirect("signin.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("email");
    String userRole = (String) session.getAttribute("role");

    // --- Messages ---
    String profileError = (String) session.getAttribute("profileError");
    String profileSuccess = (String) session.getAttribute("profileSuccess");
    session.removeAttribute("profileError");
    session.removeAttribute("profileSuccess");

    // --- Fetch previous orders ---
    List<Map<String, Object>> orders = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrocart_db", "root", "")) {
            String sql = "SELECT order_id, order_date, total_amount, status FROM orders WHERE user_id = ? ORDER BY order_date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> o = new HashMap<>();
                        o.put("order_id", rs.getInt("order_id"));
                        o.put("order_date", rs.getString("order_date"));
                        o.put("total_amount", rs.getDouble("total_amount"));
                        o.put("status", rs.getString("status"));
                        orders.add(o);
                    }
                }
            }
        }
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile - ElectroCart</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; }
        .sidebar { width: 220px; background: #007bff; color: #fff; height: 100vh; position: fixed; padding: 20px; }
        .sidebar h2 { color: #fff; font-size: 1.8rem; }
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar ul li { margin: 15px 0; }
        .sidebar ul li a { color: #fff; text-decoration: none; }
        .sidebar ul li a:hover { text-decoration: underline; }
        .main-content { margin-left: 240px; padding: 30px; }
        .profile-container { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .profile-details div { display: flex; justify-content: space-between; padding: 10px; background: #f4f6f9; border-radius: 8px; margin-bottom: 10px; }
        aside { margin-top: 20px; }
        aside h4 { margin-bottom: 10px; }
        aside ul { list-style: none; padding: 0; }
        aside ul li { margin-bottom: 8px; }
        aside ul li a { text-decoration: none; color: #007bff; }
        aside ul li a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>ElectroCart</h2>
        <ul>
            <li><a href="index.jsp"><i class="fa fa-home"></i> Shop</a></li>
            <li><a href="profile.jsp"><i class="fa fa-user"></i> My Profile</a></li>
            <li><a href="../LogoutServlet"><i class="fa fa-sign-out-alt"></i> Logout</a></li>
        </ul>

        <aside>
            <h4>My Orders</h4>
            <% if (orders.isEmpty()) { %>
                <p>No previous orders.</p>
            <% } else { %>
                <ul>
                    <% for(Map<String,Object> o : orders) { %>
                        <li>
                            <a href="view-previous-orders.jsp?order_id=<%= o.get("order_id") %>">
                                Order #<%= o.get("order_id") %> - <%= o.get("status") %>
                            </a>
                        </li>
                    <% } %>
                </ul>
            <% } %>
        </aside>
    </div>

    <div class="main-content">
        <div class="profile-container">
            <% if(profileSuccess != null) { %>
                <div class="alert alert-success"><%= profileSuccess %></div>
            <% } %>
            <% if(profileError != null) { %>
                <div class="alert alert-danger"><%= profileError %></div>
            <% } %>

            <h2>Welcome, <%= userName %></h2>

            <div class="profile-details">
                <div><span>Name:</span> <span><%= userName %></span></div>
                <div><span>Email:</span> <span><%= userEmail %></span></div>
                <div><span>Role:</span> <span><%= userRole %></span></div>
            </div>

            <h3>Edit Profile</h3>
            <form action="UpdateProfileServlet" method="post">
                <input type="text" name="name" value="<%= userName %>" class="form-control mb-2" placeholder="Name" required>
                <input type="email" name="email" value="<%= userEmail %>" class="form-control mb-2" placeholder="Email" required>
                <input type="password" name="password" class="form-control mb-2" placeholder="New Password (leave blank to keep current)">
                <button type="submit" class="btn btn-primary">Update Profile</button>
            </form>
        </div>
    </div>
</body>
</html>
