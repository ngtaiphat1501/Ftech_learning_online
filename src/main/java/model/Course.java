package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

public class Course implements Serializable {

    private static final long serialVersionUID = 1L;

    private long id;
    private long categoryId;
    private long instructorId;
    private String slug;
    private String title;
    private String subtitle;
    private String description;
    private String learningObjectives;
    private String requirements;
    private String targetAudience;
    private String thumbnailUrl;
    private String introVideoUrl;
    private String level;
    private String language;
    private BigDecimal estimatedHours;
    private String pricingType;
    private BigDecimal listPrice;
    private BigDecimal salePrice;
    private String status;

    // Joined / Calculated fields
    private String instructorName;
    private String instructorHeadline;
    private String instructorBio;
    private String instructorAvatar;
    private String categoryName;
    private int moduleCount;
    private int lessonCount;
    private int learnerCount;
    private double averageRating = 5.0;
    private int totalRatings = 0;

    private List<Chapter> chapters = new ArrayList<>();

    public Course() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(long categoryId) {
        this.categoryId = categoryId;
    }

    public long getInstructorId() {
        return instructorId;
    }

    public void setInstructorId(long instructorId) {
        this.instructorId = instructorId;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLearningObjectives() {
        return learningObjectives;
    }

    public void setLearningObjectives(String learningObjectives) {
        this.learningObjectives = learningObjectives;
    }

    public List<String> getLearningObjectivesList() {
        List<String> list = new ArrayList<>();
        if (learningObjectives != null && !learningObjectives.isBlank()) {
            String[] parts = learningObjectives.split("\\||\r?\n");
            for (String p : parts) {
                String trimmed = p.trim();
                if (!trimmed.isEmpty()) {
                    list.add(trimmed);
                }
            }
        }
        return list;
    }

    public String getRequirements() {
        return requirements;
    }

    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }

    public List<String> getRequirementsList() {
        List<String> list = new ArrayList<>();
        if (requirements != null && !requirements.isBlank()) {
            String[] parts = requirements.split("\\||\r?\n");
            for (String p : parts) {
                String trimmed = p.trim();
                if (!trimmed.isEmpty()) {
                    list.add(trimmed);
                }
            }
        }
        return list;
    }

    public String getTargetAudience() {
        return targetAudience;
    }

    public void setTargetAudience(String targetAudience) {
        this.targetAudience = targetAudience;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getIntroVideoUrl() {
        return introVideoUrl;
    }

    public void setIntroVideoUrl(String introVideoUrl) {
        this.introVideoUrl = introVideoUrl;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public BigDecimal getEstimatedHours() {
        return estimatedHours;
    }

    public void setEstimatedHours(BigDecimal estimatedHours) {
        this.estimatedHours = estimatedHours;
    }

    public String getPricingType() {
        return pricingType;
    }

    public void setPricingType(String pricingType) {
        this.pricingType = pricingType;
    }

    public boolean isFree() {
        return "FREE".equalsIgnoreCase(pricingType);
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public void setListPrice(BigDecimal listPrice) {
        this.listPrice = listPrice;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public BigDecimal getCurrentPrice() {
        if (isFree()) {
            return BigDecimal.ZERO;
        }
        return (salePrice != null) ? salePrice : (listPrice != null ? listPrice : BigDecimal.ZERO);
    }

    public boolean isDiscounted() {
        return !isFree() && salePrice != null && listPrice != null && salePrice.compareTo(listPrice) < 0;
    }

    public BigDecimal getSavings() {
        if (isDiscounted()) {
            return listPrice.subtract(salePrice);
        }
        return BigDecimal.ZERO;
    }

    public int getDiscountPercentage() {
        if (isDiscounted() && listPrice != null && listPrice.compareTo(BigDecimal.ZERO) > 0) {
            return getSavings().multiply(BigDecimal.valueOf(100))
                    .divide(listPrice, 0, RoundingMode.HALF_UP)
                    .intValue();
        }
        return 0;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }

    public String getInstructorHeadline() {
        return instructorHeadline;
    }

    public void setInstructorHeadline(String instructorHeadline) {
        this.instructorHeadline = instructorHeadline;
    }

    public String getInstructorBio() {
        return instructorBio;
    }

    public void setInstructorBio(String instructorBio) {
        this.instructorBio = instructorBio;
    }

    public String getInstructorAvatar() {
        return instructorAvatar;
    }

    public void setInstructorAvatar(String instructorAvatar) {
        this.instructorAvatar = instructorAvatar;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getModuleCount() {
        return moduleCount;
    }

    public void setModuleCount(int moduleCount) {
        this.moduleCount = moduleCount;
    }

    public int getLessonCount() {
        return lessonCount;
    }

    public void setLessonCount(int lessonCount) {
        this.lessonCount = lessonCount;
    }

    public int getLearnerCount() {
        return learnerCount;
    }

    public void setLearnerCount(int learnerCount) {
        this.learnerCount = learnerCount;
    }

    public int getEnrollmentCount() {
        return learnerCount;
    }

    public void setEnrollmentCount(int enrollmentCount) {
        this.learnerCount = enrollmentCount;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public int getTotalRatings() {
        return totalRatings;
    }

    public void setTotalRatings(int totalRatings) {
        this.totalRatings = totalRatings;
    }

    public long getReviewCount() {
        return totalRatings;
    }

    public void setReviewCount(long reviewCount) {
        this.totalRatings = (int) reviewCount;
    }

    public List<Chapter> getChapters() {
        return chapters;
    }

    public void setChapters(List<Chapter> chapters) {
        this.chapters = (chapters != null) ? chapters : new ArrayList<>();
    }

    public Long getFirstPreviewLessonId() {
        if (chapters != null) {
            for (Chapter chapter : chapters) {
                if (chapter.getLessons() != null) {
                    for (Lesson lesson : chapter.getLessons()) {
                        if (lesson.isPreview()) {
                            return lesson.getLessonId();
                        }
                    }
                }
            }
        }
        return null;
    }
}
