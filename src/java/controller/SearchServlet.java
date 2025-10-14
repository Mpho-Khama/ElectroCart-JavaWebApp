package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("query");
        List<Map<String, Object>> products = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            PreparedStatement ps;

            if (query != null && !query.trim().isEmpty()) {
                ps = conn.prepareStatement(
                    "SELECT * FROM products WHERE name LIKE ? OR description LIKE ? ORDER BY created_at DESC"
                );
                ps.setString(1, "%" + query + "%");
                ps.setString(2, "%" + query + "%");
            } else {
                ps = conn.prepareStatement("SELECT * FROM products ORDER BY created_at DESC");
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("product_id", rs.getInt("product_id"));
                p.put("name", rs.getString("name"));
                p.put("description", rs.getString("description"));
                p.put("price", rs.getDouble("price"));
                p.put("image_url", rs.getString("image_url"));
                products.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("products", products);
        RequestDispatcher rd = request.getRequestDispatcher("index.jsp");
        rd.forward(request, response);
    }
}
