<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
LLM agent

MISSION:
Generate Turkish tutor explanations using only deterministic payload numbers.

INPUTS YOU MAY USE:
- analysis_payload.md
- copy_guidelines.md
- compliance.md

OUTPUTS YOU MUST PRODUCE:
- Prompt template + formatting rules

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Use ONLY payload numbers
- No new levels
- No advice/signals
- Always include risk note

DEFINITION OF DONE:
- Exactly 4 sections
- Educational tone

ACCEPTANCE TESTS / VERIFICATION:
- Output avoids forbidden phrases
- No invented numbers

FILES YOU MAY TOUCH:
- llm_prompting.md
- supabase/functions/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# llm_prompting.md — Tutor prompt (Turkish) & response format

Hard constraints:
- Use ONLY numbers from `analysis_payload`.
- Do NOT output any additional price levels.
- Do NOT give financial advice.
- Avoid “buy/sell”, “guaranteed”, “will go to X”.
- Always include a short risk disclaimer.

Format (exactly 4 sections):
1) Summary
2) Indicators
3) Scenarios (if/then)
4) Risk note
