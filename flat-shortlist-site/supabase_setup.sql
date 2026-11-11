-- Flat Shortlist: one-time database setup.
-- In Supabase open "SQL Editor", paste this whole file, change the passcode on the
-- line marked CHANGE THIS, then press Run.

create table if not exists votes (
  listing_id text not null,
  name       text not null,
  vote       text not null check (vote in ('yes','maybe','no')),
  updated_at timestamptz not null default now(),
  primary key (listing_id, name)
);

create table if not exists comments (
  id         bigint generated always as identity primary key,
  listing_id text not null,
  name       text not null,
  body       text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now()
);

create table if not exists app_settings (
  key   text primary key,
  value text not null
);

insert into app_settings (key, value)
values ('passcode', 'CHANGE-ME')            -- CHANGE THIS: the passcode the three of you will type once
on conflict (key) do update set value = excluded.value;

-- Anyone with the site link can read votes and comments; nobody can write to the tables directly.
alter table votes        enable row level security;
alter table comments     enable row level security;
alter table app_settings enable row level security;

drop policy if exists "read votes" on votes;
create policy "read votes" on votes for select to anon using (true);
drop policy if exists "read comments" on comments;
create policy "read comments" on comments for select to anon using (true);
-- no policy on app_settings: the passcode cannot be read from the website

-- Writes go through these two functions, which check the passcode first.
create or replace function cast_vote(p_pass text, p_listing text, p_name text, p_vote text)
returns text language plpgsql security definer set search_path = public as $$
begin
  if p_pass is distinct from (select value from app_settings where key = 'passcode') then
    return 'bad_passcode';
  end if;
  if p_name not in ('Morgan','Mel','Roisin') or char_length(p_listing) > 40 then
    return 'bad_input';
  end if;
  if p_vote is null or p_vote = '' then
    delete from votes where listing_id = p_listing and name = p_name;
  elsif p_vote in ('yes','maybe','no') then
    insert into votes (listing_id, name, vote) values (p_listing, p_name, p_vote)
    on conflict (listing_id, name) do update set vote = excluded.vote, updated_at = now();
  else
    return 'bad_input';
  end if;
  return 'ok';
end $$;

create or replace function add_comment(p_pass text, p_listing text, p_name text, p_body text)
returns text language plpgsql security definer set search_path = public as $$
begin
  if p_pass is distinct from (select value from app_settings where key = 'passcode') then
    return 'bad_passcode';
  end if;
  if p_name not in ('Morgan','Mel','Roisin') or char_length(p_listing) > 40
     or p_body is null or char_length(trim(p_body)) = 0 or char_length(p_body) > 500 then
    return 'bad_input';
  end if;
  insert into comments (listing_id, name, body) values (p_listing, p_name, trim(p_body));
  return 'ok';
end $$;

revoke all on function cast_vote(text,text,text,text) from public;
revoke all on function add_comment(text,text,text,text) from public;
grant execute on function cast_vote(text,text,text,text) to anon;
grant execute on function add_comment(text,text,text,text) to anon;
