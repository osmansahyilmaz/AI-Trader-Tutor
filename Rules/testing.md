<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
QA agent

MISSION:
Provide tests and E2E checklist for Supabase backend + Flutter client.

INPUTS YOU MAY USE:
- endpoints.md
- rate_limit.md
- response_validation.md
- rls_policies.md

OUTPUTS YOU MUST PRODUCE:
- Unit/integration tests plan + manual E2E

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Must test RLS ownership
- Must test credits/idempotency
- Must test validator fallback

DEFINITION OF DONE:
- MVP verifiable quickly

ACCEPTANCE TESTS / VERIFICATION:
- Manual E2E checklist passes

FILES YOU MAY TOUCH:
- testing.md
- tests/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# testing.md — Quality plan (Supabase + Flutter)

Backend:
- Unit tests: EMA/RSI/ATR, S/R determinism
- Integration: credits decrement once; idempotency; daily reset; validator fallback
- Security: RLS prevents cross-user reads

Flutter:
- Auth -> Home
- analyzeRequest -> Result shows 4 sections
- 429 shows limit reached
- History returns only own analyses

Manual E2E:
1) Sign in
2) Run analysis (Free) => success
3) Run again same day => blocked (429 UX)
4) Open History and verify item
5) Verify disclaimer visible on Result and Settings
