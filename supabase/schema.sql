-- Run this file in the Supabase SQL Editor before deploying.
create table public.tests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  duration_minutes integer not null check (duration_minutes > 0),
  pass_percentage numeric not null check (pass_percentage between 0 and 100),
  marks_per_question numeric not null default 1 check (marks_per_question >= 0),
  negative_marking boolean not null default false,
  negative_marks numeric not null default 0 check (negative_marks >= 0),
  active boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index one_active_test on public.tests ((active)) where active;

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  prompt text not null,
  options jsonb not null check (jsonb_array_length(options) = 4),
  answer integer not null check (answer between 0 and 3),
  position integer not null default 0
);

create table public.attempts (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  candidate_name text not null,
  candidate_email text not null,
  score numeric not null,
  percentage numeric not null,
  passed boolean not null,
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.tests enable row level security;
alter table public.questions enable row level security;
alter table public.attempts enable row level security;

-- Public candidates can read only the active assessment and save their attempt.
create policy "read active tests" on public.tests for select using (active = true);
create policy "read questions for active tests" on public.questions for select using (exists (select 1 from public.tests where tests.id = questions.test_id and tests.active));
create policy "create attempts" on public.attempts for insert with check (true);

-- Admin setup: create an Auth user in Authentication > Users, then set an
-- `app_metadata.role` value of `admin` with the Supabase dashboard or Admin API.
-- The application uses only the anonymous key; never put a service-role key
-- in Netlify variables.
create policy "admins manage tests" on public.tests for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
create policy "admins manage questions" on public.questions for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
create policy "admins read attempts" on public.attempts for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
create policy "admins delete attempts" on public.attempts for delete to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
