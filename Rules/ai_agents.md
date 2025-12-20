<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
All agents

MISSION:
Coordinate roles across backend (Edge), DB (RLS), Flutter, QA, design/copy.

INPUTS YOU MAY USE:
- docs pack
- repo

OUTPUTS YOU MUST PRODUCE:
- consistent implementation

HARD CONSTRAINTS (NON-NEGOTIABLE):
- no contract drift

DEFINITION OF DONE:
- agents can work independently

ACCEPTANCE TESTS / VERIFICATION:
- PR checklist used

FILES YOU MAY TOUCH:
- ai_agents.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# ai_agents.md — Agent roles (Supabase)

- Backend Agent: Edge Functions (analyzeRequest/getAnalysis), market data, OpenAI, validator
- DB/Security Agent: Postgres schema, RLS policies, indexes
- Flutter Agent: Auth, screens, Edge calls, history reads via RLS
- QA Agent: tests + E2E
- Design/Copy Agent: design system + safe copy
