-- postgres_schema.sql — Supabase schema for Trader AI Tutor (MVP)

-- Extensions
create extension if not exists "uuid-ossp";

-- Profiles: plan + daily limits
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan text not null default 'free' check (plan in ('free','pro','plus')),
  daily_limit int not null default 1,
  used_today int not null default 0,
  last_reset_date date not null default (now() at time zone 'Europe/Istanbul')::date,
  created_at timestamptz not null default now()
);

-- Analyses: saved results
create table if not exists public.analyses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  symbol text not null,
  timeframe text not null,
  payload_version text not null default '1.0',
  analysis_payload jsonb not null,
  explanation jsonb not null,
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists analyses_user_created_idx
  on public.analyses(user_id, created_at desc);

create index if not exists analyses_user_symbol_tf_created_idx
  on public.analyses(user_id, symbol, timeframe, created_at desc);

-- Idempotency requests
create table if not exists public.requests (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id text not null,
  analysis_id uuid references public.analyses(id) on delete set null,
  status text not null default 'started' check (status in ('started','completed','failed')),
  error_code text,
  created_at timestamptz not null default now(),
  unique(user_id, request_id)
);

-- Rate limits (optional)
create table if not exists public.rate_limits (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  day date not null,
  window_start timestamptz not null,
  count int not null default 0
);

create index if not exists rate_limits_user_day_idx
  on public.rate_limits(user_id, day);

-- Optional OHLCV cache
create table if not exists public.ohlcv_cache (
  id uuid primary key default uuid_generate_v4(),
  symbol text not null,
  timeframe text not null,
  candles jsonb not null,
  fetched_at timestamptz not null default now(),
  unique(symbol, timeframe)
);

-- RLS POLICIES (from rls_policies.md)

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.analyses enable row level security;
alter table public.requests enable row level security;
alter table public.rate_limits enable row level security;
alter table public.ohlcv_cache enable row level security;

-- Policies

-- profiles: user can read own row
create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = user_id);

-- profiles: deny update (server only)
create policy "profiles_update_own_denied"
on public.profiles for update
using (false);

-- analyses: user can select own
create policy "analyses_select_own"
on public.analyses for select
using (auth.uid() = user_id);

-- analyses: deny client insert/update/delete (server only)
create policy "analyses_write_denied"
on public.analyses for all
using (false);

-- requests: deny client reads/writes (server only)
create policy "requests_select_denied"
on public.requests for select
using (false);

create policy "requests_write_denied"
on public.requests for all
using (false);

-- rate_limits: deny client reads/writes (server only)
create policy "rate_limits_select_denied"
on public.rate_limits for select
using (false);

create policy "rate_limits_write_denied"
on public.rate_limits for all
using (false);

-- ohlcv_cache: deny client reads/writes (server only)
create policy "ohlcv_cache_select_denied"
on public.ohlcv_cache for select
using (false);

create policy "ohlcv_cache_write_denied"
on public.ohlcv_cache for all
using (false);
