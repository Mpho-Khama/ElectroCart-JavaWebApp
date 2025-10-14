package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import model.OrderItem;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ViewUserOrderServlet")
public class ViewUserOrderServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("user_id");
        if (userId == null) {
            response.sendRedirect("signin.jsp");
            return;
        }

        int orderId = Integer.parseInt(request.getParameter("order_id"));
        List<OrderItem> items = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT oi.*, p.name AS product_name "
                    + "FROM order_items oi "
                    + "JOIN products p ON oi.product_id = p.product_id "
                    + "WHERE oi.order_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("order_item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getDouble("price"));
                item.setProductName(rs.getString("product_name")); // set product name
                items.add(item);
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("orderItems", items);
        request.setAttribute("orderId", orderId);
        RequestDispatcher rd = request.getRequestDispatcher("view-user-order.jsp");
        rd.forward(request, response);
    }
}
