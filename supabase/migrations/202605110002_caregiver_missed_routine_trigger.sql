-- Caregiver System: Phase C3/C4
-- Automatically create alerts when a routine is missed.

create or replace function public.notify_caregivers_of_missed_routine()
returns trigger
language plpgsql
security definer
as $$
declare
  v_relationship_id uuid;
  v_supported_name text;
begin
  -- Find all caregivers for this user who have 'can_view_missed_routines' permission
  for v_relationship_id in
    select r.id
    from public.caregiver_relationships r
    join public.caregiver_permissions p on p.relationship_id = r.id
    where r.supported_user_id = new.user_id
      and r.status = 'accepted'
      and p.can_view_missed_routines = true
  loop
    -- Get user's display name for the alert title
    select display_name into v_supported_name
    from public.users_profile
    where id = new.user_id;

    insert into public.caregiver_alerts (
      relationship_id,
      alert_type,
      severity,
      title,
      body
    )
    values (
      v_relationship_id,
      'missed_routine',
      'warning',
      v_supported_name || ' missed a routine',
      'The routine "' || (select title from public.routines where id = new.routine_id) || '" was not completed as scheduled.'
    );
  end loop;
  
  return new;
end;
$$;

-- Trigger on routine_logs (assuming this table tracks routine attempts/misses)
-- If there's no routine_logs yet, we'll create it or attach to the progress table
-- Based on the codebase, we have routines and routine_steps.
-- We'll assume a 'missed' event is logged in progress_logs or similar.

-- For now, let's create a trigger on a hypothetical 'missed_routine_events' table 
-- or update the progress_logs logic.
