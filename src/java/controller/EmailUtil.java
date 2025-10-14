
package controller;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException;


public class EmailUtil {

    public static void sendOrderConfirmation(String recipientEmail, int orderId, String trackingCode, double totalAmount) 
        throws MessagingException, UnsupportedEncodingException {
        
        final String senderEmail = "mphokhama71@gmail.com";
        final String senderPassword = "ihvyxnwcpfvtkmje"; 

        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        // ✅ Create session
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        // ✅ Create the email message
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(senderEmail, "ElectroCart"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
        message.setSubject("Order Confirmation - ElectroCart");

        String emailContent = String.format(
            "Dear Customer,\n\nThank you for your order!\n\n" +
            "Your order ID: %d\n" +
            "Tracking Code: %s\n" +
            "Total Amount: M%.2f\n\n" +
            "You can track your order by logging in to your account.\n\n" +
            "Best Regards,\nElectroCart Team",
            orderId, trackingCode, totalAmount
        );

        message.setText(emailContent);

        // ✅ Send the message
        Transport.send(message);
    }
    public static void sendStatusUpdate(String recipientEmail, int orderId, String newStatus, String trackingCode) throws MessagingException, UnsupportedEncodingException {
    final String senderEmail = "mphokhama71@gmail.com";
    final String senderPassword = "ihvyxnwcpfvtkmje";

    Properties props = new Properties();
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.port", "587");

    Session session = Session.getInstance(props, new Authenticator() {
        @Override
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(senderEmail, senderPassword);
        }
    });

    Message message = new MimeMessage(session);
    message.setFrom(new InternetAddress(senderEmail, "ElectroCart"));
    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
    message.setSubject("Order Status Update - ElectroCart");

    String emailContent = String.format(
        "Dear Customer,\n\nThe status of your order #%d has been updated.\n\n" +
        "New Status: %s\nTracking Code: %s\n\n" +
        "You can track your order in your account.\n\n" +
        "Best Regards,\nElectroCart Team",
        orderId, newStatus, trackingCode
    );

    message.setText(emailContent);
    Transport.send(message);
}
}