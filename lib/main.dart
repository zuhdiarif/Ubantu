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
    AppAuthNotifier.instance.bindAuthStateListener();
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
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: ServiceLocator.instance.authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = TaskProvider(
              repository: ServiceLocator.instance.taskRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = SosProvider(
              repository: ServiceLocator.instance.sosRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = RegistrationProvider(
              repository: ServiceLocator.instance.authRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = ProfileProvider(
              repository: ServiceLocator.instance.profileRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = BarterProvider(
              repository: ServiceLocator.instance.barterRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = RatingProvider(
              repository: ServiceLocator.instance.ratingRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = LoyaltyProvider(
              repository: ServiceLocator.instance.loyaltyRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = ScheduleProvider(
              repository: ServiceLocator.instance.scheduleRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = ServiceOrderProvider(
              repository: ServiceLocator.instance.serviceOrderRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = ChatProvider(
              repository: ServiceLocator.instance.chatRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = MitraProvider(
              repository: ServiceLocator.instance.mitraRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = NotificationProvider(
              repository: ServiceLocator.instance.notificationRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
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
