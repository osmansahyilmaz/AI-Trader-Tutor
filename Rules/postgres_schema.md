<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
DB/Security agent

MISSION:
Define Postgres tables, constraints, and indexes for MVP.

INPUTS YOU MAY USE:
- endpoints.md
- rate_limit.md
- idempotency.md

OUTPUTS YOU MUST PRODUCE:
- postgres_schema.sql and explanations
- Index recommendations

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Store minimal PII
- Use uuid primary keys
- Ensure performance for history queries

DEFINITION OF DONE:
- Schema can be applied cleanly
- Queries are supported by indexes

ACCEPTANCE TESTS / VERIFICATION:
- Apply SQL successfully
- Basic insert/select works with RLS enabled

FILES YOU MAY TOUCH:
- postgres_schema.md
- postgres_schema.sql

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# postgres_schema.md — Database tables (Supabase Postgres)

## Tables (MVP)
- `profiles` — one row per user (plan + daily limits)
- `analyses` — stored analyses (payload + explanation)
- `rate_limits` — window counters (optional hardening)
- `requests` — idempotency per user requestId
- `ohlcv_cache` — optional short-term cache for candles

## Key indexes
- analyses: (user_id, created_at desc)
- analyses: (user_id, symbol, timeframe, created_at desc) (optional filters)
- requests: (user_id, request_id) unique
