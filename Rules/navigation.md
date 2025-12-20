<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Flutter agent

MISSION:
Define routes and auth guards for the 5-screen MVP.

INPUTS YOU MAY USE:
- ui_screens.md
- supabase_flutter.md

OUTPUTS YOU MUST PRODUCE:
- Route map + guard rules

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Auth-gated routes
- Simple

DEFINITION OF DONE:
- Navigation works; unauth -> auth screen

ACCEPTANCE TESTS / VERIFICATION:
- Login redirects to Home; logout returns to Auth

FILES YOU MAY TOUCH:
- navigation.md
- lib/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# navigation.md — Route map (MVP)

Routes:
- /auth
- /home
- /result/:analysisId
- /history
- /settings

Guard:
- If no session -> /auth
- After sign-in -> /home
