<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend + DB agent

MISSION:
Implement server-side credits, daily reset (Europe/Istanbul), and optional window rate limiting using Postgres transactions.

INPUTS YOU MAY USE:
- postgres_schema.sql
- endpoints.md

OUTPUTS YOU MUST PRODUCE:
- Transaction algorithm and SQL patterns

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Server-side only
- Must be transactional
- Idempotency must prevent double charge

DEFINITION OF DONE:
- Free plan daily limit enforced; reliable under concurrency

ACCEPTANCE TESTS / VERIFICATION:
- Double requests do not double decrement
- New day resets used_today
- Over-limit returns 429

FILES YOU MAY TOUCH:
- rate_limit.md
- supabase/functions/analyzeRequest/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# rate_limit.md — Credits + daily reset (Postgres transaction)

## Requirements
- Daily reset uses Europe/Istanbul date.
- Credits are decremented server-side in a single transaction.
- Concurrency-safe: no race conditions.

## Recommended approach
In Edge Function, use a transaction with row locks:

1) Lock profile row:
- `select * from profiles where user_id = $1 for update;`

2) Daily reset:
- `today = (now() at time zone 'Europe/Istanbul')::date`
- if `last_reset_date != today` then set `used_today=0`, `last_reset_date=today`.

3) Idempotency check:
- Try select `requests` by (user_id, request_id).
  - If exists and status='completed' -> return stored analysis_id (no decrement).
  - If exists and status='started' -> return 409 or wait strategy (MVP: return 409 “in progress”).
  - Else insert request row status='started'.

4) Credit check + decrement:
- if `used_today >= daily_limit` -> rollback and return 429.
- else `used_today = used_today + 1`.

5) Optional window rate limit:
- Maintain `rate_limits` counter per window in same transaction.

6) After analysis computed:
- Insert `analyses` row
- Update `requests` to status='completed', set analysis_id

## Notes
- Keep all writes server-side using service role.
