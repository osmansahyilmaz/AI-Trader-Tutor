<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend math agent

MISSION:
Implement deterministic EMA/RSI/ATR + trend + structure computations.

INPUTS YOU MAY USE:
- analysis_payload.md
- support_resistance.md

OUTPUTS YOU MUST PRODUCE:
- Deterministic engine functions + tests

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Deterministic output
- Handle insufficient data gracefully

DEFINITION OF DONE:
- Matches payload schema
- Unit tests pass

ACCEPTANCE TESTS / VERIFICATION:
- Known-series tests
- Edge cases

FILES YOU MAY TOUCH:
- supabase/functions/**
- indicator_engine.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# indicator_engine.md — Deterministic indicator engine

## Required outputs
- current_price
- ema20/50/200 (standard EMA)
- rsi14 (Wilder)
- atr14 (Wilder) + atr_percent
- trend_state (bullish/bearish/sideways)
- structure state from pivot sequence

## Trend_state (MVP)
- bullish: ema20 > ema50 > ema200
- bearish: ema20 < ema50 < ema200
- sideways: otherwise
