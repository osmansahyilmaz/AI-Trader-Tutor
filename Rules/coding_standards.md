<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
All agents

MISSION:
Keep code consistent, testable, and safe (Edge Functions + Flutter).

INPUTS YOU MAY USE:
- repo code
- docs pack

OUTPUTS YOU MUST PRODUCE:
- consistent code changes

HARD CONSTRAINTS (NON-NEGOTIABLE):
- No service role key in client
- Transactional credits
- Deterministic computations

DEFINITION OF DONE:
- Lint/test pass; manual checklist pass

ACCEPTANCE TESTS / VERIFICATION:
- Lint/test

FILES YOU MAY TOUCH:
- coding_standards.md
- codebase

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# coding_standards.md — Conventions

Edge Functions:
- Validate inputs
- Use transactions for credits/idempotency
- Structured logs (traceId, latency, error_code)
- Secrets server-side only

Flutter:
- Feature-first folders
- Immutable models with fromJson/toJson
- Centralize theme/tokens
