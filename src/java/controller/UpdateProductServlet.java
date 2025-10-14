package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@WebServlet("/UpdateProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class UpdateProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("product_id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockQtyStr = request.getParameter("stock_qty");
        String sku = request.getParameter("sku");

        int id = 0;
        double price = 0;
        int stockQty = 0;

        try {
            id = Integer.parseInt(idStr);
            price = Double.parseDouble(priceStr);
            stockQty = Integer.parseInt(stockQtyStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-products.jsp?error=Invalid+number+format");
            return;
        }

        // Handle file upload (optional)
        Part filePart = request.getPart("image");
        String fileName = getSubmittedFileName(filePart);
        String savedFileName = null;

        if (fileName != null && !fileName.isEmpty()) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            savedFileName = System.currentTimeMillis() + "_" + fileName;
            String filePath = uploadPath + File.separator + savedFileName;
            filePart.write(filePath);
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                String sql;
                if (savedFileName != null) {
                    sql = "UPDATE products SET name=?, description=?, category=?, price=?, stock_qty=?, sku=?, image_url=?, created_at=? WHERE product_id=?";
                } else {
                    sql = "UPDATE products SET name=?, description=?, category=?, price=?, stock_qty=?, sku=?, created_at=? WHERE product_id=?";
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setString(3, category);
                    ps.setDouble(4, price);
                    ps.setInt(5, stockQty);
                    ps.setString(6, sku);

                    if (savedFileName != null) {
                        ps.setString(7, savedFileName);
                        ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                        ps.setInt(9, id);
                    } else {
                        ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
                        ps.setInt(8, id);
                    }

                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        response.sendRedirect("admin-products.jsp?success=Product+updated+successfully");
                    } else {
                        response.sendRedirect("admin-products.jsp?error=Product+not+found");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-products.jsp?error=" + e.getMessage());
        }
    }

    private String getSubmittedFileName(Part part) {
        if (part == null) return null;
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }
        return null;
    }
}
