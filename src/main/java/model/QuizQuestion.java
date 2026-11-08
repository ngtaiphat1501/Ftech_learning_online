package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class QuizQuestion implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private long quizId;
    private String content;
    private String explanation;
    private BigDecimal points = BigDecimal.ONE;
    private int sortOrder = 1;
    private long selectedOptionId;
    private List<QuizOption> options = new ArrayList<>();

    public QuizQuestion() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getQuizId() {
        return quizId;
    }

    public void setQuizId(long quizId) {
        this.quizId = quizId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public BigDecimal getPoints() {
        return points;
    }

    public void setPoints(BigDecimal points) {
        this.points = points;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public long getSelectedOptionId() {
        return selectedOptionId;
    }

    public void setSelectedOptionId(long selectedOptionId) {
        this.selectedOptionId = selectedOptionId;
    }

    public List<QuizOption> getOptions() {
        return options;
    }

    public void setOptions(List<QuizOption> options) {
        this.options = options;
    }
}
