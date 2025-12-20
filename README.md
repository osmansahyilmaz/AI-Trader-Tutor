<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
All agents

MISSION:
Build Trader AI Tutor MVP using Flutter + Supabase (Postgres + Auth + Edge Functions) with strict safety and determinism.

INPUTS YOU MAY USE:
- The Markdown docs in this pack
- Supabase project (URL + anon key)
- Edge Functions environment variables (OpenAI key, data provider keys)
- Market data provider docs
- Flutter/Supabase SDK docs

OUTPUTS YOU MUST PRODUCE:
- Working MVP: Flutter client + Supabase backend
- Deterministic analysis payload + tutor explanations
- RLS policies + secure DB
- Server-side cost controls (credits + rate limits + idempotency)
- Tests + logs
- UI design system + screen specs

HARD CONSTRAINTS (NON-NEGOTIABLE):
- No buy/sell signals
- No trade execution
- LLM must not invent numbers or levels
- Credits and rate limits MUST be server-side
- Secrets server-side only
- Educational tone only

DEFINITION OF DONE:
- MVP demo works end-to-end
- Free plan daily limit enforced
- User can only read own analyses (RLS)
- Deterministic engine unit-tested
- LLM responses validated or safely fall back
- Flutter UI matches design specs

ACCEPTANCE TESTS / VERIFICATION:
- Local Supabase + edge functions run (or deployed)
- Manual E2E checklist passes
- Validator flags invented levels and falls back

FILES YOU MAY TOUCH:
- Any .md and .sql in this pack
- supabase/migrations/** (if used)
- supabase/functions/** (if used)
- Flutter lib/**

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# Trader AI Tutor — Agent-Ready Docs Pack (Supabase Edition)

**Owner:** Osman Şah  
**Pack version: v5.4
Doc version:** 5.0 (Agent-ready + Design + Flutter + Supabase)  
**Date:** 2025-12-20

This pack is optimized for AI agents to implement the MVP with strict safety + determinism.

## Start here
1) `phases.md`
2) `backlog.md`
3) `architecture.md`
4) Backend contracts: `edge_functions.md`, `endpoints.md`, `analysis_payload.md`
5) Database & security: `postgres_schema.md`, `postgres_schema.sql`, `rls_policies.md`
6) Cost controls: `rate_limit.md`, `idempotency.md`
7) Engine: `indicator_engine.md`, `support_resistance.md`
8) AI: `llm_prompting.md`, `response_validation.md`
9) Flutter: `supabase_flutter.md`, `flutter_architecture.md`, `navigation.md`
10) Design: `design_system.md`, `ui_screens.md`, `copy_guidelines.md`, `accessibility.md`
11) QA/Ops: `testing.md`, `observability.md`

## Non-goals (MVP)
- Brokerage / exchange execution
- Personalized investment advice
- “Signals” or guaranteed outcomes


## Universe + Providers (MVP)
- symbol_universe.json / symbol_universe.md
- market_categories.md
- data_providers.md
- mvp_backlog.md


## Repository hygiene
- `.gitignore` included for Flutter + Supabase projects.
