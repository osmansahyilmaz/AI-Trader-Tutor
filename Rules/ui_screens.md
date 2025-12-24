<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Design/Flutter agent

MISSION:
Specify 5 MVP screens with buildable layout and states.

INPUTS YOU MAY USE:
- design_system.md
- copy_guidelines.md
- compliance.md
- endpoints.md

OUTPUTS YOU MUST PRODUCE:
- Screen specs and acceptance criteria

HARD CONSTRAINTS (NON-NEGOTIABLE):
- 5 screens only
- Disclaimers mandatory

DEFINITION OF DONE:
- Each screen has loading/empty/error states

ACCEPTANCE TESTS / VERIFICATION:
- Manual UI verification

FILES YOU MAY TOUCH:
- ui_screens.md
- lib/features/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# ui_screens.md — Screen specs (MVP)

Screens:
1) Auth (Tabs: Login / Register, Email+Password only)
2) Home (symbol/timeframe + Explain chart)
3) Result (4 sections + disclaimer footer)
4) History (list + details)
5) Settings (full disclaimer + sign out)

Result screen structure:
- Header (symbol/timeframe/time)
- Context card (trend_state chip)
- 4 section cards: Summary / Indicators / Scenarios / Risk note
- Footer disclaimer always visible
