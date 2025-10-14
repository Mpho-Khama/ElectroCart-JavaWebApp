package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet(name = "ViewOrderServlet", urlPatterns = {"/ViewOrderServlet"})
public class ViewOrderServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        String role = session != null ? (String) session.getAttribute("role") : null;
        Integer userId = session != null ? (Integer) session.getAttribute("user_id") : null;

        String orderIdParam = request.getParameter("order_id");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                PreparedStatement ps;
                if ("ADMIN".equals(role) && orderIdParam != null) {
                    // Admin viewing a specific order
                    ps = conn.prepareStatement(
                        "SELECT * FROM orders WHERE order_id = ?");
                    ps.setInt(1, Integer.parseInt(orderIdParam));
                } else if (userId != null) {
                    // Logged-in user viewing their own orders
                    ps = conn.prepareStatement(
                        "SELECT * FROM orders WHERE user_id = ?");
                    ps.setInt(1, userId);
                } else {
                    // Guest or unauthorized
                    out.println("<p style='color:red;text-align:center;'>You are not authorized to view this page.</p>");
                    return;
                }

                ResultSet rs = ps.executeQuery();

                out.println("<h2 style='text-align:center;'>Order Details</h2>");
                out.println("<table border='1' cellspacing='0' cellpadding='8' style='margin:auto;'>");
                out.println("<tr><th>Order ID</th><th>User ID</th><th>Date</th><th>Status</th><th>Total (M)</th><th>Payment</th></tr>");

                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    int uid = rs.getInt("user_id");
                    Timestamp date = rs.getTimestamp("order_date");
                    String status = rs.getString("status");
                    double total = rs.getDouble("total_amount");
                    String payment = rs.getString("payment_method");

                    out.println("<tr>");
                    out.println("<td>" + orderId + "</td>");
                    out.println("<td>" + uid + "</td>");
                    out.println("<td>" + date + "</td>");
                    out.println("<td>" + status + "</td>");
                    out.println("<td>M " + total + "</td>");
                    out.println("<td>" + payment + "</td>");
                    out.println("</tr>");
                }

                out.println("</table>");
                rs.close();
                ps.close();

            }
        } catch (Exception e) {
            out.println("<p style='color:red;text-align:center;'>Error: " + e.getMessage() + "</p>");
        }
    }
}
