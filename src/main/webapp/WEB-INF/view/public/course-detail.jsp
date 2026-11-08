<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Course"%>
<%@page import="model.Chapter"%>
<%@page import="model.Lesson"%>
<%@page import="model.CourseReview"%>

<%
    Course course = (Course) request.getAttribute("course");
    if (course == null) {
        response.sendRedirect(request.getContextPath() + "/courses");
        return;
    }
    Boolean isEnrolled = (Boolean) request.getAttribute("isEnrolled");
    Boolean isInCart = (Boolean) request.getAttribute("isInCart");
    List<CourseReview> reviews = (List<CourseReview>) request.getAttribute("reviews");

    if (isEnrolled == null) isEnrolled = false;
    if (isInCart == null) isInCart = false;

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .course-detail-container {
        padding-top: 2rem;
        padding-bottom: 5rem;
    }
    .sticky-course-card {
        position: sticky;
        top: 90px;
        z-index: 10;
        background-color: #151821 !important;
        border: 1px solid rgba(255, 255, 255, 0.12) !important;
        border-radius: 1.25rem !important;
        box-shadow: 0 20px 45px rgba(0, 0, 0, 0.6) !important;
    }
    .outline-accordion .accordion-item {
        background-color: #171a22 !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        border-radius: 0.85rem !important;
        margin-bottom: 0.75rem;
        overflow: hidden;
    }
    .outline-accordion .accordion-button {
        background-color: #171a22 !important;
        color: #f1f5f9 !important;
        font-weight: 600;
        box-shadow: none !important;
        padding: 1rem 1.25rem;
    }
    .outline-accordion .accordion-button:not(.collapsed) {
        background-color: #1f232d !important;
        color: #60a5fa !important;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }
    .outline-accordion .accordion-body {
        padding: 0;
        background-color: #13151c;
    }
    .lesson-item-row {
        padding: 0.85rem 1.25rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        transition: background 0.15s ease;
    }
    .lesson-item-row:last-child {
        border-bottom: none;
    }
    .lesson-item-row:hover {
        background-color: rgba(255, 255, 255, 0.03);
    }
    .review-card {
        background-color: #171a22;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 1rem;
        padding: 1.25rem;
    }
    .rating-star-interactive {
        cursor: pointer;
        font-size: 1.5rem;
        color: #475569;
        transition: color 0.15s ease;
    }
    .rating-star-interactive.active,
    .rating-star-interactive:hover {
        color: #fbbf24;
    }
</style>

<main class="container course-detail-container">

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/courses" class="text-secondary text-decoration-none">Courses</a>
            </li>
            <li class="breadcrumb-item active text-white text-truncate" style="max-width: 500px;" aria-current="page">
                <%= course.getTitle() %>
            </li>
        </ol>
    </nav>

    <div class="row g-4 g-xl-5">

        <!-- ============================================== -->
        <!-- LEFT COLUMN: PUBLIC COURSE INFORMATION         -->
        <!-- ============================================== -->
        <div class="col-12 col-lg-7 col-xl-8">

            <!-- Title & Bookmark -->
            <div class="d-flex align-items-start justify-content-between gap-3 mb-2">
                <h1 class="display-6 fw-bold text-white mb-0" style="font-size: clamp(1.8rem, 3.5vw, 2.5rem);">
                    <%= course.getTitle() %>
                </h1>
                <button type="button" class="btn btn-icon rounded-circle bg-dark border border-secondary border-opacity-25 text-secondary flex-shrink-0" title="Lưu khóa học">
                    <i class="bi bi-bookmark fs-5"></i>
                </button>
            </div>

            <!-- Subtitle from Database -->
            <% if (course.getSubtitle() != null && !course.getSubtitle().isBlank()) { %>
                <p class="text-secondary fs-6 mb-3 lh-base">
                    <%= course.getSubtitle() %>
                </p>
            <% } %>

            <!-- Category & Rating row -->
            <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1.5 fw-medium">
                    <%= course.getCategoryName() %>
                </span>
                <% if (course.getTotalRatings() > 0) { %>
                <div class="d-flex align-items-center text-warning small ms-1">
                    <i class="bi bi-star-fill me-1"></i>
                    <strong class="text-white"><%= course.getAverageRating() %></strong>
                    <span class="text-secondary ms-1">· <%= course.getTotalRatings() %> đánh giá</span>
                </div>
                <% } else { %>
                <div class="d-flex align-items-center text-secondary small ms-1">
                    <i class="bi bi-star me-1"></i>
                    <span>Chưa có đánh giá</span>
                </div>
                <% } %>
            </div>

            <!-- Meta Badges: Learners, Modules, Lessons, Hours -->
            <div class="d-flex flex-wrap gap-2 mb-4">
                <div class="badge bg-dark border border-secondary border-opacity-25 text-secondary fw-normal py-2 px-3 rounded-pill d-flex align-items-center gap-1.5">
                    <i class="bi bi-people text-primary"></i>
                    <span><%= course.getLearnerCount() %> học viên</span>
                </div>
                <div class="badge bg-dark border border-secondary border-opacity-25 text-secondary fw-normal py-2 px-3 rounded-pill d-flex align-items-center gap-1.5">
                    <i class="bi bi-stack text-info"></i>
                    <span><%= course.getModuleCount() %> chương</span>
                </div>
                <div class="badge bg-dark border border-secondary border-opacity-25 text-secondary fw-normal py-2 px-3 rounded-pill d-flex align-items-center gap-1.5">
                    <i class="bi bi-collection-play text-warning"></i>
                    <span><%= course.getLessonCount() %> bài học</span>
                </div>
                <div class="badge bg-dark border border-secondary border-opacity-25 text-secondary fw-normal py-2 px-3 rounded-pill d-flex align-items-center gap-1.5">
                    <i class="bi bi-clock text-success"></i>
                    <span><%= course.getEstimatedHours() %> giờ học</span>
                </div>
            </div>

            <!-- Description from Database -->
            <div class="mb-4 text-secondary lh-lg fs-6">
                <%= course.getDescription() %>
            </div>

            <!-- Instructor Byline -->
            <div class="d-flex align-items-center gap-2 text-secondary small mb-5 pb-3 border-bottom border-secondary border-opacity-25">
                <span>Giảng viên:</span>
                <strong class="text-white fs-6"><%= course.getInstructorName() %></strong>
                <% if (course.getInstructorHeadline() != null && !course.getInstructorHeadline().isBlank()) { %>
                    <span class="text-secondary d-none d-md-inline">· <%= course.getInstructorHeadline() %></span>
                <% } %>
            </div>

            <!-- ================= WHAT YOU'LL LEARN (LearningObjectives in DB) ================= -->
            <% if (!course.getLearningObjectivesList().isEmpty()) { %>
                <section class="mb-5">
                    <h3 class="h5 fw-bold text-white mb-3 d-flex align-items-center gap-2">
                        <i class="bi bi-check2-circle text-primary"></i>
                        <span>Những gì bạn sẽ học được</span>
                    </h3>
                    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 shadow-sm">
                        <div class="row g-3">
                            <% for (String objective : course.getLearningObjectivesList()) { %>
                                <div class="col-12 col-md-6 d-flex align-items-start gap-2.5">
                                    <i class="bi bi-check-circle-fill text-primary flex-shrink-0 mt-1"></i>
                                    <span class="text-light small lh-base"><%= objective %></span>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </section>
            <% } %>

            <!-- ================= COURSE OUTLINE (CHAPTERS & LESSONS IN DB) ================= -->
            <section class="mb-5">
                <div class="d-flex align-items-baseline justify-content-between mb-3">
                    <div>
                        <h3 class="h5 fw-bold text-white mb-1 d-flex align-items-center gap-2">
                            <i class="bi bi-journals text-primary"></i>
                            <span>Nội dung khóa học</span>
                        </h3>
                        <p class="text-secondary small mb-0">
                            <%= course.getModuleCount() %> chương · <%= course.getLessonCount() %> bài học
                        </p>
                    </div>
                    <button type="button" class="btn btn-link text-primary text-decoration-none small p-0" id="toggleAllChapters">
                        Mở tất cả
                    </button>
                </div>

                <div class="accordion outline-accordion" id="courseOutlineAccordion">
                    <%
                        List<Chapter> chapters = course.getChapters();
                        if (chapters != null && !chapters.isEmpty()) {
                            int chapterIndex = 0;
                            for (Chapter chapter : chapters) {
                                chapterIndex++;
                                String collapseId = "collapseChapter" + chapter.getChapterId();
                                boolean isFirst = (chapterIndex == 1);
                    %>
                        <div class="accordion-item shadow-sm">
                            <h2 class="accordion-header" id="heading<%= chapter.getChapterId() %>">
                                <button class="accordion-button <%= isFirst ? "" : "collapsed" %> d-flex align-items-center justify-content-between"
                                        type="button"
                                        data-bs-toggle="collapse"
                                        data-bs-target="#<%= collapseId %>"
                                        aria-expanded="<%= isFirst ? "true" : "false" %>"
                                        aria-controls="<%= collapseId %>">
                                    <div class="d-flex flex-column text-start me-3">
                                        <span class="fw-semibold text-white"><%= chapter.getTitle() %></span>
                                        <% if (chapter.getDescription() != null && !chapter.getDescription().isBlank()) { %>
                                            <span class="text-secondary small fw-normal mt-0.5"><%= chapter.getDescription() %></span>
                                        <% } %>
                                    </div>
                                    <span class="badge bg-body-tertiary text-secondary border border-secondary border-opacity-25 rounded-pill px-2.5 py-1 small fw-normal ms-auto me-3">
                                        <%= chapter.getLessonCount() %> bài
                                    </span>
                                </button>
                            </h2>
                            <div id="<%= collapseId %>"
                                 class="accordion-collapse collapse <%= isFirst ? "show" : "" %>"
                                 aria-labelledby="heading<%= chapter.getChapterId() %>">
                                <div class="accordion-body">
                                    <%
                                        List<Lesson> lessons = chapter.getLessons();
                                        if (lessons != null && !lessons.isEmpty()) {
                                            for (Lesson lesson : lessons) {
                                    %>
                                        <div class="lesson-item-row d-flex align-items-center justify-content-between gap-3">
                                            <div class="d-flex align-items-center gap-3 min-w-0">
                                                <% if (lesson.isPreview()) { %>
                                                    <i class="bi bi-play-circle-fill text-success fs-5 flex-shrink-0"></i>
                                                <% } else { %>
                                                    <i class="bi bi-lock-fill text-secondary fs-5 flex-shrink-0"></i>
                                                <% } %>
                                                <div class="min-w-0">
                                                    <div class="text-white small fw-medium text-truncate" title="<%= lesson.getTitle() %>">
                                                        <%= lesson.getTitle() %>
                                                    </div>
                                                    <span class="text-secondary small" style="font-size: 0.78rem;">
                                                        Thời lượng: <%= lesson.getFormattedDuration() %>
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="flex-shrink-0">
                                                <% if (lesson.isPreview()) { %>
                                                    <a href="${pageContext.request.contextPath}/preview?lessonId=<%= lesson.getLessonId() %>"
                                                       class="btn btn-outline-success btn-sm rounded-pill px-3 py-1"
                                                       style="font-size: 0.8rem;">
                                                        <i class="bi bi-play-fill me-1"></i>Học thử
                                                    </a>
                                                <% } else if (isEnrolled) { %>
                                                    <a href="${pageContext.request.contextPath}/student/learn?courseId=<%= course.getId() %>&lessonId=<%= lesson.getLessonId() %>"
                                                       class="btn btn-outline-primary btn-sm rounded-pill px-3 py-1"
                                                       style="font-size: 0.8rem;">
                                                        Vào học
                                                    </a>
                                                <% } else { %>
                                                    <span class="badge bg-dark text-secondary border border-secondary border-opacity-25 rounded-pill px-2.5 py-1" style="font-size: 0.75rem;">
                                                        Đã khóa
                                                    </span>
                                                <% } %>
                                            </div>
                                        </div>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="p-3 text-secondary small text-center">Chưa có bài học nào trong chương này.</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="alert alert-secondary text-center small py-3">Nội dung khóa học đang được cập nhật.</div>
                    <% } %>
                </div>
            </section>

            <!-- ================= REQUIREMENTS & TARGET AUDIENCE IN DB ================= -->
            <% if (!course.getRequirementsList().isEmpty() || (course.getTargetAudience() != null && !course.getTargetAudience().isBlank())) { %>
                <section class="mb-5">
                    <div class="row g-4">
                        <% if (!course.getRequirementsList().isEmpty()) { %>
                            <div class="col-12 col-md-6">
                                <h3 class="h6 fw-bold text-white mb-2 d-flex align-items-center gap-2">
                                    <i class="bi bi-info-circle text-primary"></i>
                                    <span>Yêu cầu tiên quyết</span>
                                </h3>
                                <ul class="list-unstyled text-secondary small mb-0 d-flex flex-column gap-1.5">
                                    <% for (String req : course.getRequirementsList()) { %>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-arrow-right-short text-primary fs-6 mt-0.5"></i>
                                            <span><%= req %></span>
                                        </li>
                                    <% } %>
                                </ul>
                            </div>
                        <% } %>

                        <% if (course.getTargetAudience() != null && !course.getTargetAudience().isBlank()) { %>
                            <div class="col-12 col-md-6">
                                <h3 class="h6 fw-bold text-white mb-2 d-flex align-items-center gap-2">
                                    <i class="bi bi-person-check text-primary"></i>
                                    <span>Khóa học dành cho ai</span>
                                </h3>
                                <p class="text-secondary small mb-0 lh-base">
                                    <%= course.getTargetAudience() %>
                                </p>
                            </div>
                        <% } %>
                    </div>
                </section>
            <% } %>

            <!-- ================= LEARNER REVIEWS IN DB ================= -->
            <section class="mb-5">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <h3 class="h5 fw-bold text-white mb-0 d-flex align-items-center gap-2">
                        <i class="bi bi-chat-heart text-primary"></i>
                        <span>Đánh giá từ học viên</span>
                    </h3>
                <% if (course.getTotalRatings() > 0) { %>
                    <div class="d-flex align-items-center gap-1 text-warning small">
                        <% for (int s = 1; s <= 5; s++) { %>
                            <i class="bi <%= s <= Math.round(course.getAverageRating()) ? "bi-star-fill" : "bi-star" %>"></i>
                        <% } %>
                        <strong class="text-white ms-1"><%= course.getAverageRating() %> / 5</strong>
                        <span class="text-secondary">· <%= course.getTotalRatings() %> đánh giá</span>
                    </div>
                <% } else { %>
                    <div class="text-secondary small">
                        <i class="bi bi-star me-1"></i> Chưa có đánh giá nào
                    </div>
                <% } %>
                </div>

                <!-- Your Rating Form (Interactive Box) -->
                <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 mb-4 shadow-sm">
                    <h6 class="text-white fw-bold mb-2">Đánh giá của bạn</h6>
                    <div class="d-flex align-items-center gap-1 mb-3" id="ratingStarsGroup">
                        <i class="bi bi-star rating-star-interactive" data-star="1"></i>
                        <i class="bi bi-star rating-star-interactive" data-star="2"></i>
                        <i class="bi bi-star rating-star-interactive" data-star="3"></i>
                        <i class="bi bi-star rating-star-interactive" data-star="4"></i>
                        <i class="bi bi-star rating-star-interactive" data-star="5"></i>
                        <span class="text-secondary small ms-2" id="starLabel">Chọn số sao</span>
                    </div>

                    <div class="mb-3">
                        <textarea class="form-control bg-body-tertiary border border-secondary border-opacity-25 text-white py-2.5 px-3 rounded-3"
                                  rows="3"
                                  placeholder="Chia sẻ cảm nhận của bạn về khóa học này (tùy chọn)..."
                                  style="resize: none; font-size: 0.92rem;"></textarea>
                    </div>

                    <div>
                        <button type="button" class="btn btn-primary rounded-3 px-4 py-2 fw-semibold shadow-sm" onclick="alert('Cảm ơn bạn đã gửi đánh giá!')">
                            Gửi đánh giá
                        </button>
                    </div>
                </div>

                <!-- Reviews List or Empty State -->
                <% if (reviews == null || reviews.isEmpty()) { %>
                    <div class="text-center py-5 rounded-4 bg-dark border border-secondary border-opacity-25">
                        <div class="rounded-circle bg-body-tertiary d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px; border: 1px solid rgba(255,255,255,0.1);">
                            <i class="bi bi-inbox fs-3 text-secondary"></i>
                        </div>
                        <h6 class="text-white fw-bold mb-1">Chưa có đánh giá nào</h6>
                        <p class="text-secondary small mb-0">Hãy là người đầu tiên trải nghiệm và chia sẻ nhận xét về khóa học này.</p>
                    </div>
                <% } else { %>
                    <div class="d-flex flex-column gap-3">
                        <% for (CourseReview review : reviews) { %>
                            <div class="review-card shadow-sm">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <div class="d-flex align-items-center gap-2.5">
                                        <% if (review.getStudentAvatar() != null && !review.getStudentAvatar().isBlank()) { %>
                                            <img src="<%= review.getStudentAvatar() %>" alt="Avatar" class="rounded-circle" style="width: 38px; height: 38px; object-fit: cover;">
                                        <% } else { %>
                                            <div class="rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center fw-bold" style="width: 38px; height: 38px;">
                                                <%= review.getStudentName() != null ? review.getStudentName().substring(0, 1) : "U" %>
                                            </div>
                                        <% } %>
                                        <div>
                                            <div class="text-white fw-semibold small"><%= review.getStudentName() %></div>
                                            <div class="text-warning small" style="font-size: 0.75rem;">
                                                <% for (int r = 1; r <= 5; r++) { %>
                                                    <i class="bi <%= r <= review.getRating() ? "bi-star-fill" : "bi-star" %>"></i>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    <span class="text-secondary small" style="font-size: 0.78rem;">
                                        <%= review.getCreatedAt() != null ? review.getCreatedAt().toString().substring(0, 10) : "" %>
                                    </span>
                                </div>
                                <p class="text-light small mb-0 lh-base"><%= review.getComment() %></p>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </section>

            <!-- ================= INSTRUCTOR PROFILE IN DB ================= -->
            <section class="mb-5">
                <h3 class="h5 fw-bold text-white mb-3 d-flex align-items-center gap-2">
                    <i class="bi bi-person-badge text-primary"></i>
                    <span>Giảng viên hướng dẫn</span>
                </h3>
                <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 shadow-sm">
                    <div class="d-flex flex-column flex-sm-row align-items-sm-center gap-3 mb-3">
                        <% if (course.getInstructorAvatar() != null && !course.getInstructorAvatar().isBlank()) { %>
                            <img src="<%= course.getInstructorAvatar() %>" alt="Avatar" class="rounded-circle" style="width: 64px; height: 64px; object-fit: cover;">
                        <% } else { %>
                            <div class="rounded-circle bg-primary-subtle text-primary fs-3 fw-bold d-flex align-items-center justify-content-center" style="width: 64px; height: 64px;">
                                <i class="bi bi-person"></i>
                            </div>
                        <% } %>
                        <div>
                            <h5 class="text-white fw-bold mb-1"><%= course.getInstructorName() %></h5>
                            <p class="text-secondary small mb-0"><%= course.getInstructorHeadline() != null ? course.getInstructorHeadline() : "Giảng viên tại Ftech" %></p>
                        </div>
                    </div>
                    <% if (course.getInstructorBio() != null && !course.getInstructorBio().isBlank()) { %>
                        <p class="text-secondary small mb-0 lh-lg"><%= course.getInstructorBio() %></p>
                    <% } %>
                </div>
            </section>

        </div>

        <!-- ============================================== -->
        <!-- RIGHT COLUMN: STICKY CART & PURCHASE CARD      -->
        <!-- ============================================== -->
        <div class="col-12 col-lg-5 col-xl-4">
            <div class="sticky-course-card p-3 p-xl-4">

                <!-- Course Cover Image ONLY (NO video link, pure thumbnail as requested) -->
                <div class="rounded-3 overflow-hidden mb-3 border border-secondary border-opacity-25" style="aspect-ratio: 16/9; background-color: #0b0d13;">
                    <% if (course.getThumbnailUrl() != null && !course.getThumbnailUrl().isBlank()) { %>
                        <img src="<%= course.getThumbnailUrl() %>"
                             alt="<%= course.getTitle() %>"
                             class="w-100 h-100 object-fit-cover">
                    <% } else { %>
                        <div class="w-100 h-100 d-flex align-items-center justify-content-center">
                            <i class="bi bi-journal-code display-4 text-secondary"></i>
                        </div>
                    <% } %>
                </div>

                <!-- Pricing Display from Database -->
                <div class="mb-3">
                    <div class="d-flex align-items-baseline gap-2">
                        <span class="fw-bold text-white fs-3">
                            <%= course.isFree() ? "Miễn phí" : currency.format(course.getCurrentPrice()) + "đ" %>
                        </span>
                        <% if (course.isDiscounted()) { %>
                            <del class="text-secondary small fs-6">
                                <%= currency.format(course.getListPrice()) %>đ
                            </del>
                            <span class="badge bg-success-subtle text-success border border-success-subtle fw-bold" style="font-size: 0.8rem;">
                                -<%= course.getDiscountPercentage() %>%
                            </span>
                        <% } %>
                    </div>
                </div>

                <!-- Action Buttons: True to Database & Cart operations -->
                <div class="d-flex flex-column gap-2 mb-3">
                    <% if (isEnrolled) { %>
                        <a href="${pageContext.request.contextPath}/student/learn?courseId=<%= course.getId() %>"
                           class="btn btn-success w-100 py-2.5 rounded-3 fw-semibold shadow-sm d-flex align-items-center justify-content-center gap-2">
                            <i class="bi bi-play-circle fs-5"></i>
                            <span>Vào học ngay</span>
                        </a>
                    <% } else if (course.isFree()) { %>
                        <a href="${pageContext.request.contextPath}/student/enroll?courseId=<%= course.getId() %>"
                           class="btn btn-primary w-100 py-2.5 rounded-3 fw-semibold shadow-sm d-flex align-items-center justify-content-center gap-2">
                            <span>Đăng ký học miễn phí</span>
                            <i class="bi bi-arrow-right"></i>
                        </a>
                    <% } else { %>
                        <!-- Mua ngay button -->
                        <button type="button"
                                class="btn btn-primary w-100 py-2.5 rounded-3 fw-semibold shadow-sm d-flex align-items-center justify-content-center gap-2"
                                onclick="handleBuyNow(<%= course.getId() %>)">
                            <span>Mua ngay</span>
                            <i class="bi bi-arrow-right"></i>
                        </button>

                        <!-- Add to Cart / In Cart button -->
                        <% if (isInCart) { %>
                            <button type="button"
                                    id="btnCartAction"
                                    class="btn btn-secondary w-100 py-2.5 rounded-3 fw-semibold d-flex align-items-center justify-content-center gap-2 bg-dark-subtle border-secondary border-opacity-50 text-white"
                                    onclick="removeCartItem(<%= course.getId() %>)">
                                <i class="bi bi-check2 text-success fs-5"></i>
                                <span>Đã có trong giỏ hàng</span>
                                <i class="bi bi-trash3 text-danger ms-1"></i>
                            </button>
                        <% } else { %>
                            <button type="button"
                                    id="btnCartAction"
                                    class="btn btn-outline-secondary text-white w-100 py-2.5 rounded-3 fw-semibold d-flex align-items-center justify-content-center gap-2 border-secondary border-opacity-50"
                                    onclick="addCourseToCart(<%= course.getId() %>)">
                                <i class="bi bi-cart-plus fs-5"></i>
                                <span>Thêm vào giỏ hàng</span>
                            </button>
                        <% } %>
                    <% } %>

                    <!-- Try for free button (only if there are preview lessons in DB) -->
                    <% if (course.getFirstPreviewLessonId() != null) { %>
                        <a href="${pageContext.request.contextPath}/preview?lessonId=<%= course.getFirstPreviewLessonId() %>"
                           class="btn btn-outline-secondary text-white w-100 py-2.5 rounded-3 fw-medium border-secondary border-opacity-50">
                            Học thử bài giảng
                        </a>
                    <% } %>
                </div>

                <!-- Course Attributes directly from Database -->
                <div class="pt-3 mt-3 border-top border-secondary border-opacity-25 small text-secondary">
                    <div class="d-flex justify-content-between mb-2">
                        <span><i class="bi bi-bar-chart-steps me-2 text-info"></i>Trình độ</span>
                        <span class="text-white fw-medium">
                            <%= "BEGINNER".equalsIgnoreCase(course.getLevel()) ? "Cơ bản" :
                                "INTERMEDIATE".equalsIgnoreCase(course.getLevel()) ? "Trung cấp" :
                                "ADVANCED".equalsIgnoreCase(course.getLevel()) ? "Nâng cao" : course.getLevel() %>
                        </span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span><i class="bi bi-clock me-2 text-success"></i>Thời lượng</span>
                        <span class="text-white fw-medium"><%= course.getEstimatedHours() %> giờ học</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span><i class="bi bi-translate me-2 text-warning"></i>Ngôn ngữ</span>
                        <span class="text-white fw-medium"><%= course.getLanguage() != null ? course.getLanguage() : "Tiếng Việt" %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span><i class="bi bi-journal-check me-2 text-primary"></i>Số bài giảng</span>
                        <span class="text-white fw-medium"><%= course.getLessonCount() %> bài</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span><i class="bi bi-people me-2 text-secondary"></i>Học viên</span>
                        <span class="text-white fw-medium"><%= course.getLearnerCount() %> người đã đăng ký</span>
                    </div>
                </div>

            </div>
        </div>

    </div>

</main>

<script>
    function updateCartButtonState(inCart) {
        const btn = document.getElementById("btnCartAction");
        if (!btn) return;
        if (inCart) {
            btn.className = "btn btn-secondary w-100 py-2.5 rounded-3 fw-semibold d-flex align-items-center justify-content-center gap-2 bg-dark-subtle border-secondary border-opacity-50 text-white";
            btn.innerHTML = '<i class="bi bi-check2 text-success fs-5"></i> <span>Đã có trong giỏ hàng</span> <i class="bi bi-trash3 text-danger ms-1"></i>';
            btn.onclick = function () {
                removeCartItem(<%= course.getId() %>);
            };
        } else {
            btn.className = "btn btn-outline-secondary text-white w-100 py-2.5 rounded-3 fw-semibold d-flex align-items-center justify-content-center gap-2 border-secondary border-opacity-50";
            btn.innerHTML = '<i class="bi bi-cart-plus fs-5"></i> <span>Thêm vào giỏ hàng</span>';
            btn.onclick = function () {
                addCourseToCart(<%= course.getId() %>);
            };
        }
    }

    async function handleBuyNow(courseId) {
        <% if (currentUserId == null) { %>
            const signInModalEl = document.getElementById("signInModal");
            if (signInModalEl && typeof bootstrap !== "undefined") {
                new bootstrap.Modal(signInModalEl).show();
            }
        <% } else { %>
            await addCourseToCart(courseId);
            window.location.href = "${pageContext.request.contextPath}/student/cart";
        <% } %>
    }

    // Toggle expand/collapse all chapters
    document.addEventListener("DOMContentLoaded", function () {
        const toggleBtn = document.getElementById("toggleAllChapters");
        if (toggleBtn) {
            let expanded = false;
            toggleBtn.addEventListener("click", function () {
                const collapses = document.querySelectorAll("#courseOutlineAccordion .accordion-collapse");
                expanded = !expanded;
                collapses.forEach(el => {
                    const bsCollapse = bootstrap.Collapse.getOrCreateInstance(el, { toggle: false });
                    if (expanded) bsCollapse.show();
                    else bsCollapse.hide();
                });
                toggleBtn.textContent = expanded ? "Thu gọn tất cả" : "Mở tất cả";
            });
        }

        // Interactive rating stars
        const starGroup = document.getElementById("ratingStarsGroup");
        if (starGroup) {
            const stars = starGroup.querySelectorAll(".rating-star-interactive");
            const label = document.getElementById("starLabel");
            const descriptions = ["Rất tệ", "Tệ", "Bình thường", "Tốt", "Tuyệt vời"];

            stars.forEach(star => {
                star.addEventListener("mouseover", function () {
                    const rating = parseInt(this.dataset.star, 10);
                    stars.forEach((s, idx) => {
                        if (idx < rating) {
                            s.classList.remove("bi-star");
                            s.classList.add("bi-star-fill");
                        } else {
                            s.classList.remove("bi-star-fill");
                            s.classList.add("bi-star");
                        }
                    });
                    if (label) label.textContent = descriptions[rating - 1];
                });

                star.addEventListener("click", function () {
                    const rating = parseInt(this.dataset.star, 10);
                    stars.forEach((s, idx) => {
                        if (idx < rating) {
                            s.classList.add("active");
                        } else {
                            s.classList.remove("active");
                        }
                    });
                });
            });
        }
    });
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
