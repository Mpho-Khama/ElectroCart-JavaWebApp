package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.*;

@WebServlet("/CardPaymentServlet")
public class CardPaymentServlet extends HttpServlet {

    // ✅ Replace with your real card payment gateway URL and credentials
    private static final String GATEWAY_API_URL = "https://sandbox.paygateway.com/api/payments";
    private static final String MERCHANT_ID = "YOUR_MERCHANT_ID";
    private static final String API_KEY = "YOUR_API_KEY";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("order_id"));
        double amount = getOrderAmount(orderId);
        String email = getCustomerEmail(orderId);

        try {
            // ✅ Build JSON payload for gateway
            String jsonBody = "{"
                    + "\"merchant_id\":\"" + MERCHANT_ID + "\","
                    + "\"amount\":\"" + amount + "\","
                    + "\"currency\":\"LSL\","
                    + "\"customer_email\":\"" + email + "\","
                    + "\"reference\":\"ORDER-" + orderId + "\","
                    + "\"callback_url\":\"https://yourdomain.com/CardCallbackServlet\""
                    + "}";

            // ✅ Send POST request to gateway
            URL url = new URL(GATEWAY_API_URL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("Authorization", "Bearer " + API_KEY);
            con.setDoOutput(true);

            try (OutputStream os = con.getOutputStream()) {
                os.write(jsonBody.getBytes());
            }

            int status = con.getResponseCode();
            if (status == 200 || status == 201) {
                // ✅ Read gateway response to get redirect URL
                StringBuilder responseStr = new StringBuilder();
                try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream()))) {
                    String line;
                    while ((line = br.readLine()) != null) responseStr.append(line);
                }

                // Normally you'd parse JSON for the checkout URL:
                String redirectUrl = extractRedirectUrl(responseStr.toString());

                // Redirect user to the secure card payment page
                response.sendRedirect(redirectUrl);

            } else {
                String errorMessage = readError(con);
                response.sendRedirect("checkout.jsp?error=Card+Payment+Failed:+"
                        + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("checkout.jsp?error=" + e.getMessage());
        }
    }

    private double getOrderAmount(int orderId) {
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrocart_db","root","")) {
            PreparedStatement ps = conn.prepareStatement("SELECT total_amount FROM orders WHERE order_id=?");
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    private String getCustomerEmail(int orderId) {
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrocart_db","root","")) {
            String sql = "SELECT u.email FROM users u JOIN orders o ON u.user_id=o.user_id WHERE o.order_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString(1);
        } catch (Exception e) { e.printStackTrace(); }
        return "customer@example.com"; // fallback for sandbox testing
    }

    private String extractRedirectUrl(String json) {
        // 👉 Simplified: You'd use a JSON parser to extract "redirect_url"
        int start = json.indexOf("https");
        int end = json.indexOf("\"", start);
        if (start != -1 && end != -1) return json.substring(start, end);
        return "checkout.jsp?error=Invalid+gateway+response";
    }

    private String readError(HttpURLConnection con) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getErrorStream()))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }
}
