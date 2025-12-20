<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Program Manager agent

MISSION:
Coordinate delivery phases for Flutter + Supabase MVP and keep scope aligned with exit criteria.

INPUTS YOU MAY USE:
- backlog.md
- architecture.md
- ui_screens.md
- testing.md

OUTPUTS YOU MUST PRODUCE:
- Phase plan with clear exit criteria and dependencies

HARD CONSTRAINTS (NON-NEGOTIABLE):
- One market data source in MVP
- Keep UI scope to 5 MVP screens
- No scope creep

DEFINITION OF DONE:
- Each phase has tasks, owner, and exit criteria

ACCEPTANCE TESTS / VERIFICATION:
- Backlog items mapped to phases
- Design deliverables mapped to Flutter implementation

FILES YOU MAY TOUCH:
- phases.md
- backlog.md
- decision_log.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# phases.md — Delivery plan (Flutter + Supabase)

## Phase 0 — Setup (0.5–1 day)
- Create Supabase project.
- Enable Supabase Auth providers (Google recommended).
- Configure Edge Functions and secrets (OpenAI key, data provider keys).
- Bootstrap Flutter app with `supabase_flutter`.
- Optional: Set up local Supabase (`supabase start`) for development.

**Exit criteria**
- Flutter can sign in and get a session.
- One trivial Edge Function returns “ok”.

## Phase 1 — Deterministic backend (3–5 days)
- Pick ONE market data source (MVP) and implement OHLCV fetch + caching.
- Implement deterministic engine:
  - EMA(20/50/200), RSI(14), ATR(14)
  - Market structure from pivots
  - Support/resistance from pivots + clustering
- Finalize `analysis_payload` schema v1.0.

**Exit criteria**
- Edge Function returns deterministic payload with all required fields.

## Phase 2 — AI tutor layer + safety (2–3 days)
- Implement tutor prompt template and OpenAI call.
- Implement response validation (no invented levels) + fallback.
- Ensure disclaimers are always present in output.

**Exit criteria**
- AI responses always contain 4 sections, no invented numbers, always risk note.

## Phase 3 — Credits + RLS + Flutter MVP screens (3–6 days)
- Server-side credits and daily limits enforced in DB transaction.
- RLS policies: user reads only own rows; prevent client writes to protected tables.
- Flutter MVP screens implemented:
  - Auth, Home, Result, History, Settings

**Exit criteria**
- Free plan can run 1 analysis/day; 2nd is blocked (429 UX).
- User sees history and can open details.

## Phase 4 — Polish + tests + release checklist (2–4 days)
- Add structured logs + basic metrics.
- Unit tests for indicator engine.
- Manual E2E checklist.
- Basic Flutter widget tests (optional) + accessibility pass.

**Exit criteria**
- Stable demo, predictable costs, and clear educational positioning.
