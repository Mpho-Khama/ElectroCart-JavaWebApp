
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 *
 * @author Mpho Khama
 */
@WebServlet(name = "AddProductServlet1", urlPatterns = {"/AddProductServlet1"})

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   
    maxFileSize = 1024 * 1024 * 10,        
    maxRequestSize = 1024 * 1024 * 50     
)
public class AddProductServlet1 extends HttpServlet {

    private static final long serialVersionUID = 1L;

    
    private final String DB_URL = "jdbc:mysql://localhost:3306/electrocart_db";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockQtyStr = request.getParameter("stock_qty");
        String sku = request.getParameter("sku");

        double price = 0;
        int stockQty = 0;

        try {
            price = Double.parseDouble(priceStr);
            stockQty = Integer.parseInt(stockQtyStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-products.jsp?error=Invalid number format");
            return;
        }

        
        Part filePart = request.getPart("image");
        String fileName = getSubmittedFileName(filePart);
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";

        
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String savedFileName = System.currentTimeMillis() + "_" + fileName; 
        String filePath = uploadPath + File.separator + savedFileName;
        filePart.write(filePath);

        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String sql = "INSERT INTO products (name, description, category, price, stock_qty, sku, image_url, created_at) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setString(2, description);
                ps.setString(3, category);
                ps.setDouble(4, price);
                ps.setInt(5, stockQty);
                ps.setString(6, sku);
                ps.setString(7, savedFileName);
                ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));

                ps.executeUpdate();
            }

            response.sendRedirect("admin-products.jsp?success=Product added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-products.jsp?error=" + e.getMessage());
        }
    }

    
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }
        return null;
    }
}
