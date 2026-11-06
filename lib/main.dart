import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/components/theme/app_theme.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/barter_provider.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/notification_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';
import 'package:ubantu/data/services/local_notification_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode && !AppConfig.isSupabaseConfigured) {
    throw StateError(
      'SUPABASE_URL/SUPABASE_ANON_KEY kosong. Jalankan dengan --dart-define-from-file=.env.json',
    );
  }
  try {
    await SupabaseService.instance.initialize();
  } catch (_) {}
  try {
    await LocalNotificationService.instance.initialize();
  } catch (_) {}
  runApp(const UbantuApp());
}

class UbantuApp extends StatelessWidget {
  const UbantuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => SosProvider(
            repository: ServiceLocator.instance.sosRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BarterProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(
          create: (_) => ServiceOrderProvider(
            repository: ServiceLocator.instance.serviceOrderRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            repository: ServiceLocator.instance.chatRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MitraProvider(
            repository: ServiceLocator.instance.mitraRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            repository: ServiceLocator.instance.notificationRepository,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ubantu',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          if (!kDebugMode) {
            return child ?? const SizedBox.shrink();
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              ?child,
              const Positioned.fill(
                child: DebugFloatingMenu(),
              ),
            ],
          );
        },
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
