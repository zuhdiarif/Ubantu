import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ubantu/app.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/services/local_notification_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';

export 'package:ubantu/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode && !AppConfig.isSupabaseConfigured) {
    throw StateError(
      'SUPABASE_URL/SUPABASE_ANON_KEY kosong. Jalankan dengan --dart-define-from-file=.env.json',
    );
  }
  try {
    await SupabaseService.instance.initialize();
    AppAuthNotifier.instance.bindAuthStateListener();
  } catch (_) {}
  try {
    await LocalNotificationService.instance.initialize();
  } catch (_) {}
  runApp(const UbantuApp());
}
