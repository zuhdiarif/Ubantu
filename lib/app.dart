import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/ui/widgets/debug_floating_menu.dart';
import 'package:ubantu/core/theme/app_theme.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/profile/barter_provider.dart';
import 'package:ubantu/ui/chat/chat_provider.dart';
import 'package:ubantu/ui/profile/loyalty_provider.dart';
import 'package:ubantu/ui/mitra/mitra_provider.dart';
import 'package:ubantu/ui/notification/notification_provider.dart';
import 'package:ubantu/ui/profile/profile_provider.dart';
import 'package:ubantu/ui/mitra/rating_provider.dart';
import 'package:ubantu/ui/auth/registration_provider.dart';
import 'package:ubantu/ui/mitra/schedule_provider.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';
import 'package:ubantu/ui/sos/sos_provider.dart';
import 'package:ubantu/ui/home/task_provider.dart';

class UbantuApp extends StatelessWidget {
  const UbantuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final p = AuthProvider(
              repository: ServiceLocator.instance.authRepository,
            );
            ServiceLocator.instance.registerProviderResetCallback(p.resetSession);
            return p;
          },
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
