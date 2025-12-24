-- Create a trigger function to create a profile for new users
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (user_id, plan, daily_limit, used_today)
  values (new.id, 'free', 1, 0);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
-- Drop if exists to be safe
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
