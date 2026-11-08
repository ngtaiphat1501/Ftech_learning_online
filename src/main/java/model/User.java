package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long userId;
    private String email;
    private String fullName;
    private String passwordHash;
    private String headline;
    private String bio;
    private String avatarUrl;
    private String status; // 'ACTIVE', 'LOCKED'
    private BigDecimal balanceVnd = BigDecimal.ZERO;
    private List<String> roles = new ArrayList<>();

    public User() {
    }

    public User(Long userId, String email, String fullName, String passwordHash, String status) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.passwordHash = passwordHash;
        this.status = status;
        this.balanceVnd = BigDecimal.ZERO;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getHeadline() {
        return headline;
    }

    public void setHeadline(String headline) {
        this.headline = headline;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getBalanceVnd() {
        return balanceVnd != null ? balanceVnd : BigDecimal.ZERO;
    }

    public void setBalanceVnd(BigDecimal balanceVnd) {
        this.balanceVnd = balanceVnd != null ? balanceVnd : BigDecimal.ZERO;
    }

    public List<String> getRoles() {
        return roles;
    }

    public void setRoles(List<String> roles) {
        this.roles = (roles != null) ? roles : new ArrayList<>();
    }

    public void addRole(String role) {
        if (role != null && !roles.contains(role)) {
            roles.add(role);
        }
    }

    public boolean hasRole(String role) {
        if (role == null || roles == null) {
            return false;
        }
        for (String r : roles) {
            if (r != null && role.trim().equalsIgnoreCase(r.trim())) {
                return true;
            }
        }
        return false;
    }

    public boolean isAdmin() {
        return hasRole("ADMIN");
    }

    public boolean isInstructor() {
        return hasRole("INSTRUCTOR");
    }

    public boolean isStudent() {
        return hasRole("STUDENT");
    }
}
