-- Run this file once in Supabase SQL Editor if you already created the tables.
alter table public.questions add column if not exists media_url text;
alter table public.questions add column if not exists media_type text;

insert into storage.buckets (id, name, public)
values ('assessment-media', 'assessment-media', true)
on conflict (id) do nothing;

drop policy if exists "admins upload question media" on storage.objects;
create policy "admins upload question media" on storage.objects for insert to authenticated
  with check (bucket_id = 'assessment-media' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "admins delete question media" on storage.objects;
create policy "admins delete question media" on storage.objects for delete to authenticated
  using (bucket_id = 'assessment-media' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
