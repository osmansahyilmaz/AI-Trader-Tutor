-- 20251220185000_transaction_rpc.sql

create or replace function public.process_request_transaction(
  p_user_id uuid,
  p_request_id text,
  p_daily_limit_override int default null -- optional override if needed later
)
returns jsonb
language plpgsql
security definer -- runs with owner privileges (bypasses RLS)
as $$
declare
  v_profile public.profiles%rowtype;
  v_request public.requests%rowtype;
  v_analysis public.analyses%rowtype;
  v_today date;
  v_limit int;
begin
  -- 1. Lock profile row for update
  select * into v_profile
  from public.profiles
  where user_id = p_user_id
  for update;

  if not found then
    raise exception 'Profile not found';
  end if;

  -- 2. Daily reset logic
  v_today := (now() at time zone 'Europe/Istanbul')::date;
  
  if v_profile.last_reset_date < v_today then
    v_profile.used_today := 0;
    v_profile.last_reset_date := v_today;
    
    update public.profiles
    set used_today = 0, last_reset_date = v_today
    where user_id = p_user_id;
  end if;

  -- 3. Idempotency check
  select * into v_request
  from public.requests
  where user_id = p_user_id and request_id = p_request_id;

  if found then
    if v_request.status = 'completed' then
      -- Fetch the completed analysis
      select * into v_analysis
      from public.analyses
      where id = v_request.analysis_id;
      
      return jsonb_build_object(
        'status', 'completed',
        'analysis_id', v_request.analysis_id,
        'analysis', row_to_json(v_analysis)
      );
    elsif v_request.status = 'started' then
      return jsonb_build_object(
        'status', 'in_progress'
      );
    else
      -- failed status, allow retry? For MVP, maybe treat as new attempt or return error
      -- Let's allow retry if failed
      null; 
    end if;
  end if;

  -- 4. Credit check
  v_limit := coalesce(p_daily_limit_override, v_profile.daily_limit);
  
  if v_profile.used_today >= v_limit then
    return jsonb_build_object(
      'status', 'limit_exceeded',
      'message', 'Daily limit reached'
    );
  end if;

  -- 5. Decrement credits (increment usage)
  update public.profiles
  set used_today = used_today + 1
  where user_id = p_user_id;

  -- 6. Insert request row (started)
  insert into public.requests (user_id, request_id, status)
  values (p_user_id, p_request_id, 'started');

  return jsonb_build_object(
    'status', 'authorized'
  );

exception when others then
  raise;
end;
$$;
