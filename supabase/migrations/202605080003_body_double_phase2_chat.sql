alter table public.body_double_messages drop constraint if exists body_double_messages_message_type_check;
alter table public.body_double_messages add constraint body_double_messages_message_type_check check (message_type in ('preset', 'system', 'text'));
