<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In - ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="login-container">
    <h2>Sign In</h2>

    <!-- Display error if login fails -->
    <c:if test="${not empty error}">
        <div class="error-message" style="color:red;">
            ${error}
        </div>
    </c:if>

    <form action="LoginServlet" method="post">
    <label>Email</label>
    <input type="email" name="email" required><br>

    <label>Password</label>
    <input type="password" name="password" required><br>

    <button type="submit">Sign In</button>
</form>

    <p>Don't have an account? <a href="signup.jsp">Sign Up</a></p>
</div>

</body>
</html>
