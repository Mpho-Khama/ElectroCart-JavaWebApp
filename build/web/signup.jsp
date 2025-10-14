<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up - ElectroCart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style1.css">
</head>
<body>

<div class="signup-container">
    <h2>Create Your Account</h2>

    <!-- Display error if registration fails -->
    <c:if test="${not empty error}">
        <div class="error-message">${error}</div>
    </c:if>

    <form action="RegisterServlet" method="post">
        <div class="form-group">
            <label for="name"><i class="fas fa-user"></i> Name</label>
            <input type="text" id="name" name="name" placeholder="Enter your name" required>
        </div>

        <div class="form-group">
            <label for="email"><i class="fas fa-envelope"></i> Email</label>
            <input type="email" id="email" name="email" placeholder="Enter your email" required>
        </div>

        <div class="form-group">
            <label for="phone"><i class="fas fa-phone"></i> Phone</label>
            <input type="text" id="phone" name="phone" placeholder="Enter your phone number">
        </div>

        <div class="form-group">
            <label for="address"><i class="fas fa-home"></i> Address</label>
            <input type="text" id="address" name="address" placeholder="Enter your address">
        </div>

        <div class="form-group password-group">
            <label for="password"><i class="fas fa-lock"></i> Password</label>
            <input type="password" id="password" name="password" placeholder="Enter password" required>
            <i class="fas fa-eye toggle-password" toggle="#password"></i>
            <div id="password-strength"></div>
        </div>

        <div class="form-group password-group">
            <label for="confirm_password"><i class="fas fa-lock"></i> Confirm Password</label>
            <input type="password" id="confirm_password" name="confirm_password" placeholder="Confirm password" required>
            <i class="fas fa-eye toggle-password" toggle="#confirm_password"></i>
        </div>

        <button type="submit" class="btn">Sign Up</button>
    </form>

    <p>Already have an account? <a href="signin.jsp">Sign In</a></p>
</div>

<script>
    // Show/Hide password toggle
    const toggleIcons = document.querySelectorAll('.toggle-password');
    toggleIcons.forEach(icon => {
        icon.addEventListener('click', () => {
            const input = document.querySelector(icon.getAttribute('toggle'));
            if (input.type === "password") {
                input.type = "text";
                icon.classList.replace("fa-eye", "fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.replace("fa-eye-slash", "fa-eye");
            }
        });
    });

    // Password strength checker
    const passwordInput = document.getElementById('password');
    const strengthBar = document.getElementById('password-strength');

    passwordInput.addEventListener('input', () => {
        const val = passwordInput.value;
        let strength = 0;
        if (val.length >= 6) strength++;
        if (/[A-Z]/.test(val)) strength++;
        if (/[0-9]/.test(val)) strength++;
        if (/[\W]/.test(val)) strength++;

        switch (strength) {
            case 0:
            case 1:
                strengthBar.textContent = "Weak";
                strengthBar.style.color = "#e74c3c";
                break;
            case 2:
            case 3:
                strengthBar.textContent = "Medium";
                strengthBar.style.color = "#f1c40f";
                break;
            case 4:
                strengthBar.textContent = "Strong";
                strengthBar.style.color = "#2ecc71";
                break;
        }
    });
</script>

</body>
</html>
