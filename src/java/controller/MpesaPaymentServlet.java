package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.*;

@WebServlet("/MpesaPaymentServlet")
public class MpesaPaymentServlet extends HttpServlet {
    private static final String M_PESA_API_URL = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";
    private static final String ACCESS_TOKEN = "YOUR_ACCESS_TOKEN";  // from M-PESA credentials

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("order_id"));
        double amount = getOrderAmount(orderId);
        String phone = getCustomerPhone(orderId);

        // JSON body
        String jsonBody = "{"
                + "\"BusinessShortCode\":\"174379\","
                + "\"Password\":\"BASE64_PASSWORD\","
                + "\"Timestamp\":\"20251007121530\","
                + "\"TransactionType\":\"CustomerPayBillOnline\","
                + "\"Amount\":\"" + amount + "\","
                + "\"PartyA\":\"" + phone + "\","
                + "\"PartyB\":\"174379\","
                + "\"PhoneNumber\":\"" + phone + "\","
                + "\"CallBackURL\":\"https://yourdomain.com/MpesaCallbackServlet\","
                + "\"AccountReference\":\"ElectroCart\","
                + "\"TransactionDesc\":\"Order Payment\"}";

        URL url = new URL(M_PESA_API_URL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Authorization", "Bearer " + ACCESS_TOKEN);
        con.setDoOutput(true);

        try (OutputStream os = con.getOutputStream()) {
            os.write(jsonBody.getBytes());
        }

        int status = con.getResponseCode();
        if (status == 200) {
            response.sendRedirect("payment-pending.jsp?order_id=" + orderId);
        } else {
            response.sendRedirect("checkout.jsp?error=M-PESA+Payment+Failed");
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
        // You should store customer phone in users table or order table
        return "254700000000";
    }
}
