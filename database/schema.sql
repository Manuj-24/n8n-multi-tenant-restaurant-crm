-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tenants Table (Stores restaurant configs & API keys)
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(50) PRIMARY KEY,
    restaurant_name VARCHAR(255) NOT NULL,
    evolution_instance_name VARCHAR(100),
    evolution_api_key TEXT,
    sms_api_key TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Customers Table (Stores diner metrics & enforces unique phone per tenant)
CREATE TABLE IF NOT EXISTS customers (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(50) REFERENCES tenants(id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    name VARCHAR(150),
    total_orders INTEGER DEFAULT 1,
    total_spent NUMERIC(10, 2) DEFAULT 0.00,
    last_order_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_tenant_customer_phone UNIQUE (tenant_id, phone)
);

-- 3. Campaign Logs Table (Stores audit history & prevents spam)
CREATE TABLE IF NOT EXISTS campaign_logs (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(50) REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE,
    campaign_type VARCHAR(50) NOT NULL,
    channel_used VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    dynamic_link TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_customers_tenant_last_order ON customers(tenant_id, last_order_at);
CREATE INDEX IF NOT EXISTS idx_campaign_logs_lookup ON campaign_logs(tenant_id, customer_id, campaign_type, status);
