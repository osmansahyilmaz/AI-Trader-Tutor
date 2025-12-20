# docs_map.md — What each file is for (Supabase + Flutter pack)

**Owner:** Osman Şah  
**Pack version:** v5.1  
**Date:** 2025-12-20

This file is meant for an AI coding agent. It explains what each document does and when to read it.

## How to use this pack
1) Start with `workplan.md` (the task tree).
2) For each task, follow the referenced docs exactly.
3) Keep contracts stable: `analysis_payload.md` and `endpoints.md`.
4) If you need to change any contract, log it in `decision_log.md`.

## Document map
- `README.md` — Pack overview + scope boundaries.
- `accessibility.md` — Basic a11y checklist (tap targets, semantics, contrast).
- `ai_agents.md` — Suggested agent roles and coordination rules.
- `analysis_payload.md` — Deterministic JSON schema; single source of truth for numbers the LLM can reference.
- `architecture.md` — End-to-end system flow and responsibilities.
- `coding_standards.md` — Conventions for Edge Functions + Flutter.
- `compliance.md` — Safety boundaries + mandatory disclaimers.
- `copy_guidelines.md` — Allowed vs forbidden language; sample UI labels; keeps educational positioning.
- `decision_log.md` — Record non-trivial decisions and contract changes.
- `design_system.md` — UI tokens + reusable components; map to Flutter Theme/widgets.
- `edge_functions.md` — Edge Functions list, auth verification, env vars, local dev guidance.
- `endpoints.md` — HTTP contracts for Edge Functions used by Flutter.
- `flutter_architecture.md` — Recommended Flutter folder structure, layers, state management boundary.
- `idempotency.md` — requestId behavior to prevent double-charges/duplicates.
- `indicator_engine.md` — Deterministic indicator computation requirements.
- `llm_prompting.md` — Tutor prompt format and constraints (no invented numbers, no advice).
- `master_agent_prompt.md` — Short master prompt placeholder (use mega_prompt.md instead).
- `navigation.md` — Routes and auth guards for 5 screens.
- `observability.md` — Logging fields and metrics to track cost/reliability.
- `phases.md` — Milestones and exit criteria; use to structure delivery.
- `postgres_schema.md` — DB design explanation; tables and indexes.
- `pr_checklist.md` — Checklist to paste into every PR.
- `rate_limit.md` — Server-side daily credits + reset + transaction patterns.
- `response_validation.md` — Validator rules + retry/fallback when LLM invents levels.
- `rls_policies.md` — Row Level Security policies; how to lock data per-user and restrict client writes.
- `supabase_flutter.md` — Flutter integration: auth, invoking edge functions, history reads via RLS.
- `support_resistance.md` — Deterministic S/R calculation requirements.
- `testing.md` — Unit/integration test plan + manual E2E checklist.
- `ui_screens.md` — Exact layout and states for Auth/Home/Result/History/Settings.
- `postgres_schema.sql` — Apply this SQL to create tables/indexes.

- `pr_sequence.md` — Recommended PR order (same as workplan’s PR sequence).
- `setup_checklist.md` — Prerequisites checklist (Supabase, secrets, DB, Flutter, safety).
- `local_dev.md` — Local development options and notes.

- `symbol_universe.json` — Single source of truth for allowed symbols (Top 30 crypto + Top 30 FX).
- `symbol_universe.md` — Human-readable universe and change rules.
- `market_categories.md` — Asset class taxonomy + routing logic.
- `data_providers.md` — Provider adapters + candle normalization + caching TTL.
- `mvp_backlog.md` — Ticket-style technical backlog (end-to-end).
