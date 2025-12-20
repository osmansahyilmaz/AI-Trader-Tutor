<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend + Flutter agent

MISSION:
Maintain deterministic JSON contract used by backend, validator, and Flutter models.

INPUTS YOU MAY USE:
- indicator_engine.md
- support_resistance.md

OUTPUTS YOU MUST PRODUCE:
- Stable schema + example

HARD CONSTRAINTS (NON-NEGOTIABLE):
- LLM uses ONLY these numbers
- Bump payload_version on breaking change

DEFINITION OF DONE:
- Schema complete and consistent

ACCEPTANCE TESTS / VERIFICATION:
- Validator allowlist uses schema
- Flutter parses JSON

FILES YOU MAY TOUCH:
- analysis_payload.md
- response_validation.md
- lib/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# analysis_payload.md — Deterministic JSON contract (payload_version: 1.0)

## Required fields
- `payload_version`: "1.0"
- `symbol`, `timeframe`
- `timestamp` (unix seconds)
- `current_price` (number)

### Indicators
- `ema`: { `ema20`, `ema50`, `ema200` }
- `trend_state`: "bullish" | "bearish" | "sideways"
- `rsi`: { `value`, `state`: "oversold"|"neutral"|"overbought" }
- `atr`: { `value`, `percent` }

### Structure
- `structure`: {
  `state`: "uptrend"|"downtrend"|"range"|"mixed",
  `recent_pivots`: [{ "type":"high"|"low", "price": number, "t": unixSeconds }]
}

### Levels
- `levels`: [{ "type":"support"|"resistance", "price": number, "distance_percent": number, "touches": number }]
