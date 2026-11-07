-- DEMO ONLY: run against a throwaway Supabase project.
-- Reproduces Auth 500s when an email signup omits optional display_name metadata.

create table if not exists public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- BUG: display_name is optional in signup metadata, but profiles.display_name
  -- is NOT NULL and this trigger passes NULL through unchanged.
  insert into public.profiles (user_id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'display_name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_demo on auth.users;
create trigger on_auth_user_created_demo
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Verify the fixture exists before testing signup.
select trigger_name, event_manipulation, action_timing
from information_schema.triggers
where event_object_schema = 'auth'
  and event_object_table = 'users'
  and trigger_name = 'on_auth_user_created_demo';

-- CLEANUP after recording (run separately, after deleting test users):
-- drop trigger if exists on_auth_user_created_demo on auth.users;
-- drop function if exists public.handle_new_user();
-- drop table if exists public.profiles;
