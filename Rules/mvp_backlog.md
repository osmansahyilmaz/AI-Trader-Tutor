# mvp_backlog.md — Technical tickets (MVP, Supabase + Flutter)

**Owner:** Osman Şah  
**Pack version:** v5.3  
**Date:** 2025-12-20

Ticket-style backlog for an AI coding agent.  
Preferred order is in `pr_sequence.md`.

---

## EPIC A — Universe + providers
### A-01 Add symbol universe assets
Tasks
- Add `symbol_universe.json` + `symbol_universe.md`
- Flutter picker reads from JSON
- Backend validates symbol against universe

Acceptance
- UI cannot select out-of-universe symbols
- Backend returns 400 for unknown symbols

Docs: `symbol_universe.md`, `symbol_universe.json`, `market_categories.md`

### A-02 Provider adapters + normalized candles
Tasks
- Create provider adapter interface:
  - `fetchCandles(assetClass, symbol, timeframe, limit) -> Candle[]`
- Implement:
  - Binance Spot adapter (crypto)
  - Twelve Data adapter (fx)
- Normalize to {t,o,h,l,c,v}
- Validate candles (ascending timestamps, numeric parsing)

Acceptance
- Same normalization contract for both providers
- Server rejects malformed candle arrays

Docs: `data_providers.md`

### A-03 Caching (optional)
Tasks
- Use `ohlcv_cache` to read-before-fetch
- Enforce TTL table by timeframe

Acceptance
- Cache hit/miss logged
- TTL respected

Docs: `data_providers.md`, `observability.md`, `postgres_schema.sql`

---

## EPIC B — Edge Functions
### B-01 analyzeRequest: contract + routing + persistence
Tasks
- Accept optional `assetClass` ("crypto"|"fx")
- Infer if missing (see `market_categories.md`)
- Validate symbol in universe
- Transaction:
  - lock profile FOR UPDATE
  - daily reset (Europe/Istanbul date)
  - idempotency via `requests (user_id, request_id)`
  - daily_limit enforcement + increment used_today
- Fetch candles via provider adapter (with optional cache)
- Compute deterministic payload v1.0
- Call OpenAI tutor with strict prompt
- Validate output (retry once then fallback)
- Insert into `analyses`; mark request completed

Acceptance
- Response matches `endpoints.md`
- idempotency prevents double charge
- 429 on limit

Docs: `endpoints.md`, `rate_limit.md`, `idempotency.md`, `analysis_payload.md`, `llm_prompting.md`, `response_validation.md`

### B-02 getAnalysis
Tasks
- Fetch by id
- Enforce ownership via RLS
- Return stored record

Acceptance
- User cannot fetch another user's analysis

Docs: `endpoints.md`, `rls_policies.md`

### B-03 universe endpoint (optional)
Tasks
- Serve universe JSON from Edge Function OR embed in Flutter only

Acceptance
- Universe consistent with backend validation

Docs: `endpoints.md`, `symbol_universe.json`

---

## EPIC C — Postgres + RLS
### C-01 Apply schema + indexes
Docs: `postgres_schema.sql`, `postgres_schema.md`

### C-02 Apply RLS policies
Docs: `rls_policies.md`

Acceptance
- Cross-user reads blocked

---

## EPIC D — Deterministic indicator engine
### D-01 Indicators: EMA/RSI/ATR + trend_state
Docs: `indicator_engine.md`, `analysis_payload.md`, `testing.md`

### D-02 Structure + Support/Resistance levels
Docs: `support_resistance.md`, `analysis_payload.md`, `testing.md`

---

## EPIC E — AI tutor + safety
### E-01 Prompt template (TR) + copy boundaries
Docs: `llm_prompting.md`, `copy_guidelines.md`, `compliance.md`

### E-02 Validator + fallback
Docs: `response_validation.md`

---

## EPIC F — Flutter MVP
### F-01 Auth + routing
Docs: `supabase_flutter.md`, `navigation.md`

### F-02 Home: asset tabs + symbol picker + timeframe chips
Docs: `ui_screens.md`, `symbol_universe.json`, `copy_guidelines.md`

### F-03 Result: 4 sections + disclaimer footer
Docs: `ui_screens.md`, `design_system.md`, `compliance.md`

### F-04 History: list + open details
Docs: `supabase_flutter.md`, `ui_screens.md`

### F-05 Settings: disclaimer + logout
Docs: `ui_screens.md`, `compliance.md`

---

## EPIC G — QA + Ops
### G-01 Manual E2E
Docs: `testing.md`

### G-02 Observability logs
Docs: `observability.md`
