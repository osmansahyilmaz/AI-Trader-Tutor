# local_dev.md — Local development notes (Supabase + Flutter)

**Date:** 2025-12-20

## Option A: Use deployed Supabase (simplest)
- Develop Flutter against the hosted project.
- Deploy Edge Functions to the hosted project.

## Option B: Local Supabase (recommended if agent supports it)
1) Install Supabase CLI
2) `supabase start`
3) Apply SQL migrations (or run `postgres_schema.sql`)
4) Serve Edge Functions:
   - `supabase functions serve analyzeRequest`
   - `supabase functions serve getAnalysis`

Notes:
- In local mode you may disable JWT verification for convenience. In production it MUST be enabled.
- Keep parity between local and prod schema/policies.
