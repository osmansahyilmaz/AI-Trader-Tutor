# pr_sequence.md — Recommended PR order (Supabase + Flutter)

**Owner:** Osman Şah  
**Pack version:** v5.2  
**Date:** 2025-12-20

This is the same PR order as in `workplan.md`, separated for quick navigation.

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
