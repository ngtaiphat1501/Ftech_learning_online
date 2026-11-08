-- =============================================================================
-- LEARNORA PAID LMS — SAFE IDEMPOTENT SQL SERVER INITIALIZATION SCRIPT
-- Database: LearnoraDemoDB
-- Note (Section 21): Does NOT drop user database when re-running.
-- =============================================================================

USE master;
GO

IF DB_ID(N'LearnoraDemoDB') IS NULL
BEGIN
    CREATE DATABASE [LearnoraDemoDB];
END
GO

USE [LearnoraDemoDB];
GO

-- =============================================================================
-- CLEAN DROP OF PREVIOUS SCHEMA OBJECTS (IN REVERSE FOREIGN-KEY ORDER)
-- Ensures re-running this script on an existing LearnoraDemoDB from an older
-- version never fails with "Invalid column name" or schema mismatch errors.
-- =============================================================================
-- Drop all existing foreign keys dynamically so any older version of LearnoraDemoDB upgrades cleanly
DECLARE @dropFkSql NVARCHAR(MAX) = N'';
SELECT @dropFkSql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
                   + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
FROM sys.foreign_keys;
IF LEN(@dropFkSql) > 0 EXEC sp_executesql @dropFkSql;
GO

IF OBJECT_ID(N'dbo.vCourseStatistics', N'V') IS NOT NULL DROP VIEW dbo.vCourseStatistics;
IF OBJECT_ID(N'dbo.vEnrollmentProgress', N'V') IS NOT NULL DROP VIEW dbo.vEnrollmentProgress;
GO

IF OBJECT_ID(N'dbo.CartItems', N'U') IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID(N'dbo.Carts', N'U') IS NOT NULL DROP TABLE dbo.Carts;
IF OBJECT_ID(N'dbo.Certificates', N'U') IS NOT NULL DROP TABLE dbo.Certificates;
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL DROP TABLE dbo.CourseReviews;
IF OBJECT_ID(N'dbo.DiscussionPosts', N'U') IS NOT NULL DROP TABLE dbo.DiscussionPosts;
IF OBJECT_ID(N'dbo.AttemptAnswers', N'U') IS NOT NULL DROP TABLE dbo.AttemptAnswers;
IF OBJECT_ID(N'dbo.QuizAttempts', N'U') IS NOT NULL DROP TABLE dbo.QuizAttempts;
IF OBJECT_ID(N'dbo.AnswerOptions', N'U') IS NOT NULL DROP TABLE dbo.AnswerOptions;
IF OBJECT_ID(N'dbo.Questions', N'U') IS NOT NULL DROP TABLE dbo.Questions;
IF OBJECT_ID(N'dbo.Quizzes', N'U') IS NOT NULL DROP TABLE dbo.Quizzes;
IF OBJECT_ID(N'dbo.LessonProgress', N'U') IS NOT NULL DROP TABLE dbo.LessonProgress;
IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL DROP TABLE dbo.AuditLogs;
IF OBJECT_ID(N'dbo.EnrollmentAccessEvents', N'U') IS NOT NULL DROP TABLE dbo.EnrollmentAccessEvents;
IF OBJECT_ID(N'dbo.Enrollments', N'U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID(N'dbo.Refunds', N'U') IS NOT NULL DROP TABLE dbo.Refunds;
IF OBJECT_ID(N'dbo.PaymentEvents', N'U') IS NOT NULL DROP TABLE dbo.PaymentEvents;
IF OBJECT_ID(N'dbo.PaymentAttempts', N'U') IS NOT NULL DROP TABLE dbo.PaymentAttempts;
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Coupons', N'U') IS NOT NULL DROP TABLE dbo.Coupons;
IF OBJECT_ID(N'dbo.LessonResources', N'U') IS NOT NULL DROP TABLE dbo.LessonResources;
IF OBJECT_ID(N'dbo.Lessons', N'U') IS NOT NULL DROP TABLE dbo.Lessons;
IF OBJECT_ID(N'dbo.Chapters', N'U') IS NOT NULL DROP TABLE dbo.Chapters;
IF OBJECT_ID(N'dbo.CourseApprovalEvents', N'U') IS NOT NULL DROP TABLE dbo.CourseApprovalEvents;
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- =============================================================================
-- LEARNORA PAID LMS — SQL SERVER SCHEMA (25 CORE TABLES + 2 EXTENDED + 3 VIEWS)
-- Strictly follows: Learnora_Paid_LMS_Thiet_ke_chi_tiet.md (Sections 7, 8, 11, 12)
-- 18 Original Tables + 7 Mandatory Buy-Now Tables:
--   Orders, OrderItems, PaymentAttempts, PaymentEvents, Refunds,
--   EnrollmentAccessEvents, AuditLogs (+ Coupons, Certificates)
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Users
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE dbo.Users (
    UserId          BIGINT IDENTITY(1,1) NOT NULL,
    Email           NVARCHAR(254) NOT NULL,
    NormalizedEmail AS LOWER(LTRIM(RTRIM(Email))) PERSISTED,
    PasswordHash    VARCHAR(255) NOT NULL,
    FullName        NVARCHAR(150) NOT NULL,
    Headline        NVARCHAR(200) NULL,
    Bio             NVARCHAR(2000) NULL,
    AvatarUrl       NVARCHAR(1000) NULL,
    Status          VARCHAR(10) NOT NULL CONSTRAINT DF_Users_Status DEFAULT ('ACTIVE'),
    BalanceVnd      DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Users_BalanceVnd DEFAULT (0),
    CreatedAt       DATETIME2(3) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt       DATETIME2(3) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId),
    CONSTRAINT UQ_Users_NormalizedEmail UNIQUE (NormalizedEmail),
    CONSTRAINT CK_Users_Status CHECK (Status IN ('ACTIVE', 'LOCKED')),
    CONSTRAINT CK_Users_BalanceVnd CHECK (BalanceVnd >= 0),
    CONSTRAINT CK_Users_Email_NotBlank CHECK (LEN(LTRIM(RTRIM(Email))) >= 5),
    CONSTRAINT CK_Users_FullName_NotBlank CHECK (LEN(LTRIM(RTRIM(FullName))) >= 2)
);
GO

-- Ensure BalanceVnd exists if table already existed in an older database
IF COL_LENGTH(N'dbo.Users', N'BalanceVnd') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD BalanceVnd DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Users_BalanceVnd DEFAULT (0);
END
GO

-- 2. Roles
IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
CREATE TABLE dbo.Roles (
    RoleCode VARCHAR(20) NOT NULL,
    RoleName NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (RoleCode),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName),
    CONSTRAINT CK_Roles_Code CHECK (RoleCode IN ('ADMIN', 'INSTRUCTOR', 'STUDENT'))
);
GO

-- 3. UserRoles
IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NULL
CREATE TABLE dbo.UserRoles (
    UserId    BIGINT NOT NULL,
    RoleCode  VARCHAR(20) NOT NULL,
    GrantedAt DATETIME2(3) NOT NULL CONSTRAINT DF_UserRoles_GrantedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_UserRoles PRIMARY KEY CLUSTERED (UserId, RoleCode),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleCode) REFERENCES dbo.Roles(RoleCode)
);
GO

-- 4. Categories
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
CREATE TABLE dbo.Categories (
    CategoryId  BIGINT IDENTITY(1,1) NOT NULL,
    Name        NVARCHAR(100) NOT NULL,
    Slug        VARCHAR(120) NULL,
    IconClass   VARCHAR(60) NULL CONSTRAINT DF_Categories_IconClass DEFAULT ('bi-code-square'),
    Description NVARCHAR(1000) NULL,
    IsActive    BIT NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT (1),
    CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (CategoryId),
    CONSTRAINT UQ_Categories_Name UNIQUE (Name)
);
GO

-- 5. Courses (With Slug, PricingType FREE/PAID, ListPriceVnd, SalePriceVnd, ProposedPriceVnd, Status incl. SUSPENDED)
IF OBJECT_ID(N'dbo.Courses', N'U') IS NULL
CREATE TABLE dbo.Courses (
    CourseId           BIGINT IDENTITY(1,1) NOT NULL,
    CategoryId         BIGINT NOT NULL,
    InstructorId       BIGINT NOT NULL,
    Slug               VARCHAR(220) NOT NULL,
    Title              NVARCHAR(200) NOT NULL,
    Subtitle           NVARCHAR(300) NULL,
    Description        NVARCHAR(MAX) NOT NULL,
    LearningObjectives NVARCHAR(MAX) NULL,
    Requirements       NVARCHAR(MAX) NULL,
    TargetAudience     NVARCHAR(1000) NULL,
    ThumbnailUrl       NVARCHAR(1000) NULL,
    IntroVideoUrl      NVARCHAR(1000) NULL,
    Level              VARCHAR(20) NOT NULL CONSTRAINT DF_Courses_Level DEFAULT ('BEGINNER'),
    Language           NVARCHAR(40) NOT NULL CONSTRAINT DF_Courses_Language DEFAULT (N'Tiếng Việt'),
    EstimatedHours     DECIMAL(5,1) NOT NULL CONSTRAINT DF_Courses_EstimatedHours DEFAULT (10.0),
    PricingType        VARCHAR(10) NOT NULL CONSTRAINT DF_Courses_PricingType DEFAULT ('FREE'),
    ListPriceVnd       DECIMAL(18,0) NOT NULL CONSTRAINT DF_Courses_ListPriceVnd DEFAULT (0),
    SalePriceVnd       DECIMAL(18,0) NULL,
    ProposedPriceVnd   DECIMAL(18,0) NULL,
    Status             VARCHAR(20) NOT NULL CONSTRAINT DF_Courses_Status DEFAULT ('DRAFT'),
    RejectionReason    NVARCHAR(2000) NULL,
    PublishedAt        DATETIME2(3) NULL,
    CreatedAt          DATETIME2(3) NOT NULL CONSTRAINT DF_Courses_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt          DATETIME2(3) NOT NULL CONSTRAINT DF_Courses_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    RowVersion         ROWVERSION NOT NULL,
    CONSTRAINT PK_Courses PRIMARY KEY CLUSTERED (CourseId),
    CONSTRAINT UQ_Courses_Slug UNIQUE (Slug),
    CONSTRAINT FK_Courses_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT FK_Courses_Users FOREIGN KEY (InstructorId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Courses_Level CHECK (Level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    CONSTRAINT CK_Courses_PricingType CHECK (PricingType IN ('FREE', 'PAID')),
    CONSTRAINT CK_Courses_Status CHECK (Status IN ('DRAFT', 'PENDING_APPROVAL', 'PUBLISHED', 'ARCHIVED', 'SUSPENDED')),
    CONSTRAINT CK_Courses_Prices CHECK (
        (PricingType = 'FREE' AND ListPriceVnd = 0 AND SalePriceVnd IS NULL) OR
        (PricingType = 'PAID' AND ListPriceVnd > 0 AND (SalePriceVnd IS NULL OR (SalePriceVnd >= 0 AND SalePriceVnd <= ListPriceVnd)))
    )
);
GO

-- 6. CourseApprovalEvents
IF OBJECT_ID(N'dbo.CourseApprovalEvents', N'U') IS NULL
CREATE TABLE dbo.CourseApprovalEvents (
    EventId    BIGINT IDENTITY(1,1) NOT NULL,
    CourseId   BIGINT NOT NULL,
    ActorId    BIGINT NOT NULL,
    Action     VARCHAR(15) NOT NULL,
    FromStatus VARCHAR(20) NOT NULL,
    ToStatus   VARCHAR(20) NOT NULL,
    Note       NVARCHAR(2000) NULL,
    CreatedAt  DATETIME2(3) NOT NULL CONSTRAINT DF_CourseApprovalEvents_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_CourseApprovalEvents PRIMARY KEY CLUSTERED (EventId),
    CONSTRAINT FK_CourseApprovalEvents_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_CourseApprovalEvents_Users FOREIGN KEY (ActorId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_CourseApprovalEvents_Action CHECK (Action IN ('SUBMIT', 'APPROVE', 'REJECT', 'ARCHIVE', 'REOPEN', 'SUSPEND', 'RESTORE'))
);
GO

-- 7. Chapters
IF OBJECT_ID(N'dbo.Chapters', N'U') IS NULL
CREATE TABLE dbo.Chapters (
    ChapterId   BIGINT IDENTITY(1,1) NOT NULL,
    CourseId    BIGINT NOT NULL,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder   INT NOT NULL,
    CONSTRAINT PK_Chapters PRIMARY KEY CLUSTERED (ChapterId),
    CONSTRAINT UQ_Chapters_ChapterId_CourseId UNIQUE (ChapterId, CourseId),
    CONSTRAINT UQ_Chapters_CourseId_SortOrder UNIQUE (CourseId, SortOrder),
    CONSTRAINT FK_Chapters_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Chapters_SortOrder CHECK (SortOrder >= 1)
);
GO

-- 8. Lessons
IF OBJECT_ID(N'dbo.Lessons', N'U') IS NULL
CREATE TABLE dbo.Lessons (
    LessonId        BIGINT IDENTITY(1,1) NOT NULL,
    ChapterId       BIGINT NOT NULL,
    CourseId        BIGINT NOT NULL,
    Title           NVARCHAR(200) NOT NULL,
    Content         NVARCHAR(MAX) NULL,
    VideoUrl        NVARCHAR(1000) NULL,
    DurationSeconds INT NULL CONSTRAINT DF_Lessons_DurationSeconds DEFAULT (600),
    SortOrder       INT NOT NULL,
    IsPreview       BIT NOT NULL CONSTRAINT DF_Lessons_IsPreview DEFAULT (0),
    IsRequired      BIT NOT NULL CONSTRAINT DF_Lessons_IsRequired DEFAULT (1),
    CONSTRAINT PK_Lessons PRIMARY KEY CLUSTERED (LessonId),
    CONSTRAINT UQ_Lessons_LessonId_CourseId UNIQUE (LessonId, CourseId),
    CONSTRAINT UQ_Lessons_ChapterId_SortOrder UNIQUE (ChapterId, SortOrder),
    CONSTRAINT FK_Lessons_Chapters FOREIGN KEY (ChapterId, CourseId) REFERENCES dbo.Chapters(ChapterId, CourseId),
    CONSTRAINT CK_Lessons_SortOrder CHECK (SortOrder >= 1),
    CONSTRAINT CK_Lessons_Duration CHECK (DurationSeconds IS NULL OR DurationSeconds >= 0)
);
GO

-- 9. LessonResources
IF OBJECT_ID(N'dbo.LessonResources', N'U') IS NULL
CREATE TABLE dbo.LessonResources (
    ResourceId   BIGINT IDENTITY(1,1) NOT NULL,
    LessonId     BIGINT NOT NULL,
    Title        NVARCHAR(200) NOT NULL,
    ResourceUrl  NVARCHAR(1000) NOT NULL,
    ResourceType VARCHAR(10) NOT NULL CONSTRAINT DF_LessonResources_Type DEFAULT ('PDF'),
    CONSTRAINT PK_LessonResources PRIMARY KEY CLUSTERED (ResourceId),
    CONSTRAINT FK_LessonResources_Lessons FOREIGN KEY (LessonId) REFERENCES dbo.Lessons(LessonId),
    CONSTRAINT CK_LessonResources_Type CHECK (ResourceType IN ('PDF', 'SLIDE', 'CODE', 'LINK', 'ZIP', 'DOC'))
);
GO

-- 10. Coupons (Extended Table for Promotional Discounts)
IF OBJECT_ID(N'dbo.Coupons', N'U') IS NULL
CREATE TABLE dbo.Coupons (
    CouponId          BIGINT IDENTITY(1,1) NOT NULL,
    Code              VARCHAR(30) NOT NULL,
    Description       NVARCHAR(250) NULL,
    DiscountPercent   INT NOT NULL,
    MaxDiscountVnd    DECIMAL(18,0) NULL,
    MinOrderVnd       DECIMAL(18,0) NOT NULL CONSTRAINT DF_Coupons_MinOrder DEFAULT (0),
    UsageLimit        INT NOT NULL CONSTRAINT DF_Coupons_UsageLimit DEFAULT (100),
    UsedCount         INT NOT NULL CONSTRAINT DF_Coupons_UsedCount DEFAULT (0),
    IsActive          BIT NOT NULL CONSTRAINT DF_Coupons_IsActive DEFAULT (1),
    ExpiresAt         DATETIME2(3) NULL,
    CreatedAt         DATETIME2(3) NOT NULL CONSTRAINT DF_Coupons_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Coupons PRIMARY KEY CLUSTERED (CouponId),
    CONSTRAINT UQ_Coupons_Code UNIQUE (Code),
    CONSTRAINT CK_Coupons_Discount CHECK (DiscountPercent BETWEEN 1 AND 100),
    CONSTRAINT CK_Coupons_Usage CHECK (UsageLimit >= 1 AND UsedCount >= 0)
);
GO

-- 10B. Carts & CartItems (Shopping Cart + Multi-Course Combo Checkout)
IF OBJECT_ID(N'dbo.Carts', N'U') IS NULL
CREATE TABLE dbo.Carts (
    CartId      BIGINT IDENTITY(1,1) NOT NULL,
    StudentId   BIGINT NOT NULL,
    CouponCode  VARCHAR(30) NULL,
    CreatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_Carts_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_Carts_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Carts PRIMARY KEY CLUSTERED (CartId),
    CONSTRAINT UQ_Carts_Student UNIQUE (StudentId),
    CONSTRAINT FK_Carts_Users FOREIGN KEY (StudentId) REFERENCES dbo.Users(UserId)
);
GO

IF OBJECT_ID(N'dbo.CartItems', N'U') IS NULL
CREATE TABLE dbo.CartItems (
    CartItemId  BIGINT IDENTITY(1,1) NOT NULL,
    CartId      BIGINT NOT NULL,
    CourseId    BIGINT NOT NULL,
    AddedAt     DATETIME2(3) NOT NULL CONSTRAINT DF_CartItems_AddedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_CartItems PRIMARY KEY CLUSTERED (CartItemId),
    CONSTRAINT UQ_CartItems_Cart_Course UNIQUE (CartId, CourseId),
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartId) REFERENCES dbo.Carts(CartId) ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId)
);
GO

-- 11. Orders (Mandatory Table #1 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
CREATE TABLE dbo.Orders (
    OrderId        BIGINT IDENTITY(1,1) NOT NULL,
    OrderCode      VARCHAR(40) NOT NULL,
    StudentId      BIGINT NOT NULL,
    Status         VARCHAR(25) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('PENDING_PAYMENT'),
    Currency       VARCHAR(3) NOT NULL CONSTRAINT DF_Orders_Currency DEFAULT ('VND'),
    SubtotalVnd    DECIMAL(18,0) NOT NULL,
    DiscountVnd    DECIMAL(18,0) NOT NULL CONSTRAINT DF_Orders_DiscountVnd DEFAULT (0),
    TotalVnd       DECIMAL(18,0) NOT NULL,
    CouponCode     VARCHAR(30) NULL,
    PolicyVersion  VARCHAR(20) NOT NULL CONSTRAINT DF_Orders_PolicyVersion DEFAULT ('v2026.1'),
    IdempotencyKey VARCHAR(64) NOT NULL,
    CreatedAt      DATETIME2(3) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSUTCDATETIME()),
    ExpiresAt      DATETIME2(3) NOT NULL,
    PaidAt         DATETIME2(3) NULL,
    RowVersion     ROWVERSION NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderId),
    CONSTRAINT UQ_Orders_OrderCode UNIQUE (OrderCode),
    CONSTRAINT UQ_Orders_Student_Idempotency UNIQUE (StudentId, IdempotencyKey),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (StudentId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('PENDING_PAYMENT', 'PAYMENT_REVIEW', 'PAID', 'CANCELLED', 'EXPIRED', 'REFUNDED')),
    CONSTRAINT CK_Orders_Amounts CHECK (SubtotalVnd >= 0 AND DiscountVnd >= 0 AND DiscountVnd <= SubtotalVnd AND TotalVnd = SubtotalVnd - DiscountVnd)
);
GO

