package model;

import java.io.Serializable;

public class QuizOption implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private String content;
    private boolean correct;
    private int sortOrder;

    public QuizOption() {
    }

    public QuizOption(long id, String content, boolean correct) {
        this.id = id;
        this.content = content;
        this.correct = correct;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isCorrect() {
        return correct;
    }

    public void setCorrect(boolean correct) {
        this.correct = correct;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
}
