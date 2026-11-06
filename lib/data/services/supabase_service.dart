import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/config/app_config.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;

  bool get isInitialized => _client != null;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase client not initialized');
    }
    return _client!;
  }

  Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) {
      if (kReleaseMode) {
        throw StateError(
          'SUPABASE_URL/SUPABASE_ANON_KEY kosong. Jalankan dengan --dart-define-from-file=.env.json',
        );
      }
      debugPrint(
        'SUPABASE_URL/SUPABASE_ANON_KEY kosong. Jalankan dengan --dart-define-from-file=.env.json',
      );
      return;
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
}
