<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
All agents

MISSION:
Use this checklist for every PR/patch.

INPUTS YOU MAY USE:
- compliance.md
- rls_policies.md
- response_validation.md

OUTPUTS YOU MUST PRODUCE:
- Completed checklist

HARD CONSTRAINTS (NON-NEGOTIABLE):
- Do not weaken safety/security without logging decision

DEFINITION OF DONE:
- Checklist filled and tests pass

ACCEPTANCE TESTS / VERIFICATION:
- Verify checkboxes

FILES YOU MAY TOUCH:
- pr_checklist.md

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# pr_checklist.md — Copy/paste into PR description

## Functional
- [ ] Endpoint contract stable (or docs updated)
- [ ] Credits/rate limits enforced server-side (transaction)
- [ ] Idempotency prevents double charge
- [ ] Deterministic engine stable

## Safety
- [ ] No buy/sell language introduced (UI or prompts)
- [ ] LLM constrained to payload numbers
- [ ] Validator blocks invented levels (retry/fallback)

## Security
- [ ] RLS enabled and correct policies applied
- [ ] User can only read own analyses
- [ ] No service role key shipped to client
- [ ] No secrets logged

## Quality
- [ ] Unit/integration tests updated
- [ ] Manual E2E checklist updated if needed
- [ ] UI follows design tokens
