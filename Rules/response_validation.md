<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Backend + AI safety agent

MISSION:
Validate LLM output; block invented levels; retry once or fallback.

INPUTS YOU MAY USE:
- analysis_payload.md
- llm_prompting.md

OUTPUTS YOU MUST PRODUCE:
- Validator spec

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Never show invented numbers
- Retry at most once
- Fallback must be safe and educational

DEFINITION OF DONE:
- Validator prevents hallucinated levels reaching client

ACCEPTANCE TESTS / VERIFICATION:
- Forced hallucination blocked
- OpenAI failure triggers fallback

FILES YOU MAY TOUCH:
- response_validation.md
- supabase/functions/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# response_validation.md — Anti-hallucination

Allowlist numbers:
- current_price
- ema20/50/200
- levels[].price
(Optional) rsi/atr numbers if allowed (not levels)

Enforcement:
- Extract price-like numbers from output
- If any number not in allowlist (tolerance): retry once
- If still invalid: fallback to deterministic summary + risk note
