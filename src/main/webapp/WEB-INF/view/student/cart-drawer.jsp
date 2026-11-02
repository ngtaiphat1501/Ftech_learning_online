<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String initialCartCsrf = (session != null) ? util.CartCsrf.getOrCreate(session) : "";
%>

<div class="offcanvas offcanvas-end text-bg-dark border-start border-secondary border-opacity-25 shadow-lg"
     tabindex="-1"
     id="cartDrawer"
     aria-labelledby="cartDrawerTitle"
     style="--bs-offcanvas-width: 440px; background-color: #12141a !important;">

    <!-- HEADER: Matching Design -->
    <div class="offcanvas-header border-bottom border-secondary border-opacity-25 position-relative justify-content-center py-3">
        <div class="text-center">
            <i class="bi bi-cart3 text-primary fs-3 d-block mb-1"></i>
            <h5 class="offcanvas-title fw-bold text-white fs-5" id="cartDrawerTitle">Cart</h5>
        </div>
        <button type="button"
                class="btn-close btn-close-white position-absolute top-0 end-0 m-3"
                data-bs-dismiss="offcanvas"
                aria-label="Đóng">
        </button>
    </div>

    <!-- BODY -->
    <div class="offcanvas-body d-flex flex-column p-3">
        <!-- Danh sách khóa học -->
        <div class="flex-grow-1 overflow-auto pe-1" id="cartDrawerItems">
            <div class="text-center py-5">
                <i class="bi bi-cart-x display-4 text-secondary"></i>
                <p class="mt-3 text-secondary small">Giỏ hàng đang trống</p>
            </div>
        </div>
    </div>

    <!-- FOOTER CỦA DRAWER -->
    <div class="border-top border-secondary border-opacity-25 p-3 mt-auto bg-dark-subtle" style="background-color: #161821 !important;">
        <!-- Total Row -->
        <div class="d-flex justify-content-between align-items-center mb-1">
            <span class="text-white fw-semibold fs-6">Total</span>
            <div class="text-end">
                <span id="cartDrawerTotal" class="fw-bold fs-5 text-white">0đ</span>
                <del id="cartDrawerListTotal" class="text-secondary small ms-2 d-none"></del>
                <span id="cartDrawerDiscountBadge" class="badge bg-success-subtle text-success border border-success-subtle ms-1 d-none" style="font-size: 0.72rem;"></span>
            </div>
        </div>

        <!-- Savings Row -->
        <div id="cartDrawerSavingsRow" class="text-success small fw-semibold text-end mb-3 d-none">
            You save <span id="cartDrawerSavings">0đ</span>
        </div>

        <!-- Checkout Action Button -->
        <a href="${pageContext.request.contextPath}/student/checkout"
           id="cartCheckoutBtn"
           class="btn btn-primary w-100 py-2.5 rounded-3 fw-semibold shadow-sm mb-2 d-flex align-items-center justify-content-center gap-2">
            <span>Checkout</span>
            <i class="bi bi-arrow-right"></i>
        </a>

        <!-- View Full Cart Link -->
        <a href="${pageContext.request.contextPath}/student/cart"
           class="btn btn-outline-secondary text-white w-100 py-2.5 rounded-3 fw-medium border-secondary border-opacity-50">
            View full cart
        </a>
    </div>
</div>

