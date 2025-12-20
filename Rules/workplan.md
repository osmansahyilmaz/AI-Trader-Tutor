# workplan.md — Master task tree (main tasks + subtasks)

**Owner:** Osman Şah  
**Pack version:** v5.1  
**Date:** 2025-12-20

This file is for an AI coding agent to execute the project.  
It gives a complete task tree and points to the exact docs for each step.

---

## 0) Non‑negotiables (must enforce everywhere)
- Educational only; **no buy/sell signals**.
- LLM **must not invent numbers** (levels/prices). All numbers must come from `analysis_payload`.
- Credits + rate limits + idempotency are **server-side only** (DB transaction).
- No secrets in Flutter client (no service role key; only anon key).
- RLS must ensure a user only reads their own analyses.

References: `compliance.md`, `copy_guidelines.md`, `llm_prompting.md`, `response_validation.md`, `rls_policies.md`, `rate_limit.md`, `idempotency.md`

---

## 1) Project setup (Supabase + Flutter)
### 1.1 Supabase project bootstrap
- Create project
- Enable Auth provider(s) (Google recommended)
- Configure Edge Function secrets/env vars
- (Optional) enable local Supabase with CLI

References: `edge_functions.md`, `supabase_flutter.md`, `phases.md`

### 1.2 Apply DB schema
- Apply `postgres_schema.sql` (tables + indexes)
- Enable RLS on all tables
- Apply policies from `rls_policies.md`
- Create initial `profiles` row on user signup (trigger or first login flow)

References: `postgres_schema.sql`, `postgres_schema.md`, `rls_policies.md`

Deliverable:
- DB is ready; RLS blocks cross-user reads.

---

## 2) Backend: Edge Functions
### 2.1 Implement analyzeRequest (core)
Subtasks:
- Input validation: symbol/timeframe/requestId
- Auth verification: derive `user_id` from JWT (do not trust client)
- Transaction block:
  - lock profile row (`FOR UPDATE`)
  - daily reset (Europe/Istanbul date)
  - idempotency check on `requests (user_id, request_id)`
  - enforce daily_limit and increment used_today
  - optional window limit
- OHLCV fetch (one provider for MVP) + optional cache
- Deterministic compute (`analysis_payload` v1.0):
  - EMA20/50/200, RSI14, ATR14, trend_state, structure, levels[]
- Call OpenAI tutor with strict prompt
- Validate output (no invented levels); retry once or fallback
- Insert into `analyses` and finalize `requests` status
- Return response JSON matching `endpoints.md`

References:
- Contracts: `endpoints.md`, `analysis_payload.md`
- DB + limits: `postgres_schema.sql`, `rate_limit.md`, `idempotency.md`
- Engine: `indicator_engine.md`, `support_resistance.md`
- AI: `llm_prompting.md`, `response_validation.md`
- Logging: `observability.md`

### 2.2 Implement getAnalysis
- Fetch analysis by id
- Rely on RLS for ownership OR explicitly filter by user_id
- Return same response shape

References: `endpoints.md`, `rls_policies.md`

### 2.3 (Optional) listAnalyses
- Pagination + sort by created_at desc
- Filters: symbol/timeframe (optional)

References: `postgres_schema.md`, `endpoints.md`

Deliverables:
- Edge Functions deployed and callable from Flutter.

---

## 3) Flutter app (5 MVP screens)
### 3.1 App skeleton + Supabase init
- Setup `supabase_flutter`
- Auth state listener
- Route guarding

References: `supabase_flutter.md`, `navigation.md`, `flutter_architecture.md`

### 3.2 Implement UI with design system
- Implement tokens and reusable widgets:
  - PrimaryButton, AppCard/SectionCard, InfoChip, HistoryListItem, LoadingState, ErrorState
- Apply `ThemeData` based on tokens

References: `design_system.md`, `accessibility.md`

### 3.3 Screens (exact)
1) Auth
2) Home (symbol/timeframe + “Explain chart”)
3) Result (4 sections + disclaimer footer)
4) History (list + open details)
5) Settings (full disclaimer + sign out)

References: `ui_screens.md`, `copy_guidelines.md`, `compliance.md`

### 3.4 Networking + models
- Implement API client for Edge Functions
- Define models aligned to response schema
- Handle errors 401/429/503 with user-friendly UX

References: `endpoints.md`, `analysis_payload.md`, `supabase_flutter.md`

Deliverables:
- End-to-end user journey works on emulator/device.

---

## 4) Tests + safety verification
### 4.1 Backend tests
- Unit tests: EMA/RSI/ATR
- Determinism test: S/R stable for same candles
- Integration tests: credits/idempotency/daily reset
- Validator tests: invented level blocked -> fallback

