
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<main class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-7 col-lg-6">

            <div class="card rounded-4 shadow-sm border-0">
                <div class="card-body p-4 p-md-5 text-center">

                    <i class="bi bi-book-half display-3 text-primary"></i>

                    <h1 class="h3 fw-bold mt-3">
                        Đăng ký khóa học
                    </h1>

                    <!-- Tên khóa học -->
                    <h2 class="h5 mt-3 mb-4">
                        ${safeTitle}
                    </h2>

                    <!-- Trạng thái khóa học -->
                    <div class="alert alert-info" role="status">
                        ${statusMessage}
                    </div>

                    <!-- Kết quả sau khi đăng ký -->
                    <div class="alert alert-success
                         ${empty resultMessage ? 'd-none' : ''}"
                         role="status">
                        ${resultMessage}
                    </div>

                    <!-- Chỉ hiển thị khi được đăng ký -->
                    <form method="post"
                          class="${canEnroll ? '' : 'd-none'}"
                          action="${pageContext.request.contextPath}/student/enroll">

                        <input type="hidden"
                               name="courseId"
                               value="${courseId}">

                        <input type="hidden"
                               name="csrfToken"
                               value="${csrfToken}">

                        <button type="submit"
                                class="btn btn-primary rounded-pill px-4 py-2">
                            Xác nhận đăng ký miễn phí
                        </button>
                    </form>

                    <a href="${pageContext.request.contextPath}/"
                       class="btn btn-outline-secondary rounded-pill mt-3">
                        Về trang chủ
                    </a>

                </div>
            </div>
        </div>
    </div>
</main>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>

</body>
</html>
