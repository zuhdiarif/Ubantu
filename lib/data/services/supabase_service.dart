import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/config/app_config.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase client not initialized');
    }
    return _client!;
  }

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
}