-- 12. OrderItems (Mandatory Table #2 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NULL
CREATE TABLE dbo.OrderItems (
    OrderItemId         BIGINT IDENTITY(1,1) NOT NULL,
    OrderId             BIGINT NOT NULL,
    CourseId            BIGINT NOT NULL,
    CourseTitleSnapshot NVARCHAR(200) NOT NULL,
    UnitPriceVnd        DECIMAL(18,0) NOT NULL,
    DiscountVnd         DECIMAL(18,0) NOT NULL CONSTRAINT DF_OrderItems_DiscountVnd DEFAULT (0),
    PayableVnd          DECIMAL(18,0) NOT NULL,
    CONSTRAINT PK_OrderItems PRIMARY KEY CLUSTERED (OrderItemId),
    CONSTRAINT UQ_OrderItems_Order_Course UNIQUE (OrderId, CourseId),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderItems_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_OrderItems_Amounts CHECK (UnitPriceVnd >= 0 AND DiscountVnd >= 0 AND DiscountVnd <= UnitPriceVnd AND PayableVnd = UnitPriceVnd - DiscountVnd)
);
GO

-- 13. PaymentAttempts (Mandatory Table #3 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.PaymentAttempts', N'U') IS NULL
CREATE TABLE dbo.PaymentAttempts (
    PaymentAttemptId      BIGINT IDENTITY(1,1) NOT NULL,
    OrderId               BIGINT NOT NULL,
    MerchantReference     VARCHAR(64) NOT NULL,
    Provider              VARCHAR(30) NOT NULL CONSTRAINT DF_PaymentAttempts_Provider DEFAULT ('VNPAY_SANDBOX'),
    ProviderTransactionId VARCHAR(100) NULL,
    AmountVnd             DECIMAL(18,0) NOT NULL,
    Currency              VARCHAR(3) NOT NULL CONSTRAINT DF_PaymentAttempts_Currency DEFAULT ('VND'),
    Status                VARCHAR(20) NOT NULL CONSTRAINT DF_PaymentAttempts_Status DEFAULT ('CREATED'),
    CreatedAt             DATETIME2(3) NOT NULL CONSTRAINT DF_PaymentAttempts_CreatedAt DEFAULT (SYSUTCDATETIME()),
    LastVerifiedAt        DATETIME2(3) NULL,
    CONSTRAINT PK_PaymentAttempts PRIMARY KEY CLUSTERED (PaymentAttemptId),
    CONSTRAINT UQ_PaymentAttempts_MerchantRef UNIQUE (MerchantReference),
    CONSTRAINT FK_PaymentAttempts_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT CK_PaymentAttempts_Status CHECK (Status IN ('CREATED', 'PENDING', 'SUCCEEDED', 'FAILED', 'CANCELLED', 'EXPIRED', 'UNKNOWN')),
    CONSTRAINT CK_PaymentAttempts_Amount CHECK (AmountVnd >= 0)
);
GO

-- 14. PaymentEvents (Mandatory Table #4 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.PaymentEvents', N'U') IS NULL
CREATE TABLE dbo.PaymentEvents (
    PaymentEventId     BIGINT IDENTITY(1,1) NOT NULL,
    PaymentAttemptId   BIGINT NULL,
    PayloadHash        VARCHAR(64) NOT NULL,
    ReceivedAt         DATETIME2(3) NOT NULL CONSTRAINT DF_PaymentEvents_ReceivedAt DEFAULT (SYSUTCDATETIME()),
    VerificationResult VARCHAR(30) NOT NULL,
    ProcessResult      VARCHAR(40) NOT NULL,
    ProviderEventId    VARCHAR(100) NULL,
    MaskedSummary      NVARCHAR(500) NULL,
    CONSTRAINT PK_PaymentEvents PRIMARY KEY CLUSTERED (PaymentEventId),
    CONSTRAINT FK_PaymentEvents_Attempts FOREIGN KEY (PaymentAttemptId) REFERENCES dbo.PaymentAttempts(PaymentAttemptId)
);
GO

-- 15. Refunds (Mandatory Table #5 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.Refunds', N'U') IS NULL
CREATE TABLE dbo.Refunds (
    RefundId         BIGINT IDENTITY(1,1) NOT NULL,
    OrderId          BIGINT NOT NULL,
    PaymentAttemptId BIGINT NOT NULL,
    RefundReference  VARCHAR(64) NOT NULL,
    AmountVnd        DECIMAL(18,0) NOT NULL,
    Reason           NVARCHAR(1000) NOT NULL,
    Status           VARCHAR(20) NOT NULL CONSTRAINT DF_Refunds_Status DEFAULT ('REQUESTED'),
    RequestedBy      BIGINT NOT NULL,
    ApprovedBy       BIGINT NULL,
    RequestedAt      DATETIME2(3) NOT NULL CONSTRAINT DF_Refunds_RequestedAt DEFAULT (SYSUTCDATETIME()),
    RefundedAt       DATETIME2(3) NULL,
    CONSTRAINT PK_Refunds PRIMARY KEY CLUSTERED (RefundId),
    CONSTRAINT UQ_Refunds_Reference UNIQUE (RefundReference),
    CONSTRAINT FK_Refunds_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_Refunds_Attempts FOREIGN KEY (PaymentAttemptId) REFERENCES dbo.PaymentAttempts(PaymentAttemptId),
    CONSTRAINT FK_Refunds_RequestedBy FOREIGN KEY (RequestedBy) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Refunds_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Refunds_Status CHECK (Status IN ('REQUESTED', 'APPROVED', 'PROCESSING', 'SUCCEEDED', 'REJECTED', 'FAILED')),
    CONSTRAINT CK_Refunds_Amount CHECK (AmountVnd > 0)
);
GO

-- 16. Enrollments (With AccessStatus ACTIVE/SUSPENDED/REVOKED, SourceType, CurrentOrderItemId)
IF OBJECT_ID(N'dbo.Enrollments', N'U') IS NULL
CREATE TABLE dbo.Enrollments (
    EnrollmentId         BIGINT IDENTITY(1,1) NOT NULL,
    StudentId            BIGINT NOT NULL,
    CourseId             BIGINT NOT NULL,
    AccessStatus         VARCHAR(20) NOT NULL CONSTRAINT DF_Enrollments_AccessStatus DEFAULT ('ACTIVE'),
    SourceType           VARCHAR(20) NOT NULL CONSTRAINT DF_Enrollments_SourceType DEFAULT ('FREE_ENROLL'),
    CurrentOrderItemId   BIGINT NULL,
    EnrolledAt           DATETIME2(3) NOT NULL CONSTRAINT DF_Enrollments_EnrolledAt DEFAULT (SYSUTCDATETIME()),
    CompletedAt          DATETIME2(3) NULL,
    LastAccessedLessonId BIGINT NULL,
    LastAccessedAt       DATETIME2(3) NULL,
    RowVersion           ROWVERSION NOT NULL,
    CONSTRAINT PK_Enrollments PRIMARY KEY CLUSTERED (EnrollmentId),
    CONSTRAINT UQ_Enrollments_Student_Course UNIQUE (StudentId, CourseId),
    CONSTRAINT UQ_Enrollments_Enrollment_Course UNIQUE (EnrollmentId, CourseId),
    CONSTRAINT FK_Enrollments_Users FOREIGN KEY (StudentId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrollments_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_Enrollments_OrderItems FOREIGN KEY (CurrentOrderItemId) REFERENCES dbo.OrderItems(OrderItemId),
    CONSTRAINT CK_Enrollments_AccessStatus CHECK (AccessStatus IN ('ACTIVE', 'SUSPENDED', 'REVOKED')),
    CONSTRAINT CK_Enrollments_SourceType CHECK (SourceType IN ('FREE_ENROLL', 'ORDER_PURCHASE', 'PROMO_FULL_DISCOUNT'))
);
GO

-- 17. EnrollmentAccessEvents (Mandatory Table #6 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.EnrollmentAccessEvents', N'U') IS NULL
CREATE TABLE dbo.EnrollmentAccessEvents (
    EventId           BIGINT IDENTITY(1,1) NOT NULL,
    EnrollmentId      BIGINT NOT NULL,
    SourceOrderItemId BIGINT NULL,
    EventType         VARCHAR(20) NOT NULL,
    ActorId           BIGINT NULL,
    CreatedAt         DATETIME2(3) NOT NULL CONSTRAINT DF_EnrollmentAccessEvents_CreatedAt DEFAULT (SYSUTCDATETIME()),
    Reason            NVARCHAR(500) NULL,
    CONSTRAINT PK_EnrollmentAccessEvents PRIMARY KEY CLUSTERED (EventId),
    CONSTRAINT FK_EnrollmentAccessEvents_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollments(EnrollmentId),
    CONSTRAINT FK_EnrollmentAccessEvents_OrderItems FOREIGN KEY (SourceOrderItemId) REFERENCES dbo.OrderItems(OrderItemId),
    CONSTRAINT FK_EnrollmentAccessEvents_Users FOREIGN KEY (ActorId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_EnrollmentAccessEvents_Type CHECK (EventType IN ('GRANTED', 'REVOKED', 'REACTIVATED', 'SUSPENDED'))
);
GO

-- 18. AuditLogs (Mandatory Table #7 of 7 in Section 12.2)
IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NULL
CREATE TABLE dbo.AuditLogs (
    AuditLogId    BIGINT IDENTITY(1,1) NOT NULL,
    ActorId       BIGINT NULL,
    Action        VARCHAR(60) NOT NULL,
    EntityType    VARCHAR(40) NOT NULL,
    EntityId      VARCHAR(64) NOT NULL,
    CreatedAt     DATETIME2(3) NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CorrelationId VARCHAR(64) NULL,
    ChangeSummary NVARCHAR(1000) NULL,
    CONSTRAINT PK_AuditLogs PRIMARY KEY CLUSTERED (AuditLogId),
    CONSTRAINT FK_AuditLogs_Users FOREIGN KEY (ActorId) REFERENCES dbo.Users(UserId)
);
GO

-- 19. LessonProgress
IF OBJECT_ID(N'dbo.LessonProgress', N'U') IS NULL
CREATE TABLE dbo.LessonProgress (
    EnrollmentId        BIGINT NOT NULL,
    LessonId            BIGINT NOT NULL,
    CourseId            BIGINT NOT NULL,
    LastPositionSeconds INT NOT NULL CONSTRAINT DF_LessonProgress_LastPosition DEFAULT (0),
    StudentNotes        NVARCHAR(MAX) NULL,
    LastAccessedAt      DATETIME2(3) NOT NULL CONSTRAINT DF_LessonProgress_LastAccessed DEFAULT (SYSUTCDATETIME()),
    CompletedAt         DATETIME2(3) NULL,
    CONSTRAINT PK_LessonProgress PRIMARY KEY CLUSTERED (EnrollmentId, LessonId),
    CONSTRAINT FK_LessonProgress_Enrollments FOREIGN KEY (EnrollmentId, CourseId) REFERENCES dbo.Enrollments(EnrollmentId, CourseId),
    CONSTRAINT FK_LessonProgress_Lessons FOREIGN KEY (LessonId, CourseId) REFERENCES dbo.Lessons(LessonId, CourseId),
    CONSTRAINT CK_LessonProgress_Position CHECK (LastPositionSeconds >= 0)
);
GO

-- 20. Quizzes
IF OBJECT_ID(N'dbo.Quizzes', N'U') IS NULL
CREATE TABLE dbo.Quizzes (
    QuizId          BIGINT IDENTITY(1,1) NOT NULL,
    CourseId        BIGINT NOT NULL,
    Title           NVARCHAR(200) NOT NULL,
    Description     NVARCHAR(1000) NULL,
    DurationMinutes INT NOT NULL CONSTRAINT DF_Quizzes_Duration DEFAULT (20),
    MaxAttempts     INT NOT NULL CONSTRAINT DF_Quizzes_MaxAttempts DEFAULT (3),
    PassingScore    DECIMAL(5,2) NOT NULL CONSTRAINT DF_Quizzes_PassingScore DEFAULT (70.00),
    IsRequired      BIT NOT NULL CONSTRAINT DF_Quizzes_IsRequired DEFAULT (1),
    SortOrder       INT NOT NULL CONSTRAINT DF_Quizzes_SortOrder DEFAULT (1),
    CONSTRAINT PK_Quizzes PRIMARY KEY CLUSTERED (QuizId),
    CONSTRAINT UQ_Quizzes_QuizId_CourseId UNIQUE (QuizId, CourseId),
    CONSTRAINT UQ_Quizzes_CourseId_SortOrder UNIQUE (CourseId, SortOrder),
    CONSTRAINT FK_Quizzes_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Quizzes_Duration CHECK (DurationMinutes BETWEEN 1 AND 300),
    CONSTRAINT CK_Quizzes_MaxAttempts CHECK (MaxAttempts BETWEEN 1 AND 50),
    CONSTRAINT CK_Quizzes_PassingScore CHECK (PassingScore BETWEEN 0 AND 100)
);
GO

-- 21. Questions
IF OBJECT_ID(N'dbo.Questions', N'U') IS NULL
CREATE TABLE dbo.Questions (
    QuestionId  BIGINT IDENTITY(1,1) NOT NULL,
    QuizId      BIGINT NOT NULL,
    Content     NVARCHAR(MAX) NOT NULL,
    Explanation NVARCHAR(MAX) NULL,
    Points      DECIMAL(6,2) NOT NULL CONSTRAINT DF_Questions_Points DEFAULT (1.00),
    SortOrder   INT NOT NULL,
    CONSTRAINT PK_Questions PRIMARY KEY CLUSTERED (QuestionId),
    CONSTRAINT UQ_Questions_QuestionId_QuizId UNIQUE (QuestionId, QuizId),
    CONSTRAINT UQ_Questions_QuizId_SortOrder UNIQUE (QuizId, SortOrder),
    CONSTRAINT FK_Questions_Quizzes FOREIGN KEY (QuizId) REFERENCES dbo.Quizzes(QuizId),
    CONSTRAINT CK_Questions_Points CHECK (Points > 0),
    CONSTRAINT CK_Questions_SortOrder CHECK (SortOrder >= 1)
);
GO

-- 22. AnswerOptions
IF OBJECT_ID(N'dbo.AnswerOptions', N'U') IS NULL
CREATE TABLE dbo.AnswerOptions (
    OptionId   BIGINT IDENTITY(1,1) NOT NULL,
    QuestionId BIGINT NOT NULL,
    Content    NVARCHAR(2000) NOT NULL,
    IsCorrect  BIT NOT NULL CONSTRAINT DF_AnswerOptions_IsCorrect DEFAULT (0),
    SortOrder  INT NOT NULL,
    CONSTRAINT PK_AnswerOptions PRIMARY KEY CLUSTERED (OptionId),
    CONSTRAINT UQ_AnswerOptions_OptionId_QuestionId UNIQUE (OptionId, QuestionId),
    CONSTRAINT UQ_AnswerOptions_QuestionId_SortOrder UNIQUE (QuestionId, SortOrder),
    CONSTRAINT FK_AnswerOptions_Questions FOREIGN KEY (QuestionId) REFERENCES dbo.Questions(QuestionId),
    CONSTRAINT CK_AnswerOptions_SortOrder CHECK (SortOrder >= 1)
);
GO

-- 23. QuizAttempts
IF OBJECT_ID(N'dbo.QuizAttempts', N'U') IS NULL
CREATE TABLE dbo.QuizAttempts (
    AttemptId            BIGINT IDENTITY(1,1) NOT NULL,
    EnrollmentId         BIGINT NOT NULL,
    QuizId               BIGINT NOT NULL,
    CourseId             BIGINT NOT NULL,
    AttemptNumber        INT NOT NULL,
    StartedAt            DATETIME2(3) NOT NULL CONSTRAINT DF_QuizAttempts_StartedAt DEFAULT (SYSUTCDATETIME()),
    ExpiresAt            DATETIME2(3) NOT NULL,
    FinalizedAt          DATETIME2(3) NULL,
    Status               VARCHAR(15) NOT NULL CONSTRAINT DF_QuizAttempts_Status DEFAULT ('IN_PROGRESS'),
    FinishReason         VARCHAR(10) NULL,
    PassingScoreSnapshot DECIMAL(5,2) NOT NULL,
    TotalPoints          DECIMAL(12,2) NOT NULL,
    EarnedPoints         DECIMAL(12,2) NULL,
    Score                AS CONVERT(DECIMAL(5,2), 100.0 * EarnedPoints / NULLIF(TotalPoints, 0)) PERSISTED,
    CONSTRAINT PK_QuizAttempts PRIMARY KEY CLUSTERED (AttemptId),
    CONSTRAINT UQ_QuizAttempts_Enrollment_Quiz_Number UNIQUE (EnrollmentId, QuizId, AttemptNumber),
    CONSTRAINT UQ_QuizAttempts_AttemptId_QuizId UNIQUE (AttemptId, QuizId),
    CONSTRAINT FK_QuizAttempts_Enrollments FOREIGN KEY (EnrollmentId, CourseId) REFERENCES dbo.Enrollments(EnrollmentId, CourseId),
    CONSTRAINT FK_QuizAttempts_Quizzes FOREIGN KEY (QuizId, CourseId) REFERENCES dbo.Quizzes(QuizId, CourseId),
    CONSTRAINT CK_QuizAttempts_Status CHECK (Status IN ('IN_PROGRESS', 'FINISHED')),
    CONSTRAINT CK_QuizAttempts_FinishReason CHECK (FinishReason IS NULL OR FinishReason IN ('SUBMITTED', 'TIMEOUT'))
);
GO

-- 24. AttemptAnswers
IF OBJECT_ID(N'dbo.AttemptAnswers', N'U') IS NULL
CREATE TABLE dbo.AttemptAnswers (
    AttemptId        BIGINT NOT NULL,
    QuizId           BIGINT NOT NULL,
    QuestionId       BIGINT NOT NULL,
    SelectedOptionId BIGINT NULL,
    QuestionPoints   DECIMAL(6,2) NOT NULL,
    AwardedPoints    DECIMAL(6,2) NULL,
    SavedAt          DATETIME2(3) NULL,
    CONSTRAINT PK_AttemptAnswers PRIMARY KEY CLUSTERED (AttemptId, QuestionId),
    CONSTRAINT FK_AttemptAnswers_QuizAttempts FOREIGN KEY (AttemptId, QuizId) REFERENCES dbo.QuizAttempts(AttemptId, QuizId),
    CONSTRAINT FK_AttemptAnswers_Questions FOREIGN KEY (QuestionId, QuizId) REFERENCES dbo.Questions(QuestionId, QuizId),
    CONSTRAINT FK_AttemptAnswers_AnswerOptions FOREIGN KEY (SelectedOptionId, QuestionId) REFERENCES dbo.AnswerOptions(OptionId, QuestionId)
);
GO

-- 25. DiscussionPosts
IF OBJECT_ID(N'dbo.DiscussionPosts', N'U') IS NULL
CREATE TABLE dbo.DiscussionPosts (
    PostId       BIGINT IDENTITY(1,1) NOT NULL,
    LessonId     BIGINT NOT NULL,
    AuthorId     BIGINT NOT NULL,
    ParentPostId BIGINT NULL,
    Body         NVARCHAR(4000) NOT NULL,
    IsHidden     BIT NOT NULL CONSTRAINT DF_DiscussionPosts_IsHidden DEFAULT (0),
    IsDeleted    BIT NOT NULL CONSTRAINT DF_DiscussionPosts_IsDeleted DEFAULT (0),
    CreatedAt    DATETIME2(3) NOT NULL CONSTRAINT DF_DiscussionPosts_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt    DATETIME2(3) NOT NULL CONSTRAINT DF_DiscussionPosts_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_DiscussionPosts PRIMARY KEY CLUSTERED (PostId),
    CONSTRAINT UQ_DiscussionPosts_PostId_LessonId UNIQUE (PostId, LessonId),
    CONSTRAINT FK_DiscussionPosts_Lessons FOREIGN KEY (LessonId) REFERENCES dbo.Lessons(LessonId),
    CONSTRAINT FK_DiscussionPosts_Users FOREIGN KEY (AuthorId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_DiscussionPosts_Parent FOREIGN KEY (ParentPostId, LessonId) REFERENCES dbo.DiscussionPosts(PostId, LessonId)
);
GO

-- 26. CourseReviews
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NULL
CREATE TABLE dbo.CourseReviews (
    EnrollmentId BIGINT NOT NULL,
    Rating       TINYINT NOT NULL,
    Comment      NVARCHAR(2000) NULL,
    IsHidden     BIT NOT NULL CONSTRAINT DF_CourseReviews_IsHidden DEFAULT (0),
    CreatedAt    DATETIME2(3) NOT NULL CONSTRAINT DF_CourseReviews_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt    DATETIME2(3) NOT NULL CONSTRAINT DF_CourseReviews_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_CourseReviews PRIMARY KEY CLUSTERED (EnrollmentId),
    CONSTRAINT FK_CourseReviews_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollments(EnrollmentId),
    CONSTRAINT CK_CourseReviews_Rating CHECK (Rating BETWEEN 1 AND 5)
);
GO

-- 27. Certificates
IF OBJECT_ID(N'dbo.Certificates', N'U') IS NULL
CREATE TABLE dbo.Certificates (
    CertificateId   BIGINT IDENTITY(1,1) NOT NULL,
    EnrollmentId    BIGINT NOT NULL,
    CertificateCode VARCHAR(40) NOT NULL,
    Status          VARCHAR(20) NOT NULL CONSTRAINT DF_Certificates_Status DEFAULT ('VALID'),
    IssuedAt        DATETIME2(3) NOT NULL CONSTRAINT DF_Certificates_IssuedAt DEFAULT (SYSUTCDATETIME()),
    VerificationUrl NVARCHAR(500) NULL,
    CONSTRAINT PK_Certificates PRIMARY KEY CLUSTERED (CertificateId),
    CONSTRAINT UQ_Certificates_EnrollmentId UNIQUE (EnrollmentId),
    CONSTRAINT UQ_Certificates_Code UNIQUE (CertificateCode),
    CONSTRAINT FK_Certificates_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollments(EnrollmentId),
    CONSTRAINT CK_Certificates_Status CHECK (Status IN ('VALID', 'REVOKED'))
);
GO

-- =============================================================================
-- VIEWS
-- =============================================================================

-- View 1: vEnrollmentProgress
CREATE OR ALTER VIEW dbo.vEnrollmentProgress AS
WITH RequiredLessons AS (
    SELECT
        c.CourseId,
        COUNT(l.LessonId) AS TotalRequiredLessons
    FROM dbo.Courses c
    LEFT JOIN dbo.Lessons l ON l.CourseId = c.CourseId AND l.IsRequired = 1
    GROUP BY c.CourseId
),
CompletedLessons AS (
    SELECT
        e.EnrollmentId,
        COUNT(lp.LessonId) AS CompletedRequiredLessons
    FROM dbo.Enrollments e
    LEFT JOIN dbo.LessonProgress lp ON lp.EnrollmentId = e.EnrollmentId AND lp.CompletedAt IS NOT NULL
    LEFT JOIN dbo.Lessons l ON l.LessonId = lp.LessonId AND l.CourseId = e.CourseId AND l.IsRequired = 1
    WHERE l.LessonId IS NOT NULL
    GROUP BY e.EnrollmentId
),
RequiredQuizzes AS (
    SELECT
        c.CourseId,
        COUNT(q.QuizId) AS TotalRequiredQuizzes
    FROM dbo.Courses c
    LEFT JOIN dbo.Quizzes q ON q.CourseId = c.CourseId AND q.IsRequired = 1
    GROUP BY c.CourseId
),
PassedQuizzes AS (
    SELECT
        e.EnrollmentId,
        COUNT(DISTINCT qa.QuizId) AS PassedRequiredQuizzes
    FROM dbo.Enrollments e
    JOIN dbo.Quizzes q ON q.CourseId = e.CourseId AND q.IsRequired = 1
    JOIN dbo.QuizAttempts qa ON qa.EnrollmentId = e.EnrollmentId
        AND qa.QuizId = q.QuizId
        AND qa.Status = 'FINISHED'
        AND qa.Score >= qa.PassingScoreSnapshot
    GROUP BY e.EnrollmentId
)
SELECT
    e.EnrollmentId,
    e.StudentId,
    e.CourseId,
    e.AccessStatus,
    e.SourceType,
    e.CurrentOrderItemId,
    e.EnrolledAt,
    e.CompletedAt,
    ISNULL(rl.TotalRequiredLessons, 0) AS TotalRequiredLessons,
    ISNULL(cl.CompletedRequiredLessons, 0) AS CompletedRequiredLessons,
    CAST(
        CASE
            WHEN ISNULL(rl.TotalRequiredLessons, 0) = 0 THEN 0.00
            ELSE ROUND(100.0 * ISNULL(cl.CompletedRequiredLessons, 0) / rl.TotalRequiredLessons, 2)
        END
    AS DECIMAL(5,2)) AS ProgressPercent,
    ISNULL(rq.TotalRequiredQuizzes, 0) AS TotalRequiredQuizzes,
    ISNULL(pq.PassedRequiredQuizzes, 0) AS PassedRequiredQuizzes,
    CAST(
        CASE
            WHEN e.AccessStatus = 'ACTIVE'
                 AND ISNULL(rl.TotalRequiredLessons, 0) > 0
                 AND ISNULL(cl.CompletedRequiredLessons, 0) >= ISNULL(rl.TotalRequiredLessons, 0)
                 AND ISNULL(pq.PassedRequiredQuizzes, 0) >= ISNULL(rq.TotalRequiredQuizzes, 0)
            THEN 1
            ELSE 0
        END
    AS BIT) AS IsEligibleForCompletion
FROM dbo.Enrollments e
LEFT JOIN RequiredLessons rl ON rl.CourseId = e.CourseId
LEFT JOIN CompletedLessons cl ON cl.EnrollmentId = e.EnrollmentId
LEFT JOIN RequiredQuizzes rq ON rq.CourseId = e.CourseId
LEFT JOIN PassedQuizzes pq ON pq.EnrollmentId = e.EnrollmentId;
GO

-- View 2: vCourseStatistics (Section 10.3 & 16: Excludes REVOKED enrollments from active reviews & aggregates OrderItems revenue)
CREATE OR ALTER VIEW dbo.vCourseStatistics AS
WITH EnrollmentAgg AS (
    SELECT
        CourseId,
        COUNT(CASE WHEN AccessStatus = 'ACTIVE' THEN EnrollmentId END) AS EnrollmentCount,
        SUM(CASE WHEN AccessStatus = 'ACTIVE' AND CompletedAt IS NOT NULL THEN 1 ELSE 0 END) AS CompletedEnrollmentCount
    FROM dbo.Enrollments
    GROUP BY CourseId
),
RevenueAgg AS (
    SELECT
        oi.CourseId,
        COUNT(DISTINCT o.OrderId) AS PaidOrderCount,
        SUM(CASE WHEN o.Status IN ('PAID', 'REFUNDED') THEN oi.PayableVnd ELSE 0 END) AS GrossCourseSalesVnd,
        SUM(CASE WHEN o.Status = 'PAID' THEN oi.PayableVnd ELSE 0 END) AS TotalRevenue
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON o.OrderId = oi.OrderId
    WHERE o.Status IN ('PAID', 'REFUNDED')
    GROUP BY oi.CourseId
),
ReviewAgg AS (
    SELECT
        e.CourseId,
        COUNT(cr.EnrollmentId) AS ReviewCount,
        CAST(AVG(CAST(cr.Rating AS DECIMAL(5,2))) AS DECIMAL(3,2)) AS AverageRating
    FROM dbo.CourseReviews cr
    JOIN dbo.Enrollments e ON e.EnrollmentId = cr.EnrollmentId
    WHERE cr.IsHidden = 0 AND e.AccessStatus = 'ACTIVE'
    GROUP BY e.CourseId
),
CurriculumAgg AS (
    SELECT
        c.CourseId,
        (SELECT COUNT(*) FROM dbo.Chapters ch WHERE ch.CourseId = c.CourseId) AS ChapterCount,
        (SELECT COUNT(*) FROM dbo.Lessons l WHERE l.CourseId = c.CourseId) AS LessonCount,
        (SELECT COUNT(*) FROM dbo.Quizzes q WHERE q.CourseId = c.CourseId) AS QuizCount
    FROM dbo.Courses c
)
SELECT
    c.CourseId,
    c.Slug,
    c.Title,
    c.InstructorId,
    c.CategoryId,
    c.Status,
    c.PricingType,
    c.ListPriceVnd,
    c.SalePriceVnd,
    ISNULL(ea.EnrollmentCount, 0) AS EnrollmentCount,
    ISNULL(ea.CompletedEnrollmentCount, 0) AS CompletedEnrollmentCount,
    CAST(
        CASE
            WHEN ISNULL(ea.EnrollmentCount, 0) = 0 THEN 0.00
            ELSE ROUND(100.0 * ISNULL(ea.CompletedEnrollmentCount, 0) / ea.EnrollmentCount, 2)
        END
    AS DECIMAL(5,2)) AS CompletionRate,
    ISNULL(ra.ReviewCount, 0) AS ReviewCount,
    ra.AverageRating,
    ISNULL(ca.ChapterCount, 0) AS ChapterCount,
    ISNULL(ca.LessonCount, 0) AS LessonCount,
    ISNULL(ca.QuizCount, 0) AS QuizCount,
    ISNULL(rva.PaidOrderCount, 0) AS PaidOrderCount,
    ISNULL(rva.GrossCourseSalesVnd, 0) AS GrossCourseSalesVnd,
    ISNULL(rva.TotalRevenue, 0) AS TotalRevenue
FROM dbo.Courses c
LEFT JOIN EnrollmentAgg ea ON ea.CourseId = c.CourseId
LEFT JOIN RevenueAgg rva ON rva.CourseId = c.CourseId
LEFT JOIN ReviewAgg ra ON ra.CourseId = c.CourseId
LEFT JOIN CurriculumAgg ca ON ca.CourseId = c.CourseId;
GO

-- =============================================================================
-- LEARNORA PAID LMS — SQL SERVER INDEXES (Section 12.5)
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_AnswerOptions_OneCorrectPerQuestion' AND object_id = OBJECT_ID(N'dbo.AnswerOptions'))
CREATE UNIQUE NONCLUSTERED INDEX UX_AnswerOptions_OneCorrectPerQuestion
ON dbo.AnswerOptions(QuestionId)
WHERE IsCorrect = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_QuizAttempts_ActivePerEnrollmentQuiz' AND object_id = OBJECT_ID(N'dbo.QuizAttempts'))
CREATE UNIQUE NONCLUSTERED INDEX UX_QuizAttempts_ActivePerEnrollmentQuiz
ON dbo.QuizAttempts(EnrollmentId, QuizId)
WHERE Status = 'IN_PROGRESS';
GO

-- Filtered UNIQUE(Provider, ProviderTransactionId) when not NULL (Section 12.5)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PaymentAttempts_Provider_TxId' AND object_id = OBJECT_ID(N'dbo.PaymentAttempts'))
CREATE UNIQUE NONCLUSTERED INDEX UX_PaymentAttempts_Provider_TxId
ON dbo.PaymentAttempts(Provider, ProviderTransactionId)
WHERE ProviderTransactionId IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Courses_Status_Category_PublishedAt' AND object_id = OBJECT_ID(N'dbo.Courses'))
CREATE NONCLUSTERED INDEX IX_Courses_Status_Category_PublishedAt
ON dbo.Courses(Status, CategoryId, PricingType, PublishedAt DESC)
INCLUDE (Slug, Title, InstructorId, Level, ThumbnailUrl, EstimatedHours, ListPriceVnd, SalePriceVnd);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Orders_StudentId_Status' AND object_id = OBJECT_ID(N'dbo.Orders'))
CREATE NONCLUSTERED INDEX IX_Orders_StudentId_Status
ON dbo.Orders(StudentId, Status, CreatedAt DESC)
INCLUDE (OrderCode, TotalVnd, ExpiresAt, PaidAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PaymentAttempts_OrderId_Status' AND object_id = OBJECT_ID(N'dbo.PaymentAttempts'))
CREATE NONCLUSTERED INDEX IX_PaymentAttempts_OrderId_Status
ON dbo.PaymentAttempts(OrderId, Status, CreatedAt DESC)
INCLUDE (MerchantReference, Provider, ProviderTransactionId, AmountVnd);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Enrollments_StudentId_CourseId' AND object_id = OBJECT_ID(N'dbo.Enrollments'))
CREATE NONCLUSTERED INDEX IX_Enrollments_StudentId_CourseId
ON dbo.Enrollments(StudentId, AccessStatus, EnrolledAt DESC)
INCLUDE (CourseId, CompletedAt, CurrentOrderItemId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LessonProgress_EnrollmentId' AND object_id = OBJECT_ID(N'dbo.LessonProgress'))
CREATE NONCLUSTERED INDEX IX_LessonProgress_EnrollmentId
ON dbo.LessonProgress(EnrollmentId, CompletedAt)
INCLUDE (LessonId, LastPositionSeconds, LastAccessedAt);
GO

-- =============================================================================
-- LEARNORA PAID LMS — IDEMPOTENT SEED DATA (Section 1.2, 12.2, 20, 21)
-- Demo password for all accounts: Learnora@123
-- =============================================================================

SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleCode = 'ADMIN')
BEGIN
    INSERT INTO dbo.Roles (RoleCode, RoleName) VALUES
    ('ADMIN',      N'Quản trị viên hệ thống'),
    ('INSTRUCTOR', N'Giảng viên'),
    ('STUDENT',    N'Học viên');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.Users ON;
    INSERT INTO dbo.Users (UserId, Email, PasswordHash, FullName, Headline, Bio, AvatarUrl, Status, BalanceVnd, CreatedAt, UpdatedAt) VALUES
    (1, N'admin@learnora.test',      'pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9hZG1pbjE=$I9NVwAL4Rj7khVmGnXBwFhSM7B0IP7A+EQj025hiTTA=', N'Nguyễn Quản Trị',    N'Platform Operations & Revenue Director', N'Quản trị viên hệ thống Learnora LMS, phụ trách kiểm duyệt học liệu, đối soát thanh toán và xử lý hoàn tiền.', N'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=240&auto=format&fit=crop&q=80', 'ACTIVE', 5000000.00, DATEADD(DAY, -90, SYSUTCDATETIME()), SYSUTCDATETIME()),
    (2, N'instructor@learnora.test', 'pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9pbnN0MDE=$wndrWQBOK7goPhRMUT549NkgmVyuVyanxR29HabfC0Y=', N'TS. Trần Minh Khoa', N'Principal Java Architect & Senior Lecturer', N'Hơn 12 năm kinh nghiệm phát triển hệ thống Enterprise Java, kiến trúc thương mại điện tử và đào tạo kỹ sư phần mềm.', N'https://images.unsplash.com/photo-1507003211169-0a1dd728f2d?w=240&auto=format&fit=crop&q=80', 'ACTIVE', 12500000.00, DATEADD(DAY, -85, SYSUTCDATETIME()), SYSUTCDATETIME()),
    (3, N'student@learnora.test',    'pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9zdHVkMDE=$pIEfoEUU0D10NnHrv/2k8oyUBgk9wexhaS7DoYknDGM=', N'Lê Hoàng Nam',       N'Sinh viên Kỹ thuật Phần mềm năm 3', N'Đam mê lập trình Backend Java Web, cơ sở dữ liệu SQL Server và thiết kế hệ thống hướng đối tượng.', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=240&auto=format&fit=crop&q=80', 'ACTIVE', 2000000.00, DATEADD(DAY, -60, SYSUTCDATETIME()), SYSUTCDATETIME()),
    (4, N'student2@learnora.test',   'pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9zdHVkMDI=$WzXGAbYrBPwV2sQs3yBecGJkJxvCiFxfvMRVQ932ABI=', N'Phạm Thu Hà',        N'Full-stack Developer Intern', N'Học viên tích cực trên Learnora, yêu thích xây dựng giao diện SaaS hiện đại kết hợp nền tảng Java vững chắc.', N'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240&auto=format&fit=crop&q=80', 'ACTIVE', 1500000.00, DATEADD(DAY, -45, SYSUTCDATETIME()), SYSUTCDATETIME()),
    (5, N'locked@learnora.test',     'pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9sb2NrMDE=$ndCWHguJ8pCfGo39J14ReawxuHMts6AKq45ZFfKjU/k=', N'Vũ Tài Khoản Khóa',  N'Tài khoản thử nghiệm trạng thái khóa', N'Tài khoản dùng để kiểm thử bộ lọc bảo mật chặn người dùng bị khóa.', NULL, 'LOCKED', 0.00, DATEADD(DAY, -30, SYSUTCDATETIME()), SYSUTCDATETIME()),
    (6, N'instructor2@learnora.test','pbkdf2_sha256$600000$bGVhcm5vcmFfc2FsdF9pbnN0MDI=$ERbfVZHsLrpa1pTj09G+x7ZZTcvuuiTOk7bWcCwRmPY=', N'ThS. Đặng Lan Anh',  N'Senior UI/UX & Frontend Engineering Lead', N'Chuyên gia thiết kế hệ thống Design System, kiến trúc CSS hiện đại và tối ưu trải nghiệm học tập số.', N'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=240&auto=format&fit=crop&q=80', 'ACTIVE', 8000000.00, DATEADD(DAY, -70, SYSUTCDATETIME()), SYSUTCDATETIME());
    SET IDENTITY_INSERT dbo.Users OFF;

    INSERT INTO dbo.UserRoles (UserId, RoleCode) VALUES
    (1, 'ADMIN'),
    (2, 'INSTRUCTOR'),
    (2, 'STUDENT'),
    (3, 'STUDENT'),
    (4, 'STUDENT'),
    (5, 'STUDENT'),
    (6, 'INSTRUCTOR');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.Categories ON;
    INSERT INTO dbo.Categories (CategoryId, Name, Slug, IconClass, Description, IsActive) VALUES
    (1, N'Lập trình Java & Backend',   'java-backend',   'bi-cpu',            N'Nền tảng Java Core, OOP, Java Web Servlet/JSP, JDBC và kiến trúc ứng dụng doanh nghiệp.', 1),
    (2, N'Cơ sở dữ liệu & SQL Server', 'database-sql',   'bi-database-check', N'Thiết kế cơ sở dữ liệu quan hệ, chuẩn hóa, T-SQL, tối ưu truy vấn và quản trị giao dịch trên SQL Server.', 1),
    (3, N'Thiết kế UI/UX & Frontend',  'ui-ux-frontend', 'bi-window-stack',   N'HTML5, CSS3, JavaScript ES6+, Design Tokens và xây dựng giao diện SaaS hiện đại.', 1),
    (4, N'Kỹ năng mềm & Quản trị',     'soft-skills',    'bi-compass',        N'Quản lý thời gian, tư duy giải quyết vấn đề, làm việc nhóm Agile/Scrum cho kỹ sư phần mềm.', 1);
    SET IDENTITY_INSERT dbo.Categories OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Courses WHERE CourseId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.Courses ON;
    INSERT INTO dbo.Courses (
        CourseId, CategoryId, InstructorId, Slug, Title, Subtitle, Description,
        LearningObjectives, Requirements, TargetAudience, ThumbnailUrl, Level, Language,
        EstimatedHours, PricingType, ListPriceVnd, SalePriceVnd, ProposedPriceVnd,
        Status, RejectionReason, PublishedAt, CreatedAt, UpdatedAt
    ) VALUES
    (
        1, 1, 2, 'java-co-ban-va-oop-toan-dien',
        N'Java cơ bản và Lập trình Hướng đối tượng toàn diện',
        N'Xây dựng tư duy lập trình vững chắc với Java 17+, OOP, Collections và xử lý ngoại lệ thực chiến.',
        N'Khóa học nền tảng miễn phí cung cấp kiến thức cốt lõi nhất của ngôn ngữ Java 17+. Học viên được dẫn dắt từ cú pháp cơ bản, cấu trúc điều khiển, mảng cho đến 4 trụ cột của lập trình hướng đối tượng (Đóng gói, Kế thừa, Đa hình, Trừu tượng), Collections Framework và Clean Code.',
        N'Nắm vững cú pháp Java 17+, kiểu dữ liệu, toán tử và cấu trúc điều khiển|Vận dụng thành thạo 4 tính chất OOP vào thiết kế lớp và interface|Làm chủ List, Set, Map và Generics trong xử lý dữ liệu bộ nhớ|Xử lý ngoại lệ an toàn và viết mã nguồn rõ ràng, dễ bảo trì',
        N'Không yêu cầu kinh nghiệm lập trình trước đó|Máy tính cài đặt JDK 17+ và NetBeans hoặc IntelliJ IDEA',
        N'Sinh viên năm 1-2 CNTT và người mới bắt đầu học lập trình Java',
        N'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop&q=80',
        'BEGINNER', N'Tiếng Việt', 18.5, 'FREE', 0, NULL, 0, 'PUBLISHED', NULL,
        DATEADD(DAY, -40, SYSUTCDATETIME()), DATEADD(DAY, -55, SYSUTCDATETIME()), DATEADD(DAY, -40, SYSUTCDATETIME())
    ),
    (
        2, 1, 2, 'java-servlet-jsp-tu-nen-tang-den-mvc',
        N'Java Servlet & JSP từ nền tảng đến MVC',
        N'Xây dựng hệ thống web thương mại chuẩn MVC với Jakarta Servlet 6.0, JSP, JSTL, Cổng thanh toán VNPAY Sandbox và SQL Server.',
        N'Khóa học xuyên suốt theo đúng đặc tả Learnora Paid LMS (giá bán 499.000đ): hướng dẫn toàn diện từ kiến trúc HTTP, Servlet Filter, quản lý phiên HttpSession, giỏ hàng/đơn hàng idempotent, tích hợp VNPAY Return URL & IPN đến kiểm soát quyền học và xử lý hoàn tiền.',
        N'Triển khai chuẩn xác mô hình MVC với Servlet, JSP, JSTL và Expression Language (EL)|Thiết kế luồng tạo đơn hàng Idempotent, chốt giá Snapshot và xác thực chữ ký HMAC-SHA512 của VNPAY|Kiểm soát trạng thái Order, PaymentAttempt, Refund và Enrollment.AccessStatus chặt chẽ|Bảo vệ tài liệu/video trả phí qua Servlet kiểm tra quyền truy cập',
        N'Đã nắm vững Java Core và SQL cơ bản|Cài đặt JDK 17+, Apache Tomcat 10.1+ và SQL Server',
        N'Sinh viên thực hiện đồ án PRJ301 và lập trình viên Java Web',
        N'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&auto=format&fit=crop&q=80',
        'INTERMEDIATE', N'Tiếng Việt', 24.0, 'PAID', 699000, 499000, 499000, 'PUBLISHED', NULL,
        DATEADD(DAY, -35, SYSUTCDATETIME()), DATEADD(DAY, -50, SYSUTCDATETIME()), DATEADD(DAY, -35, SYSUTCDATETIME())
    ),
    (
        3, 2, 2, 'sql-server-thuc-chien-va-toi-uu-giao-dich',
        N'SQL Server Thực chiến: Thiết kế Database 25 Bảng & Tối ưu Giao dịch',
        N'Làm chủ T-SQL, khóa ngoại ghép, Filtered Unique Index, View thống kê doanh thu và ACID Transaction.',
        N'Khóa học chuyên sâu giúp học viên thiết kế cơ sở dữ liệu chuẩn hóa cho nền tảng EdTech/Thương mại điện tử, tránh bẫy nhân bản dữ liệu khi JOIN nhiều bảng và sử dụng khóa UPDLOCK/HOLDLOCK chống xung đột thanh toán.',
        N'Thiết kế sơ đồ quan hệ ERD 25 bảng cho hệ thống LMS có thu phí|Viết truy vấn CTE tổng hợp doanh thu gộp, tiền hoàn và doanh thu ròng chính xác|Sử dụng Filtered Unique Index chống ghi nhận trùng mã giao dịch cổng thanh toán|Điều phối JDBC Transaction nhiều bảng an toàn tuyệt đối',
        N'Biết sử dụng SQL cơ bản|Đã cài đặt SQL Server và SSMS',
        N'Sinh viên CNTT và kỹ sư Backend/Database',
        N'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800&auto=format&fit=crop&q=80',
        'INTERMEDIATE', N'Tiếng Việt', 20.0, 'PAID', 599000, 399000, 399000, 'PUBLISHED', NULL,
        DATEADD(DAY, -25, SYSUTCDATETIME()), DATEADD(DAY, -35, SYSUTCDATETIME()), DATEADD(DAY, -25, SYSUTCDATETIME())
    ),
    (
        4, 3, 6, 'thiet-ke-giao-dien-saas-edtech-hien-dai',
        N'Thiết kế Giao diện SaaS Thương mại với HTML5, CSS Variables & Bootstrap 5',
        N'Nâng tầm giao diện dự án Java Web lên chuẩn sản phẩm EdTech 2026 lấy cảm hứng từ Linear, Notion và Coursera.',
        N'Khóa học hướng dẫn cách xây dựng hệ thống Design Tokens bằng CSS Variables, thiết kế trang bán khóa học chuyển đổi cao, không gian học tập không xao nhãng và bảng điều khiển quản trị đối soát rõ ràng.',
        N'Xây dựng bảng màu #F8FAFC / #0F172A / #4F46E5 / #059669 nhất quán|Thiết kế tách biệt bố cục Trang bán hàng, Trang học tập và Trang quản trị|Đảm bảo khả năng truy cập bàn phím, label biểu mẫu chuẩn và chống gửi lặp',
        N'Biết HTML/CSS cơ bản',
        N'Sinh viên và Frontend/Full-stack Developer',
        N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&auto=format&fit=crop&q=80',
        'INTERMEDIATE', N'Tiếng Việt', 16.0, 'PAID', 550000, 450000, 450000, 'PENDING_APPROVAL', NULL,
        NULL, DATEADD(DAY, -10, SYSUTCDATETIME()), DATEADD(DAY, -2, SYSUTCDATETIME())
    ),
    (
        5, 4, 2, 'quan-ly-thoi-gian-deep-work-cho-ky-su',
        N'Quản lý Thời gian và Hiệu suất Học tập cho Kỹ sư Phần mềm',
        N'Phương pháp Deep Work, quản trị năng lượng cá nhân và lập kế hoạch đồ án học kỳ hiệu quả.',
        N'Khóa học đang trong quá trình biên soạn nội dung nháp (DRAFT) giúp sinh viên CNTT cân bằng giữa việc học lý thuyết, thực hành phòng lab và hoàn thành đồ án đúng tiến độ.',
        N'Áp dụng kỹ thuật Deep Work và Timeboxing khi lập trình|Chia nhỏ backlog đồ án theo từng tuần làm việc',
        N'Dành cho mọi sinh viên và lập trình viên trẻ',
        N'Sinh viên các ngành kỹ thuật',
        N'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=800&auto=format&fit=crop&q=80',
        'BEGINNER', N'Tiếng Việt', 6.5, 'FREE', 0, NULL, 0, 'DRAFT', NULL,
        NULL, DATEADD(DAY, -5, SYSUTCDATETIME()), DATEADD(DAY, -1, SYSUTCDATETIME())
    ),
    (
        6, 1, 2, 'kien-truc-ung-dung-java-web-nang-cao-va-bao-mat',
        N'Kiến trúc Ứng dụng Java Web Nâng cao, Bảo mật OWASP & Hiệu năng',
        N'Chuyên sâu về bảo mật PBKDF2, CSRF, XSS, SQL Injection, Connection Pooling và tối ưu tải cao cho Java Web MVC.',
        N'Khóa học trả phí nâng cao giúp học viên làm chủ toàn bộ kỹ thuật bảo mật ứng dụng web theo chuẩn OWASP Top 10, thiết kế bộ lọc xác thực nhiều tầng, chống tấn công giả mạo chữ ký cổng thanh toán và tối ưu hiệu năng truy vấn JDBC trên SQL Server.',
        N'Triển khai chuẩn bảo mật OWASP cho Java Servlet/JSP|Thiết kế cơ chế chống Replay Attack và Idempotency Key|Tối ưu hóa hiệu năng truy vấn và chống N+1 Query trong DAO|Xây dựng hệ thống Audit Log và xuất báo cáo an toàn',
        N'Đã nắm vững Java Servlet/JSP cơ bản',
        N'Sinh viên năm 3-4 CNTT và kỹ sư Backend Java',
        N'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
        'ADVANCED', N'Tiếng Việt', 22.0, 'PAID', 799000, 599000, 599000, 'PUBLISHED', NULL,
        DATEADD(DAY, -15, SYSUTCDATETIME()), DATEADD(DAY, -25, SYSUTCDATETIME()), DATEADD(DAY, -15, SYSUTCDATETIME())
    );
    SET IDENTITY_INSERT dbo.Courses OFF;

    SET IDENTITY_INSERT dbo.CourseApprovalEvents ON;
    INSERT INTO dbo.CourseApprovalEvents (EventId, CourseId, ActorId, Action, FromStatus, ToStatus, Note, CreatedAt) VALUES
    (1, 1, 2, 'SUBMIT',  'DRAFT',            'PENDING_APPROVAL', N'Gửi duyệt khóa học miễn phí Java cơ bản.', DATEADD(DAY, -42, SYSUTCDATETIME())),
    (2, 1, 1, 'APPROVE', 'PENDING_APPROVAL', 'PUBLISHED',        N'Phê duyệt xuất bản khóa học miễn phí.', DATEADD(DAY, -40, SYSUTCDATETIME())),
    (3, 2, 2, 'SUBMIT',  'DRAFT',            'PENDING_APPROVAL', N'Gửi duyệt khóa trả phí Java Servlet & JSP từ nền tảng đến MVC (Giá bán 499.000đ).', DATEADD(DAY, -37, SYSUTCDATETIME())),
    (4, 2, 1, 'APPROVE', 'PENDING_APPROVAL', 'PUBLISHED',        N'Đã kiểm tra nội dung và duyệt mức giá 499.000đ.', DATEADD(DAY, -35, SYSUTCDATETIME())),
    (5, 3, 2, 'SUBMIT',  'DRAFT',            'PENDING_APPROVAL', N'Gửi duyệt khóa trả phí SQL Server Thực chiến (Giá bán 399.000đ).', DATEADD(DAY, -27, SYSUTCDATETIME())),
    (6, 3, 1, 'APPROVE', 'PENDING_APPROVAL', 'PUBLISHED',        N'Phê duyệt nội dung và giá bán 399.000đ.', DATEADD(DAY, -25, SYSUTCDATETIME())),
    (7, 4, 6, 'SUBMIT',  'DRAFT',            'PENDING_APPROVAL', N'Đề nghị duyệt khóa học Thiết kế Giao diện SaaS (Giá đề xuất 450.000đ).', DATEADD(DAY, -2, SYSUTCDATETIME()));
    SET IDENTITY_INSERT dbo.CourseApprovalEvents OFF;

    SET IDENTITY_INSERT dbo.Chapters ON;
    INSERT INTO dbo.Chapters (ChapterId, CourseId, Title, Description, SortOrder) VALUES
    (1, 1, N'Chương 1: Làm quen với nền tảng Java 17 và Cú pháp cốt lõi', N'Cài đặt môi trường JDK, hiểu cơ chế biên dịch Bytecode/JVM và các kiểu dữ liệu cơ bản.', 1),
    (2, 1, N'Chương 2: Lập trình Hướng đối tượng (OOP) và Collections', N'Thiết kế lớp, kế thừa, đa hình và quản lý tập hợp đối tượng với Java Collections Framework.', 2),
    (3, 2, N'Chương 1: Kiến trúc HTTP, Jakarta Servlet, Session và Filter Bảo mật', N'Xử lý GET/POST theo mẫu PRG, đổi Session ID chống Session Fixation và kiểm soát phân quyền 3 lớp.', 1),
    (4, 2, N'Chương 2: Luồng Đơn hàng Idempotent, Tích hợp VNPAY Sandbox & Hoàn tiền', N'Thiết kế Orders, OrderItems, PaymentAttempts, xác thực chữ ký HMAC-SHA512 IPN và quản lý quyền học.', 2),
    (5, 3, N'Chương 1: Thiết kế 25 Bảng Chuẩn hóa & Khóa ngoại Ghép trên SQL Server', N'Khởi tạo bảng, kiểu dữ liệu DECIMAL(18,0) cho tiền tệ VND và khóa ngoại ghép bảo vệ tiến độ.', 1),
    (6, 3, N'Chương 2: View Thống kê Doanh thu, Filtered Index & ACID Transaction', N'Tối ưu hóa truy vấn với CTE, chỉ mục có điều kiện lọc và khóa dòng UPDLOCK/HOLDLOCK.', 2),
    (7, 4, N'Chương 1: Hệ thống Design Tokens và Bố cục Chuyên biệt theo Mục đích', N'Tách biệt bố cục trang bán hàng, trang học tập và trang quản trị.', 1),
    (8, 5, N'Chương 1: Thiết lập Hệ thống Làm việc Sâu (Deep Work)', N'Nhận diện các yếu tố gây xao nhãng khi lập trình.', 1),
    (9, 6, N'Chương 1: Bảo mật Ứng dụng Java Web theo Chuẩn OWASP', N'Phòng chống SQLi, XSS, CSRF và Session Fixation trong thực tế.', 1);
    SET IDENTITY_INSERT dbo.Chapters OFF;

    SET IDENTITY_INSERT dbo.Lessons ON;
    INSERT INTO dbo.Lessons (LessonId, ChapterId, CourseId, Title, Content, VideoUrl, DurationSeconds, SortOrder, IsPreview, IsRequired) VALUES
    -- Course 1 (FREE - 4 required lessons)
    (1, 1, 1, N'Bài 1: Kiến trúc JVM, JDK 17 và Chương trình Java đầu tiên',
     N'<h3>1. Tổng quan về nền tảng Java</h3><p>Java hoạt động theo nguyên lý <strong>Write Once, Run Anywhere</strong> nhờ cơ chế biên dịch mã nguồn <code>.java</code> thành mã trung gian <strong>Bytecode (<code>.class</code>)</strong> và thực thi trên máy ảo <strong>JVM (Java Virtual Machine)</strong>.</p><pre><code>public class HelloLearnora {
    public static void main(String[] args) {
        System.out.println("Chào mừng bạn đến với Learnora LMS!");
    }
}</code></pre>',
     N'https://www.youtube.com/embed/eIrMbAQSU34', 720, 1, 1, 1),
    (2, 1, 1, N'Bài 2: Biến, Kiểu dữ liệu và Sử dụng BigDecimal cho Tiền tệ VND',
     N'<h3>1. Tại sao dùng BigDecimal cho tiền tệ?</h3><p>Trong hệ thống bán khóa học bằng VND (<code>DECIMAL(18,0)</code>), tuyệt đối không dùng <code>float</code> hoặc <code>double</code> để cộng trừ tiền nhằm tránh sai số nhị phân. Luôn sử dụng <code>java.math.BigDecimal</code>.</p>',
     N'https://www.youtube.com/embed/RRubcjpTkks', 840, 2, 0, 1),
    (3, 2, 1, N'Bài 3: Đóng gói, Kế thừa, Đa hình và Thiết kế JavaBeans/POJO',
     N'<h3>1. Quy chuẩn JavaBeans trong kiến trúc MVC</h3><p>Các lớp thực thể (Model) tuân theo quy ước JavaBeans để Expression Language (EL) trong JSP có thể đọc dữ liệu an toàn mà không cần scriptlet Java.</p>',
     N'https://www.youtube.com/embed/pTB0EiLXUC8', 960, 1, 0, 1),
    (4, 2, 1, N'Bài 4: Quản lý Danh sách với Collections Framework và Try-with-resources',
     N'<h3>1. Đóng kết nối JDBC an toàn</h3><p>Sử dụng <code>try-with-resources</code> giúp tự động giải phóng <code>Connection</code>, <code>PreparedStatement</code> và <code>ResultSet</code>.</p>',
     N'https://www.youtube.com/embed/GdAon80-0KA', 900, 2, 0, 1),

    -- Course 2 (PAID 499.000đ: "Java Servlet & JSP từ nền tảng đến MVC" - 4 required lessons, Lesson 5 is Preview!)
    (5, 3, 2, N'Bài 1 [Học thử]: Kiến trúc HTTP, Jakarta Servlet và Quy tắc Post-Redirect-Get',
     N'<h3>1. Luồng xử lý Request trong Java Web MVC</h3><p>Mọi yêu cầu từ trình duyệt đi qua chuỗi <code>EncodingFilter</code> &rarr; <code>AuthenticationFilter</code> &rarr; <code>AuthorizationFilter</code> &rarr; <code>CsrfFilter</code> trước khi tới <code>Servlet Controller</code>. Các bài học không đánh dấu <code>IsPreview=1</code> sẽ được bảo vệ nghiêm ngặt bởi kiểm tra <code>Enrollment.AccessStatus = ACTIVE</code>.</p>',
     N'https://www.youtube.com/embed/eIrMbAQSU34', 780, 1, 1, 1),
    (6, 3, 2, N'Bài 2: Kiểm soát Phân quyền 3 Lớp và Bảo vệ Tài liệu Trả phí qua MediaServlet',
     N'<h3>1. Ba lớp kiểm tra quyền truy cập</h3><ol><li>Người dùng đã đăng nhập và có trạng thái <code>Users.Status = ACTIVE</code>.</li><li>Tài khoản có vai trò phù hợp trong <code>UserRoles</code>.</li><li>Kiểm tra quyền sở hữu dữ liệu: có bản ghi <code>Enrollments</code> với <code>AccessStatus = ACTIVE</code> cho đúng khóa học đó.</li></ol>',
     N'https://www.youtube.com/embed/RRubcjpTkks', 860, 2, 0, 1),
    (7, 4, 2, N'Bài 3: Thiết kế Đơn hàng Idempotent, Chốt giá Snapshot và Tích hợp VNPAY Sandbox',
     N'<h3>1. Nguyên tắc Không tin Giá từ Trình duyệt</h3><p>Khi học viên bấm mua, <code>CheckoutService</code> đọc <code>ListPriceVnd</code> và <code>SalePriceVnd</code> trực tiếp từ bảng <code>Courses</code>, tạo <code>Orders</code> và <code>OrderItems</code> lưu <code>CourseTitleSnapshot</code>, <code>UnitPriceVnd</code>, <code>DiscountVnd</code> và <code>PayableVnd</code> tại thời điểm mua.</p><h3>2. Tách biệt Return URL và IPN</h3><p>Theo tài liệu VNPAY PAY, <code>vnp_Amount</code> bằng số tiền VND nhân 100. Backend xác minh chữ ký <code>HMAC-SHA512</code> trên dữ liệu đã sắp xếp bảng chữ cái trước khi ghi nhận thanh toán và cấp quyền học.</p>',
     N'https://www.youtube.com/embed/3cBcH1N0eE4', 940, 1, 0, 1),
    (8, 4, 2, N'Bài 4: Xử lý Giao dịch Bất thường, Đối soát và Thu hồi Quyền học khi Hoàn tiền',
     N'<h3>1. Quy trình Hoàn tiền Có Kiểm duyệt</h3><p>Học viên gửi yêu cầu hoàn tiền (trong vòng 7 ngày kể từ <code>PaidAt</code>, tiến độ dưới 20% và chưa cấp chứng nhận). Chỉ khi giao dịch hoàn tiền đạt trạng thái <code>SUCCEEDED</code>, hệ thống mới chuyển <code>Orders.Status = REFUNDED</code> và <code>Enrollments.AccessStatus = REVOKED</code> trong cùng một JDBC Transaction.</p>',
     N'https://www.youtube.com/embed/9Pzj7Aj25lw', 900, 2, 0, 1),

    -- Course 3 (PAID 399.000đ: SQL Server Thực chiến - 2 required lessons)
    (9,  5, 3, N'Bài 1 [Học thử]: Thiết kế 25 Bảng Chuẩn hóa và Ràng buộc Khóa ngoại Ghép',
     N'<h3>1. Tách biệt Orders, PaymentAttempts và Refunds</h3><p>Một đơn hàng (<code>Orders</code>) có thể có nhiều lần thử thanh toán tuần tự (<code>PaymentAttempts</code>), mỗi lần nhận callback được lưu vết vào <code>PaymentEvents</code>.</p>',
     N'https://www.youtube.com/embed/HXV3zeQKqGY', 820, 1, 1, 1),
    (10, 6, 3, N'Bài 2: Tổng hợp Doanh thu Gộp, Tiền Hoàn và Doanh thu Ròng bằng CTE',
     N'<h3>1. Báo cáo tài chính chính xác</h3><p>Doanh thu ròng trong kỳ bằng Tổng khoản thu đã xác minh (<code>PaymentAttempts.Status = SUCCEEDED</code>) trừ đi Tổng khoản hoàn thành công (<code>Refunds.Status = SUCCEEDED</code>).</p>',
     N'https://www.youtube.com/embed/7S_tz1z_5bA', 880, 1, 0, 1),

    -- Course 4 (PENDING_APPROVAL) & Course 5 (DRAFT)
    (11, 7, 4, N'Bài 1: Hệ thống Design Tokens #F8FAFC / #0F172A / #4F46E5 / #059669',
     N'<h3>1. Thiết kế Giao diện theo Ngữ cảnh</h3><p>Trang bán khóa học ưu tiên thông tin đầu ra và giá bán; trang học tập ưu tiên trình phát bài giảng; trang quản trị ưu tiên bảng lọc và đối soát.</p>',
     N'https://www.youtube.com/embed/yfoY53QXEnI', 750, 1, 1, 1),
    (12, 8, 5, N'Bài 1: Nguyên lý Deep Work dành cho Sinh viên Kỹ thuật Phần mềm',
     N'<h3>1. Tập trung sâu</h3><p>Chia ngày học tập thành các phiên làm việc 90 phút không thông báo.</p>',
     NULL, 600, 1, 0, 1),
    (13, 9, 6, N'Bài 1 [Học thử]: Phòng chống CSRF, XSS và SQL Injection trong Java Servlet/JSP',
     N'<h3>1. Bảo mật 3 lớp trong Java Web</h3><p>Sử dụng PreparedStatement 100%, escape đầu ra bằng JSTL <code>&lt;c:out&gt;</code> và kiểm tra CSRF Token trên mọi POST request.</p>',
     N'https://www.youtube.com/embed/eIrMbAQSU34', 900, 1, 1, 1);
    SET IDENTITY_INSERT dbo.Lessons OFF;

    SET IDENTITY_INSERT dbo.LessonResources ON;
    INSERT INTO dbo.LessonResources (ResourceId, LessonId, Title, ResourceUrl, ResourceType) VALUES
    (1, 1, N'Tài liệu tóm tắt Kiến trúc JDK 17 & JVM',               N'https://docs.oracle.com/en/java/javase/17/docs/api/', 'LINK'),
    (2, 5, N'Đặc tả Jakarta Servlet 6.0 & Quy trình Filter',         N'https://jakarta.ee/specifications/servlet/6.0/',      'DOC'),
    (3, 7, N'Tài liệu tích hợp cổng thanh toán VNPAY PAY chính thức', N'https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html', 'LINK'),
    (4, 9, N'Hướng dẫn Filtered Indexes trên Microsoft SQL Server',  N'https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes', 'LINK');
    SET IDENTITY_INSERT dbo.LessonResources OFF;

    SET IDENTITY_INSERT dbo.Coupons ON;
    INSERT INTO dbo.Coupons (CouponId, Code, Description, DiscountPercent, MaxDiscountVnd, MinOrderVnd, UsageLimit, UsedCount, IsActive, ExpiresAt) VALUES
    (1, 'LEARNORA20', N'Giảm 20% học phí cho các khóa học trả phí trên Learnora', 20, 200000, 200000, 500, 1, 1, DATEADD(DAY, 180, SYSUTCDATETIME())),
    (2, 'PRJ301VIP',  N'Học bổng giảm 30% dành cho sinh viên Công nghệ thông tin', 30, 300000, 300000, 200, 0, 1, DATEADD(DAY, 120, SYSUTCDATETIME()));
    SET IDENTITY_INSERT dbo.Coupons OFF;

    SET IDENTITY_INSERT dbo.Carts ON;
    INSERT INTO dbo.Carts (CartId, StudentId, CouponCode, CreatedAt, UpdatedAt) VALUES
    (1, 3, 'LEARNORA20', SYSUTCDATETIME(), SYSUTCDATETIME());
    SET IDENTITY_INSERT dbo.Carts OFF;

    SET IDENTITY_INSERT dbo.CartItems ON;
    INSERT INTO dbo.CartItems (CartItemId, CartId, CourseId, AddedAt) VALUES
    (1, 1, 6, SYSUTCDATETIME());
    SET IDENTITY_INSERT dbo.CartItems OFF;

    -- Seed Orders, OrderItems, PaymentAttempts, PaymentEvents, Refunds, Enrollments, EnrollmentAccessEvents
    -- Scenario 1: Student 1 (UserId=3) enrolled in Course 1 (FREE, Completed 100%)
    -- Scenario 2: Student 1 (UserId=3) purchased Course 2 ("Java Servlet & JSP từ nền tảng đến MVC" - 499,000đ) via Order #1 (PAID), currently 25% progress (1/4 lessons -> eligible for refund demo or continuing learning!)
    -- Scenario 3: Student 2 (UserId=4) purchased Course 2 via Order #2 (PAID) AND completed a Refund (REFUNDED -> Enrollment.AccessStatus = REVOKED) to demonstrate the REVOKED CTA state!
    -- Scenario 4: Student 2 (UserId=4) purchased Course 3 ("SQL Server Thực chiến" - 399,000đ) via Order #3 (PAID, ACTIVE)
    SET IDENTITY_INSERT dbo.Orders ON;
    INSERT INTO dbo.Orders (
        OrderId, OrderCode, StudentId, Status, Currency, SubtotalVnd, DiscountVnd, TotalVnd,
        CouponCode, PolicyVersion, IdempotencyKey, CreatedAt, ExpiresAt, PaidAt
    ) VALUES
    (1, 'ORD-20261012-0001', 3, 'PAID',     'VND', 499000, 0,     499000, NULL,         'v2026.1', 'seed-idem-stud3-course2', DATEADD(DAY, -4, SYSUTCDATETIME()), DATEADD(MINUTE, 30, DATEADD(DAY, -4, SYSUTCDATETIME())), DATEADD(DAY, -4, SYSUTCDATETIME())),
    (2, 'ORD-20261010-0002', 4, 'REFUNDED', 'VND', 499000, 99800, 399200, 'LEARNORA20', 'v2026.1', 'seed-idem-stud4-course2', DATEADD(DAY, -6, SYSUTCDATETIME()), DATEADD(MINUTE, 30, DATEADD(DAY, -6, SYSUTCDATETIME())), DATEADD(DAY, -6, SYSUTCDATETIME())),
    (3, 'ORD-20261014-0003', 4, 'PAID',           'VND', 399000, 0,     399000, NULL,         'v2026.1', 'seed-idem-stud4-course3', DATEADD(DAY, -2, SYSUTCDATETIME()), DATEADD(MINUTE, 30, DATEADD(DAY, -2, SYSUTCDATETIME())), DATEADD(DAY, -2, SYSUTCDATETIME())),
    (4, 'ORD-20261015-0004', 3, 'PAYMENT_REVIEW', 'VND', 399000, 0,     399000, NULL,         'v2026.1', 'seed-idem-stud3-course3', DATEADD(HOUR, -6, SYSUTCDATETIME()), DATEADD(MINUTE, 30, DATEADD(HOUR, -6, SYSUTCDATETIME())), NULL);
    SET IDENTITY_INSERT dbo.Orders OFF;

    SET IDENTITY_INSERT dbo.OrderItems ON;
    INSERT INTO dbo.OrderItems (OrderItemId, OrderId, CourseId, CourseTitleSnapshot, UnitPriceVnd, DiscountVnd, PayableVnd) VALUES
    (1, 1, 2, N'Java Servlet & JSP từ nền tảng đến MVC',                               499000, 0,     499000),
    (2, 2, 2, N'Java Servlet & JSP từ nền tảng đến MVC',                               499000, 99800, 399200),
    (3, 3, 3, N'SQL Server Thực chiến: Thiết kế Database 25 Bảng & Tối ưu Giao dịch', 399000, 0,     399000),
    (4, 4, 3, N'SQL Server Thực chiến: Thiết kế Database 25 Bảng & Tối ưu Giao dịch', 399000, 0,     399000);
    SET IDENTITY_INSERT dbo.OrderItems OFF;

    SET IDENTITY_INSERT dbo.PaymentAttempts ON;
    INSERT INTO dbo.PaymentAttempts (
        PaymentAttemptId, OrderId, MerchantReference, Provider, ProviderTransactionId,
        AmountVnd, Currency, Status, CreatedAt, LastVerifiedAt
    ) VALUES
    (1, 1, 'TXN-ORD1-20261012-A1', 'VNPAY_SANDBOX', 'VNP14500101', 499000, 'VND', 'SUCCEEDED', DATEADD(DAY, -4, SYSUTCDATETIME()), DATEADD(DAY, -4, SYSUTCDATETIME())),
    (2, 2, 'TXN-ORD2-20261010-A1', 'VNPAY_SANDBOX', 'VNP14500102', 399200, 'VND', 'SUCCEEDED', DATEADD(DAY, -6, SYSUTCDATETIME()), DATEADD(DAY, -6, SYSUTCDATETIME())),
    (3, 3, 'TXN-ORD3-20261014-A1', 'VNPAY_SANDBOX', 'VNP14500103', 399000, 'VND', 'SUCCEEDED', DATEADD(DAY, -2, SYSUTCDATETIME()), DATEADD(DAY, -2, SYSUTCDATETIME())),
    (4, 4, 'TXN-ORD4-20261015-A1', 'VNPAY_SANDBOX', 'VNP14500104', 399000, 'VND', 'UNKNOWN',   DATEADD(HOUR, -6, SYSUTCDATETIME()), DATEADD(HOUR, -6, SYSUTCDATETIME()));
    SET IDENTITY_INSERT dbo.PaymentAttempts OFF;

    SET IDENTITY_INSERT dbo.PaymentEvents ON;
    INSERT INTO dbo.PaymentEvents (PaymentEventId, PaymentAttemptId, PayloadHash, ReceivedAt, VerificationResult, ProcessResult, ProviderEventId, MaskedSummary) VALUES
    (1, 1, 'a8f5f167f44f4964e6c998dee827110c', DATEADD(DAY, -4, SYSUTCDATETIME()), 'SIGNATURE_VALID', 'ORDER_PAID_AND_ENROLLED', 'IPN-VNP14500101', N'vnp_ResponseCode=00, vnp_Amount=49900000, vnp_TxnRef=TXN-ORD1-20261012-A1'),
    (2, 2, 'b9d6e278a55e5075f7d009eff938221d', DATEADD(DAY, -6, SYSUTCDATETIME()), 'SIGNATURE_VALID', 'ORDER_PAID_AND_ENROLLED', 'IPN-VNP14500102', N'vnp_ResponseCode=00, vnp_Amount=39920000, vnp_TxnRef=TXN-ORD2-20261010-A1'),
    (3, 3, 'c7e4d389b66f6186a8e110f00049332e', DATEADD(DAY, -2, SYSUTCDATETIME()), 'SIGNATURE_VALID', 'ORDER_PAID_AND_ENROLLED', 'IPN-VNP14500103', N'vnp_ResponseCode=00, vnp_Amount=39900000, vnp_TxnRef=TXN-ORD3-20261014-A1');
    SET IDENTITY_INSERT dbo.PaymentEvents OFF;

    SET IDENTITY_INSERT dbo.Refunds ON;
    INSERT INTO dbo.Refunds (
        RefundId, OrderId, PaymentAttemptId, RefundReference, AmountVnd,
        Reason, Status, RequestedBy, ApprovedBy, RequestedAt, RefundedAt
    ) VALUES
    (1, 2, 2, 'RFD-20261011-0001', 399200, N'Đăng ký nhầm khóa học, mới học dưới 20% thời lượng trong vòng 7 ngày.', 'SUCCEEDED', 4, 1,    DATEADD(DAY, -5, SYSUTCDATETIME()), DATEADD(DAY, -5, SYSUTCDATETIME())),
    (2, 3, 3, 'RFD-20261016-0002', 399000, N'Em muốn đổi sang lộ trình Combo 2 khóa học nên xin hoàn tiền đơn lẻ này.', 'REQUESTED', 4, NULL, DATEADD(HOUR, -3, SYSUTCDATETIME()), NULL);
    SET IDENTITY_INSERT dbo.Refunds OFF;

    SET IDENTITY_INSERT dbo.Enrollments ON;
    INSERT INTO dbo.Enrollments (
        EnrollmentId, StudentId, CourseId, AccessStatus, SourceType, CurrentOrderItemId,
        EnrolledAt, CompletedAt, LastAccessedLessonId, LastAccessedAt
    ) VALUES
    (1, 3, 1, 'ACTIVE',  'FREE_ENROLL',    NULL, DATEADD(DAY, -30, SYSUTCDATETIME()), DATEADD(DAY, -20, SYSUTCDATETIME()), 4, DATEADD(DAY, -20, SYSUTCDATETIME())),
    (2, 3, 2, 'ACTIVE',  'ORDER_PURCHASE', 1,    DATEADD(DAY, -4,  SYSUTCDATETIME()), NULL,                               5, DATEADD(DAY, -1,  SYSUTCDATETIME())),
    (3, 4, 1, 'ACTIVE',  'FREE_ENROLL',    NULL, DATEADD(DAY, -25, SYSUTCDATETIME()), DATEADD(DAY, -12, SYSUTCDATETIME()), 4, DATEADD(DAY, -12, SYSUTCDATETIME())),
    (4, 4, 2, 'REVOKED', 'ORDER_PURCHASE', 2,    DATEADD(DAY, -6,  SYSUTCDATETIME()), NULL,                               5, DATEADD(DAY, -5,  SYSUTCDATETIME())),
    (5, 4, 3, 'ACTIVE',  'ORDER_PURCHASE', 3,    DATEADD(DAY, -2,  SYSUTCDATETIME()), NULL,                               9, DATEADD(DAY, -1,  SYSUTCDATETIME()));
    SET IDENTITY_INSERT dbo.Enrollments OFF;

    SET IDENTITY_INSERT dbo.EnrollmentAccessEvents ON;
    INSERT INTO dbo.EnrollmentAccessEvents (EventId, EnrollmentId, SourceOrderItemId, EventType, ActorId, CreatedAt, Reason) VALUES
    (1, 1, NULL, 'GRANTED', 3, DATEADD(DAY, -30, SYSUTCDATETIME()), N'Đăng ký khóa học miễn phí.'),
    (2, 2, 1,    'GRANTED', 3, DATEADD(DAY, -4,  SYSUTCDATETIME()), N'Cấp quyền học tự động sau khi xác minh giao dịch VNP14500101.'),
    (3, 3, NULL, 'GRANTED', 4, DATEADD(DAY, -25, SYSUTCDATETIME()), N'Đăng ký khóa học miễn phí.'),
    (4, 4, 2,    'GRANTED', 4, DATEADD(DAY, -6,  SYSUTCDATETIME()), N'Cấp quyền học tự động sau khi xác minh giao dịch VNP14500102.'),
    (5, 4, 2,    'REVOKED', 1, DATEADD(DAY, -5,  SYSUTCDATETIME()), N'Thu hồi quyền học sau khi hoàn tất hoàn tiền RFD-20261011-0001.'),
    (6, 5, 3,    'GRANTED', 4, DATEADD(DAY, -2,  SYSUTCDATETIME()), N'Cấp quyền học tự động sau khi xác minh giao dịch VNP14500103.');
    SET IDENTITY_INSERT dbo.EnrollmentAccessEvents OFF;

    SET IDENTITY_INSERT dbo.AuditLogs ON;
    INSERT INTO dbo.AuditLogs (AuditLogId, ActorId, Action, EntityType, EntityId, CreatedAt, CorrelationId, ChangeSummary) VALUES
    (1, 1, 'COURSE_APPROVE',  'Course', '2', DATEADD(DAY, -35, SYSUTCDATETIME()), 'corr-seed-001', N'Phê duyệt khóa học trả phí Java Servlet & JSP (Giá niêm yết 699.000đ, Giá bán 499.000đ).'),
    (2, 3, 'PAYMENT_SUCCESS', 'Order',  '1', DATEADD(DAY, -4,  SYSUTCDATETIME()), 'corr-seed-002', N'Xác nhận IPN hợp lệ cho đơn ORD-20261012-0001 (499.000đ) và cấp Enrollment #2.'),
    (3, 1, 'REFUND_SUCCEEDED','Refund', '1', DATEADD(DAY, -5,  SYSUTCDATETIME()), 'corr-seed-003', N'Thực thi hoàn tiền RFD-20261011-0001 (399.200đ) và chuyển Enrollment #4 sang REVOKED.');
    SET IDENTITY_INSERT dbo.AuditLogs OFF;

    INSERT INTO dbo.LessonProgress (EnrollmentId, LessonId, CourseId, LastPositionSeconds, StudentNotes, LastAccessedAt, CompletedAt) VALUES
    (1, 1, 1, 720, N'Ghi chú: JVM thực thi bytecode, JDK bao gồm JRE và bộ công cụ phát triển.', DATEADD(DAY, -28, SYSUTCDATETIME()), DATEADD(DAY, -28, SYSUTCDATETIME())),
    (1, 2, 1, 840, N'Luôn dùng BigDecimal cho tiền tệ VND (DECIMAL(18,0)).',                     DATEADD(DAY, -26, SYSUTCDATETIME()), DATEADD(DAY, -26, SYSUTCDATETIME())),
    (1, 3, 1, 960, N'JavaBeans bắt buộc có default constructor và getter/setter chuẩn cho EL.', DATEADD(DAY, -23, SYSUTCDATETIME()), DATEADD(DAY, -23, SYSUTCDATETIME())),
    (1, 4, 1, 900, N'Luôn dùng try-with-resources trong mọi phương thức DAO.',                  DATEADD(DAY, -21, SYSUTCDATETIME()), DATEADD(DAY, -21, SYSUTCDATETIME())),
    -- Enrollment 2 (Student 1 in Course 2: 1/4 lessons completed -> 25% progress)
    (2, 5, 2, 780, N'PRG giúp tránh gửi lặp form POST khi refresh trình duyệt.',                DATEADD(DAY, -2,  SYSUTCDATETIME()), DATEADD(DAY, -2,  SYSUTCDATETIME())),
    (2, 6, 2, 240, N'Đang học phần kiểm tra quyền 3 lớp và MediaServlet.',                      DATEADD(DAY, -1,  SYSUTCDATETIME()), NULL),
    -- Enrollment 3 (Student 2 in Course 1: 4/4 completed)
    (3, 1, 1, 720, NULL, DATEADD(DAY, -20, SYSUTCDATETIME()), DATEADD(DAY, -20, SYSUTCDATETIME())),
    (3, 2, 1, 840, NULL, DATEADD(DAY, -18, SYSUTCDATETIME()), DATEADD(DAY, -18, SYSUTCDATETIME())),
    (3, 3, 1, 960, NULL, DATEADD(DAY, -15, SYSUTCDATETIME()), DATEADD(DAY, -15, SYSUTCDATETIME())),
    (3, 4, 1, 900, NULL, DATEADD(DAY, -13, SYSUTCDATETIME()), DATEADD(DAY, -13, SYSUTCDATETIME())),
    -- Enrollment 5 (Student 2 in Course 3: 1/2 completed -> 50%)
    (5, 9, 3, 820, N'Đã nắm rõ quan hệ giữa Orders, OrderItems, PaymentAttempts và Refunds.',   DATEADD(DAY, -1,  SYSUTCDATETIME()), DATEADD(DAY, -1,  SYSUTCDATETIME()));

    SET IDENTITY_INSERT dbo.Quizzes ON;
    INSERT INTO dbo.Quizzes (QuizId, CourseId, Title, Description, DurationMinutes, MaxAttempts, PassingScore, IsRequired, SortOrder) VALUES
    (1, 1, N'Bài kiểm tra Cuối khóa: Nền tảng Java & Lập trình Hướng đối tượng',
     N'Đánh giá mức độ nắm vững kiến trúc JVM, kiểu dữ liệu, tính chất OOP và quản lý tài nguyên trong Java 17.',
     15, 3, 70.00, 1, 1),
    (2, 2, N'Bài kiểm tra Cuối khóa: Kiến trúc Java Servlet/JSP MVC & Thanh toán Trực tuyến',
     N'Kiểm tra quy trình xử lý request MVC, Idempotent Order, xác thực chữ ký VNPAY IPN và kiểm soát quyền học.',
     20, 3, 70.00, 1, 1),
    (3, 3, N'Bài kiểm tra Cuối khóa: Thiết kế Database 25 Bảng & Báo cáo Doanh thu Ròng',
     N'Kiểm tra kiến thức về khóa ngoại ghép, Filtered Unique Index, View thống kê và ACID Transaction.',
     20, 3, 70.00, 1, 1);
    SET IDENTITY_INSERT dbo.Quizzes OFF;

    SET IDENTITY_INSERT dbo.Questions ON;
    INSERT INTO dbo.Questions (QuestionId, QuizId, Content, Explanation, Points, SortOrder) VALUES
    (1, 1, N'Thành phần nào trong nền tảng Java chịu trách nhiệm trực tiếp thực thi mã Bytecode (.class) trên từng hệ điều hành?',
     N'JVM (Java Virtual Machine) thông dịch và biên dịch JIT mã Bytecode sang mã máy của hệ điều hành đích.', 2.50, 1),
    (2, 1, N'Trong dự án Java Web kết nối SQL Server, kiểu dữ liệu Java nào phù hợp nhất để tính toán tiền tệ VND (DECIMAL(18,0)) chính xác?',
     N'BigDecimal giúp tính toán số học thập phân chính xác tuyệt đối, không bị sai số dấu phẩy động như float/double.', 2.50, 2),
    (3, 1, N'Quy ước nào sau đây là BẮT BUỘC đối với một lớp JavaBean để Expression Language (EL) trong JSP có thể đọc thuộc tính?',
     N'JavaBean cần có các thuộc tính private, constructor không tham số và các phương thức getter/setter đúng chuẩn đặt tên.', 2.50, 3),
    (4, 1, N'Cấu trúc nào trong Java 7+ giúp tự động đóng Connection, PreparedStatement và ResultSet ngay cả khi xảy ra ngoại lệ?',
     N'Cấu trúc try-with-resources tự động gọi close() trên mọi đối tượng cài đặt AutoCloseable.', 2.50, 4),
    (5, 2, N'Theo tài liệu tích hợp VNPAY PAY, giá trị tham số vnp_Amount được quy đổi từ số tiền VND như thế nào?',
     N'Giá trị vnp_Amount bằng số tiền VND nhân với 100 để triệt tiêu phần thập phân.', 5.00, 1),
    (6, 2, N'Trong kiến trúc Learnora Paid LMS, thời điểm nào quyền học (Enrollment.AccessStatus) bị chuyển sang REVOKED khi xử lý hoàn tiền?',
     N'Chỉ sau khi giao dịch hoàn tiền đã được xác minh thành công (Refunds.Status = SUCCEEDED) trong cùng một JDBC Transaction.', 5.00, 2),
    (7, 3, N'Chỉ mục nào trên bảng PaymentAttempts giúp chống việc ghi nhận cùng một mã giao dịch của nhà cung cấp cho nhiều lần thử khác nhau?',
     N'Filtered Unique Index trên cặp cột (Provider, ProviderTransactionId) với điều kiện WHERE ProviderTransactionId IS NOT NULL.', 5.00, 1),
    (8, 3, N'Công thức tính Doanh thu Ròng (Net Revenue) trong kỳ trên báo cáo quản trị là gì?',
     N'Tổng khoản thu đã xác minh thành công (SUCCEEDED) trong kỳ trừ đi Tổng khoản hoàn tiền đã thực hiện thành công (SUCCEEDED) trong kỳ.', 5.00, 2);
    SET IDENTITY_INSERT dbo.Questions OFF;

    SET IDENTITY_INSERT dbo.AnswerOptions ON;
    INSERT INTO dbo.AnswerOptions (OptionId, QuestionId, Content, IsCorrect, SortOrder) VALUES
    (1,  1, N'JVM (Java Virtual Machine)', 1, 1),
    (2,  1, N'Trình soạn thảo mã nguồn NetBeans IDE', 0, 2),
    (3,  1, N'Tệp cấu hình pom.xml của Maven', 0, 3),
    (4,  1, N'Cơ sở dữ liệu SQL Server', 0, 4),
    (5,  2, N'Kiểu float hoặc double', 0, 1),
    (6,  2, N'Lớp java.math.BigDecimal', 1, 2),
    (7,  2, N'Kiểu char', 0, 3),
    (8,  2, N'Kiểu boolean', 0, 4),
    (9,  3, N'Viết câu lệnh SQL trực tiếp bên trong lớp Model', 0, 1),
    (10, 3, N'Khai báo thuộc tính private, có constructor không tham số và các phương thức getter/setter chuẩn', 1, 2),
    (11, 3, N'Bắt buộc kế thừa lớp HttpServlet', 0, 3),
    (12, 3, N'Đặt tất cả các trường ở chế độ public static', 0, 4),
    (13, 4, N'Khối lệnh try-with-resources', 1, 1),
    (14, 4, N'Vòng lặp do-while vô hạn', 0, 2),
    (15, 4, N'Từ khóa synchronized trên tên lớp', 0, 3),
    (16, 4, N'Khai báo biến toàn cục static Connection', 0, 4),
    (17, 5, N'Bằng số tiền VND nhân với 100', 1, 1),
    (18, 5, N'Lấy trực tiếp giá trị từ thẻ input ẩn trên trình duyệt mà không kiểm tra', 0, 2),
    (19, 5, N'Chia số tiền VND cho 1000', 0, 3),
    (20, 6, N'Ngay khi học viên vừa bấm nút gửi yêu cầu hoàn tiền', 0, 1),
    (21, 6, N'Chỉ sau khi kết quả hoàn tiền được xác minh thành công (Refunds.Status = SUCCEEDED) trong transaction', 1, 2),
    (22, 6, N'Xóa thẳng bản ghi Order và Enrollment khỏi cơ sở dữ liệu', 0, 3),
    (23, 7, N'Filtered UNIQUE(Provider, ProviderTransactionId) WHERE ProviderTransactionId IS NOT NULL', 1, 1),
    (24, 7, N'Không cần bất kỳ chỉ mục hay ràng buộc nào', 0, 2),
    (25, 8, N'Tổng khoản thu đã xác minh (SUCCEEDED) trong kỳ trừ Tổng tiền hoàn thành công (SUCCEEDED) trong kỳ', 1, 1),
    (26, 8, N'Cộng tất cả các đơn hàng đã hủy (CANCELLED) và hết hạn (EXPIRED)', 0, 2);
    SET IDENTITY_INSERT dbo.AnswerOptions OFF;

    SET IDENTITY_INSERT dbo.QuizAttempts ON;
    INSERT INTO dbo.QuizAttempts (
        AttemptId, EnrollmentId, QuizId, CourseId, AttemptNumber,
        StartedAt, ExpiresAt, FinalizedAt, Status, FinishReason,
        PassingScoreSnapshot, TotalPoints, EarnedPoints
    ) VALUES
    (1, 1, 1, 1, 1,
     DATEADD(MINUTE, -35, DATEADD(DAY, -20, SYSUTCDATETIME())),
     DATEADD(MINUTE, -20, DATEADD(DAY, -20, SYSUTCDATETIME())),
     DATEADD(MINUTE, -24, DATEADD(DAY, -20, SYSUTCDATETIME())),
     'FINISHED', 'SUBMITTED', 70.00, 10.00, 10.00),
    (2, 3, 1, 1, 1,
     DATEADD(MINUTE, -30, DATEADD(DAY, -12, SYSUTCDATETIME())),
     DATEADD(MINUTE, -15, DATEADD(DAY, -12, SYSUTCDATETIME())),
     DATEADD(MINUTE, -18, DATEADD(DAY, -12, SYSUTCDATETIME())),
     'FINISHED', 'SUBMITTED', 70.00, 10.00, 10.00);
    SET IDENTITY_INSERT dbo.QuizAttempts OFF;

    INSERT INTO dbo.AttemptAnswers (AttemptId, QuizId, QuestionId, SelectedOptionId, QuestionPoints, AwardedPoints, SavedAt) VALUES
    (1, 1, 1, 1,  2.50, 2.50, DATEADD(DAY, -20, SYSUTCDATETIME())),
    (1, 1, 2, 6,  2.50, 2.50, DATEADD(DAY, -20, SYSUTCDATETIME())),
    (1, 1, 3, 10, 2.50, 2.50, DATEADD(DAY, -20, SYSUTCDATETIME())),
    (1, 1, 4, 13, 2.50, 2.50, DATEADD(DAY, -20, SYSUTCDATETIME())),
    (2, 1, 1, 1,  2.50, 2.50, DATEADD(DAY, -12, SYSUTCDATETIME())),
    (2, 1, 2, 6,  2.50, 2.50, DATEADD(DAY, -12, SYSUTCDATETIME())),
    (2, 1, 3, 10, 2.50, 2.50, DATEADD(DAY, -12, SYSUTCDATETIME())),
    (2, 1, 4, 13, 2.50, 2.50, DATEADD(DAY, -12, SYSUTCDATETIME()));

    SET IDENTITY_INSERT dbo.DiscussionPosts ON;
    INSERT INTO dbo.DiscussionPosts (PostId, LessonId, AuthorId, ParentPostId, Body, IsHidden, IsDeleted, CreatedAt, UpdatedAt) VALUES
    (1, 5, 3, NULL, N'Thầy cho em hỏi: Vì sao trên trang thanh toán không nên có nút "Tôi đã thanh toán" tự đổi trạng thái đơn sang PAID ạ?', 0, 0, DATEADD(DAY, -3, SYSUTCDATETIME()), DATEADD(DAY, -3, SYSUTCDATETIME())),
    (2, 5, 2, 1,    N'Câu hỏi rất cốt lõi Nam nhé! Nếu cho client tự gửi trạng thái PAID mà không xác minh chữ ký số từ cổng thanh toán (IPN) hoặc đối soát của Admin thì người dùng có thể giả mạo request để mở khóa học miễn phí.', 0, 0, DATEADD(DAY, -3, SYSUTCDATETIME()), DATEADD(DAY, -3, SYSUTCDATETIME()));
    SET IDENTITY_INSERT dbo.DiscussionPosts OFF;

    INSERT INTO dbo.CourseReviews (EnrollmentId, Rating, Comment, IsHidden, CreatedAt, UpdatedAt) VALUES
    (1, 5, N'Khóa học miễn phí nhưng giải thích cực kỳ bài bản về OOP, BigDecimal và quản lý tài nguyên JDBC!', 0, DATEADD(DAY, -19, SYSUTCDATETIME()), DATEADD(DAY, -19, SYSUTCDATETIME())),
    (2, 5, N'Khóa học Java Servlet & JSP MVC 499.000đ giải thích cực kỳ chi tiết về luồng đơn hàng Idempotent, VNPAY IPN và hoàn tiền.', 0, DATEADD(DAY, -1, SYSUTCDATETIME()), DATEADD(DAY, -1, SYSUTCDATETIME())),
    (3, 5, N'Nội dung mạch lạc, bài kiểm tra bám sát kiến thức thực tế.', 0, DATEADD(DAY, -11, SYSUTCDATETIME()), DATEADD(DAY, -11, SYSUTCDATETIME()));

    SET IDENTITY_INSERT dbo.Certificates ON;
    INSERT INTO dbo.Certificates (CertificateId, EnrollmentId, CertificateCode, Status, IssuedAt, VerificationUrl) VALUES
    (1, 1, 'LN-2026-JAVA-0001', 'VALID', DATEADD(DAY, -20, SYSUTCDATETIME()), N'/student/progress?cert=LN-2026-JAVA-0001'),
    (2, 3, 'LN-2026-JAVA-0003', 'VALID', DATEADD(DAY, -12, SYSUTCDATETIME()), N'/student/progress?cert=LN-2026-JAVA-0003');
    SET IDENTITY_INSERT dbo.Certificates OFF;
END
GO
