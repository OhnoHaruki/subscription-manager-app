-- 1. 全テーブルでRLSを有効化
alter table profiles enable row level security;
alter table payment_methods enable row level security;
alter table subscriptions enable row level security;
alter table tags enable row level security;
alter table subscription_tags enable row level security;

-- 2. profilesポリシー (自分のプロフィールのみ読み書き可)
create policy "Allow own profile" on profiles for all using (auth.uid() = id);

-- 3. payment_methodsポリシー
create policy "Allow own payment_methods" on payment_methods for all using (auth.uid() = user_id);

-- 4. subscriptionsポリシー
create policy "Allow own subscriptions" on subscriptions for all using (auth.uid() = user_id);

-- 5. tagsポリシー
create policy "Allow own tags" on tags for all using (auth.uid() = user_id);

-- 6. subscription_tagsポリシー
create policy "Allow own subscription_tags" on subscription_tags for all using (
  exists (select 1 from subscriptions where subscriptions.id = subscription_id and subscriptions.user_id = auth.uid())
);
