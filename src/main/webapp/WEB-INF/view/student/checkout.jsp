<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="service.CheckoutService.CheckoutQuote"%>
<%@page import="model.CartItem"%>

<%
    request.setAttribute("pageTitle", "Xác nhận thanh toán - Ftech");
    request.setAttribute("activeMenu", "");
%>
<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<%
    CheckoutQuote quote = (CheckoutQuote) request.getAttribute("quote");
    String checkoutError = (String) request.getAttribute("checkoutError");
    String couponCode = (String) request.getAttribute("couponCode");
    String csrfToken = (String) request.getAttribute("csrfToken");

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);

    if (quote == null) {
        quote = new CheckoutQuote();
    }
%>

<style>
    .checkout-container {
        max-width: 1140px;
        margin: 0 auto;
        padding-top: 2.5rem;
        padding-bottom: 5rem;
    }
    .checkout-card {
        background-color: #151821 !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        border-radius: 1.25rem !important;
        padding: 1.5rem !important;
    }
    .checkout-item-row {
        background-color: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 0.85rem;
        padding: 1rem 1.15rem;
        transition: all 0.2s ease;
    }
    .checkout-item-row:hover {
        border-color: rgba(99, 102, 241, 0.35);
        background-color: rgba(255, 255, 255, 0.04);
    }
    .checkout-item-thumb {
        width: 72px;
        height: 72px;
        object-fit: cover;
        border-radius: 0.65rem;
        background-color: #0d0f15;
    }
    .btn-remove-checkout {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        color: #94a3b8;
        background: transparent;
        transition: all 0.2s ease;
    }
    .btn-remove-checkout:hover {
        color: #ef4444 !important;
        background-color: rgba(239, 68, 68, 0.12) !important;
        transform: scale(1.1);
    }
    .qr-container {
        background-color: #10121a;
        border: 1px dashed rgba(255, 255, 255, 0.2);
        border-radius: 1rem;
        padding: 1.25rem;
    }
    .qr-image {
        max-width: 220px;
        border-radius: 0.75rem;
        background-color: #ffffff;
        padding: 0.5rem;
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
    }
    .form-check-input:checked {
        background-color: #4f46e5;
        border-color: #4f46e5;
    }
    .toast-notice {
        position: fixed;
        bottom: 2rem;
        right: 2rem;
        z-index: 1080;
        min-width: 320px;
    }
</style>

