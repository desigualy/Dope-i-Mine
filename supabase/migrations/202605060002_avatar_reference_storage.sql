insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatar-reference-images',
  'avatar-reference-images',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "avatar_reference_images_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'avatar-reference-images'
    and auth.uid()::text = (storage.foldername(name))[2]
  );

create policy "avatar_reference_images_select_own"
  on storage.objects for select
  using (
    bucket_id = 'avatar-reference-images'
    and auth.uid()::text = (storage.foldername(name))[2]
  );

create policy "avatar_reference_images_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'avatar-reference-images'
    and auth.uid()::text = (storage.foldername(name))[2]
  );
