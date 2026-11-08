package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Chapter implements Serializable {

    private static final long serialVersionUID = 1L;

    private long chapterId;
    private long courseId;
    private String title;
    private String description;
    private int sortOrder;
    private List<Lesson> lessons = new ArrayList<>();

    public Chapter() {
    }

    public Chapter(long chapterId, long courseId, String title, String description, int sortOrder) {
        this.chapterId = chapterId;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.sortOrder = sortOrder;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public List<Lesson> getLessons() {
        return lessons;
    }

    public void setLessons(List<Lesson> lessons) {
        this.lessons = (lessons != null) ? lessons : new ArrayList<>();
    }

    public void addLesson(Lesson lesson) {
        if (lesson != null) {
            this.lessons.add(lesson);
        }
    }

    public int getLessonCount() {
        return (lessons != null) ? lessons.size() : 0;
    }
}
