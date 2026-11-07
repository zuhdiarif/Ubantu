-- Ubantu Database Schema Migration
-- Migration: 20261106000000_ubantu_full_schema.sql

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- 1. Profiles Table
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text not null default '',
  email text not null default '',
  phone_number text not null default '',
  nim text not null default '',
  ktm_photo_url text,
  avatar_url text,
  verification_status text not null default 'unverified',
  role text not null default 'customer',
  gender text not null default 'unspecified',
  is_female_only_preferred boolean not null default false,
  reward_points integer not null default 0,
  faculty text,
  bio text,
  email_otp_skipped boolean not null default false,
  is_online boolean not null default true,
  mitra_categories text[] default '{}',
  mitra_vehicle_type text,
  mitra_vehicle_plate text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

-- 2. Service Orders Table
create table if not exists public.service_orders (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid references public.profiles(id) on delete set null,
  requester_name text,
  helper_id uuid references public.profiles(id) on delete set null,
  helper_name text,
  category text not null,
  status text not null default 'waiting',
  location_origin text not null default '',
  location_destination text not null default '',
  scheduled_at timestamptz not null default now(),
  item_description text not null default '',
  barter_type text not null default 'makanan',
  barter_description text not null default '',
  barter_photo_url text,
  vehicle_type text,
  weight_kg numeric(8,2),
  is_female_only boolean not null default false,
  receiver_name text,
  receiver_phone text,
  completion_photo_url text,
  completed_at timestamptz,
  barter_confirmed_by_customer boolean not null default false,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now()),
  constraint service_orders_no_self_accept check (helper_id is null or helper_id <> requester_id)
);

-- 3. Tasks Table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  requester_name text not null default '',
  rating numeric(3,2) not null default 0.0,
  rating_count integer not null default 0,
  category text not null default 'bersihKos',
  location text not null default '',
  date text not null default '',
  time text not null default '',
  notes text not null default '',
  status text not null default 'pending',
  is_female_only boolean not null default false,
  is_emergency boolean not null default false,
  reward_points integer not null default 10,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);
-- 4. SOS Reports Table
create table if not exists public.sos_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  reporter_id uuid references public.profiles(id) on delete set null,
  issue_type text not null default '',
  status text not null default 'received',
  latitude numeric(10,7),
  longitude numeric(10,7),
  notes text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

