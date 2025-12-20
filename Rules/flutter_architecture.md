<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Flutter agent

MISSION:
Define Flutter app structure, state management, models, and repository boundaries.

INPUTS YOU MAY USE:
- supabase_flutter.md
- analysis_payload.md
- design_system.md

OUTPUTS YOU MUST PRODUCE:
- Folder structure + models + repositories plan

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Keep MVP simple
- No business logic in widgets

DEFINITION OF DONE:
- Clear separation of layers
- Robust JSON parsing

ACCEPTANCE TESTS / VERIFICATION:
- Parsing unit test (optional)
- Widget smoke test (optional)

FILES YOU MAY TOUCH:
- flutter_architecture.md
- lib/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# flutter_architecture.md — Recommended structure (MVP)

Use feature-first structure:
lib/
  core/ (theme, widgets, utils)
  features/
    auth/
    analysis/
    history/
    settings/

Recommended state management:
- Riverpod OR Bloc (choose one and log in decision_log.md)

Repository:
- AnalysisRepository:
  - analyzeRequest(symbol, timeframe, requestId) via Edge Function
  - getAnalysis(id)
  - listAnalyses() via RLS select
