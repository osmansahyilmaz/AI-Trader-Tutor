<!--
AGENT INSTRUCTIONS (READ FIRST)

ROLE:
DB/Security agent

MISSION:
Define and apply Row Level Security (RLS) policies to enforce ownership and prevent abuse.

INPUTS YOU MAY USE:
- postgres_schema.sql
- endpoints.md

OUTPUTS YOU MUST PRODUCE:
- RLS policies and explanation

HARD CONSTRAINTS (NON-NEGOTIABLE):
- User can only read own analyses
- Client should not write to protected tables
- Edge Functions use service role for privileged writes (recommended)

DEFINITION OF DONE:
- RLS enabled and policies applied
- Ownership enforced

ACCEPTANCE TESTS / VERIFICATION:
- User cannot read another user's rows
- Client cannot insert into analyses if blocked
- Edge function (service role) can insert

FILES YOU MAY TOUCH:
- rls_policies.md
- supabase SQL editor/migrations

STYLE:
- Prefer small, reviewable changes.
- If you must make assumptions, list them explicitly.
- Do not introduce new scope without documenting it in decision_log.md.
-->


# rls_policies.md — Row Level Security (RLS)

## Strategy
- Enable RLS on all tables.
- Allow users to read their own `profiles` and `analyses`.
- Prefer: **clients do not insert/update `analyses`, `requests`, `rate_limits`**.
  - Edge Functions perform these writes using the **service role** key or elevated privileges.

## Apply RLS (SQL)
```sql
alter table public.profiles enable row level security;
alter table public.analyses enable row level security;
alter table public.requests enable row level security;
alter table public.rate_limits enable row level security;
alter table public.ohlcv_cache enable row level security;
```

## Policies (SQL)

### profiles: user can read own row
```sql
create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = user_id);
```

(Optional) user can update own profile fields? MVP usually **NO** (server-controlled plan/limits):
```sql
create policy "profiles_update_own_denied"
on public.profiles for update
using (false);
```

### analyses: user can select own
```sql
create policy "analyses_select_own"
on public.analyses for select
using (auth.uid() = user_id);
```

Deny client insert/update/delete (server only):
```sql
create policy "analyses_write_denied"
on public.analyses for all
using (false);
```

### requests: deny client reads/writes (server only)
```sql
create policy "requests_select_denied"
on public.requests for select
using (false);

create policy "requests_write_denied"
on public.requests for all
using (false);
```

### rate_limits: deny client reads/writes (server only)
```sql
create policy "rate_limits_select_denied"
on public.rate_limits for select
using (false);

create policy "rate_limits_write_denied"
on public.rate_limits for all
using (false);
```

### ohlcv_cache: deny client reads/writes (server only)
```sql
create policy "ohlcv_cache_select_denied"
on public.ohlcv_cache for select
using (false);

create policy "ohlcv_cache_write_denied"
on public.ohlcv_cache for all
using (false);
```

## Notes
- In production, Edge Functions should use the **service role** key (server-side only) to bypass restrictive client RLS for writes.
- Clients will still be able to read their analyses via RLS `select` policy.
