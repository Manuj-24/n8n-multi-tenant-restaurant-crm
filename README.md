# Multi-Tenant Restaurant AI CRM & Retention Engine

An automated backend pipeline built for restaurants to process POS transactions and execute context-aware retention campaigns. Powered by **n8n**, **Supabase (PostgreSQL)**, **Google Gemini AI**, and **Evolution API**.

---

## Architecture Overview

The system runs on three decoupled engines:

1. **Engine 1: Order Ingestion & Sync**
   * Webhook endpoint receives POS order data.
   * Isolates tenant credentials dynamically.
   * Performs atomic SQL upserts (`ON CONFLICT (tenant_id, phone) DO UPDATE`) to track lifetime spend and order recency.
   * Automatically triggers a welcome discount on first visits.

2. **Engine 2: Retention & Dormancy Scanner**
   * Scheduled cron job running daily at 11:00 AM.
   * Scans for customers inactive between 14 and 30+ days (`REENGAGE_14D`, `WINBACK_30D`).
   * Enforces a strict 14-day anti-spam cooldown window via SQL `NOT EXISTS` checks against outbound logs.

3. **Engine 3: Multi-Tenant AI Dispatcher**
   * Uses **Google Gemini** to generate personalized, 2-sentence WhatsApp copy based on customer order history.
   * Dispatches messages via the **Evolution API** using restaurant-specific credentials.
   * Features automated multi-channel fallback (WhatsApp → SMS → Email).
   * Logs every delivery outcome in `campaign_logs`.

---

## Tech Stack
* **Workflow Automation:** n8n
* **Database:** Supabase / PostgreSQL
* **Generative AI:** Google Gemini via n8n LangChain
* **Messaging APIs:** Evolution API (WhatsApp), SMS Gateway, Email

---

## Database Setup
Run `database/schema.sql` inside your Supabase SQL editor to create the `tenants`, `customers`, and `campaign_logs` tables.
