<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Design/Flutter agent

MISSION:
Define tokens and reusable components for consistent UI.

INPUTS YOU MAY USE:
- ui_screens.md
- copy_guidelines.md
- accessibility.md

OUTPUTS YOU MUST PRODUCE:
- Tokens + components + theme mapping

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Minimal MVP
- Trustworthy, educational look

DEFINITION OF DONE:
- Tokens + components defined

ACCEPTANCE TESTS / VERIFICATION:
- Visual consistency
- Tap targets and readability

FILES YOU MAY TOUCH:
- design_system.md
- lib/core/theme/**
- lib/core/widgets/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# design_system.md — Tokens + components (MVP)

Goals: calm, trustworthy, educational; readable for long text.

Tokens:
- Spacing: 8/16/24/32
- Radii: card 16, button 12, chip pill
- Typography: Title 20–22, Body 14–16, Caption 12–13
- Colors: Material 3 scheme; avoid aggressive neon.

Components:
- PrimaryButton, SecondaryButton
- AppCard / SectionCard
- InfoChip (timeframe, trend_state)
- HistoryListItem
- LoadingState, ErrorState
