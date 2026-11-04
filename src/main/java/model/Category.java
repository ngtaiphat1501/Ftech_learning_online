package model;

import java.io.Serializable;

public class Category implements Serializable {

    private static final long serialVersionUID = 1L;

    private long id;
    private String name;
    private String slug;
    private String iconClass;
    private String description;
    private boolean isActive = true;
    private int courseCount = 0;

    public Category() {
    }

    public Category(long id, String name) {
        this.id = id;
        this.name = name;
    }

    public Category(long id, String name, String slug, String iconClass, String description, boolean isActive) {
        this.id = id;
        this.name = name;
        this.slug = slug;
        this.iconClass = iconClass;
        this.description = description;
        this.isActive = isActive;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getIconClass() {
        return iconClass != null && !iconClass.isBlank() ? iconClass : "bi-code-square";
    }

    public void setIconClass(String iconClass) {
        this.iconClass = iconClass;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public int getCourseCount() {
        return courseCount;
    }

    public void setCourseCount(int courseCount) {
        this.courseCount = courseCount;
    }
}
