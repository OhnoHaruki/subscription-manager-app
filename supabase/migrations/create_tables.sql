drop table if exists subscription_tags;
drop table if exists tags;
drop table if exists subscriptions;
drop table if exists payment_methods;
drop table if exists profiles;

create table profiles (
  id uuid references auth.users not null primary key,
  username text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table payment_methods (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) not null,
  name text not null,
  type text not null,
  last4 text,
  expiry_date timestamp with time zone
);

create table subscriptions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) not null,
  payment_method_id uuid references payment_methods(id),
  name text not null,
  amount int not null,
  cycle text not null,
  next_payment_date timestamp with time zone not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table tags (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) not null,
  name text not null
);

create table subscription_tags (
  subscription_id uuid references subscriptions(id) on delete cascade,
  tag_id uuid references tags(id) on delete cascade,
  primary key (subscription_id, tag_id)
);
