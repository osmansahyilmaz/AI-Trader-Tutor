<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Design/QA agent

MISSION:
Ensure basic accessibility.

INPUTS YOU MAY USE:
- design_system.md
- ui_screens.md

OUTPUTS YOU MUST PRODUCE:
- A11y checklist

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Tap targets >= 48dp
- Readable text

DEFINITION OF DONE:
- MVP passes basic a11y checks

ACCEPTANCE TESTS / VERIFICATION:
- Labels exist; contrast reasonable; buttons accessible

FILES YOU MAY TOUCH:
- accessibility.md
- Flutter widgets

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# accessibility.md — MVP checklist
- Tap targets >= 48dp
- Body text >= 14
- Semantic labels for main buttons
- Error messages accessible
- Dark mode readability
