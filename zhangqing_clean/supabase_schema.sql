-- 账清 · 数据库初始化脚本（Supabase SQL Editor 执行）
create table mates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null check (char_length(name) between 1 and 20),
  created_at timestamptz not null default now()
);

create table records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  mate_id uuid references mates(id) on delete cascade not null,
  amount numeric(10,2) not null check (amount > 0 and amount <= 99999),
  status text not null default 'unpaid' check (status in ('unpaid','paid','deleted')),
  created_at timestamptz not null default now()
);

create index mates_user_idx on mates(user_id);
create index records_mate_idx on records(mate_id, status);
create index records_user_date_idx on records(user_id, created_at desc);

alter table mates enable row level security;
alter table records enable row level security;

create policy "mates_own" on mates
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "records_own" on records
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ===== 2026 新规则：显式授权给 API 角色（必须！）=====
grant select, insert, update, delete on mates to authenticated;
grant select, insert, update, delete on records to authenticated;
grant select, insert, update, delete on mates to anon;
grant select, insert, update, delete on records to anon;
