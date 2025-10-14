package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.*;

@WebServlet("/EcoCashPaymentServlet")
public class EcoCashPaymentServlet extends HttpServlet {

    // ✅ Sandbox URL — replace with production URL in live mode
    private static final String ECOCASH_API_URL = "https://sandbox.api.ecocash.co.ls/payments";
    private static final String MERCHANT_ID = "YOUR_MERCHANT_ID";
    private static final String MERCHANT_KEY = "YOUR_API_KEY_OR_SECRET";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("order_id"));
        double amount = getOrderAmount(orderId);
        String customerPhone = getCustomerPhone(orderId);

        try {
            // ✅ Build JSON body for EcoCash payment
            String jsonBody = "{"
                    + "\"merchant_id\":\"" + MERCHANT_ID + "\","
                    + "\"amount\":\"" + amount + "\","
                    + "\"currency\":\"LSL\","
                    + "\"phone\":\"" + customerPhone + "\","
                    + "\"reference\":\"ORDER-" + orderId + "\","
                    + "\"callback_url\":\"https://yourdomain.com/EcoCashCallbackServlet\""
                    + "}";

            // ✅ Make POST request to EcoCash API
            URL url = new URL(ECOCASH_API_URL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("Authorization", "Bearer " + MERCHANT_KEY);
            con.setDoOutput(true);

            try (OutputStream os = con.getOutputStream()) {
                os.write(jsonBody.getBytes());
            }

            int status = con.getResponseCode();
            if (status == 200 || status == 201) {
                // ✅ Payment initiated successfully
                response.sendRedirect("payment-pending.jsp?order_id=" + orderId + "&method=EcoCash");
            } else {
                // ❌ Failed to initiate payment — show error
                String errorMessage = readError(con);
                response.sendRedirect("checkout.jsp?error=EcoCash+Payment+Failed:+"
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

    private String getCustomerPhone(int orderId) {
        // 👉 You should fetch this from users table or orders table
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrocart_db","root","")) {
            String sql = "SELECT u.phone FROM users u JOIN orders o ON u.user_id=o.user_id WHERE o.order_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString(1);
        } catch (Exception e) { e.printStackTrace(); }
        return "26650000000"; // fallback demo number for EcoCash sandbox
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
