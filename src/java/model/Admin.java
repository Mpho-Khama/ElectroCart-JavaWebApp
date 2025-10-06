
package model;

/**
 *
 * @author Mpho Khama
 */
public class Admin {
 private int adminId;
    private String username;
    private String password; // hashed
    private String role;     // e.g. SUPER_ADMIN or ADMIN

    // Getters and setters
    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
