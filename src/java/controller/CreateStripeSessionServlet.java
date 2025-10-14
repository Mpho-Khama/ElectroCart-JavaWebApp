package controller;

import com.google.gson.JsonObject;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet("/CreateStripeSessionServlet")
public class CreateStripeSessionServlet extends HttpServlet {

    // ✅ Replace with your real Stripe Secret Key
    private static final String STRIPE_SECRET_KEY = "sk_test_51SH0YqK5Pf3xk9OvWnajWDwJDbx6Ykzl0Bln2nfevFsPPVXl5LiGZJ6sa3uxXbNVJ4pnE6DNL1I4btoezA8DBHrf00Z2wv6f1n";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        double amount = 0.0;
        try {
            String body = sb.toString();
            // Extract numeric part of amount
            amount = Double.parseDouble(body.replaceAll("\\D+", ""));
        } catch (Exception e) {
            response.getWriter().write("{\"error\": \"Invalid amount format.\"}");
            return;
        }

        Stripe.apiKey = STRIPE_SECRET_KEY;

        try {
            long amountInCents = (long) (amount * 100);

            // ✅ Create a Stripe Checkout Session
            SessionCreateParams params = SessionCreateParams.builder()
                    .setMode(SessionCreateParams.Mode.PAYMENT)
                    .setSuccessUrl("http://localhost:8080/Electrocard/checkout-success.jsp")
                    .setCancelUrl("http://localhost:8080/Electrocard/checkout.jsp")
                    .addLineItem(
                            SessionCreateParams.LineItem.builder()
                                    .setQuantity(1L)
                                    .setPriceData(
                                            SessionCreateParams.LineItem.PriceData.builder()
                                                    .setCurrency("usd")
                                                    .setUnitAmount(amountInCents)
                                                    .setProductData(
                                                            SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                                    .setName("ElectroCart Order")
                                                                    .build()
                                                    )
                                                    .build()
                                    )
                                    .build()
                    )
                    .build();

            Session session = Session.create(params);

            JsonObject json = new JsonObject();
            json.addProperty("sessionId", session.getId());
            response.getWriter().write(json.toString());

        } catch (StripeException e) {
            e.printStackTrace();
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("error", e.getMessage());
            response.getWriter().write(errorJson.toString());
        }
    }
}
