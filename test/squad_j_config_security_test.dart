import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/data/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Squad J Config Security Tests', () {
    test('AppConfig defaults to empty and isSupabaseConfigured is false', () {
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.isSupabaseConfigured, isFalse);
    });

    test('SupabaseService initialize does not throw and leaves uninitialized', () async {
      await SupabaseService.instance.initialize();
      expect(SupabaseService.instance.isInitialized, isFalse);
    });

    test('SupabaseService client throws StateError when uninitialized', () {
      if (!SupabaseService.instance.isInitialized) {
        expect(() => SupabaseService.instance.client, throwsStateError);
      }
    });
  });
}