<script>
    let globalCartCsrf = "<%= initialCartCsrf %>";

    async function loadCartDrawer() {
        const cartItems = document.getElementById("cartDrawerItems");
        const cartTotal = document.getElementById("cartDrawerTotal");
        const listTotalEl = document.getElementById("cartDrawerListTotal");
        const badgeEl = document.getElementById("cartDrawerDiscountBadge");
        const savingsRow = document.getElementById("cartDrawerSavingsRow");
        const savingsEl = document.getElementById("cartDrawerSavings");
        const checkoutBtn = document.getElementById("cartCheckoutBtn");
        const headerBadge = document.getElementById("headerCartBadge");

        if (!cartItems) return;

        try {
            const cacheBuster = "_t=" + Date.now();
            const response = await fetch("${pageContext.request.contextPath}/student/cart?view=drawer&" + cacheBuster, {
                method: "GET",
                headers: { "X-Requested-With": "XMLHttpRequest" },
                credentials: "same-origin",
                cache: "no-store"
            });

            if (response.status === 401) {
                cartItems.innerHTML =
                    '<div class="text-center py-5">' +
                    '<div class="rounded-circle bg-dark d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px; border: 1px solid rgba(255,255,255,0.1);">' +
                    '<i class="bi bi-person-lock fs-3 text-secondary"></i>' +
                    '</div>' +
                    '<h6 class="text-white fw-bold">Chưa đăng nhập</h6>' +
                    '<p class="text-secondary small mt-1 mb-3">Vui lòng đăng nhập để xem và quản lý giỏ hàng của bạn.</p>' +
                    '<button type="button" class="btn btn-primary btn-sm rounded-pill px-3 py-1.5" data-bs-toggle="modal" data-bs-target="#signInModal">' +
                    'Đăng nhập ngay' +
                    '</button>' +
                    '</div>';
                cartTotal.textContent = "0đ";
                if (listTotalEl) listTotalEl.classList.add("d-none");
                if (badgeEl) badgeEl.classList.add("d-none");
                if (savingsRow) savingsRow.classList.add("d-none");
                if (checkoutBtn) checkoutBtn.classList.add("disabled");
                if (headerBadge) headerBadge.textContent = "0";
                return;
            }

            if (!response.ok) {
                throw new Error("Không thể tải dữ liệu giỏ hàng");
            }

            const html = await response.text();
            const doc = new DOMParser().parseFromString(html, "text/html");
            const cartResponse = doc.querySelector("#cartResponse");

            if (!cartResponse) {
                throw new Error("Dữ liệu giỏ hàng không đúng cấu trúc");
            }

            cartItems.innerHTML = cartResponse.innerHTML;

            const count = parseInt(cartResponse.dataset.count || "0", 10);
            const totalStr = cartResponse.dataset.total || "0đ";
            const listTotalStr = cartResponse.dataset.listTotal || "0đ";
            const savingsStr = cartResponse.dataset.savings || "0đ";
            const hasSavings = cartResponse.dataset.hasSavings === "true";
            const discountPercentStr = cartResponse.dataset.discountPercent || "";
            globalCartCsrf = cartResponse.dataset.csrf || globalCartCsrf;

            if (headerBadge) {
                headerBadge.textContent = count;
                if (count > 0) {
                    headerBadge.classList.remove("d-none");
                } else {
                    headerBadge.classList.add("d-none");
                }
            }

            cartTotal.textContent = totalStr;

            if (hasSavings && count > 0) {
                if (listTotalEl) {
                    listTotalEl.textContent = listTotalStr;
                    listTotalEl.classList.remove("d-none");
                }
                if (badgeEl && discountPercentStr) {
                    badgeEl.textContent = discountPercentStr;
                    badgeEl.classList.remove("d-none");
                }
                if (savingsRow && savingsEl) {
                    savingsEl.textContent = savingsStr;
                    savingsRow.classList.remove("d-none");
                }
            } else {
                if (listTotalEl) listTotalEl.classList.add("d-none");
                if (badgeEl) badgeEl.classList.add("d-none");
                if (savingsRow) savingsRow.classList.add("d-none");
            }

            if (checkoutBtn) {
                if (count > 0) {
                    checkoutBtn.classList.remove("disabled");
                    checkoutBtn.removeAttribute("tabindex");
                    checkoutBtn.removeAttribute("aria-disabled");
                } else {
                    checkoutBtn.classList.add("disabled");
                    checkoutBtn.setAttribute("tabindex", "-1");
                    checkoutBtn.setAttribute("aria-disabled", "true");
                }
            }

        } catch (error) {
            console.error("Cart error:", error);
            cartItems.innerHTML =
                '<div class="alert alert-danger py-2 small mb-0">' +
                'Không thể tải dữ liệu giỏ hàng. Vui lòng thử lại sau.' +
                '</div>';
        }
    }

    async function removeCartItem(courseId) {
        if (!courseId) return false;

        try {
            const formData = new URLSearchParams();
            formData.append("action", "remove");
            formData.append("courseId", courseId);
            formData.append("csrfToken", globalCartCsrf);

            const response = await fetch("${pageContext.request.contextPath}/student/cart", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: formData.toString()
            });

            if (response.status === 401) {
                const signInModalEl = document.getElementById("signInModal");
                if (signInModalEl && typeof bootstrap !== "undefined") {
                    new bootstrap.Modal(signInModalEl).show();
                }
                return false;
            }

            const data = await response.json().catch(() => null);

            // Cập nhật lại drawer live
            await loadCartDrawer();

            // Đồng bộ trạng thái nút nếu đang ở trang chi tiết khóa học
            if (typeof updateCartButtonState === "function") {
                updateCartButtonState(false);
            }

            return true;

        } catch (err) {
            console.error("Remove cart item error:", err);
            alert("Lỗi khi xóa khóa học khỏi giỏ hàng.");
            return false;
        }
    }

    async function addCourseToCart(courseId) {
        if (!courseId) return false;

        try {
            const formData = new URLSearchParams();
            formData.append("action", "add");
            formData.append("courseId", courseId);
            formData.append("csrfToken", globalCartCsrf);

            const response = await fetch("${pageContext.request.contextPath}/student/cart", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: formData.toString()
            });

            if (response.status === 401) {
                // Chưa đăng nhập -> Hiện modal đăng nhập
                const signInModalEl = document.getElementById("signInModal");
                if (signInModalEl && typeof bootstrap !== "undefined") {
                    new bootstrap.Modal(signInModalEl).show();
                }
                return false;
            }

            const data = await response.json().catch(() => null);

            if (!response.ok || !data) {
                alert((data && data.message) ? data.message : "Có lỗi xảy ra khi thêm vào giỏ hàng.");
                return false;
            }

            if (!data.success) {
                alert(data.message || "Không thể thêm khóa học vào giỏ hàng.");
                return false;
            }

            // Cập nhật số lượng giỏ hàng trên header nếu có
            const headerBadge = document.getElementById("headerCartBadge");
            if (headerBadge && typeof data.cartCount !== "undefined") {
                headerBadge.textContent = data.cartCount;
                if (data.cartCount > 0) {
                    headerBadge.classList.remove("d-none");
                } else {
                    headerBadge.classList.add("d-none");
                }
            }

            // Mở cart drawer và load lại dữ liệu mới nhất
            const drawerEl = document.getElementById("cartDrawer");
            if (drawerEl && typeof bootstrap !== "undefined") {
                const offcanvas = bootstrap.Offcanvas.getOrCreateInstance(drawerEl);
                offcanvas.show();
            }
            await loadCartDrawer();

            // Đồng bộ trạng thái nút nếu đang ở trang chi tiết khóa học
            if (typeof updateCartButtonState === "function") {
                updateCartButtonState(true);
            }

            return true;

        } catch (err) {
            console.error("Add to cart error:", err);
            alert("Không thể thêm vào giỏ hàng. Vui lòng thử lại sau.");
            return false;
        }
    }

    function handleOpenCart() {
        <% if (currentUserId == null) { %>
            const signInModalEl = document.getElementById("signInModal");
            if (signInModalEl && typeof bootstrap !== "undefined") {
                new bootstrap.Modal(signInModalEl).show();
            }
        <% } else { %>
            const drawerEl = document.getElementById("cartDrawer");
            if (drawerEl && typeof bootstrap !== "undefined") {
                const offcanvas = bootstrap.Offcanvas.getOrCreateInstance(drawerEl);
                offcanvas.show();
            }
        <% } %>
    }

    document.addEventListener("DOMContentLoaded", function () {
        const drawer = document.getElementById("cartDrawer");
        if (drawer) {
            drawer.addEventListener("show.bs.offcanvas", function () {
                loadCartDrawer();
            });
        }
        <% if (currentUserId != null) { %>
            loadCartDrawer();
        <% } %>
    });
</script>
