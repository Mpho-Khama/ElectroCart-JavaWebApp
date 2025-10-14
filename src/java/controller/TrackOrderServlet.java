package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

@WebServlet("/TrackOrderServlet")
public class TrackOrderServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String trackingCode = request.getParameter("trackingCode");

        if (trackingCode == null || trackingCode.isEmpty()) {
            response.sendRedirect("track-order.jsp?error=Enter+tracking+code");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            String sql = "SELECT o.order_id, o.user_id, o.order_date, o.status, o.total_amount, o.payment_method, o.tracking_code " +
                         "FROM orders o WHERE o.tracking_code = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, trackingCode);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                request.setAttribute("order", rs);
                request.getRequestDispatcher("track-order-result.jsp").forward(request, response);
            } else {
                response.sendRedirect("track-order.jsp?error=Order+not+found");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("track-order.jsp?error=Database+error");
        }
    }
}
