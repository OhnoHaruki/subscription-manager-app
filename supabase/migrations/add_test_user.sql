-- テスト用のユーザーを追加し、外部キー制約をクリアします
insert into profiles (id, username) 
values ('00000000-0000-0000-0000-000000000000', 'test_user')
on conflict (id) do nothing;
