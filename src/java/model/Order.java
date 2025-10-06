
package model;
import java.util.Date;
/**
 *
 * @author Mpho Khama
 */
public class Order {
    
private int orderId;
    private int userId;
    private Date orderDate;
    private String status;       // PLACED, SHIPPED, DELIVERED, 
    private double totalAmount;
    private String paymentMethod; // M-PESA, EcoCash, Card, Bank

    // Getters and setters
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
}

