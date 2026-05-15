-- 既存のRLSポリシーを一旦削除して全許可にします
drop policy if exists "Allow own subscriptions" on subscriptions;
drop policy if exists "Allow own payment_methods" on payment_methods;
drop policy if exists "Allow own profile" on profiles;

create policy "Allow all" on subscriptions for all using (true) with check (true);
create policy "Allow all" on payment_methods for all using (true) with check (true);
create policy "Allow all" on profiles for all using (true) with check (true);
