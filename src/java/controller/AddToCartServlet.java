package controller;

import java.io.IOException;
import java.util.HashMap;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("text/plain"); // plain text for AJAX
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        // Retrieve or create cart (product_id -> quantity)
        HashMap<Integer, Integer> cart = (HashMap<Integer, Integer>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        try {
            int productId = Integer.parseInt(request.getParameter("product_id"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            // Add or update quantity
            if (cart.containsKey(productId)) {
                cart.put(productId, cart.get(productId) + quantity);
            } else {
                cart.put(productId, quantity);
            }

            // Save cart back in session
            session.setAttribute("cart", cart);

            // Return total items in cart
            int totalItems = cart.values().stream().mapToInt(Integer::intValue).sum();
            response.getWriter().print(totalItems);

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("0");
        }
    }
}
