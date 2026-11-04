package model;

import java.io.Serializable;

public class Lesson implements Serializable {

    private static final long serialVersionUID = 1L;

    private long lessonId;
    private long chapterId;
    private long courseId;
    private String title;
    private String content;
    private String videoUrl;
    private Integer durationSeconds;
    private int sortOrder;
    private boolean isPreview;
    private boolean isRequired;

    public Lesson() {
    }

    public Lesson(long lessonId, long chapterId, long courseId, String title, String videoUrl,
                  Integer durationSeconds, int sortOrder, boolean isPreview, boolean isRequired) {
        this.lessonId = lessonId;
        this.chapterId = chapterId;
        this.courseId = courseId;
        this.title = title;
        this.videoUrl = videoUrl;
        this.durationSeconds = durationSeconds;
        this.sortOrder = sortOrder;
        this.isPreview = isPreview;
        this.isRequired = isRequired;
    }

    public long getLessonId() {
        return lessonId;
    }

    public void setLessonId(long lessonId) {
        this.lessonId = lessonId;
    }

    public long getChapterId() {
        return chapterId;
    }

    public void setChapterId(long chapterId) {
        this.chapterId = chapterId;
    }

    public long getCourseId() {
        return courseId;
    }

    public void setCourseId(long courseId) {
        this.courseId = courseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public Integer getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(Integer durationSeconds) {
        this.durationSeconds = durationSeconds;
    }

    public String getFormattedDuration() {
        if (durationSeconds == null || durationSeconds <= 0) {
            return "10:00";
        }
        int minutes = durationSeconds / 60;
        int seconds = durationSeconds % 60;
        return String.format("%02d:%02d", minutes, seconds);
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isPreview() {
        return isPreview;
    }

    public void setPreview(boolean preview) {
        isPreview = preview;
    }

    public boolean isRequired() {
        return isRequired;
    }

    public void setRequired(boolean required) {
        isRequired = required;
    }
}
