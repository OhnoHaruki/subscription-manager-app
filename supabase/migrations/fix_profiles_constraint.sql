-- 1. profiles テーブルから auth.users への外部キー制約を削除
alter table profiles drop constraint if exists profiles_id_fkey;

-- 2. ダミーユーザーを profiles テーブルに強制挿入
insert into profiles (id, username) 
values ('00000000-0000-0000-0000-000000000000', 'test_user')
on conflict (id) do nothing;
