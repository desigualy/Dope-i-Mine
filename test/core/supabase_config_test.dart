import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/core/utils/supabase_config.dart';

void main() {
  group('normalizeSupabaseUrl', () {
    test('strips REST API path from Supabase REST endpoint URL', () {
      expect(
        normalizeSupabaseUrl('https://example.supabase.co/rest/v1/'),
        'https://example.supabase.co',
      );
    });

    test('preserves project base URL without trailing slash', () {
      expect(
        normalizeSupabaseUrl('https://example.supabase.co/'),
        'https://example.supabase.co',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        normalizeSupabaseUrl('  https://example.supabase.co/rest/v1/  '),
        'https://example.supabase.co',
      );
    });

    test('returns empty value unchanged', () {
      expect(normalizeSupabaseUrl(''), '');
    });
  });
}