<main class="container checkout-container">

    <!-- Header Navigation & Title -->
    <div class="d-flex align-items-center gap-3 mb-4">
        <a href="${pageContext.request.contextPath}/student/cart" 
           class="btn btn-outline-secondary btn-sm rounded-circle p-2 text-white border-secondary border-opacity-50"
           title="Quay lại giỏ hàng">
            <i class="bi bi-arrow-left fs-5"></i>
        </a>
        <div>
            <h1 class="h3 fw-bold text-white mb-0">Thanh toán đơn hàng</h1>
            <p class="text-secondary small mb-0">Chọn khóa học muốn thanh toán hoặc bỏ khóa học ra khỏi đơn hiện tại</p>
        </div>
    </div>

    <!-- Error Alert if any -->
    <% if (checkoutError != null && !checkoutError.isBlank()) { %>
        <div class="alert alert-danger py-2.5 small mb-4 border-0 d-flex align-items-center gap-2 rounded-3">
            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
            <span><%= checkoutError %></span>
        </div>
    <% } %>

    <div class="row g-4 align-items-start">

        <!-- LEFT COLUMN: Courses List & Item Selection (7 cols) -->
        <div class="col-lg-7">

            <div class="checkout-card shadow-sm mb-4">
                
                <!-- Card Header with Select All Checkbox -->
                <div class="d-flex align-items-center justify-content-between pb-3 mb-3 border-bottom border-secondary border-opacity-25 flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                        <div class="form-check m-0">
                            <input class="form-check-input" type="checkbox" id="selectAllCheckbox" checked onchange="toggleSelectAll(this.checked)">
                            <label class="form-check-label text-white fw-bold cursor-pointer" for="selectAllCheckbox">
                                Chọn tất cả
                            </label>
                        </div>
                        <span class="text-secondary small">
                            (<span id="selectedCountDisplay"><%= quote.cartItems.size() %></span>/<span id="totalCountDisplay"><%= quote.cartItems.size() %></span> khóa học)
                        </span>
                    </div>

                    <a href="${pageContext.request.contextPath}/student/cart" class="text-primary small text-decoration-none">
                        <i class="bi bi-cart3 me-1"></i>Xem giỏ hàng đầy đủ
                    </a>
                </div>

                <!-- Empty Selection Warning (Hidden initially) -->
                <div id="emptySelectionWarning" class="alert alert-warning py-3 small mb-3 border-0 rounded-3 d-none">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-exclamation-circle-fill fs-5"></i>
                        <span class="fw-semibold">Bạn chưa chọn khóa học nào để thanh toán.</span>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-warning btn-sm fw-medium px-3" onclick="selectAllCourses()">
                            <i class="bi bi-check2-all me-1"></i>Chọn lại tất cả
                        </button>
                        <a href="${pageContext.request.contextPath}/student/cart" class="btn btn-outline-secondary btn-sm text-white">
                            Về giỏ hàng
                        </a>
                    </div>
                </div>

                <!-- Courses List Container -->
                <div class="d-flex flex-column gap-3" id="checkoutCoursesList">
                    <% for (CartItem item : quote.cartItems) {
                        BigDecimal p = item.getCurrentPriceVnd() != null ? item.getCurrentPriceVnd() : BigDecimal.ZERO;
                        int discountPercent = item.getDiscountPercentage();
                    %>
                        <div class="checkout-item-row d-flex align-items-center gap-3" id="course-row-<%= item.getCourseId() %>">
                            
                            <!-- Individual Checkbox -->
                            <div class="form-check m-0">
                                <input class="form-check-input course-checkbox" 
                                       type="checkbox" 
                                       value="<%= item.getCourseId() %>"
                                       data-price="<%= p %>"
                                       data-list-price="<%= item.getListPriceVnd() != null ? item.getListPriceVnd() : p %>"
                                       data-title="<%= item.getTitle() %>"
                                       checked
                                       onchange="onCourseSelectionChange()">
                            </div>

                            <!-- Thumbnail -->
                            <% if (item.getThumbnailUrl() != null && !item.getThumbnailUrl().isBlank()) { %>
                                <img src="<%= item.getThumbnailUrl() %>" alt="<%= item.getTitle() %>" class="checkout-item-thumb flex-shrink-0">
                            <% } else { %>
                                <div class="checkout-item-thumb d-flex align-items-center justify-content-center flex-shrink-0 text-secondary">
                                    <i class="bi bi-journal-code fs-3 text-primary"></i>
                                </div>
                            <% } %>

                            <!-- Title, Instructor, Pricing -->
                            <div class="flex-grow-1 min-w-0">
                                <h6 class="text-white fw-semibold mb-1 text-truncate" title="<%= item.getTitle() %>">
                                    <a href="${pageContext.request.contextPath}/course?id=<%= item.getCourseId() %>" class="text-white text-decoration-none hover-primary">
                                        <%= item.getTitle() %>
                                    </a>
                                </h6>
                                <div class="d-flex align-items-baseline flex-wrap gap-2">
                                    <span class="fw-bold text-white"><%= currency.format(p) %>đ</span>
                                    <% if (discountPercent > 0) { %>
                                        <del class="text-secondary small"><%= currency.format(item.getListPriceVnd()) %>đ</del>
                                        <span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-25" style="font-size: 0.72rem;">
                                            -<%= discountPercent %>%
                                        </span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Remove / Exclude Mark ('x') -->
                            <button type="button" 
                                    class="btn btn-remove-checkout flex-shrink-0" 
                                    onclick="excludeCourseFromCheckout(<%= item.getCourseId() %>)"
                                    title="Bỏ khỏi đợt thanh toán này (vẫn giữ trong giỏ hàng)"
                                    aria-label="Bỏ khỏi đợt thanh toán">
                                <i class="bi bi-x-lg"></i>
                            </button>

                        </div>
                    <% } %>
                </div>

                <!-- Footer Note inside Card -->
                <div class="d-flex align-items-center gap-2 text-secondary small pt-3 mt-3 border-top border-secondary border-opacity-25">
                    <i class="bi bi-info-circle text-info flex-shrink-0"></i>
                    <span>Bấm dấu <b class="text-white">✕</b> chỉ bỏ khóa học khỏi đơn này, khóa học <b>vẫn được lưu an toàn trong giỏ hàng</b> của bạn.</span>
                </div>

            </div>

        </div>

        <!-- RIGHT COLUMN: Account, Payment Summary & Actions (5 cols) -->
        <div class="col-lg-5">

            <!-- Card 1: Account & Balance Info -->
            <div class="checkout-card mb-4 shadow-sm">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <span class="text-secondary small fw-medium text-uppercase">Tài khoản thanh toán</span>
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Học viên</span>
                </div>
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div>
                        <h6 class="text-white fw-bold mb-1"><%= currentUserFullName != null ? currentUserFullName : "Học viên" %></h6>
                        <span class="text-secondary small"><%= currentUser != null ? currentUser.getEmail() : "" %></span>
                    </div>
                    <div class="text-end">
                        <span class="text-secondary small d-block mb-1">Số dư tài khoản:</span>
                        <span class="fw-bold fs-5 text-warning" id="userBalanceDisplay"><%= currency.format(quote.userBalance) %>đ</span>
                    </div>
                </div>
            </div>

            <!-- Card 2: Summary, Voucher & Instant Payment Actions -->
            <div class="checkout-card shadow-sm mb-4">
                <h6 class="text-white fw-bold mb-3 d-flex align-items-center gap-2">
                    <i class="bi bi-receipt text-primary"></i>
                    <span>Tóm tắt thanh toán</span>
                </h6>

                <!-- Coupon Form -->
                <form action="${pageContext.request.contextPath}/student/checkout" method="post" id="couponForm" class="mb-3">
                    <input type="hidden" name="action" value="apply_coupon">
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                    <label class="form-label text-secondary small mb-1">Mã giảm giá</label>
                    <div class="input-group">
                        <input type="text"
                               name="couponCode"
                               id="couponCodeInput"
                               class="form-control bg-dark border-secondary border-opacity-50 text-white font-monospace text-uppercase"
                               placeholder="VD: LEARNORA20"
                               value="<%= quote.appliedCoupon != null ? quote.appliedCoupon.getCode() : couponCode %>">
                        <button type="submit" class="btn btn-outline-primary px-3 fw-medium">
                            Áp dụng
                        </button>
                    </div>
                    <% if (quote.couponMessage != null && !quote.couponMessage.isBlank()) { %>
                        <div class="small mt-1.5 <%= quote.appliedCoupon != null ? "text-success" : "text-danger" %>">
                            <i class="bi <%= quote.appliedCoupon != null ? "bi-check-circle" : "bi-x-circle" %> me-1"></i>
                            <%= quote.couponMessage %>
                        </div>
                    <% } %>
                </form>

                <hr class="border-secondary border-opacity-25 my-3">

                <!-- Totals Breakdown -->
                <div class="d-flex justify-content-between mb-2 small">
                    <span class="text-secondary">Tạm tính:</span>
                    <span class="text-white fw-medium" id="summarySubtotal"><%= currency.format(quote.subtotalVnd) %>đ</span>
                </div>

                <div class="d-flex justify-content-between mb-2 small text-success <%= quote.discountVnd.compareTo(BigDecimal.ZERO) > 0 ? "" : "d-none" %>" id="summaryDiscountRow">
                    <span>Giảm giá (Coupon):</span>
                    <span class="fw-medium" id="summaryDiscount">-<%= currency.format(quote.discountVnd) %>đ</span>
                </div>

                <hr class="border-secondary border-opacity-25 my-3">

                <div class="d-flex justify-content-between align-items-baseline mb-4">
                    <span class="fw-bold text-white fs-6">Tổng cần trả:</span>
                    <span class="fw-bold fs-3 text-primary" id="summaryTotal"><%= currency.format(quote.totalVnd) %>đ</span>
                </div>

                <!-- PAYMENT ACTIONS (Cleanly placed right below Totals) -->
                
                <!-- CASE 1: ĐỦ TIỀN THANH TOÁN -->
                <div id="sufficientBalanceBox" class="<%= quote.isSufficient ? "" : "d-none" %> mb-4">
                    <div class="p-3 rounded-3 bg-success bg-opacity-10 border border-success border-opacity-25 mb-3">
                        <div class="d-flex align-items-center gap-2 text-success small fw-medium mb-1">
                            <i class="bi bi-wallet2"></i> Số dư khả dụng đủ thanh toán
                        </div>
                        <div class="text-white-50 small">
                            Số dư còn lại sau khi thanh toán: <b class="text-white" id="summaryRemainingBalance"><%= currency.format(quote.remainingBalanceAfterPay) %>đ</b>
                        </div>
                    </div>

                    <button type="button" 
                            id="btnPayWithBalance" 
                            onclick="submitCheckout('pay')" 
                            class="btn btn-primary w-100 py-3 rounded-pill fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-shield-check fs-5"></i>
                        <span>Xác nhận thanh toán ngay (<span class="btn-total-amount"><%= currency.format(quote.totalVnd) %>đ</span>)</span>
                    </button>
                </div>

                <!-- CASE 2: THIẾU TIỀN -> VIETQR NẠP BÙ & NÚT DEMO -->
                <div id="insufficientBalanceBox" class="<%= !quote.isSufficient ? "" : "d-none" %> mb-4">
                    <div class="p-3 rounded-3 bg-warning bg-opacity-10 border border-warning border-opacity-25 mb-3">
                        <div class="d-flex align-items-center gap-2 text-warning small fw-medium mb-1">
                            <i class="bi bi-exclamation-triangle-fill"></i> Số dư không đủ để thanh toán
                        </div>
                        <div class="text-white-50 small">
                            Cần nạp thêm: <b class="text-danger fw-bold" id="summaryMissingAmount"><%= currency.format(quote.missingVnd) %>đ</b>
                        </div>
                    </div>

                    <!-- QR Box: VietQR Code & Bank Info -->
                    <div class="qr-container text-center mb-3">
                        <div class="text-secondary small mb-2 fw-medium">Quét mã QR để nạp số tiền còn thiếu vào tài khoản:</div>
                        
                        <div class="d-inline-block position-relative my-2">
                            <img id="vietQrImg"
                                 src="https://api.vietqr.io/image/970422-0987654321-compact2.png?amount=<%= quote.missingVnd %>&addInfo=NAPTIEN%20<%= currentUserId %>&accountName=LEARNORA%20LMS"
                                 alt="VietQR nạp tiền"
                                 class="qr-image img-fluid"
                                 onerror="this.onerror=null; this.src='https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=NAPTIEN_<%= currentUserId %>_<%= quote.missingVnd %>';">
                        </div>

                        <!-- Transfer metadata -->
                        <div class="row g-2 text-start mt-2 mx-auto small text-secondary" style="max-width: 340px;">
                            <div class="col-5">Ngân hàng:</div>
                            <div class="col-7 text-white fw-semibold">MBBank (Quân Đội)</div>
                            <div class="col-5">Số tài khoản:</div>
                            <div class="col-7 text-white fw-semibold font-monospace">0987654321</div>
                            <div class="col-5">Chủ tài khoản:</div>
                            <div class="col-7 text-white fw-semibold">LEARNORA LMS</div>
                            <div class="col-5">Số tiền nạp:</div>
                            <div class="col-7 text-danger fw-bold" id="qrMissingAmountText"><%= currency.format(quote.missingVnd) %>đ</div>
                            <div class="col-5">Nội dung:</div>
                            <div class="col-7 text-warning fw-bold font-monospace">NAPTIEN <%= currentUserId %></div>
                        </div>
                    </div>

                    <!-- Instant Simulation Action for Demo/Grading -->
                    <button type="button" 
                            id="btnTopUpAndPay" 
                            onclick="submitCheckout('topup_and_pay')" 
                            class="btn btn-success w-100 py-3 rounded-pill fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-qr-code-scan fs-5"></i>
                        <span>Xác nhận đã chuyển khoản (Nạp tiền Demo & Thanh toán)</span>
                    </button>
                    <div class="text-center text-secondary small mt-2">
                        <i class="bi bi-info-circle me-1"></i>Hệ thống tự động cộng tiền vào ví và kích hoạt khóa học ngay lập tức.
                    </div>
                </div>

                <!-- Security Guarantees -->
                <div class="pt-3 border-top border-secondary border-opacity-25 text-secondary small">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-shield-lock-fill text-success"></i>
                        <span>Bảo mật giao dịch tuyệt đối chuẩn ACID</span>
                    </div>
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-lightning-charge-fill text-warning"></i>
                        <span>Kích hoạt khóa học ngay sau khi thanh toán</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-patch-check-fill text-info"></i>
                        <span>Cấp chứng chỉ hoàn thành sau khi học xong</span>
                    </div>
                </div>

            </div>

        </div>

    </div>

</main>

<!-- Hidden form for Checkout Post Submission -->
<form id="checkoutSubmitForm" action="${pageContext.request.contextPath}/student/checkout" method="post" class="d-none">
    <input type="hidden" name="action" id="formAction" value="pay">
    <input type="hidden" name="topUpAmount" id="formTopUpAmount" value="0">
    <input type="hidden" name="couponCode" value="<%= quote.appliedCoupon != null ? quote.appliedCoupon.getCode() : "" %>">
    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
    <!-- Selected course ID hidden inputs will be injected here before submit -->
    <div id="hiddenSelectedCourseInputs"></div>
</form>

<!-- Toast notification for excluded item -->
<div id="toastNotification" class="toast-notice alert alert-secondary border-0 shadow-lg d-none text-white bg-dark d-flex align-items-center gap-2 py-3 px-4 rounded-4" style="border: 1px solid rgba(255,255,255,0.15) !important;">
    <i class="bi bi-info-circle-fill text-info fs-5 flex-shrink-0"></i>
    <div class="small flex-grow-1" id="toastMessage">Đã bỏ khóa học khỏi đơn này. Khóa học vẫn còn lưu trong giỏ hàng.</div>
    <button type="button" class="btn-close btn-close-white ms-2" onclick="hideToast()"></button>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // State initialization from server
    const userBalance = <%= quote.userBalance != null ? quote.userBalance.longValue() : 0 %>;
    const couponDiscountPercent = <%= quote.appliedCoupon != null ? quote.appliedCoupon.getDiscountPercent() : 0 %>;
    const couponMaxDiscount = <%= (quote.appliedCoupon != null && quote.appliedCoupon.getMaxDiscountVnd() != null) ? quote.appliedCoupon.getMaxDiscountVnd().longValue() : 0 %>;
    const currentUserId = '<%= currentUserId != null ? currentUserId : "" %>';

    function formatCurrency(val) {
        return new Intl.NumberFormat('vi-VN').format(Math.max(0, Math.round(val))) + 'đ';
    }

    function showToast(msg) {
        const toast = document.getElementById('toastNotification');
        const text = document.getElementById('toastMessage');
        if (toast && text) {
            text.innerHTML = msg;
            toast.classList.remove('d-none');
            clearTimeout(window._toastTimeout);
            window._toastTimeout = setTimeout(() => {
                toast.classList.add('d-none');
            }, 3500);
        }
    }

    function hideToast() {
        const toast = document.getElementById('toastNotification');
        if (toast) toast.classList.add('d-none');
    }

    // Recalculates all pricing, balance checks, and VietQR state
    function recalculateTotals() {
        const allCheckboxes = Array.from(document.querySelectorAll('.course-checkbox'));
        const checkedCheckboxes = allCheckboxes.filter(cb => cb.checked);

        // Update counts
        const selectedCount = checkedCheckboxes.length;
        const totalCount = allCheckboxes.length;
        const selectedCountDisplay = document.getElementById('selectedCountDisplay');
        const totalCountDisplay = document.getElementById('totalCountDisplay');
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const emptyWarning = document.getElementById('emptySelectionWarning');

        if (selectedCountDisplay) selectedCountDisplay.innerText = selectedCount;
        if (totalCountDisplay) totalCountDisplay.innerText = totalCount;
        if (selectAllCheckbox) selectAllCheckbox.checked = (selectedCount > 0 && selectedCount === totalCount);

        // Check if 0 items selected
        if (selectedCount === 0) {
            if (emptyWarning) emptyWarning.classList.remove('d-none');
            document.getElementById('summarySubtotal').innerText = '0đ';
            document.getElementById('summaryTotal').innerText = '0đ';
            document.querySelectorAll('.btn-total-amount').forEach(el => el.innerText = '0đ');
            
            document.getElementById('btnPayWithBalance').disabled = true;
            document.getElementById('btnTopUpAndPay').disabled = true;
            return;
        }

        if (emptyWarning) emptyWarning.classList.add('d-none');
        document.getElementById('btnPayWithBalance').disabled = false;
        document.getElementById('btnTopUpAndPay').disabled = false;

        // Calculate Subtotal
        let subtotal = 0;
        checkedCheckboxes.forEach(cb => {
            const p = parseFloat(cb.getAttribute('data-price')) || 0;
            subtotal += p;
        });

        // Calculate Discount
        let discount = 0;
        if (couponDiscountPercent > 0 && subtotal > 0) {
            discount = Math.round((subtotal * couponDiscountPercent) / 100);
            if (couponMaxDiscount > 0 && discount > couponMaxDiscount) {
                discount = couponMaxDiscount;
            }
            if (discount > subtotal) {
                discount = subtotal;
            }
        }

        const total = Math.max(0, subtotal - discount);

        // Update UI Text
        document.getElementById('summarySubtotal').innerText = formatCurrency(subtotal);
        const discountRow = document.getElementById('summaryDiscountRow');
        const discountText = document.getElementById('summaryDiscount');
        if (discount > 0) {
            if (discountRow) discountRow.classList.remove('d-none');
            if (discountText) discountText.innerText = '-' + formatCurrency(discount);
        } else {
            if (discountRow) discountRow.classList.add('d-none');
        }

        document.getElementById('summaryTotal').innerText = formatCurrency(total);
        document.querySelectorAll('.btn-total-amount').forEach(el => el.innerText = formatCurrency(total));

        // Evaluate Balance vs Total
        const sufficientBox = document.getElementById('sufficientBalanceBox');
        const insufficientBox = document.getElementById('insufficientBalanceBox');

        if (userBalance >= total) {
            // Case 1: Sufficient
            if (sufficientBox) sufficientBox.classList.remove('d-none');
            if (insufficientBox) insufficientBox.classList.add('d-none');

            const remaining = userBalance - total;
            const remainingEl = document.getElementById('summaryRemainingBalance');
            if (remainingEl) remainingEl.innerText = formatCurrency(remaining);

        } else {
            // Case 2: Insufficient
            if (sufficientBox) sufficientBox.classList.add('d-none');
            if (insufficientBox) insufficientBox.classList.remove('d-none');

            const missing = total - userBalance;
            const missingEl = document.getElementById('summaryMissingAmount');
            const qrMissingText = document.getElementById('qrMissingAmountText');
            if (missingEl) missingEl.innerText = formatCurrency(missing);
            if (qrMissingText) qrMissingText.innerText = formatCurrency(missing);

            // Update Dynamic VietQR Image URL
            const vietQrImg = document.getElementById('vietQrImg');
            if (vietQrImg) {
                vietQrImg.src = "https://api.vietqr.io/image/970422-0987654321-compact2.png?amount=" + missing + "&addInfo=NAPTIEN%20" + currentUserId + "&accountName=LEARNORA%20LMS";
            }
        }
    }

    // Toggle individual checkbox
    function onCourseSelectionChange() {
        recalculateTotals();
    }

    // Select/Deselect All Checkbox
    function toggleSelectAll(checked) {
        document.querySelectorAll('.course-checkbox').forEach(cb => {
            cb.checked = checked;
        });
        recalculateTotals();
    }

    function selectAllCourses() {
        toggleSelectAll(true);
    }

    // Exclude course from this checkout order (DOES NOT delete from cart DB)
    function excludeCourseFromCheckout(courseId) {
        const row = document.getElementById('course-row-' + courseId);
        if (!row) return;

        const checkbox = row.querySelector('.course-checkbox');
        const courseTitle = checkbox ? checkbox.getAttribute('data-title') : 'Khóa học';

        // Animate removal from checkout list
        row.style.transition = 'all 0.3s ease';
        row.style.opacity = '0';
        row.style.transform = 'translateX(20px)';

        setTimeout(() => {
            row.remove();
            recalculateTotals();
            showToast('Đã bỏ <b>' + courseTitle + '</b> khỏi đơn này. <span class="text-white-50">Khóa học vẫn còn lưu trong giỏ hàng của bạn.</span>');
        }, 250);
    }

    // Form submission
    function submitCheckout(actionType) {
        const checkedCheckboxes = Array.from(document.querySelectorAll('.course-checkbox:checked'));
        if (checkedCheckboxes.length === 0) {
            alert('Vui lòng chọn ít nhất 1 khóa học để thanh toán.');
            return;
        }

        const form = document.getElementById('checkoutSubmitForm');
        const formAction = document.getElementById('formAction');
        const formTopUpAmount = document.getElementById('formTopUpAmount');
        const inputsContainer = document.getElementById('hiddenSelectedCourseInputs');

        formAction.value = actionType;
        inputsContainer.innerHTML = '';

        checkedCheckboxes.forEach(cb => {
            const hidden = document.createElement('input');
            hidden.type = 'hidden';
            hidden.name = 'selectedCourseIds';
            hidden.value = cb.value;
            inputsContainer.appendChild(hidden);
        });

        if (actionType === 'topup_and_pay') {
            let subtotal = 0;
            checkedCheckboxes.forEach(cb => subtotal += (parseFloat(cb.getAttribute('data-price')) || 0));
            let discount = 0;
            if (couponDiscountPercent > 0 && subtotal > 0) {
                discount = Math.round((subtotal * couponDiscountPercent) / 100);
                if (couponMaxDiscount > 0 && discount > couponMaxDiscount) discount = couponMaxDiscount;
                if (discount > subtotal) discount = subtotal;
            }
            const total = Math.max(0, subtotal - discount);
            const missing = Math.max(0, total - userBalance);
            formTopUpAmount.value = missing;
        }

        form.submit();
    }
</script>
</body>
</html>
