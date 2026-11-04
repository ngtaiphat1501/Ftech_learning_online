package model;

import java.util.ArrayList;
import java.util.List;

public class CurriculumChapter {

    private long chapterId;
    private long courseId;
    private String title;
    private String description;
    private int sortOrder;
    private List<CurriculumLesson> lessons = new ArrayList<>();

    public CurriculumChapter() {
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

    public List<CurriculumLesson> getLessons() {
        return lessons;
    }

    public void setLessons(List<CurriculumLesson> lessons) {
        this.lessons = lessons;
    }
}