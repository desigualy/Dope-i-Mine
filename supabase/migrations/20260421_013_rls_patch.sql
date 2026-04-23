alter table user_avatar_config enable row level security;
alter table caregiver_assigned_routines enable row level security;

create policy "user_avatar_config_self_all" on user_avatar_config
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "caregiver_assigned_routines_visible_to_party" on caregiver_assigned_routines
  for select using (auth.uid() = caregiver_user_id or auth.uid() = target_user_id);

create policy "caregiver_assigned_routines_insert_caregiver" on caregiver_assigned_routines
  for insert with check (auth.uid() = caregiver_user_id);

create policy "caregiver_assigned_routines_update_caregiver_or_target" on caregiver_assigned_routines
  for update using (auth.uid() = caregiver_user_id or auth.uid() = target_user_id);
