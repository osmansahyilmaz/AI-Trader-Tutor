<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend agent

MISSION:
Define Edge Functions, auth handling, and environment variables for Supabase.

INPUTS YOU MAY USE:
- endpoints.md
- postgres_schema.md
- rls_policies.md

OUTPUTS YOU MUST PRODUCE:
- Edge Functions list + required env vars + local dev instructions

HARD CONSTRAINTS (NON-NEGOTIABLE):
- OpenAI key server-side only
- Validate inputs
- Use DB transactions for credits/idempotency

DEFINITION OF DONE:
- Functions deployable
- Local dev workable

ACCEPTANCE TESTS / VERIFICATION:
- curl/postman can call functions with auth token

FILES YOU MAY TOUCH:
- supabase/functions/**
- edge_functions.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# edge_functions.md — Supabase Edge Functions

## Functions (MVP)
1) `analyzeRequest`
- Validates auth
- Enforces credits + idempotency + rate limits (DB transaction)
- Fetches OHLCV (cache)
- Computes deterministic payload
- Calls OpenAI + validates output
- Writes `analyses` row and returns response

2) `getAnalysis`
- Takes `analysisId`
- Returns analysis row (RLS protects access)

3) (Optional) `listAnalyses`
- Pagination + filters (symbol/timeframe)
- RLS protects access

## Environment variables (Edge)
- `OPENAI_API_KEY`
- `DATA_PROVIDER_API_KEY` (if needed)
- `DATA_PROVIDER_BASE_URL` (optional)
- `TWELVEDATA_API_KEY` (required for FX provider)

## Local development
- Use Supabase CLI:
  - `supabase start`
  - `supabase functions serve analyzeRequest --no-verify-jwt` (for local only)
- In prod, ALWAYS verify JWT.

## Auth verification
- In Edge Functions, verify Supabase JWT and derive `user.id` (uid).
- NEVER trust client-provided uid.
