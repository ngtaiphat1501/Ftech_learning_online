<%-- 
    Document   : courses
    Created on : Oct 18, 2026, 6:45:01 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.StudentCourse"%>
<%@page import="model.CourseReview"%>
<%@page import="java.util.Map"%>

<%!
    private String escape(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    List<StudentCourse> list
            = (List<StudentCourse>) request.getAttribute("list");

    String contextPath = request.getContextPath();
    Map<Long, CourseReview> reviews = (Map<Long, CourseReview>) request.getAttribute("reviews");

    int studyingCount = 0;
    int completedCount = 0;
    int unavailableCount = 0;

    for (StudentCourse course : list) {
        if (!"ACTIVE".equals(course.getAccessStatus())) {
            unavailableCount++;
        } else if (course.isCompleted()) {
            completedCount++;
        } else {
            studyingCount++;
        }
    }
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp"%>

<style>
    .review-stars { display:inline-flex; flex-direction:row-reverse; gap:10px; }
    .review-stars input { position:absolute; width:1px; height:1px; opacity:0; }
    .review-stars label { font-size:2.25rem; color:var(--bs-secondary-color); cursor:pointer; transition:color .15s, transform .15s; }
    .review-stars input:checked ~ label,
    .review-stars label:hover,
    .review-stars label:hover ~ label { color:#ffc107; }
    .review-stars label:hover { transform:translateY(-2px); }
    .review-stars input:focus-visible + label { outline:2px solid var(--bs-primary); border-radius:6px; }
</style>

<main class="container-xl py-4 py-lg-5">

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <div>
            <h1 class="h2 fw-bold mb-2">Khóa học của tôi</h1>
            <p class="text-body-secondary mb-0">
                Theo dõi tiến độ và tiếp tục hành trình học tập của bạn.
            </p>
        </div>

        <a href="<%= contextPath %>/courses"
           class="btn btn-outline-primary rounded-pill px-4">
            <i class="bi bi-search me-2"></i>
            Khám phá khóa học
        </a>
    </div>

    <% if ("1".equals(request.getParameter("reviewSaved"))) { %>
    <div class="alert alert-success rounded-3" role="status">
        <i class="bi bi-check-circle me-2"></i>Đã lưu đánh giá khóa học của bạn.
    </div>
    <% } %>

    <div class="row g-3 mb-4">

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Tổng số khóa
                    </div>
                    <div class="h3 fw-bold mb-0">
                        <%= list.size() %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Chưa hoàn thành
                    </div>
                    <div class="h3 fw-bold text-primary mb-0">
                        <%= studyingCount %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Đã hoàn thành
                    </div>
                    <div class="h3 fw-bold text-success mb-0">
                        <%= completedCount %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6 col-lg-3">
            <div class="card h-100 rounded-4">
                <div class="card-body">
                    <div class="text-body-secondary small mb-2">
                        Tạm dừng / thu hồi
                    </div>
                    <div class="h3 fw-bold text-warning mb-0">
                        <%= unavailableCount %>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <% if (list.isEmpty()) { %>

    <div class="card rounded-4 text-center">
        <div class="card-body py-5">
            <i class="bi bi-journal-bookmark display-3 text-body-secondary"></i>

            <h2 class="h4 mt-4">Bạn chưa đăng ký khóa học nào</h2>

            <p class="text-body-secondary mb-4">
                Khám phá và chọn một khóa học phù hợp để bắt đầu.
            </p>

            <a href="<%= contextPath %>/courses"
               class="btn btn-primary rounded-pill px-4">
                Khám phá ngay
            </a>
        </div>
    </div>

    <% } else { %>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">

        <% for (StudentCourse course : list) {
            boolean active = "ACTIVE".equals(course.getAccessStatus());
            CourseReview review = reviews == null ? null : reviews.get(course.getCourseId());
            boolean canReview = active && course.isCompleted() && review != null && review.isEligible();
            boolean revoked = "REVOKED".equals(course.getAccessStatus());

            String imageUrl = course.getThumbnailUrl();

            boolean hasImage = imageUrl != null
                    && (imageUrl.startsWith("https://")
                    || imageUrl.startsWith("http://"));

            String progress = course.getProgressPercent().toPlainString();
        %>

        <div class="col">
            <article id="course-<%= course.getCourseId() %>" class="card h-100 rounded-4 overflow-hidden">

                <div class="ratio ratio-16x9 bg-body-tertiary">

                    <% if (hasImage) { %>

                    <img src="<%= escape(imageUrl) %>"
                         alt="<%= escape(course.getTitle()) %>"
                         class="object-fit-cover"
                         loading="lazy">

                    <% } else { %>

                    <div class="d-flex align-items-center justify-content-center">
                        <i class="bi bi-book display-3 text-primary"></i>
                    </div>

                    <% } %>

                </div>

                <div class="card-body d-flex flex-column p-4">

                    <div class="mb-3">

                        <% if (!active) { %>

                        <span class="badge <%= revoked ? "text-bg-danger" : "text-bg-warning" %>">
                            <%= revoked ? "Đã thu hồi quyền học" : "Tạm dừng quyền học" %>
                        </span>

                        <% } else if (course.isCompleted()) { %>

                        <span class="badge text-bg-success">
                            Đã hoàn thành
                        </span>

                        <% } else { %>

                        <span class="badge text-bg-primary">
                            Chưa hoàn thành
                        </span>

                        <% } %>

                    </div>

                    <h2 class="h5 fw-bold mb-3">
                        <%= escape(course.getTitle()) %>
                    </h2>

                    <p class="small text-body-secondary mb-4">
                        <i class="bi bi-person-circle me-2"></i>
                        <%= escape(course.getInstructorName()) %>
                    </p>

                    <div class="mt-auto">

                        <div class="d-flex justify-content-between small mb-2">
                            <span>Tiến độ bài học</span>
                            <span class="fw-semibold">
                                <%= progress %>%
                            </span>
                        </div>

                        <div class="progress mb-2"
                             role="progressbar"
                             aria-label="Tiến độ bài học"
                             aria-valuenow="<%= progress %>"
                             aria-valuemin="0"
                             aria-valuemax="100">

                            <div class="progress-bar <%= course.isCompleted() ? "bg-success" : "" %>"
                                 style="width: <%= progress %>%">
                            </div>
                        </div>

                        <p class="small text-body-secondary mb-4">
                            Đã hoàn thành
                            <%= course.getCompletedLessons() %>/<%= course.getTotalLessons() %>
                            bài bắt buộc
                        </p>

                        <% if (active) { %>

                        <a href="<%= contextPath %>/student/learn?courseId=<%= course.getCourseId() %>"
                           class="btn btn-primary w-100">
                            <i class="bi bi-play-circle me-2"></i>
                            <%= course.isCompleted() ? "Xem lại khóa học" : "Tiếp tục học" %>
                        </a>

                        <% if (course.isCompleted()) { %>
                        <a href="<%= contextPath %>/student/certificate?courseId=<%= course.getCourseId() %>"
                           class="btn btn-warning w-100 mt-2 fw-bold text-dark rounded-3 d-flex align-items-center justify-content-center gap-2 shadow-sm">
                            <i class="bi bi-award-fill fs-5 text-dark"></i>
                            <span>Xem chứng chỉ hoàn thành</span>
                        </a>
                        <% } %>

                        <% } else { %>

                        <button type="button"
                                class="btn btn-outline-secondary w-100"
                                disabled>
                            <i class="bi bi-lock me-2"></i>
                            Chưa thể truy cập
                        </button>

                        <% } %>

                        <% if (canReview) { %>
                        <button type="button" class="btn btn-outline-warning w-100 mt-2"
                                data-bs-toggle="modal" data-bs-target="#reviewModal-<%= course.getCourseId() %>">
                            <% if (review.isExisting()) { %>
                            <span aria-label="<%= review.getRating() %> trên 5 sao">
                                <% for (int star=1; star<=5; star++) { %>
                                <i class="bi <%= star<=review.getRating()?"bi-star-fill":"bi-star" %>" aria-hidden="true"></i>
                                <% } %>
                            </span>
                            <span class="ms-2">Sửa đánh giá</span>
                            <% } else { %>
                            <i class="bi bi-star me-2"></i>Đánh giá khóa học
                            <% } %>
                        </button>
                        <% } %>

                    </div>
                </div>
            </article>
            <% if (canReview) { %>
            <div class="modal fade" id="reviewModal-<%= course.getCourseId() %>" tabindex="-1"
                 aria-labelledby="reviewTitle-<%= course.getCourseId() %>" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content rounded-4">
                        <form method="post" action="<%= contextPath %>/student/review">
                            <div class="modal-header border-0 pb-0">
                                <h2 class="modal-title fs-5 fw-bold" id="reviewTitle-<%= course.getCourseId() %>">
                                    <%= review.isExisting()?"Cập nhật đánh giá":"Đánh giá khóa học" %>
                                </h2>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                            </div>
                            <div class="modal-body p-4">
                                <p class="text-body-secondary"><%= escape(course.getTitle()) %></p>
                                <input type="hidden" name="courseId" value="<%= course.getCourseId() %>">
                                <input type="hidden" name="csrfToken" value="<%= escape((String)session.getAttribute("csrfToken")) %>">
                                <fieldset class="text-center mb-4">
                                    <legend class="fs-6">Bạn cảm thấy khóa học thế nào?</legend>
                                    <div class="review-stars">
                                        <% for (int star=5; star>=1; star--) { %>
                                        <input type="radio" name="rating" id="star-<%= course.getCourseId() %>-<%= star %>"
                                               value="<%= star %>" required <%= review.getRating()==star?"checked":"" %>
                                               data-review-rating="<%= course.getCourseId() %>">
                                        <label for="star-<%= course.getCourseId() %>-<%= star %>" title="<%= star %> sao">
                                            <i class="bi bi-star-fill" aria-hidden="true"></i>
                                            <span class="visually-hidden"><%= star %> sao</span>
                                        </label>
                                        <% } %>
                                    </div>
                                    <p class="small text-body-secondary mt-2 mb-0" id="ratingText-<%= course.getCourseId() %>" aria-live="polite">
                                        <%= review.isExisting()?review.getRating()+"/5 sao":"Bấm chọn từ 1 đến 5 sao" %>
                                    </p>
                                </fieldset>
                                <label for="reviewComment-<%= course.getCourseId() %>" class="form-label">Nhận xét của bạn</label>
                                <textarea id="reviewComment-<%= course.getCourseId() %>" name="comment" class="form-control"
                                          rows="4" maxlength="2000" placeholder="Chia sẻ điều bạn thích hoặc góp ý để khóa học tốt hơn…"><%= escape(review.getComment()) %></textarea>
                                <div class="form-text">Không bắt buộc, tối đa 2000 ký tự.</div>
                            </div>
                            <div class="modal-footer border-0 pt-0">
                                <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal">Để sau</button>
                                <button type="submit" class="btn btn-primary rounded-pill px-4"><%= review.isExisting()?"Lưu thay đổi":"Gửi đánh giá" %></button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <% } %>

    </div>

    <% } %>

</main>
<script>
    document.querySelectorAll('[data-review-rating]').forEach(function (input) {
        input.addEventListener('change', function () {
            var labels = ['', 'Rất không hài lòng', 'Chưa hài lòng', 'Bình thường', 'Hài lòng', 'Rất hài lòng'];
            var target = document.getElementById('ratingText-' + input.dataset.reviewRating);
            target.textContent = input.value + '/5 — ' + labels[Number(input.value)];
        });
    });
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp"%>