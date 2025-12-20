<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend agent

MISSION:
Prevent double-charging and duplicate analysis creation on retries/timeouts.

INPUTS YOU MAY USE:
- rate_limit.md
- endpoints.md
- postgres_schema.sql

OUTPUTS YOU MUST PRODUCE:
- Idempotency behavior rules and error codes

HARD CONSTRAINTS (NON-NEGOTIABLE):
- requestId is mandatory
- Must be checked before credit decrement

DEFINITION OF DONE:
- Same requestId returns same analysisId without extra credits

ACCEPTANCE TESTS / VERIFICATION:
- Retry with same requestId returns original analysis

FILES YOU MAY TOUCH:
- idempotency.md
- supabase/functions/analyzeRequest/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# idempotency.md — requestId rules

## Input
Client must send `requestId` (UUIDv4 recommended).

## Behavior
- If `(user_id, request_id)` exists with status='completed':
  - return the same `analysisId` and stored result (no credit decrement).
- If exists with status='started':
  - MVP option A: return 409 “in progress”
  - MVP option B: short wait + re-check (avoid long waits)
- If not exists:
  - create request row status='started' within transaction

## Why
- Network retries and double taps should not double-charge user or create duplicate analyses.
