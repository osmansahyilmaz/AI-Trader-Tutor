<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend math agent

MISSION:
Compute support/resistance levels deterministically (pivots + clustering).

INPUTS YOU MAY USE:
- indicator_engine.md
- analysis_payload.md

OUTPUTS YOU MUST PRODUCE:
- levels[] output

HARD CONSTRAINTS (NON-NEGOTIABLE):
- No LLM
- Deterministic
- Limit to 2–5 levels

DEFINITION OF DONE:
- Stable outputs
- Sanity checks pass

ACCEPTANCE TESTS / VERIFICATION:
- Determinism test
- Supports below price, resistances above (when possible)

FILES YOU MAY TOUCH:
- supabase/functions/**
- support_resistance.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# support_resistance.md — Pivot levels + clustering

1) Generate pivot highs/lows candidates  
2) Cluster by threshold (percent or ATR-based)  
3) Rank by touches + recency  
4) Select 2 supports + 2 resistances near current price (max 5)
