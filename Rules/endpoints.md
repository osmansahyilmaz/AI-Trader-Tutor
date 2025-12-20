<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend agent

MISSION:
Implement Edge Function HTTP contracts stable for Flutter client consumption.

INPUTS YOU MAY USE:
- analysis_payload.md
- postgres_schema.md
- rate_limit.md
- idempotency.md

OUTPUTS YOU MUST PRODUCE:
- analyzeRequest
- getAnalysis
- optional listAnalyses

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Auth required
- Credits+idempotency transactional
- Never return secrets

DEFINITION OF DONE:
- Contracts implemented and stable

ACCEPTANCE TESTS / VERIFICATION:
- 200 success; 400 invalid; 401 unauthorized; 429 limit; 503 data provider

FILES YOU MAY TOUCH:
- supabase/functions/**
- endpoints.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# endpoints.md — API contract (Supabase Edge Functions)

## analyzeRequest
**POST** `/functions/v1/analyzeRequest`  
**Auth:** Required (Supabase JWT)

Request:
```json
{ "assetClass": "crypto", "symbol": "BTCUSDT", "timeframe": "1h", "requestId": "uuid" }
```

Response:
```json
{
  "analysisId": "uuid",
  "createdAt": "2025-12-20T12:00:00Z",
  "payload_version": "1.0",
  "analysis_payload": {},
  "explanation": { "summary": "", "indicators": [], "scenarios": [], "risk_note": "" }
}
```

Errors:
- 401 UNAUTHORIZED
- 400 INVALID_ARGUMENT
- 429 RESOURCE_EXHAUSTED
- 503 UNAVAILABLE

## getAnalysis
**GET** `/functions/v1/getAnalysis?id=<analysisId>`  
**Auth:** Required (RLS ensures ownership)

Response: same as analyzeRequest response.


---

## universe (optional but recommended)
**GET** `/functions/v1/universe`  
**Auth:** optional (MVP can be public), but rate limit if public.

Response: the contents of `symbol_universe.json`.

Notes:
- Flutter may also ship the universe locally.
- Backend MUST validate symbols against the same universe.
