-- ============================================================
-- MELARIUM - V2: Add email field to users
-- V2__add_email_to_users.sql
-- ============================================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Update OtpResponse to support email-based OTP
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name_display VARCHAR(100);
