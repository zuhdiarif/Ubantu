create table if not exists public.loyalty_point_awards (
  order_id text primary key,
  user_id text not null,
  points integer not null default 10,
  created_at timestamptz not null default now()
);

alter table public.loyalty_point_awards enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'loyalty_point_awards'
      and policyname = 'loyalty_point_awards_select_own'
  ) then
    create policy loyalty_point_awards_select_own
      on public.loyalty_point_awards
      for select
      using (user_id = auth.uid()::text);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'loyalty_points'
      and policyname = 'loyalty_points_read_own'
  ) then
    create policy loyalty_points_read_own
      on public.loyalty_points
      for select
      using (user_id = auth.uid()::text);
  end if;
end $$;

create or replace function public.award_order_points(p_order_id text)
returns public.loyalty_points language plpgsql security definer set search_path = '' as $$
declare v_uid text := (select auth.uid())::text; v_points constant integer := 10; v_inserted integer; v_row public.loyalty_points;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode = '28000'; end if;
  if not exists (select 1 from public.service_orders o where o.id::text = p_order_id and o.requester_id::text = v_uid and o.status = 'completed') then
    raise exception 'order_not_eligible' using errcode = 'P0001'; end if;
  insert into public.loyalty_points (user_id) values (v_uid) on conflict (user_id) do nothing;
  insert into public.loyalty_point_awards (order_id, user_id, points) values (p_order_id, v_uid, v_points) on conflict (order_id) do nothing;
  get diagnostics v_inserted = row_count;
  if v_inserted > 0 then update public.loyalty_points set total_points = total_points + v_points, updated_at = now() where user_id = v_uid; end if;
  select * into v_row from public.loyalty_points where user_id = v_uid; return v_row;
end; $$;

create or replace function public.claim_loyalty_voucher()
returns public.loyalty_points language plpgsql security definer set search_path = '' as $$
declare v_uid text := (select auth.uid())::text; v_cost constant integer := 100; v_row public.loyalty_points;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode = '28000'; end if;
  select * into v_row from public.loyalty_points where user_id = v_uid for update;
  if not found or v_row.total_points < v_cost then raise exception 'insufficient_points' using errcode = 'P0001'; end if;
  update public.loyalty_points set total_points = total_points - v_cost, available_vouchers = available_vouchers + 1,
    claimed_voucher_codes = array_append(claimed_voucher_codes, 'GRATIS1X_' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10))), updated_at = now()
  where user_id = v_uid returning * into v_row;
  return v_row;
end; $$;

revoke insert, update, delete, truncate, trigger, references on public.loyalty_points from anon, authenticated;
grant select on public.loyalty_points to authenticated;

revoke insert, update, delete, truncate, trigger, references on public.loyalty_point_awards from anon, authenticated;
grant select on public.loyalty_point_awards to authenticated;

revoke all on function public.award_order_points(text) from public, anon;
grant execute on function public.award_order_points(text) to authenticated;

revoke all on function public.claim_loyalty_voucher() from public, anon;
grant execute on function public.claim_loyalty_voucher() to authenticated;
