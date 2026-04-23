insert into voice_profiles (provider, label, accent, pace, warmth, firmness, tone_preset)
values
  ('system', 'Calm Guide UK', 'UK', 'slow', 'high', 'low', 'calm_guide'),
  ('system', 'Practical Coach UK', 'UK', 'normal', 'medium', 'high', 'practical_coach'),
  ('system', 'Gentle Companion US', 'US', 'slow', 'high', 'low', 'gentle_companion'),
  ('system', 'Focus Drill UK', 'UK', 'normal', 'low', 'high', 'focus_drill'),
  ('system', 'Friendly Peer UK', 'UK', 'normal', 'medium', 'medium', 'friendly_peer')
on conflict do nothing;
