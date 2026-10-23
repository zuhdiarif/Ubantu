import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/barter_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';
import 'package:ubantu/data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.instance.initialize();
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
        ChangeNotifierProvider(create: (_) => SosProvider()),
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
      ],
      child: MaterialApp.router(
        title: 'Ubantu',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        builder: (context, child) {
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
        theme: ThemeData(
          fontFamily: AppTypography.fontFamily,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGreen,
            primary: AppColors.primaryGreen,
            secondary: AppColors.accentOrange,
            surface: AppColors.background,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.primaryDark,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
