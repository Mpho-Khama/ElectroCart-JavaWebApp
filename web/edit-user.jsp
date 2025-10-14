<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("signin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit User | ElectroCart Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background: #f4f6f9; }
        .container {
            max-width: 600px; margin: 50px auto; background: white; padding: 20px;
            border-radius: 8px; box-shadow: 0 0 8px rgba(0,0,0,0.1);
        }
        h2 { text-align: center; margin-bottom: 20px; }
        form input, form select, form textarea {
            width: 100%; padding: 10px; margin-bottom: 12px;
            border: 1px solid #ccc; border-radius: 4px;
        }
        button {
            background: #3498db; color: white; border: none;
            padding: 10px 15px; border-radius: 4px; cursor: pointer;
        }
        .back-link {
            display: inline-block; margin-top: 10px; text-decoration: none; color: #333;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Edit User</h2>
    <form action="EditUserServlet" method="post">
        <input type="hidden" name="user_id" value="<%= request.getAttribute("user_id") %>">

        <label>Name:</label>
        <input type="text" name="name" value="<%= request.getAttribute("name") %>" required>

        <label>Email:</label>
        <input type="email" name="email" value="<%= request.getAttribute("email") %>" required>

        <label>Phone:</label>
        <input type="text" name="phone" value="<%= request.getAttribute("phone") %>">

        <label>Role:</label>
        <select name="role" required>
            <option value="USER" <%= "USER".equals(request.getAttribute("role")) ? "selected" : "" %>>USER</option>
            <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("role")) ? "selected" : "" %>>ADMIN</option>
        </select>

        <label>Address:</label>
        <textarea name="address"><%= request.getAttribute("address") %></textarea>

        <button type="submit">Update User</button>
    </form>

    <a href="admin-users.jsp" class="back-link"><i class="fa fa-arrow-left"></i> Back to User Management</a>
</div>
</body>
</html>
