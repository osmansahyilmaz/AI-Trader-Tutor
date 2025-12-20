<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Ops agent

MISSION:
Instrument logging/metrics in Edge Functions for reliability and cost control.

INPUTS YOU MAY USE:
- endpoints.md
- response_validation.md

OUTPUTS YOU MUST PRODUCE:
- Log fields and metric suggestions

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Never log secrets
- Minimize PII

DEFINITION OF DONE:
- Each request has traceable log record

ACCEPTANCE TESTS / VERIFICATION:
- Spot-check logs

FILES YOU MAY TOUCH:
- observability.md
- supabase/functions/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# observability.md — Logging & monitoring

Log per analyzeRequest:
- traceId
- userId (hashed optional)
- symbol/timeframe
- cache_hit
- latency_ms
- validator_violation + retry_count
- error_code
- token usage (if available)

Track:
- requests/day
- failure rate
- p95 latency
- validator violation rate
- estimated cost per analysis