References: `testing.md`, `indicator_engine.md`, `support_resistance.md`, `rate_limit.md`, `response_validation.md`

### 4.2 Flutter verification
- Manual E2E checklist
- Optional widget smoke tests
- Basic accessibility checks

References: `testing.md`, `accessibility.md`

---

## 5) Observability + release checks
- Add structured logs (traceId, latency, cache_hit, validator_violation)
- Confirm secrets not in client
- Confirm RLS policies correct
- Confirm disclaimers visible in Result + Settings

References: `observability.md`, `pr_checklist.md`, `rls_policies.md`, `compliance.md`

---

## Definition of Done (MVP)
- Free plan: 1 analysis/day enforced server-side.
- Same requestId never double-charges.
- User cannot access other users’ data (RLS).
- LLM never invents price levels; validator enforces.
- Flutter UI matches `ui_screens.md` and uses design system.


---

## Suggested PR sequence (recommended order)
> Goal: keep PRs small and reviewable; each PR should be shippable and testable.

### PR #1 — Supabase + Flutter bootstrap
- Supabase project config placeholders
- Flutter app initializes Supabase and shows Auth screen
- Basic route guard (unauth -> /auth)

Docs: `supabase_flutter.md`, `navigation.md`, `flutter_architecture.md`

**DoD**
- App runs on emulator; login stub UI renders.

### PR #2 — Postgres schema + RLS policies applied
- Apply `postgres_schema.sql`
- Enable RLS on tables
- Apply policies from `rls_policies.md`
- Add documentation notes for applying via migrations/SQL editor

Docs: `postgres_schema.sql`, `rls_policies.md`

**DoD**
- User cannot read other users’ analyses.

### PR #3 — Edge Function skeletons + auth verification
- Create Edge Functions: `analyzeRequest`, `getAnalysis`
- Strict input validation + JWT verification wiring
- Structured logging scaffold (traceId)

Docs: `edge_functions.md`, `endpoints.md`, `observability.md`

**DoD**
- Functions deploy and return well-formed errors (401/400).

### PR #4 — Credits + daily reset + idempotency transaction
- Implement Postgres transaction flow (FOR UPDATE lock)
- Enforce daily limit; Europe/Istanbul reset
- Implement `requests` idempotency rules (409 in-progress)

Docs: `rate_limit.md`, `idempotency.md`, `postgres_schema.sql`

**DoD**
- Same requestId never double-charges.
- Over-limit returns 429.

### PR #5 — Market data provider integration + optional cache
- Choose ONE provider (document in decision_log.md)
- Fetch OHLCV candles; validate candle ordering
- Optional `ohlcv_cache` usage

Docs: `architecture.md`

**DoD**
- Can fetch candles reliably for one symbol/timeframe.

### PR #6 — Deterministic engine (EMA/RSI/ATR + trend_state)
- Implement indicator computations
- Add unit tests for indicators

Docs: `indicator_engine.md`, `analysis_payload.md`, `testing.md`

**DoD**
- Unit tests pass and output matches schema.

### PR #7 — Structure + Support/Resistance levels
- Implement pivots + clustering -> levels[]
- Add determinism + sanity tests

Docs: `support_resistance.md`, `analysis_payload.md`, `testing.md`

**DoD**
- levels[] stable for same candles.

### PR #8 — OpenAI tutor + strict prompt + validator retry/fallback
- Implement OpenAI call
- Implement validator allowlist
- Retry once then fallback

Docs: `llm_prompting.md`, `response_validation.md`, `compliance.md`

**DoD**
- Hallucinated levels never reach client.

### PR #9 — Persist analysis + getAnalysis + history query
- Insert into `analyses`
- Finalize `requests` status
- `getAnalysis` returns stored analysis
- Flutter History screen reads via RLS select and opens Result

Docs: `endpoints.md`, `ui_screens.md`, `supabase_flutter.md`

**DoD**
- Full flow: run analysis -> result -> history -> open detail.

### PR #10 — UI polish + copy + Settings + E2E checklist
- Implement design tokens/components
- Ensure disclaimers in Result + Settings
- Error UX for 401/429/503
- Manual E2E checklist finalized

Docs: `design_system.md`, `ui_screens.md`, `copy_guidelines.md`, `testing.md`

**DoD**
- MVP demo ready and compliant.

### PR #11 (optional) — Observability + basic dashboards
- Log fields finalized
- Add lightweight metrics strategy (if available)

Docs: `observability.md`

**DoD**
- Costs and failures are visible.
