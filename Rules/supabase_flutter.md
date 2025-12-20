<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
Flutter agent

MISSION:
Integrate Supabase Auth + Edge Functions + RLS-based reads into the Flutter app.

INPUTS YOU MAY USE:
- endpoints.md
- postgres_schema.md
- rls_policies.md
- ui_screens.md

OUTPUTS YOU MUST PRODUCE:
- Supabase client setup
- Auth flow
- Edge Function calls
- History reads via Postgres with RLS

HARD CONSTRAINTS (NON-NEGOTIABLE):
- No service role key in client
- Use anon key only
- Handle session refresh
- Friendly error handling

DEFINITION OF DONE:
- Sign-in works
- analyzeRequest works
- history query works via RLS

ACCEPTANCE TESTS / VERIFICATION:
- Sign in/out
- Call analyzeRequest with token
- Query analyses returns only own rows

FILES YOU MAY TOUCH:
- supabase_flutter.md
- lib/**
- pubspec.yaml

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# supabase_flutter.md — Flutter integration notes

## Packages
- `supabase_flutter`

## Initialization
- Store Supabase URL + anon key in app config (NOT secrets; anon key is ok).
- Initialize Supabase in `main()` before runApp.

## Auth (Google)
- Use Supabase Auth providers.
- Listen to auth state changes to guard routes.

## Calling Edge Functions
- Use `supabase.functions.invoke('analyzeRequest', body: {...})`
- Ensure session token is attached automatically by the client.

Handle errors:
- 401 -> re-auth
- 429 -> show daily limit dialog
- 503 -> show data provider unavailable message

## History reads (RLS)
- Query `analyses` table with `supabase.from('analyses').select().order('created_at', descending: true)`
- RLS ensures user sees only their rows.
