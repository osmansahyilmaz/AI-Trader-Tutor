<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
All agents

MISSION:
Record key decisions and assumptions.

INPUTS YOU MAY USE:
- PR discussions

OUTPUTS YOU MUST PRODUCE:
- Dated decisions

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Breaking changes must be logged

DEFINITION OF DONE:
- Decisions concise

ACCEPTANCE TESTS / VERIFICATION:
- N/A

FILES YOU MAY TOUCH:
- decision_log.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# decision_log.md — Key decisions

## 2025-12-20 — Supabase chosen (replacing Firebase)
**Why:** Postgres + RLS + Edge Functions fit cost controls and ownership rules cleanly.

## 2025-12-20 — Flutter client
**Why:** User requirement.

## 2025-12-20 — Deterministic numbers; LLM explains
**Why:** Trust and safety.

## 2025-12-20 — Server-side credits + idempotency
**Why:** Prevent bypass and double-charge.


## 2025-12-20 — Symbol universe locked (Top 30 crypto + Top 30 FX)
**Why:** Keep scope tight, reduce UI/backend complexity, and make tests reproducible.

## 2025-12-20 — Multi-provider routing (MVP)
- crypto -> Binance Spot klines
- fx -> Twelve Data time series
**Why:** Cover both categories with minimal provider count.
