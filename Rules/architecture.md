<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend/Architecture agent

MISSION:
Implement Supabase-first architecture integrated with Flutter client; ensure determinism and safety.

INPUTS YOU MAY USE:
- edge_functions.md
- endpoints.md
- analysis_payload.md
- postgres_schema.md
- rls_policies.md
- ui_screens.md

OUTPUTS YOU MUST PRODUCE:
- Implemented pipeline and integration plan

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Secrets server-side only
- Deterministic numbers; LLM explains
- RLS must enforce ownership
- Server-side credits/rate limits

DEFINITION OF DONE:
- End-to-end analyze pipeline works
- Ownership enforced by RLS
- Validation+fallback implemented

ACCEPTANCE TESTS / VERIFICATION:
- analyzeRequest writes analysis row
- user cannot read others' analyses
- Flutter renders response

FILES YOU MAY TOUCH:
- architecture.md
- supabase/functions/**
- lib/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# architecture.md — System architecture (Flutter + Supabase)

## Components
- **Flutter Client**
  - Auth, symbol/timeframe selection, results UI, history, settings
- **Supabase Auth**
  - Google sign-in (recommended)
- **Supabase Postgres**
  - Stores profiles (plan/credits), analyses, rate limits, idempotency requests, caches (optional)
- **Supabase Edge Functions**
  - `analyzeRequest`: pipeline orchestration + OpenAI + deterministic compute
  - `getAnalysis`: fetch analysis with authorization (RLS)
  - (optional) `listAnalyses`: pagination
- **Market Data Provider**
  - OHLCV candles
- **OpenAI API**
  - Tutor explanation generated from deterministic payload

## Data flow: analyzeRequest
1) Flutter calls Edge Function `analyzeRequest` with `symbol`, `timeframe`, `requestId`.
2) Edge Function verifies JWT/session.
3) Edge Function performs a DB transaction:
   - daily reset (Europe/Istanbul date)
   - credit decrement (plan limits)
   - idempotency check (requestId)
   - optional window rate limit
4) Fetch & cache OHLCV
5) Compute deterministic payload (`analysis_payload` v1.0)
6) Call OpenAI with tutor prompt
7) Validate LLM output; retry once or fallback deterministically
8) Insert into `analyses` and finalize `requests` status
9) Return response to Flutter

## Key rule
**Numbers are computed, not invented.**
The LLM never generates new levels/prices.
