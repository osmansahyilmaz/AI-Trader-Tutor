# setup_checklist.md — What you need before coding

**Date:** 2025-12-20

## Supabase
- [ ] Create Supabase project
- [ ] Note: Project URL + anon key (for Flutter)
- [ ] Enable Auth provider(s) (Google recommended)
- [ ] Decide whether to use local Supabase CLI for dev

## Secrets (server-side only)
- [ ] OPENAI_API_KEY (Edge Functions secret)
- [ ] Market data provider key (if needed)

## Database
- [ ] Apply `postgres_schema.sql`
- [ ] Enable RLS + apply policies from `rls_policies.md`
- [ ] Confirm `profiles` row exists for new users (create strategy: trigger or first login)

## Flutter
- [ ] Add `supabase_flutter` and initialize
- [ ] Implement Auth flow + route guards
- [ ] Confirm NO service role key exists in client

## Safety
- [ ] Ensure UI uses allowed terms (see `copy_guidelines.md`)
- [ ] Ensure Result + Settings show disclaimers (see `compliance.md`)
