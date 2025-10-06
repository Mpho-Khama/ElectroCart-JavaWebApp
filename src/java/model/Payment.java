
package model;
import java.util.Date;
/**
 *
 * @author Mpho Khama
 */
public class Payment {
private int paymentId;
    private int orderId;
    private double amount;
    private String method;        // M_PESA, EcoCash, CARD, BANK
    private String status;        // PENDING, CONFIRMED, FAILED
    private String transactionCode;
    private Date createdAt;

    // Getters and Setters
    public int getPaymentId() {
        return paymentId;
    }
    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getOrderId() {
        return orderId;
    }
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public double getAmount() {
        return amount;
    }
    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getMethod() {
        return method;
    }
    public void setMethod(String method) {
        this.method = method;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getTransactionCode() {
        return transactionCode;
    }
    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public Date getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}