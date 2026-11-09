<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String modalCsrf = (session != null) ? util.CartCsrf.getOrCreate(session) : "";
%>
<!-- In-place Checkout Modal (matching design reference) -->
<style>
    .modal-checkout-dialog {
        max-width: 520px;
        margin: 1.75rem auto;
    }
    .modal-checkout-content {
        background-color: var(--ftech-card-bg, #151821) !important;
        border: 1px solid var(--ftech-card-border, rgba(255, 255, 255, 0.12)) !important;
        border-radius: 1.25rem !important;
        color: var(--ftech-text-main, #ffffff) !important;
        box-shadow: 0 25px 60px rgba(0, 0, 0, 0.65) !important;
        overflow: hidden;
    }
    [data-bs-theme="light"] .modal-checkout-content {
        background-color: #ffffff !important;
        border-color: rgba(0, 0, 0, 0.1) !important;
        color: #0f172a !important;
        box-shadow: 0 25px 60px rgba(0, 0, 0, 0.15) !important;
    }
    .modal-qr-box {
        background: #0d0f15;
        border: 1px dashed rgba(255, 255, 255, 0.18);
    }
    [data-bs-theme="light"] .modal-qr-box {
        background: #f8fafc;
        border-color: rgba(0, 0, 0, 0.15);
    }
    .modal-qr-val {
        color: #ffffff;
        font-weight: 600;
    }
    [data-bs-theme="light"] .modal-qr-val {
        color: #0f172a !important;
    }
    .modal-checkout-header {
        border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
        padding: 1.25rem 1.5rem 1rem 1.5rem !important;
    }
    .modal-checkout-body {
        padding: 1.25rem 1.5rem !important;
    }
    .modal-checkout-item {
        background-color: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 0.85rem;
        padding: 0.85rem 1rem;
        transition: all 0.2s ease;
    }
    .modal-checkout-item:hover {
        background-color: rgba(255, 255, 255, 0.04);
        border-color: rgba(99, 102, 241, 0.3);
    }
    .modal-checkout-thumb {
        width: 52px;
        height: 52px;
        border-radius: 0.6rem;
        object-fit: cover;
        background-color: #0b0c10;
        flex-shrink: 0;
    }
    .modal-coupon-box {
        background-color: #0e1017;
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 0.75rem;
        padding: 0.25rem 0.25rem 0.25rem 0.85rem;
    }
    .modal-coupon-input {
        background: transparent !important;
        border: none !important;
        color: #ffffff !important;
        font-size: 0.9rem;
        outline: none !important;
        box-shadow: none !important;
    }
    .modal-coupon-input::placeholder {
        color: #64748b;
    }
    .modal-coupon-btn {
        background-color: rgba(255, 255, 255, 0.08);
        border: none;
        color: #ffffff;
        font-size: 0.85rem;
        font-weight: 500;
        border-radius: 0.55rem;
        padding: 0.45rem 1rem;
        transition: all 0.2s ease;
    }
    .modal-coupon-btn:hover {
        background-color: #4f46e5;
        color: #ffffff;
    }
    .btn-checkout-primary {
        background-color: #4f46e5 !important;
        border: none !important;
        color: #ffffff !important;
        font-weight: 600;
        font-size: 0.95rem;
        padding: 0.85rem;
        border-radius: 0.75rem !important;
        transition: all 0.2s ease;
    }
    .btn-checkout-primary:hover {
        background-color: #4338ca !important;
        box-shadow: 0 8px 20px rgba(79, 70, 229, 0.35);
    }
    .badge-sale-discount {
        background-color: rgba(34, 197, 94, 0.15);
        color: #22c55e;
        border-radius: 999px;
        font-size: 0.72rem;
        font-weight: 600;
        padding: 2px 7px;
    }
    .modal-btn-close {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background-color: rgba(255, 255, 255, 0.08);
        border: none;
        color: #94a3b8;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.15s ease;
    }
    .modal-btn-close:hover {
        background-color: rgba(255, 255, 255, 0.15);
        color: #ffffff;
    }
    .btn-remove-modal-item {
        color: #64748b;
        background: transparent;
        border: none;
        padding: 4px;
        border-radius: 50%;
        transition: all 0.15s ease;
        line-height: 1;
    }
    .btn-remove-modal-item:hover {
        color: #ef4444;
        background-color: rgba(239, 68, 68, 0.1);
    }
</style>

<div class="modal fade" id="checkoutModal" tabindex="-1" aria-labelledby="checkoutModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered modal-checkout-dialog">
        <div class="modal-content modal-checkout-content">

            <!-- STEP 1: ORDER REVIEW (Matching uploaded image) -->
            <div id="modalStepReview">
                <!-- Header -->
                <div class="modal-checkout-header d-flex align-items-center justify-content-between">
                    <div>
                        <h4 class="modal-title fw-bold text-white mb-0" id="checkoutModalLabel">Checkout</h4>
                        <div class="text-secondary small mt-0.5" id="modalBuyingSubtitle">
                            Buying (<span id="modalItemCount">0</span> courses)
                        </div>
                    </div>
                    <button type="button" class="modal-btn-close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>

                <!-- Body -->
                <div class="modal-checkout-body">

                    <!-- Loading State -->
                    <div id="modalCheckoutLoading" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status" style="width: 2.5rem; height: 2.5rem;">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <div class="text-secondary small mt-2">Đang tải thông tin đơn hàng...</div>
                    </div>

                    <!-- Empty State in Modal -->
                    <div id="modalCheckoutEmpty" class="text-center py-4 d-none">
                        <i class="bi bi-cart-x fs-1 text-secondary mb-2"></i>
                        <h6 class="text-white fw-bold mb-1">Chưa có khóa học nào được chọn</h6>
                        <p class="text-secondary small mb-3">Vui lòng thêm khóa học vào giỏ để thanh toán.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                            Xem khóa học
                        </a>
                    </div>

                    <!-- Main Content (when data loaded) -->
                    <div id="modalCheckoutData" class="d-none">

                        <!-- Courses List -->
                        <div class="d-flex flex-column gap-2 mb-3" id="modalCoursesList">
                            <!-- Populated dynamically via JS -->
                        </div>

                        <!-- Coupon Input (No Coins!) -->
                        <div class="modal-coupon-box d-flex align-items-center mb-3">
                            <input type="text" 
                                   id="modalCouponInput" 
                                   class="form-control modal-coupon-input flex-grow-1" 
                                   placeholder="Enter coupon code" 
                                   autocomplete="off">
                            <button type="button" class="modal-coupon-btn" onclick="applyModalCoupon()">
                                Apply
                            </button>
                        </div>
                        <div id="modalCouponMessage" class="small mb-3 d-none"></div>

                        <!-- Price Breakdown -->
                        <div class="pt-2 mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1 text-secondary small">
                                <span>Subtotal</span>
                                <span class="text-white fw-medium" id="modalSubtotal">0đ</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-1 text-success small d-none" id="modalDiscountRow">
                                <span>Sale discount</span>
                                <span class="fw-medium" id="modalDiscount">- 0đ</span>
                            </div>
                            <hr class="border-secondary border-opacity-25 my-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold text-white">Total</span>
                                <span class="fw-bold text-white fs-5" id="modalTotal">0đ</span>
                            </div>
                        </div>

                        <!-- Continue to payment button -->
                        <button type="button" 
                                id="btnModalContinueToPayment" 
                                onclick="goToModalPaymentStep()" 
                                class="btn btn-checkout-primary w-100 d-flex align-items-center justify-content-center gap-2">
                            <span>Continue to payment</span>
                            <i class="bi bi-arrow-right"></i>
                        </button>

                    </div>

                </div>
            </div>

            <!-- STEP 2: PAYMENT EXECUTION (In-place modal transition) -->
            <div id="modalStepPayment" class="d-none">
                <!-- Header with Back Button -->
                <div class="modal-checkout-header d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-2">
                        <button type="button" class="btn btn-link text-secondary p-0 text-decoration-none" onclick="backToReviewStep()" title="Quay lại">
                            <i class="bi bi-arrow-left fs-5 text-white"></i>
                        </button>
                        <div>
                            <h5 class="modal-title fw-bold text-white mb-0">Thanh toán đơn hàng</h5>
                            <span class="text-secondary small">Xác nhận trừ ví hoặc quét VietQR nạp bù</span>
                        </div>
                    </div>
                    <button type="button" class="modal-btn-close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>

                <div class="modal-checkout-body">

                    <!-- User Balance Card -->
                    <div class="p-3 rounded-3 mb-3" style="background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08);">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <span class="text-secondary small d-block">Số dư ví Learnora:</span>
                                <span class="fw-bold text-warning fs-5" id="modalUserBalanceDisplay">0đ</span>
                            </div>
                            <div class="text-end">
                                <span class="text-secondary small d-block">Tổng đơn hàng:</span>
                                <span class="fw-bold text-white fs-5" id="modalOrderTotalDisplay">0đ</span>
                            </div>
                        </div>
                    </div>

                    <!-- CASE 1: SUFFICIENT BALANCE -->
                    <div id="modalSufficientBox" class="d-none">
                        <div class="p-3 rounded-3 bg-success bg-opacity-10 border border-success border-opacity-25 mb-3">
                            <div class="d-flex align-items-center gap-2 text-success small fw-medium mb-1">
                                <i class="bi bi-wallet2"></i> Số dư khả dụng đủ thanh toán
                            </div>
                            <div class="text-white-50 small">
                                Số dư còn lại sau khi trừ ví: <b class="text-white" id="modalRemainingBalanceDisplay">0đ</b>
                            </div>
                        </div>

                        <button type="button" 
                                id="btnModalPayWithBalance" 
                                onclick="executeModalCheckout('pay')" 
                                class="btn btn-checkout-primary w-100 py-3 rounded-3 fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                            <i class="bi bi-shield-check fs-5"></i>
                            <span>Xác nhận thanh toán ngay (<span class="modal-pay-amount">0đ</span>)</span>
                        </button>
                    </div>

                    <!-- CASE 2: INSUFFICIENT BALANCE -> DYNAMIC VIETQR -->
                    <div id="modalInsufficientBox" class="d-none">
                        <div class="p-3 rounded-3 bg-warning bg-opacity-10 border border-warning border-opacity-25 mb-3">
                            <div class="d-flex align-items-center gap-2 text-warning small fw-medium mb-1">
                                <i class="bi bi-exclamation-triangle-fill"></i> Số dư không đủ để thanh toán
                            </div>
                            <div class="text-white-50 small">
                                Cần nạp thêm: <b class="text-danger fw-bold fs-6" id="modalMissingAmountDisplay">0đ</b>
                            </div>
                        </div>

                        <!-- VietQR Container -->
                        <div class="text-center p-3 rounded-3 mb-3 modal-qr-box">
                            <div class="text-secondary small mb-2">Quét mã QR để nạp số tiền còn thiếu:</div>
                            <div class="d-inline-block bg-white p-2 rounded-3 mb-2 shadow">
                                <img id="modalVietQrImage" src="" alt="VietQR" class="img-fluid" style="width: 180px; height: 180px; object-fit: contain;">
                            </div>
                            <div class="row g-1 text-start mx-auto small text-secondary" style="max-width: 280px; font-size: 0.8rem;">
                                <div class="col-5">Ngân hàng:</div>
                                <div class="col-7 modal-qr-val">MBBank</div>
                                <div class="col-5">Số tài khoản:</div>
                                <div class="col-7 modal-qr-val font-monospace">0987654321</div>
                                <div class="col-5">Nội dung:</div>
                                <div class="col-7 text-warning fw-bold font-monospace" id="modalTransferSyntax">NAPTIEN</div>
                            </div>
                        </div>

                        <!-- Simulated demo action -->
                        <button type="button" 
                                id="btnModalTopUpAndPay" 
                                onclick="executeModalCheckout('topup_and_pay')" 
                                class="btn btn-success w-100 py-2.5 rounded-3 fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                            <i class="bi bi-qr-code-scan fs-5"></i>
                            <span>Xác nhận đã chuyển khoản (Nạp demo & Kích hoạt)</span>
                        </button>
                    </div>

                    <!-- Payment error notice if any -->
                    <div id="modalPaymentError" class="alert alert-danger py-2.5 px-3 small mt-3 mb-0 d-none d-flex align-items-center gap-2 rounded-3 border-0">
                        <i class="bi bi-exclamation-triangle-fill flex-shrink-0 fs-5 text-danger"></i>
                        <span id="modalPaymentErrorText"></span>
                    </div>

                </div>
            </div>

            <!-- STEP 3: PAYMENT SUCCESS (In-place) -->
            <div id="modalStepSuccess" class="d-none">
                <div class="modal-checkout-header d-flex align-items-center justify-content-between">
                    <h5 class="modal-title fw-bold text-white mb-0">Hoàn tất đơn hàng</h5>
                    <button type="button" class="modal-btn-close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <div class="modal-checkout-body text-center py-4">
                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                         style="width: 72px; height: 72px; background: rgba(34, 197, 94, 0.15); border: 2px solid rgba(34, 197, 94, 0.4); color: #22c55e; font-size: 2rem;">
                        <i class="bi bi-check-lg"></i>
                    </div>
                    <h4 class="fw-bold text-white mb-1">Thanh toán thành công!</h4>
                    <p class="text-secondary small mb-3">
                        Mã đơn hàng: <span class="text-info font-monospace fw-semibold" id="modalSuccessOrderCode">#ORD</span><br>
                        Khóa học đã được kích hoạt ngay vào tài khoản của bạn.
                    </p>
                    <div class="d-flex gap-2 justify-content-center">
                        <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary px-4 py-2 rounded-pill fw-semibold">
                            <i class="bi bi-collection-play me-1"></i> Khám phá thêm
                        </a>
                        <button type="button" class="btn btn-outline-secondary text-white px-4 py-2 rounded-pill" data-bs-dismiss="modal">
                            Đóng
                        </button>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    // In-place Checkout Modal State
    window.CheckoutModalState = {
        quote: null,
        excludedCourseIds: new Set(),
        currentCouponCode: '',
        userId: '<%= currentUserId != null ? currentUserId : "" %>'
    };

    function formatVndPrice(num) {
        return new Intl.NumberFormat('vi-VN').format(Math.max(0, Math.round(num))) + 'đ';
    }

    // Opens the in-place Checkout Modal from ANY page or cart drawer
    async function openCheckoutModal(presetCourseIds) {
        // Close cart drawer if open
        const cartDrawerEl = document.getElementById('cartDrawer');
        if (cartDrawerEl && typeof bootstrap !== 'undefined') {
            const drawerInstance = bootstrap.Offcanvas.getInstance(cartDrawerEl);
            if (drawerInstance) drawerInstance.hide();
        }

        const modalEl = document.getElementById('checkoutModal');
        if (!modalEl) return;
        const modal = new bootstrap.Modal(modalEl);
        modal.show();

        // Reset steps
        document.getElementById('modalStepReview').classList.remove('d-none');
        document.getElementById('modalStepPayment').classList.add('d-none');
        document.getElementById('modalStepSuccess').classList.add('d-none');

        document.getElementById('modalCheckoutLoading').classList.remove('d-none');
        document.getElementById('modalCheckoutData').classList.add('d-none');
        document.getElementById('modalCheckoutEmpty').classList.add('d-none');

        window.CheckoutModalState.excludedCourseIds.clear();

        await loadCheckoutModalData(presetCourseIds);
    }

    async function loadCheckoutModalData(courseIds, coupon) {
        try {
            let url = '${pageContext.request.contextPath}/student/checkout?format=json';
            if (courseIds && courseIds.length > 0) {
                url += '&courses=' + encodeURIComponent(courseIds.join(','));
            }
            if (coupon && coupon.trim() !== '') {
                url += '&coupon=' + encodeURIComponent(coupon.trim());
            }

            const response = await fetch(url, {
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            const data = await response.json();

            if (!data.success && data.error === 'UNAUTHENTICATED') {
                // Open login modal
                bootstrap.Modal.getInstance(document.getElementById('checkoutModal')).hide();
                const signinModal = document.getElementById('signInModal');
                if (signinModal) new bootstrap.Modal(signinModal).show();
                return;
            }

            window.CheckoutModalState.quote = data;
            renderCheckoutModalReview();

        } catch (err) {
            console.error('Load checkout quote error:', err);
            document.getElementById('modalCheckoutLoading').classList.add('d-none');
            document.getElementById('modalCheckoutEmpty').classList.remove('d-none');
        }
    }

    function renderCheckoutModalReview() {
        const state = window.CheckoutModalState;
        const quote = state.quote;

        document.getElementById('modalCheckoutLoading').classList.add('d-none');

        if (!quote || !quote.items || quote.items.length === 0) {
            document.getElementById('modalCheckoutEmpty').classList.remove('d-none');
            document.getElementById('modalCheckoutData').classList.add('d-none');
            return;
        }

        document.getElementById('modalCheckoutEmpty').classList.add('d-none');
        document.getElementById('modalCheckoutData').classList.remove('d-none');

        // Filter out excluded items
        const activeItems = quote.items.filter(it => !state.excludedCourseIds.has(it.courseId));

        // Subtitle
        const countSpan = document.getElementById('modalItemCount');
        if (countSpan) countSpan.innerText = activeItems.length;
        const subTitle = document.getElementById('modalBuyingSubtitle');
        if (subTitle) {
            subTitle.innerHTML = 'Buying (' + activeItems.length + (activeItems.length === 1 ? ' course' : ' courses') + ')';
        }

        // Render Items List matching the screenshot
        const listContainer = document.getElementById('modalCoursesList');
        listContainer.innerHTML = '';

        if (activeItems.length === 0) {
            listContainer.innerHTML = '<div class="alert alert-warning py-2 text-center small mb-0">Bạn đã bỏ tất cả khóa học khỏi đơn này.</div>';
            document.getElementById('btnModalContinueToPayment').disabled = true;
        } else {
            document.getElementById('btnModalContinueToPayment').disabled = false;
        }

        let subtotal = 0;

        activeItems.forEach(item => {
            subtotal += item.price;

            const itemEl = document.createElement('div');
            itemEl.className = 'modal-checkout-item d-flex align-items-center justify-content-between gap-3';
            itemEl.id = 'modal-course-item-' + item.courseId;

            const thumb = item.thumbnailUrl && item.thumbnailUrl.trim() !== ''
                ? '<img src="' + item.thumbnailUrl + '" alt="' + item.title + '" class="modal-checkout-thumb">'
                : '<div class="modal-checkout-thumb d-flex align-items-center justify-content-center text-primary"><i class="bi bi-journal-code fs-4"></i></div>';

            const discountBadge = item.discountPercent > 0
                ? '<del class="text-secondary small ms-1" style="font-size: 0.78rem;">' + formatVndPrice(item.listPrice) + '</del>'
                  + '<span class="badge-sale-discount ms-1">-' + item.discountPercent + '%</span>'
                : '';

            itemEl.innerHTML = 
                '<div class="d-flex align-items-center gap-2.5 flex-grow-1 min-w-0">'
              +     thumb
              +     '<div class="flex-grow-1 min-w-0 pe-2">'
              +         '<h6 class="text-white fw-semibold mb-1 text-truncate small" title="' + item.title + '">' + item.title + '</h6>'
              +         '<div class="d-flex align-items-baseline">'
              +             '<span class="fw-bold text-white small">' + formatVndPrice(item.price) + '</span>'
              +             discountBadge
              +         '</div>'
              +     '</div>'
              + '</div>'
              + '<button type="button" class="btn-remove-modal-item flex-shrink-0" onclick="excludeCourseFromModal(' + item.courseId + ')" title="Bỏ khỏi đơn này (vẫn giữ trong giỏ hàng)">'
              +     '<i class="bi bi-x-lg fs-6"></i>'
              + '</button>';

            listContainer.appendChild(itemEl);
        });

        // Calculate discount from coupon if applied
        let discount = quote.discount || 0;
        if (quote.subtotal > 0 && subtotal !== quote.subtotal && quote.subtotal > 0) {
            // Recalculate discount proportionally
            discount = Math.round((discount * subtotal) / quote.subtotal);
        }
        const total = Math.max(0, subtotal - discount);

        // Update Price Breakdown
        document.getElementById('modalSubtotal').innerText = formatVndPrice(subtotal);
        const discountRow = document.getElementById('modalDiscountRow');
        const discountEl = document.getElementById('modalDiscount');
        if (discount > 0) {
            discountRow.classList.remove('d-none');
            discountEl.innerText = '- ' + formatVndPrice(discount);
        } else {
            discountRow.classList.add('d-none');
        }
        document.getElementById('modalTotal').innerText = formatVndPrice(total);

        // Coupon input message
        const couponMsg = document.getElementById('modalCouponMessage');
        if (quote.couponMessage && quote.couponMessage.trim() !== '') {
            couponMsg.classList.remove('d-none');
            couponMsg.className = 'small mb-3 ' + (quote.couponCode ? 'text-success' : 'text-danger');
            couponMsg.innerText = quote.couponMessage;
        } else {
            couponMsg.classList.add('d-none');
        }
        if (quote.couponCode) {
            document.getElementById('modalCouponInput').value = quote.couponCode;
        }
    }

    // Exclude course from this modal (DOES NOT delete from DB cart!)
    function excludeCourseFromModal(courseId) {
        window.CheckoutModalState.excludedCourseIds.add(courseId);
        renderCheckoutModalReview();
    }

    // Apply Coupon in Modal
    async function applyModalCoupon() {
        const input = document.getElementById('modalCouponInput');
        const code = input ? input.value.trim() : '';
        const state = window.CheckoutModalState;

        const activeCourseIds = state.quote.items
            .filter(it => !state.excludedCourseIds.has(it.courseId))
            .map(it => it.courseId);

        await loadCheckoutModalData(activeCourseIds, code);
    }

    // Transition from Step 1 to Step 2 (Payment)
    function goToModalPaymentStep() {
        const state = window.CheckoutModalState;
        const quote = state.quote;
        if (!quote) return;

        const activeItems = quote.items.filter(it => !state.excludedCourseIds.has(it.courseId));
        if (activeItems.length === 0) {
            alert('Vui lòng chọn ít nhất 1 khóa học để thanh toán.');
            return;
        }

        // Calculate current total
        let subtotal = 0;
        activeItems.forEach(it => subtotal += it.price);
        let discount = quote.discount || 0;
        if (quote.subtotal > 0 && subtotal !== quote.subtotal) {
            discount = Math.round((discount * subtotal) / quote.subtotal);
        }
        const total = Math.max(0, subtotal - discount);
        const userBalance = quote.userBalance || 0;

        document.getElementById('modalStepReview').classList.add('d-none');
        document.getElementById('modalStepPayment').classList.remove('d-none');
        document.getElementById('modalStepSuccess').classList.add('d-none');

        document.getElementById('modalUserBalanceDisplay').innerText = formatVndPrice(userBalance);
        document.getElementById('modalOrderTotalDisplay').innerText = formatVndPrice(total);
        document.querySelectorAll('.modal-pay-amount').forEach(el => el.innerText = formatVndPrice(total));

        const sufficientBox = document.getElementById('modalSufficientBox');
        const insufficientBox = document.getElementById('modalInsufficientBox');

        if (userBalance >= total) {
            // Case 1: Sufficient
            sufficientBox.classList.remove('d-none');
            insufficientBox.classList.add('d-none');
            document.getElementById('modalRemainingBalanceDisplay').innerText = formatVndPrice(userBalance - total);
        } else {
            // Case 2: Insufficient -> VietQR
            sufficientBox.classList.add('d-none');
            insufficientBox.classList.remove('d-none');
            const missing = total - userBalance;
            document.getElementById('modalMissingAmountDisplay').innerText = formatVndPrice(missing);

            const userId = state.userId;
            const qrImg = document.getElementById('modalVietQrImage');
            qrImg.src = 'https://api.vietqr.io/image/970422-0987654321-compact2.png?amount=' + missing + '&addInfo=NAPTIEN%20' + userId + '&accountName=LEARNORA%20LMS';
            document.getElementById('modalTransferSyntax').innerText = 'NAPTIEN ' + userId;
        }
    }

    function backToReviewStep() {
        document.getElementById('modalStepReview').classList.remove('d-none');
        document.getElementById('modalStepPayment').classList.add('d-none');
    }

    // Execute Payment via AJAX
    async function executeModalCheckout(actionType) {
        const state = window.CheckoutModalState;
        const activeItems = state.quote.items.filter(it => !state.excludedCourseIds.has(it.courseId));
        if (activeItems.length === 0) return;

        let subtotal = 0;
        activeItems.forEach(it => subtotal += it.price);
        let discount = state.quote.discount || 0;
        if (state.quote.subtotal > 0 && subtotal !== state.quote.subtotal) {
            discount = Math.round((discount * subtotal) / state.quote.subtotal);
        }
        const total = Math.max(0, subtotal - discount);
        const missing = Math.max(0, total - (state.quote.userBalance || 0));

        const errBox = document.getElementById('modalPaymentError');
        errBox.classList.add('d-none');

        // Prepare POST body
        const params = new URLSearchParams();
        params.append('action', actionType);
        params.append('couponCode', state.quote.couponCode || '');
        params.append('topUpAmount', missing);
        params.append('csrfToken', '<%= modalCsrf %>');

        activeItems.forEach(it => {
            params.append('selectedCourseIds', it.courseId);
        });

        const btnPay = document.getElementById('btnModalPayWithBalance');
        const btnTopUp = document.getElementById('btnModalTopUpAndPay');
        if (btnPay) btnPay.disabled = true;
        if (btnTopUp) btnTopUp.disabled = true;

        try {
            const response = await fetch('${pageContext.request.contextPath}/student/checkout?format=json', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params.toString()
            });

            const result = await response.json();

            if (result.success) {
                // Update cart count badge in navbar
                const badges = document.querySelectorAll('.cart-badge');
                badges.forEach(b => {
                    b.innerText = result.remainingCartCount;
                    if (result.remainingCartCount === 0) b.classList.add('d-none');
                    else b.classList.remove('d-none');
                });

                // Transition to Step 3: Success
                document.getElementById('modalStepPayment').classList.add('d-none');
                document.getElementById('modalStepSuccess').classList.remove('d-none');
                document.getElementById('modalSuccessOrderCode').innerText = '#' + result.orderCode;

            } else {
                const msgText = document.getElementById('modalPaymentErrorText');
                if (msgText) msgText.innerText = result.message || 'Thanh toán thất bại. Vui lòng kiểm tra lại số dư ví.';
                else errBox.innerText = result.message || 'Thanh toán thất bại. Vui lòng kiểm tra lại số dư ví.';
                errBox.classList.remove('d-none');
                if (btnPay) btnPay.disabled = false;
                if (btnTopUp) btnTopUp.disabled = false;
            }

        } catch (err) {
            console.error('Execute modal checkout error:', err);
            const msgText = document.getElementById('modalPaymentErrorText');
            if (msgText) msgText.innerText = 'Lỗi kết nối máy chủ. Vui lòng kiểm tra lại.';
            else errBox.innerText = 'Lỗi kết nối máy chủ. Vui lòng kiểm tra lại.';
            errBox.classList.remove('d-none');
            if (btnPay) btnPay.disabled = false;
            if (btnTopUp) btnTopUp.disabled = false;
        }
    }
</script>