-- 5. Chat Rooms Table
create table if not exists public.chat_rooms (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.service_orders(id) on delete set null,
  customer_id uuid references public.profiles(id) on delete cascade,
  helper_id uuid references public.profiles(id) on delete set null,
  order_number text,
  service_title text not null default 'Bantuan Ubantu',
  service_status text not null default 'in_progress',
  item_summary text default '',
  pickup_location text default '',
  destination_location text default '',
  total_price text,
  last_message text not null default '',
  last_message_time timestamptz not null default now(),
  unread_count integer not null default 0,
  other_user_name text,
  other_user_faculty text,
  is_active boolean not null default true,
  closed_at timestamptz,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

-- 6. Chat Messages Table
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references public.chat_rooms(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete set null not null,
  sender_name text not null default 'User',
  message text not null default '',
  attachment_url text,
  is_read boolean not null default false,
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- 7. Notifications Table
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  title text not null,
  body text not null,
  type text not null default 'order',
  payload jsonb default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- 8. Ratings Table
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  order_id text,
  task_id text,
  target_user_id uuid references public.profiles(id) on delete cascade not null,
  reviewer_id uuid references public.profiles(id) on delete set null,
  reviewer_name text not null default 'Mahasiswa UB',
  score numeric(2,1) not null default 5.0,
  review_text text not null default '',
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- 9. Loyalty Points & Transactions Tables
create table if not exists public.loyalty_points (
  user_id uuid references public.profiles(id) on delete cascade primary key,
  total_points integer not null default 0,
  available_vouchers integer not null default 0,
  claimed_voucher_codes text[] default '{}',
  updated_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.loyalty_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  points_change integer not null,
  transaction_type text not null,
  description text,
  voucher_code text,
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- 10. Mitra Schedules & Student Schedules Tables
create table if not exists public.mitra_schedules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  day_of_week integer not null,
  course_name text not null default '',
  room text not null default '',
  start_time text not null,
  end_time text not null,
  is_busy boolean not null default true,
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.student_schedules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  day_of_week integer not null,
  course_name text not null default '',
  room text not null default '',
  start_time text not null,
  end_time text not null,
  is_busy boolean not null default true,
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.schedules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  service_category text not null,
  scheduled_time timestamptz not null,
  status text not null default 'scheduled',
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- 11. Mitra Declined Orders Table
create table if not exists public.mitra_declined_orders (
  id uuid primary key default gen_random_uuid(),
  mitra_id uuid references public.profiles(id) on delete cascade not null,
  order_id uuid references public.service_orders(id) on delete cascade not null,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (mitra_id, order_id)
);

-- 12. Indexes
create index if not exists idx_profiles_nim on public.profiles(nim);
create index if not exists idx_profiles_role on public.profiles(role);
create index if not exists idx_service_orders_requester on public.service_orders(requester_id);
create index if not exists idx_service_orders_helper on public.service_orders(helper_id);
create index if not exists idx_service_orders_status on public.service_orders(status);
create index if not exists idx_service_orders_created_at on public.service_orders(created_at desc);
create index if not exists idx_tasks_status on public.tasks(status);
create index if not exists idx_sos_reports_user on public.sos_reports(user_id);
create index if not exists idx_chat_rooms_customer on public.chat_rooms(customer_id);
create index if not exists idx_chat_rooms_helper on public.chat_rooms(helper_id);
create index if not exists idx_chat_rooms_order on public.chat_rooms(order_id);
create index if not exists idx_chat_messages_room on public.chat_messages(room_id);
create index if not exists idx_chat_messages_created_at on public.chat_messages(created_at asc);
create index if not exists idx_notifications_user on public.notifications(user_id);
create index if not exists idx_ratings_target on public.ratings(target_user_id);
create index if not exists idx_loyalty_transactions_user on public.loyalty_transactions(user_id);
create index if not exists idx_mitra_schedules_user on public.mitra_schedules(user_id);
create index if not exists idx_student_schedules_user on public.student_schedules(user_id);
create index if not exists idx_mitra_declined_orders on public.mitra_declined_orders(mitra_id, order_id);

-- 13. Row Level Security
alter table public.profiles enable row level security;
alter table public.service_orders enable row level security;
alter table public.tasks enable row level security;
alter table public.sos_reports enable row level security;
alter table public.chat_rooms enable row level security;
alter table public.chat_messages enable row level security;
alter table public.notifications enable row level security;
alter table public.ratings enable row level security;
alter table public.loyalty_points enable row level security;
alter table public.loyalty_transactions enable row level security;
alter table public.mitra_schedules enable row level security;
alter table public.student_schedules enable row level security;
alter table public.schedules enable row level security;
alter table public.mitra_declined_orders enable row level security;

-- 14. RLS Policies
drop policy if exists "Profiles read access" on public.profiles;
create policy "Profiles read access" on public.profiles for select using (true);

drop policy if exists "Profiles insert own" on public.profiles;
create policy "Profiles insert own" on public.profiles for insert with check (auth.uid() = id);

drop policy if exists "Profiles update own" on public.profiles;
create policy "Profiles update own" on public.profiles for update using (auth.uid() = id);

drop policy if exists "Service orders select" on public.service_orders;
create policy "Service orders select" on public.service_orders for select using (
  status = 'waiting' or requester_id = auth.uid() or helper_id = auth.uid()
);

drop policy if exists "Service orders insert" on public.service_orders;
create policy "Service orders insert" on public.service_orders for insert with check (
  requester_id = auth.uid()
);

drop policy if exists "Service orders update" on public.service_orders;
create policy "Service orders update" on public.service_orders for update using (
  requester_id = auth.uid() or helper_id = auth.uid() or status = 'waiting'
);

drop policy if exists "Tasks select all" on public.tasks;
create policy "Tasks select all" on public.tasks for select using (true);

drop policy if exists "Tasks insert authenticated" on public.tasks;
create policy "Tasks insert authenticated" on public.tasks for insert with check (auth.role() = 'authenticated');

drop policy if exists "Tasks update authenticated" on public.tasks;
create policy "Tasks update authenticated" on public.tasks for update using (auth.role() = 'authenticated');

drop policy if exists "SOS reports access" on public.sos_reports;
create policy "SOS reports access" on public.sos_reports for all using ((select auth.uid())::text = coalesce(user_id::text, '') or (select auth.uid())::text = coalesce(reporter_id::text, ''));

drop policy if exists "Chat rooms access" on public.chat_rooms;
create policy "Chat rooms access" on public.chat_rooms for all using (
  customer_id = auth.uid() or helper_id = auth.uid()
);

drop policy if exists "Chat messages select" on public.chat_messages;
create policy "Chat messages select" on public.chat_messages for select using (
  exists (
    select 1 from public.chat_rooms
    where id = chat_messages.room_id
    and (customer_id = auth.uid() or helper_id = auth.uid())
  )
);

drop policy if exists "Chat messages insert" on public.chat_messages;
create policy "Chat messages insert" on public.chat_messages for insert with check (
  sender_id = auth.uid() and
  exists (
    select 1 from public.chat_rooms
    where id = chat_messages.room_id
    and (customer_id = auth.uid() or helper_id = auth.uid())
  )
);

drop policy if exists "Notifications access" on public.notifications;
create policy "Notifications access" on public.notifications for all using (user_id = auth.uid());

drop policy if exists "Ratings select" on public.ratings;
create policy "Ratings select" on public.ratings for select using (true);

drop policy if exists "Ratings insert" on public.ratings;
create policy "Ratings insert" on public.ratings for insert with check (reviewer_id = auth.uid());

drop policy if exists "Loyalty points access" on public.loyalty_points;
create policy "Loyalty points access" on public.loyalty_points for select using (user_id = auth.uid());

drop policy if exists "Loyalty transactions access" on public.loyalty_transactions;
create policy "Loyalty transactions access" on public.loyalty_transactions for all using (user_id = auth.uid());

drop policy if exists "Mitra schedules access" on public.mitra_schedules;
create policy "Mitra schedules access" on public.mitra_schedules for all using (user_id = auth.uid());

drop policy if exists "Student schedules access" on public.student_schedules;
create policy "Student schedules access" on public.student_schedules for all using (user_id = auth.uid());

drop policy if exists "Schedules access" on public.schedules;
create policy "Schedules access" on public.schedules for all using (user_id = auth.uid());

drop policy if exists "Mitra declined orders access" on public.mitra_declined_orders;
create policy "Mitra declined orders access" on public.mitra_declined_orders for all using (mitra_id = auth.uid());

-- 15. Storage Buckets (5MB = 5242880 bytes limit)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('ktm_photos', 'ktm_photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('task_images', 'task_images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('order_photos', 'order_photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('chat_attachments', 'chat_attachments', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('order-proofs', 'order-proofs', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Storage Objects Policies
drop policy if exists "Public storage objects select" on storage.objects;
create policy "Public storage objects select" on storage.objects for select using (
  bucket_id in (
    'ktm_photos',
    'avatars',
    'task_images',
    'order_photos',
    'chat_attachments',
    'order-proofs'
  )
);

drop policy if exists "Authenticated storage objects insert" on storage.objects;
create policy "Authenticated storage objects insert" on storage.objects for insert with check (
  auth.role() = 'authenticated' and
  bucket_id in (
    'ktm_photos',
    'avatars',
    'task_images',
    'order_photos',
    'chat_attachments',
    'order-proofs'
  )
);

drop policy if exists "Authenticated storage objects update" on storage.objects;
create policy "Authenticated storage objects update" on storage.objects for update using (
  auth.role() = 'authenticated' and
  bucket_id in (
    'ktm_photos',
    'avatars',
    'task_images',
    'order_photos',
    'chat_attachments',
    'order-proofs'
  )
);

-- 16. Supabase Realtime Publication
do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end $$;

do $$
begin
  begin
    alter publication supabase_realtime add table public.service_orders;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.chat_rooms;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.chat_messages;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.notifications;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.sos_reports;
  exception when duplicate_object then null;
  end;
end $$;

create or replace function public.delete_current_user_account()
returns void
language plpgsql
security definer
set search_path = public
as 
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from public.profiles where id = auth.uid();
  delete from auth.users where id = auth.uid();
end;
;
