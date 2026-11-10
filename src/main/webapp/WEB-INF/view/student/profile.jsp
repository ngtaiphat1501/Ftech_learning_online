<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.User"%>
<%@page import="model.WalletTransaction"%>

<%
    User userProfile = (User) request.getAttribute("userProfile");
    Integer enrolledCount = (Integer) request.getAttribute("enrolledCount");
    Integer completedCount = (Integer) request.getAttribute("completedCount");
    List<WalletTransaction> walletTransactions = (List<WalletTransaction>) request.getAttribute("walletTransactions");
    String activeTab = (String) request.getAttribute("activeTab");

    if (enrolledCount == null) enrolledCount = 0;
    if (completedCount == null) completedCount = 0;
    if (activeTab == null || activeTab.isBlank()) activeTab = "info";

    NumberFormat currency = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
    currency.setMaximumFractionDigits(0);
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    String msg = request.getParameter("msg");
    String err = request.getParameter("error");

    String avatar = (userProfile != null && userProfile.getAvatarUrl() != null && !userProfile.getAvatarUrl().isBlank())
            ? userProfile.getAvatarUrl()
            : null;
%>

<%@include file="/WEB-INF/view/layout/PublicHeader.jsp" %>

<style>
    .wallet-chip-btn {
        border: 1px solid rgba(255, 255, 255, 0.15);
        background: rgba(255, 255, 255, 0.04);
        color: var(--ftech-text-main, #ffffff);
        border-radius: 999px;
        padding: 0.35rem 0.85rem;
        font-size: 0.85rem;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    [data-bs-theme="light"] .wallet-chip-btn {
        border-color: rgba(0, 0, 0, 0.15);
        background: #f1f5f9;
        color: #0f172a;
    }
    .wallet-chip-btn:hover, .wallet-chip-btn.active {
        border-color: #4f46e5;
        background: rgba(79, 70, 229, 0.15);
        color: #4f46e5;
        font-weight: 600;
    }
    .wallet-method-card {
        border: 2px solid rgba(255, 255, 255, 0.12);
        background: rgba(255, 255, 255, 0.03);
        border-radius: 0.85rem;
        padding: 0.85rem 1rem;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    [data-bs-theme="light"] .wallet-method-card {
        border-color: rgba(0, 0, 0, 0.12);
        background: #f8fafc;
    }
    .wallet-method-card:hover {
        border-color: #6366f1;
    }
    .wallet-method-card.active-vietqr {
        border-color: #4f46e5 !important;
        background: rgba(79, 70, 229, 0.12) !important;
    }
    .wallet-method-card.active-momo {
        border-color: #d82d8b !important;
        background: rgba(216, 45, 139, 0.12) !important;
    }
</style>

<main class="container my-5" style="min-height: 65vh;">
    <!-- Alert notifications -->
    <% if (msg != null && !msg.isBlank()) { %>
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>
    <% if (err != null && !err.isBlank()) { %>
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= err %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <% if (userProfile != null) { %>
    <!-- Profile Banner & Summary Card -->
    <div class="card bg-dark border border-secondary border-opacity-25 rounded-4 p-4 mb-4 shadow-sm">
        <div class="row align-items-center g-4">
            <div class="col-12 col-md-auto text-center">
                <% if (avatar != null) { %>
                    <img src="<%= avatar %>" alt="Avatar" class="rounded-circle border border-primary border-3 shadow object-fit-cover"
                         style="width: 100px; height: 100px;"
                         onerror="this.src='https://placehold.co/120x120/212529/ced4da?text=User'">
                <% } else { %>
                    <div class="avatar bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-1 mx-auto shadow"
                         style="width: 100px; height: 100px;">
                        <%= (userProfile.getFullName() != null && !userProfile.getFullName().isBlank()) ? userProfile.getFullName().substring(0, 1).toUpperCase() : "U" %>
                    </div>
                <% } %>
            </div>

            <div class="col-12 col-md">
                <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                    <h2 class="h4 fw-bold text-body mb-0"><%= userProfile.getFullName() %></h2>
                    <% if (userProfile.isAdmin()) { %>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill small">Quản trị viên</span>
                    <% } %>
                    <% if (userProfile.isInstructor()) { %>
                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill small">Giảng viên</span>
                    <% } %>
                    <% if (userProfile.isStudent()) { %>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill small">Học viên</span>
                    <% } %>
                </div>
                <div class="text-secondary small mb-2"><i class="bi bi-envelope me-1"></i><%= userProfile.getEmail() %></div>
                <div class="text-body-secondary small"><%= userProfile.getHeadline() != null ? userProfile.getHeadline() : "Thành viên nền tảng học tập Ftech" %></div>
            </div>

            <div class="col-12 col-md-auto text-md-end border-top border-md-top-0 border-secondary border-opacity-25 pt-3 pt-md-0">
                <div class="d-flex flex-row flex-md-column gap-3 justify-content-around">
                    <div>
                        <span class="text-secondary small d-block">Số dư ví</span>
                        <span class="fw-bold text-success font-monospace fs-4">
                            <%= currency.format(userProfile.getBalanceVnd()) %> đ
                        </span>
                        <div class="d-flex gap-2 mt-2 justify-content-md-end">
                            <button type="button" class="btn btn-sm btn-success rounded-pill fw-medium px-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#topUpModal">
                                <i class="bi bi-plus-circle me-1"></i>Nạp tiền
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-warning rounded-pill fw-medium px-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#withdrawModal">
                                <i class="bi bi-box-arrow-up-right me-1"></i>Rút tiền
                            </button>
                        </div>
                    </div>
                    <div class="mt-2">
                        <span class="text-secondary small d-block">Khóa học ghi danh</span>
                        <span class="fw-bold text-body fs-5">
                            <i class="bi bi-journal-check text-primary me-1"></i><%= enrolledCount %> khóa
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="card bg-body-tertiary border border-secondary border-opacity-25 rounded-4 shadow-sm overflow-hidden">
        <div class="card-header bg-body-secondary border-bottom border-secondary border-opacity-25 px-4 pt-3 pb-0">
            <ul class="nav nav-tabs card-header-tabs border-bottom-0" id="profileTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= "info".equals(activeTab) ? "active bg-transparent text-body border-0 border-bottom border-primary border-3 fw-medium pb-3" : "bg-transparent text-body-secondary border-0 fw-medium pb-3" %>"
                            id="info-tab" data-bs-toggle="tab" data-bs-target="#info-pane" type="button" role="tab">
                        <i class="bi bi-person me-2"></i>Thông tin tài khoản
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= "wallet".equals(activeTab) ? "active bg-transparent text-body border-0 border-bottom border-primary border-3 fw-medium pb-3" : "bg-transparent text-body-secondary border-0 fw-medium pb-3" %>"
                            id="wallet-tab" data-bs-toggle="tab" data-bs-target="#wallet-pane" type="button" role="tab">
                        <i class="bi bi-wallet2 me-2"></i>Ví học viên & Giao dịch
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= "password".equals(activeTab) ? "active bg-transparent text-body border-0 border-bottom border-primary border-3 fw-medium pb-3" : "bg-transparent text-body-secondary border-0 fw-medium pb-3" %>"
                            id="password-tab" data-bs-toggle="tab" data-bs-target="#password-pane" type="button" role="tab">
                        <i class="bi bi-shield-lock me-2"></i>Đổi mật khẩu
                    </button>
                </li>
            </ul>
        </div>

        <div class="card-body p-4">
            <div class="tab-content" id="profileTabContent">
                
                <!-- Tab 1: Update Profile Info -->
                <div class="tab-pane fade <%= "info".equals(activeTab) ? "show active" : "" %>" id="info-pane" role="tabpanel">
                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="row g-3">
                        <input type="hidden" name="action" value="update_profile">

                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary small fw-medium">Email đăng nhập</label>
                            <input type="email" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-secondary"
                                   value="<%= userProfile.getEmail() %>" disabled>
                            <div class="form-text text-secondary small">Email đăng nhập dùng để xác thực và không thể chỉnh sửa.</div>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary small fw-medium">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   value="<%= userProfile.getFullName() != null ? userProfile.getFullName() : "" %>" required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Tiêu đề chuyên môn / Nghề nghiệp</label>
                            <input type="text" name="headline" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="VD: Sinh viên ngành Kỹ thuật phần mềm | Lập trình viên Java Fullstack"
                                   value="<%= userProfile.getHeadline() != null ? userProfile.getHeadline() : "" %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Đường dẫn ảnh đại diện (Avatar URL)</label>
                            <input type="url" name="avatarUrl" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="https://example.com/avatar.jpg"
                                   value="<%= userProfile.getAvatarUrl() != null ? userProfile.getAvatarUrl() : "" %>">
                            <div class="form-text text-secondary small">Nhập URL hình ảnh công khai (.jpg, .png) để cập nhật ảnh đại diện.</div>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Giới thiệu bản thân (Bio)</label>
                            <textarea name="bio" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                      rows="4" placeholder="Chia sẻ kinh nghiệm, sở thích hoặc định hướng học tập của bạn..."><%= userProfile.getBio() != null ? userProfile.getBio() : "" %></textarea>
                        </div>

                        <div class="col-12 text-end pt-3 border-top border-secondary border-opacity-25 mt-4">
                            <button type="submit" class="btn btn-primary rounded-pill px-4">
                                <i class="bi bi-save me-1"></i>Lưu Thay Đổi
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Tab 2: Wallet Management & Transaction History -->
                <div class="tab-pane fade <%= "wallet".equals(activeTab) ? "show active" : "" %>" id="wallet-pane" role="tabpanel">
                    
                    <!-- Wallet Overview Banner -->
                    <div class="p-4 rounded-4 mb-4" style="background: linear-gradient(135deg, rgba(79, 70, 229, 0.15) 0%, rgba(216, 45, 139, 0.1) 100%); border: 1px solid rgba(99, 102, 241, 0.25);">
                        <div class="row align-items-center g-3">
                            <div class="col-md-7">
                                <span class="text-secondary small text-uppercase fw-semibold d-block mb-1">
                                    <i class="bi bi-wallet-fill text-primary me-1"></i>Số dư khả dụng Ví Ftech
                                </span>
                                <h2 class="display-6 fw-bold text-success font-monospace mb-1">
                                    <%= currency.format(userProfile.getBalanceVnd()) %> đ
                                </h2>
                                <p class="text-secondary small mb-0">
                                    Dùng để thanh toán tức thì mọi khóa học. Tiền trong ví có thể rút về tài khoản Ngân hàng hoặc ví MoMo bất kỳ lúc nào.
                                </p>
                            </div>
                            <div class="col-md-5 text-md-end">
                                <div class="d-flex flex-wrap gap-2 justify-content-md-end">
                                    <button type="button" class="btn btn-success px-4 py-2.5 rounded-pill fw-bold shadow-sm d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#topUpModal">
                                        <i class="bi bi-plus-circle fs-5"></i>
                                        <span>Nạp tiền vào ví</span>
                                    </button>
                                    <button type="button" class="btn btn-outline-warning px-4 py-2.5 rounded-pill fw-bold shadow-sm d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#withdrawModal">
                                        <i class="bi bi-box-arrow-up-right fs-5"></i>
                                        <span>Rút tiền</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Transaction History -->
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h5 class="fw-bold text-body mb-0 d-flex align-items-center gap-2">
                            <i class="bi bi-clock-history text-primary"></i>
                            <span>Lịch sử nạp & rút tiền</span>
                        </h5>
                        <span class="text-secondary small">Gần nhất <%= walletTransactions != null ? walletTransactions.size() : 0 %> giao dịch</span>
                    </div>

                    <% if (walletTransactions == null || walletTransactions.isEmpty()) { %>
                        <div class="text-center py-5 border border-secondary border-opacity-25 rounded-4 bg-body-secondary bg-opacity-25">
                            <i class="bi bi-receipt text-secondary fs-1 d-block mb-2"></i>
                            <h6 class="text-body fw-bold mb-1">Chưa có giao dịch ví nào</h6>
                            <p class="text-secondary small mb-3">Các giao dịch nạp tiền, rút tiền hoặc thanh toán khóa học sẽ được hiển thị đầy đủ tại đây.</p>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#topUpModal">
                                Nạp tiền ngay
                            </button>
                        </div>
                    <% } else { %>
                        <div class="table-responsive rounded-4 border border-secondary border-opacity-25">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr class="small text-secondary">
                                        <th scope="col" class="ps-3">Mã GD</th>
                                        <th scope="col">Thời gian</th>
                                        <th scope="col">Loại giao dịch</th>
                                        <th scope="col">Phương thức</th>
                                        <th scope="col">Số tiền</th>
                                        <th scope="col">Trạng thái</th>
                                        <th scope="col" class="pe-3">Chi tiết / Ghi chú</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (WalletTransaction tx : walletTransactions) {
                                        boolean isTopUp = "TOPUP".equalsIgnoreCase(tx.getType());
                                    %>
                                        <tr>
                                            <td class="ps-3 font-monospace small fw-semibold text-secondary">
                                                #TX-<%= tx.getTransactionId() %>
                                            </td>
                                            <td class="small text-secondary">
                                                <%= tx.getCreatedAt() != null ? dtf.format(tx.getCreatedAt()) : "Vừa xong" %>
                                            </td>
                                            <td>
                                                <% if (isTopUp) { %>
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                                                        <i class="bi bi-arrow-down-left me-1"></i>Nạp tiền
                                                    </span>
                                                <% } else { %>
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill">
                                                        <i class="bi bi-arrow-up-right me-1"></i>Rút tiền
                                                    </span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <span class="badge bg-secondary-subtle text-body border border-secondary-subtle rounded-pill font-monospace small">
                                                    <%= tx.getMethod() != null ? tx.getMethod() : "VIETQR" %>
                                                </span>
                                            </td>
                                            <td class="font-monospace fw-bold <%= isTopUp ? "text-success" : "text-danger" %>">
                                                <%= isTopUp ? "+" : "-" %> <%= currency.format(tx.getAmount()) %> đ
                                            </td>
                                            <td>
                                                <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 rounded-pill small">
                                                    Thành công
                                                </span>
                                            </td>
                                            <td class="pe-3 small text-secondary">
                                                <%= tx.getDescription() != null ? tx.getDescription() : "Giao dịch ví" %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>

                </div>

                <!-- Tab 3: Change Password -->
                <div class="tab-pane fade <%= "password".equals(activeTab) ? "show active" : "" %>" id="password-pane" role="tabpanel">
                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="row g-3" style="max-width: 600px;">
                        <input type="hidden" name="action" value="change_password">

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                            <input type="password" name="currentPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Nhập mật khẩu bạn đang sử dụng..." required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Mật khẩu mới <span class="text-danger">*</span></label>
                            <input type="password" name="newPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Tối thiểu 6 ký tự..." minlength="6" required>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-secondary small fw-medium">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                            <input type="password" name="confirmPassword" class="form-control bg-body-tertiary border-secondary border-opacity-25 text-body"
                                   placeholder="Nhập lại mật khẩu mới..." minlength="6" required>
                        </div>

                        <div class="col-12 pt-3">
                            <button type="submit" class="btn btn-warning rounded-pill px-4 fw-medium">
                                <i class="bi bi-key me-1"></i>Cập Nhật Mật Khẩu
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
    <% } %>
</main>

<!-- MODAL NẠP TIỀN -->
<div class="modal fade" id="topUpModal" tabindex="-1" aria-labelledby="topUpModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px;">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow-lg overflow-hidden">
            
            <div class="modal-header border-bottom border-secondary border-opacity-25 px-4 pt-3 pb-2">
                <div>
                    <h5 class="modal-title fw-bold text-white mb-0" id="topUpModalLabel">
                        <i class="bi bi-plus-circle text-success me-2"></i>Nạp tiền vào Ví Ftech
                    </h5>
                    <span class="text-secondary small">Chọn số tiền và phương thức chuyển khoản</span>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="topup">
                <input type="hidden" name="method" id="topUpModalMethod" value="VIETQR">

                <div class="modal-body p-4">
                    
                    <!-- Quick Amount Chips -->
                    <label class="form-label text-secondary small fw-medium mb-2">Chọn nhanh số tiền nạp:</label>
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <button type="button" class="wallet-chip-btn" onclick="setTopUpAmount(50000)">50.000đ</button>
                        <button type="button" class="wallet-chip-btn active" onclick="setTopUpAmount(100000)">100.000đ</button>
                        <button type="button" class="wallet-chip-btn" onclick="setTopUpAmount(200000)">200.000đ</button>
                        <button type="button" class="wallet-chip-btn" onclick="setTopUpAmount(500000)">500.000đ</button>
                        <button type="button" class="wallet-chip-btn" onclick="setTopUpAmount(1000000)">1.000.000đ</button>
                        <button type="button" class="wallet-chip-btn" onclick="setTopUpAmount(2000000)">2.000.000đ</button>
                    </div>

                    <!-- Custom Amount Input -->
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Số tiền muốn nạp (VNĐ) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="number" 
                                   name="amount" 
                                   id="topUpAmountInput" 
                                   class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace fs-5 fw-bold" 
                                   value="100000" 
                                   min="10000" 
                                   step="10000" 
                                   required 
                                   oninput="onTopUpAmountChange()">
                            <span class="input-group-text bg-body-tertiary border-secondary border-opacity-25 text-secondary">VNĐ</span>
                        </div>
                        <div class="form-text text-secondary small">Nạp tối thiểu 10.000đ. Hệ thống tự động cộng tiền sau khi chuyển.</div>
                    </div>

                    <!-- Method Selection (VietQR vs MoMo) -->
                    <label class="form-label text-secondary small fw-medium mb-2">Phương thức chuyển tiền:</label>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <div class="wallet-method-card active-vietqr d-flex align-items-center gap-2" id="walletMethodVietQr" onclick="setWalletTopUpMethod('VIETQR')">
                                <i class="bi bi-bank fs-4 text-primary flex-shrink-0"></i>
                                <div class="lh-sm">
                                    <div class="fw-bold small text-white">Chuyển khoản QR</div>
                                    <div class="text-secondary" style="font-size: 0.72rem;">Ngân hàng MBBank</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="wallet-method-card d-flex align-items-center gap-2" id="walletMethodMomo" onclick="setWalletTopUpMethod('MOMO')">
                                <div class="rounded-circle d-flex align-items-center justify-content-center text-white fw-bold flex-shrink-0" style="width: 26px; height: 26px; background: #d82d8b; font-size: 0.75rem;">M</div>
                                <div class="lh-sm">
                                    <div class="fw-bold small text-white">Ví MoMo</div>
                                    <div class="text-secondary" style="font-size: 0.72rem;">Quét QR MoMo</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Interactive QR Code Box -->
                    <div class="text-center p-3 rounded-3 mb-3 bg-body-tertiary border border-secondary border-opacity-25">
                        <div class="text-secondary small mb-2 fw-medium" id="walletQrTitle">Quét mã VietQR bằng App Ngân hàng bất kỳ:</div>
                        <div class="d-inline-block bg-white p-2 rounded-3 mb-2 shadow">
                            <img id="walletQrImage" 
                                 src="https://api.vietqr.io/image/970422-0987654321-compact2.png?amount=100000&addInfo=NAPTIEN%20<%= userProfile.getUserId() %>&accountName=FTECH%20LMS" 
                                 alt="QR Nạp tiền" 
                                 class="img-fluid" 
                                 style="width: 175px; height: 175px; object-fit: contain;">
                        </div>

                        <div class="row g-1 text-start mx-auto small text-secondary" style="max-width: 300px; font-size: 0.82rem;">
                            <div class="col-5" id="walletDestLabel">Ngân hàng:</div>
                            <div class="col-7 text-white fw-semibold" id="walletDestVal">MBBank (Quân Đội)</div>
                            <div class="col-5" id="walletAccLabel">Số tài khoản:</div>
                            <div class="col-7 text-white font-monospace fw-semibold" id="walletAccVal">0987654321</div>
                            <div class="col-5">Chủ tài khoản:</div>
                            <div class="col-7 text-white fw-semibold">FTECH LMS</div>
                            <div class="col-5">Số tiền nạp:</div>
                            <div class="col-7 text-danger fw-bold font-monospace" id="walletAmountDisplay">100.000đ</div>
                            <div class="col-5">Nội dung:</div>
                            <div class="col-7 text-warning fw-bold font-monospace">NAPTIEN <%= userProfile.getUserId() %></div>
                        </div>
                    </div>

                    <!-- Instant Simulation Confirmation Button -->
                    <button type="submit" class="btn btn-success w-100 py-3 rounded-pill fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-qr-code-scan fs-5"></i>
                        <span id="btnWalletTopUpSubmitText">Xác nhận đã chuyển khoản nạp tiền ngay</span>
                    </button>
                    <div class="text-center text-secondary small mt-2">
                        <i class="bi bi-shield-check me-1"></i>Hệ thống tự động ghi nhận giao dịch và cộng tiền vào ví lập tức.
                    </div>

                </div>
            </form>

        </div>
    </div>
</div>

<!-- MODAL RÚT TIỀN -->
<div class="modal fade" id="withdrawModal" tabindex="-1" aria-labelledby="withdrawModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px;">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 rounded-4 shadow-lg overflow-hidden">
            
            <div class="modal-header border-bottom border-secondary border-opacity-25 px-4 pt-3 pb-2">
                <div>
                    <h5 class="modal-title fw-bold text-white mb-0" id="withdrawModalLabel">
                        <i class="bi bi-box-arrow-up-right text-warning me-2"></i>Rút tiền từ Ví Ftech
                    </h5>
                    <span class="text-secondary small">Rút về tài khoản ngân hàng hoặc ví điện tử MoMo</span>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="withdraw">

                <div class="modal-body p-4">

                    <!-- Balance alert -->
                    <div class="p-3 rounded-3 bg-primary bg-opacity-10 border border-primary border-opacity-25 mb-3 d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-secondary small d-block">Số dư khả dụng hiện tại:</span>
                            <span class="fw-bold text-success font-monospace fs-5">
                                <%= currency.format(userProfile.getBalanceVnd()) %> đ
                            </span>
                        </div>
                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill fw-medium" onclick="withdrawMaxAmount(<%= userProfile.getBalanceVnd().longValue() %>)">
                            Rút tối đa
                        </button>
                    </div>

                    <!-- Withdrawal Amount Input -->
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium">Số tiền muốn rút (VNĐ) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="number" 
                                   name="amount" 
                                   id="withdrawAmountInput" 
                                   class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace fs-5 fw-bold" 
                                   placeholder="Tối thiểu 20.000đ..." 
                                   min="20000" 
                                   max="<%= userProfile.getBalanceVnd().longValue() %>" 
                                   step="10000" 
                                   required>
                            <span class="input-group-text bg-body-tertiary border-secondary border-opacity-25 text-secondary">VNĐ</span>
                        </div>
                        <div class="form-text text-secondary small">Hạn mức rút từ 20.000đ đến <%= currency.format(userProfile.getBalanceVnd()) %>đ. Miễn phí rút.</div>
                    </div>

                    <!-- Destination Method Radio Selector -->
                    <label class="form-label text-secondary small fw-medium mb-2">Nhận tiền qua:</label>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <div class="wallet-method-card active-vietqr d-flex align-items-center gap-2" id="withdrawMethodBankCard" onclick="setWithdrawMethod('BANK')">
                                <input class="form-check-input m-0 d-none" type="radio" name="method" id="withdrawMethodBank" value="BANK" checked>
                                <i class="bi bi-bank fs-4 text-primary flex-shrink-0"></i>
                                <div class="lh-sm">
                                    <div class="fw-bold small text-white">Tài khoản Ngân hàng</div>
                                    <div class="text-secondary" style="font-size: 0.72rem;">Chuyển khoản 24/7</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="wallet-method-card d-flex align-items-center gap-2" id="withdrawMethodMomoCard" onclick="setWithdrawMethod('MOMO')">
                                <input class="form-check-input m-0 d-none" type="radio" name="method" id="withdrawMethodMomo" value="MOMO">
                                <div class="rounded-circle d-flex align-items-center justify-content-center text-white fw-bold flex-shrink-0" style="width: 26px; height: 26px; background: #d82d8b; font-size: 0.75rem;">M</div>
                                <div class="lh-sm">
                                    <div class="fw-bold small text-white">Ví MoMo</div>
                                    <div class="text-secondary" style="font-size: 0.72rem;">Nhận qua SĐT</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Destination Fields for Bank -->
                    <div id="withdrawBankFields">
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-medium">Ngân hàng nhận tiền <span class="text-danger">*</span></label>
                            <select name="bankName" id="bankNameSelect" class="form-select bg-body-tertiary border-secondary border-opacity-25 text-white">
                                <option value="MBBank (Quân Đội)" selected>MBBank (Ngân hàng Quân Đội)</option>
                                <option value="Vietcombank">Vietcombank (Ngoại Thương Việt Nam)</option>
                                <option value="Techcombank">Techcombank (Kỹ Thương)</option>
                                <option value="BIDV">BIDV (Đầu tư và Phát triển)</option>
                                <option value="VietinBank">VietinBank (Công Thương)</option>
                                <option value="ACB">ACB (Á Châu)</option>
                                <option value="VPBank">VPBank (Việt Nam Thịnh Vượng)</option>
                                <option value="TPBank">TPBank (Tiên Phong)</option>
                                <option value="Sacombank">Sacombank (Sài Gòn Thương Tín)</option>
                            </select>
                        </div>
                    </div>

                    <!-- Account / Phone Number -->
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-medium" id="withdrawAccLabel">Số tài khoản nhận tiền <span class="text-danger">*</span></label>
                        <input type="text" 
                               name="accountNo" 
                               id="withdrawAccInput" 
                               class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white font-monospace" 
                               placeholder="VD: 0987654321..." 
                               required>
                    </div>

                    <!-- Account Holder Name -->
                    <div class="mb-4">
                        <label class="form-label text-secondary small fw-medium">Tên chủ tài khoản / người nhận <span class="text-danger">*</span></label>
                        <input type="text" 
                               name="accountHolder" 
                               class="form-control bg-body-tertiary border-secondary border-opacity-25 text-white text-uppercase" 
                               placeholder="VD: NGUYEN VAN A" 
                               value="<%= userProfile.getFullName() != null ? userProfile.getFullName().toUpperCase() : "" %>" 
                               required>
                        <div class="form-text text-secondary small">Vui lòng nhập tên chính xác trùng khớp với tài khoản nhận.</div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="btn btn-warning w-100 py-3 rounded-pill fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-cash-stack fs-5"></i>
                        <span>Xác nhận yêu cầu rút tiền</span>
                    </button>
                    <div class="text-center text-secondary small mt-2">
                        <i class="bi bi-clock-history me-1"></i>Hệ thống tự động duyệt và chuyển tiền về tài khoản của bạn.
                    </div>

                </div>
            </form>

        </div>
    </div>
</div>

<script>
    const currentUserId = '<%= userProfile.getUserId() %>';
    let currentTopUpMethod = 'VIETQR';

    function formatCurrency(val) {
        return new Intl.NumberFormat('vi-VN').format(Math.max(0, Math.round(val))) + 'đ';
    }

    function setTopUpAmount(val) {
        const input = document.getElementById('topUpAmountInput');
        if (input) {
            input.value = val;
            onTopUpAmountChange();
        }
        document.querySelectorAll('.wallet-chip-btn').forEach(btn => {
            btn.classList.toggle('active', btn.innerText.includes(formatCurrency(val)));
        });
    }

    function onTopUpAmountChange() {
        const input = document.getElementById('topUpAmountInput');
        const amount = input ? parseInt(input.value) || 0 : 0;
        const display = document.getElementById('walletAmountDisplay');
        if (display) display.innerText = formatCurrency(amount);
        updateWalletQrImage();
    }

    function setWalletTopUpMethod(method) {
        currentTopUpMethod = method;
        const hiddenMethod = document.getElementById('topUpModalMethod');
        if (hiddenMethod) hiddenMethod.value = method;

        const btnVietQr = document.getElementById('walletMethodVietQr');
        const btnMomo = document.getElementById('walletMethodMomo');
        const title = document.getElementById('walletQrTitle');
        const destLabel = document.getElementById('walletDestLabel');
        const destVal = document.getElementById('walletDestVal');
        const accLabel = document.getElementById('walletAccLabel');
        const accVal = document.getElementById('walletAccVal');
        const submitText = document.getElementById('btnWalletTopUpSubmitText');

        if (method === 'MOMO') {
            if (btnVietQr) btnVietQr.classList.remove('active-vietqr');
            if (btnMomo) btnMomo.classList.add('active-momo');
            if (title) title.innerText = 'Quét mã QR bằng App Ví điện tử MoMo:';
            if (destLabel) destLabel.innerText = 'Dịch vụ:';
            if (destVal) destVal.innerText = 'Ví MoMo';
            if (accLabel) accLabel.innerText = 'SĐT nhận:';
            if (accVal) accVal.innerText = '0987654321';
            if (submitText) submitText.innerText = 'Xác nhận đã chuyển qua MoMo nạp tiền ngay';
        } else {
            if (btnMomo) btnMomo.classList.remove('active-momo');
            if (btnVietQr) btnVietQr.classList.add('active-vietqr');
            if (title) title.innerText = 'Quét mã VietQR bằng App Ngân hàng bất kỳ:';
            if (destLabel) destLabel.innerText = 'Ngân hàng:';
            if (destVal) destVal.innerText = 'MBBank (Quân Đội)';
            if (accLabel) accLabel.innerText = 'Số tài khoản:';
            if (accVal) accVal.innerText = '0987654321';
            if (submitText) submitText.innerText = 'Xác nhận đã chuyển khoản VietQR nạp tiền ngay';
        }

        updateWalletQrImage();
    }

    function updateWalletQrImage() {
        const input = document.getElementById('topUpAmountInput');
        const amount = input ? parseInt(input.value) || 0 : 100000;
        const img = document.getElementById('walletQrImage');
        if (!img) return;

        if (currentTopUpMethod === 'MOMO') {
            img.src = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=2|99|0987654321|FTECH%20LMS||0|0|' + amount + '|NAPTIEN%20' + currentUserId + '|transfer_mycode';
        } else {
            img.src = 'https://api.vietqr.io/image/970422-0987654321-compact2.png?amount=' + amount + '&addInfo=NAPTIEN%20' + currentUserId + '&accountName=FTECH%20LMS';
        }
    }

    function withdrawMaxAmount(maxVal) {
        const input = document.getElementById('withdrawAmountInput');
        if (input) input.value = maxVal;
    }

    function setWithdrawMethod(method) {
        const bankCard = document.getElementById('withdrawMethodBankCard');
        const momoCard = document.getElementById('withdrawMethodMomoCard');
        const bankRadio = document.getElementById('withdrawMethodBank');
        const momoRadio = document.getElementById('withdrawMethodMomo');
        const bankFields = document.getElementById('withdrawBankFields');
        const accLabel = document.getElementById('withdrawAccLabel');
        const accInput = document.getElementById('withdrawAccInput');

        if (method === 'MOMO') {
            if (bankCard) bankCard.classList.remove('active-vietqr');
            if (momoCard) momoCard.classList.add('active-momo');
            if (momoRadio) momoRadio.checked = true;
            if (bankFields) bankFields.classList.add('d-none');
            if (accLabel) accLabel.innerHTML = 'Số điện thoại Ví MoMo nhận tiền <span class="text-danger">*</span>';
            if (accInput) accInput.placeholder = 'VD: 0987654321';
        } else {
            if (momoCard) momoCard.classList.remove('active-momo');
            if (bankCard) bankCard.classList.add('active-vietqr');
            if (bankRadio) bankRadio.checked = true;
            if (bankFields) bankFields.classList.remove('d-none');
            if (accLabel) accLabel.innerHTML = 'Số tài khoản ngân hàng nhận tiền <span class="text-danger">*</span>';
            if (accInput) accInput.placeholder = 'VD: 0987654321';
        }
    }

    // Tab switcher
    document.querySelectorAll('#profileTab button').forEach(function(triggerEl) {
        triggerEl.addEventListener('click', function(event) {
            event.preventDefault();
            document.querySelectorAll('#profileTab button').forEach(function(btn) {
                btn.classList.remove('active', 'text-white', 'border-bottom', 'border-primary', 'border-3');
                btn.classList.add('text-secondary');
            });
            triggerEl.classList.add('active', 'text-white', 'border-bottom', 'border-primary', 'border-3');
            triggerEl.classList.remove('text-secondary');
        });
    });
</script>

<%@include file="/WEB-INF/view/layout/publicFooter.jsp" %>
