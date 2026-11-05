-- Run in the Supabase SQL Editor for the private-study project.
-- The FastAPI backend uses its server-only service role key. Never put that key
-- in frontend code or expose it to browsers.

create table if not exists public.study_state (
  owner_id uuid primary key,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.study_backups (
  owner_id uuid not null,
  name text not null,
  state jsonb not null,
  created_at timestamptz not null default now(),
  primary key (owner_id, name)
);

create table if not exists public.study_secure_settings (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  encrypted_settings text not null,
  updated_at timestamptz not null default now()
);

alter table public.study_state enable row level security;
alter table public.study_backups enable row level security;
alter table public.study_secure_settings enable row level security;
grant all on public.study_state to service_role;
grant all on public.study_backups to service_role;
grant all on public.study_secure_settings to service_role;

-- Intentionally define no anon/authenticated policies: browser clients cannot
-- directly read or mutate personal records. Only the authenticated backend's
-- service role accesses these tables, after checking the single owner account.

insert into storage.buckets (id, name, public, file_size_limit)
values ('study-files', 'study-files', false, 26214400)
on conflict (id) do update set public = false, file_size_limit = 26214400;

-- Do not add storage.objects policies for anon/authenticated. The backend uses
-- its service role to write, and all objects are scoped under STUDY_OWNER_ID/.
