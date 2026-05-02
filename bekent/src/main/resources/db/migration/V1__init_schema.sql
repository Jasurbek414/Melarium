-- ============================================================
-- MELARIUM - Initial Schema Migration
-- V1__init_schema.sql
-- ============================================================

-- ENUMS
CREATE TYPE user_role AS ENUM ('INVESTOR', 'BEEKEEPER', 'ADMIN');
CREATE TYPE colony_status AS ENUM ('AVAILABLE', 'ACTIVE', 'HARVESTING', 'COMPLETED', 'SUSPENDED');
CREATE TYPE investment_status AS ENUM ('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED');
CREATE TYPE transaction_status AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED');
CREATE TYPE transaction_type AS ENUM ('INVESTMENT', 'HONEY_SALE', 'COMMISSION', 'REFUND', 'PAYOUT');
CREATE TYPE payment_provider AS ENUM ('CLICK', 'PAYME', 'UZCARD', 'HUMO', 'MOCK');
CREATE TYPE honey_choice AS ENUM ('DELIVERY', 'SELL');

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    phone       VARCHAR(15)  NOT NULL UNIQUE,
    full_name   VARCHAR(100),
    role        user_role    NOT NULL DEFAULT 'INVESTOR',
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    otp_code    VARCHAR(10),
    otp_expires_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users (phone);
CREATE INDEX idx_users_role  ON users (role);

-- ============================================================
-- COLONIES TABLE
-- ============================================================
CREATE TABLE colonies (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    location            VARCHAR(255) NOT NULL,
    description         TEXT,
    beekeeper_id        BIGINT       NOT NULL REFERENCES users(id),
    price_per_share     NUMERIC(12,2) NOT NULL,
    total_shares        INT          NOT NULL DEFAULT 100,
    available_shares    INT          NOT NULL DEFAULT 100,
    expected_roi_pct    NUMERIC(5,2) NOT NULL,    -- e.g. 18.50 means 18.5%
    season_start        DATE,
    season_end          DATE,
    status              colony_status NOT NULL DEFAULT 'AVAILABLE',
    -- IoT Simulation fields (manually entered for MVP)
    temperature_celsius NUMERIC(4,1),
    humidity_pct        NUMERIC(4,1),
    weight_kg           NUMERIC(6,2),
    -- Metadata
    image_url           VARCHAR(500),
    is_verified         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_colonies_beekeeper ON colonies (beekeeper_id);
CREATE INDEX idx_colonies_status    ON colonies (status);

-- ============================================================
-- INVESTMENTS TABLE
-- ============================================================
CREATE TABLE investments (
    id              BIGSERIAL PRIMARY KEY,
    investor_id     BIGINT        NOT NULL REFERENCES users(id),
    colony_id       BIGINT        NOT NULL REFERENCES colonies(id),
    shares_count    INT           NOT NULL,
    share_price_at_purchase NUMERIC(12,2) NOT NULL,
    total_invested  NUMERIC(14,2) NOT NULL,   -- shares_count * share_price_at_purchase
    expected_roi    NUMERIC(14,2),             -- calculated
    actual_return   NUMERIC(14,2) DEFAULT 0,
    status          investment_status NOT NULL DEFAULT 'PENDING',
    honey_choice    honey_choice,              -- set after harvest
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_investments_investor ON investments (investor_id);
CREATE INDEX idx_investments_colony   ON investments (colony_id);
CREATE INDEX idx_investments_status   ON investments (status);

-- ============================================================
-- TRANSACTIONS TABLE
-- ============================================================
CREATE TABLE transactions (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT        NOT NULL REFERENCES users(id),
    investment_id       BIGINT        REFERENCES investments(id),
    amount              NUMERIC(14,2) NOT NULL,
    type                transaction_type    NOT NULL,
    provider            payment_provider    NOT NULL DEFAULT 'MOCK',
    status              transaction_status  NOT NULL DEFAULT 'PENDING',
    provider_tx_id      VARCHAR(100),   -- external payment system transaction ID
    provider_payload    JSONB,          -- raw webhook payload
    description         TEXT,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_user   ON transactions (user_id);
CREATE INDEX idx_transactions_status ON transactions (status);
CREATE INDEX idx_transactions_type   ON transactions (type);

-- ============================================================
-- HONEY REPORTS TABLE
-- ============================================================
CREATE TABLE honey_reports (
    id                  BIGSERIAL PRIMARY KEY,
    colony_id           BIGINT        NOT NULL REFERENCES colonies(id),
    beekeeper_id        BIGINT        NOT NULL REFERENCES users(id),
    period_start        DATE          NOT NULL,
    period_end          DATE          NOT NULL,
    honey_volume_kg     NUMERIC(8,2)  NOT NULL,
    expenses_usd        NUMERIC(12,2) NOT NULL DEFAULT 0,
    honey_price_per_kg  NUMERIC(8,2)  NOT NULL,  -- market price at time of report
    notes               TEXT,
    is_finalized        BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_honey_reports_colony ON honey_reports (colony_id);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE notifications (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT      NOT NULL REFERENCES users(id),
    title       VARCHAR(200) NOT NULL,
    body        TEXT         NOT NULL,
    type        VARCHAR(50)  NOT NULL,  -- PURCHASE, HARVEST, STATUS_CHANGE, etc.
    is_read     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user   ON notifications (user_id);
CREATE INDEX idx_notifications_unread ON notifications (user_id, is_read) WHERE is_read = FALSE;

-- ============================================================
-- AUDIT LOG TABLE
-- ============================================================
CREATE TABLE audit_logs (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT,
    action      VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id   BIGINT,
    details     JSONB,
    ip_address  VARCHAR(45),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user   ON audit_logs (user_id);
CREATE INDEX idx_audit_action ON audit_logs (action);
