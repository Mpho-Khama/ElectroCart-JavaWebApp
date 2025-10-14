<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, jakarta.servlet.http.HttpSession" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id"); // can be null

    HashMap<Integer, Integer> cart = (HashMap<Integer, Integer>) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }

    String dbURL = "jdbc:mysql://localhost:3306/electrocart_db";
    String dbUser = "root";
    String dbPass = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ElectroCart - Checkout</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://js.stripe.com/v3/"></script> <!-- ✅ Stripe SDK -->
    <style>
        body { font-family: Arial, sans-serif; margin:0; background:#f0f2f5; }
        header { display:flex; justify-content: space-between; align-items:center; padding:10px 20px; background:#333; color:#fff; }
        header h1 { margin:0; }
        nav a { color:#fff; margin-right:15px; text-decoration:none; }
        table { width:90%; margin:20px auto; border-collapse: collapse; background:#fff; }
        th, td { padding:10px; border:1px solid #ccc; text-align:center; }
        th { background:#333; color:#fff; }
        input, select { padding:8px; width:100%; margin-bottom:10px; border-radius:4px; border:1px solid #ccc; }
        .checkout-form { width:50%; margin:20px auto; background:#fff; padding:20px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,0.1); }
        .place-order { background:#27ae60; color:#fff; padding:10px 15px; border:none; border-radius:4px; cursor:pointer; }
    </style>
</head>
<body>
<header>
    <h1>ElectroCart</h1>
    <nav>
        <a href="index.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="cart.jsp"><i class="fas fa-shopping-cart"></i> Cart</a>
    </nav>
</header>

<h2 style="text-align:center; margin-top:20px;">Checkout</h2>

<div class="checkout-form">
    <form id="checkoutForm" action="PlaceOrderServlet" method="post">
        <h3>Shipping & Payment Information</h3>
        <label for="fullname">Full Name</label>
        <input type="text" id="fullname" name="fullname" required>

        <label for="address">Address</label>
        <input type="text" id="address" name="address" required>

        <label for="phone">Phone Number</label>
        <input type="text" id="phone" name="phone" required>

        <label for="email">Email (for receipt / tracking)</label>
        <input type="email" id="email" name="email" required>

        <label><input type="radio" name="payment_method" value="M-PESA" required> M-PESA</label><br>
        <label><input type="radio" name="payment_method" value="EcoCash"> EcoCash</label><br>
        <label><input type="radio" name="payment_method" value="Card"> Debit/Credit Card</label><br>

        <h3>Order Summary</h3>
        <table>
            <tr>
                <th>Name</th><th>Qty</th><th>Price (M)</th><th>Subtotal (M)</th>
            </tr>
            <%
                double total = 0;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    String query = "SELECT * FROM products WHERE product_id=?";
                    PreparedStatement ps = conn.prepareStatement(query);

                    for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                        int pid = entry.getKey();
                        int qty = entry.getValue();
                        ps.setInt(1, pid);
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            String pname = rs.getString("name");
                            double price = rs.getDouble("price");
                            double subtotal = price * qty;
                            total += subtotal;
            %>
            <tr>
                <td><%= pname %></td>
                <td><%= qty %></td>
                <td>M <%= price %></td>
                <td>M <%= subtotal %></td>
            </tr>
            <%
                        }
                        rs.close();
                    }
                    ps.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<tr><td colspan='4' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
            <tr>
                <td colspan="3" style="text-align:right;"><strong>Total:</strong></td>
                <td><strong>M <%= total %></strong></td>
            </tr>
        </table>

        <input type="hidden" name="user_id" value="<%= (userId != null ? userId : "") %>">
        <input type="hidden" name="total_amount" id="total_amount" value="<%= total %>">

        <button type="submit" id="placeOrderBtn" class="place-order">Place Order</button>
    </form>
</div>

<script>
document.getElementById("checkoutForm").addEventListener("submit", async function(e) {
    const method = document.querySelector('input[name="payment_method"]:checked').value;
    if (method === "Card") {
        e.preventDefault();

        const total = document.getElementById("total_amount").value;
        try {
            // ✅ Call backend servlet to create Stripe session
            const response = await fetch("CreateStripeSessionServlet", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ amount: total })
            });
            const data = await response.json();

            if (data.sessionId) {
                const stripe = Stripe("pk_test_your_public_key_here"); // ✅ replace with your Stripe public key
                await stripe.redirectToCheckout({ sessionId: data.sessionId });
            } else {
                alert("Stripe payment initialization failed.");
            }
        } catch (err) {
            alert("Payment error: " + err.message);
        }
    }
});
</script>

</body>
</html>
