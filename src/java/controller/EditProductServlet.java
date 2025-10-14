package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.*;

@WebServlet("/EditProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15
)
public class EditProductServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    // Load product data for editing
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("admin-products.jsp?error=Missing+product+ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                String sql = "SELECT * FROM products WHERE product_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            request.setAttribute("productID", id);
                            request.setAttribute("name", rs.getString("name"));
                            request.setAttribute("description", rs.getString("description"));
                            request.setAttribute("category", rs.getString("category"));
                            request.setAttribute("price", rs.getDouble("price"));
                            request.setAttribute("stock_qty", rs.getInt("stock_qty"));
                            request.setAttribute("sku", rs.getString("sku"));
                            request.setAttribute("image_url", rs.getString("image_url"));

                            request.getRequestDispatcher("edit-product.jsp").forward(request, response);
                        } else {
                            response.sendRedirect("admin-products.jsp?error=Product+not+found");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-products.jsp?error=" + e.getMessage());
        }
    }

    // Update product details
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("productID");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockQtyStr = request.getParameter("stock_qty");
        String sku = request.getParameter("sku");

        Part imagePart = request.getPart("image");
        String imageName = null;

        String uploadPath = getServletContext().getRealPath("") + "uploads\\";
        java.io.File uploadDir = new java.io.File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        if (imagePart != null && imagePart.getSize() > 0) {
            imageName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            imagePart.write(uploadPath + imageName);
        }

        try {
            int id = Integer.parseInt(idStr);
            double price = Double.parseDouble(priceStr);
            int stockQty = Integer.parseInt(stockQtyStr);

            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                String sql;
                if (imageName != null && !imageName.isEmpty()) {
                    sql = "UPDATE products SET name=?, description=?, category=?, price=?, stock_qty=?, sku=?, image_url=? WHERE product_id=?";
                } else {
                    sql = "UPDATE products SET name=?, description=?, category=?, price=?, stock_qty=?, sku=? WHERE product_id=?";
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setString(3, category);
                    ps.setDouble(4, price);
                    ps.setInt(5, stockQty);
                    ps.setString(6, sku);

                    if (imageName != null && !imageName.isEmpty()) {
                        ps.setString(7, imageName);
                        ps.setInt(8, id);
                    } else {
                        ps.setInt(7, id);
                    }

                    int rows = ps.executeUpdate();
                    if (rows > 0)
                        response.sendRedirect("admin-products.jsp?success=Product+updated");
                    else
                        response.sendRedirect("admin-products.jsp?error=Product+not+found");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-products.jsp?error=" + e.getMessage());
        }
    }
}
