import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/presentation/views/help_detail_view.dart';
import 'package:ubantu/presentation/views/ktm_verification_view.dart';
import 'package:ubantu/presentation/views/login_view.dart';
import 'package:ubantu/presentation/views/main_navigation_view.dart';
import 'package:ubantu/presentation/views/onboarding_view.dart';
import 'package:ubantu/presentation/views/otp_verification_view.dart';
import 'package:ubantu/presentation/views/register_view.dart';
import 'package:ubantu/presentation/views/sos_active_tracking_view.dart';
import 'package:ubantu/presentation/views/sos_finish_dialog_view.dart';
import 'package:ubantu/presentation/views/sos_form_view.dart';

class AppAuthNotifier extends ChangeNotifier {
  static final AppAuthNotifier instance = AppAuthNotifier._();
  AppAuthNotifier._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }
}

class AppRouter {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String ktmVerification = '/ktm-verification';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String helpDetail = '/help-detail';
  static const String sosForm = '/sos-form';
  static const String sosActive = '/sos-active';
  static const String sosFinish = '/sos-finish';
  static const String loginCallback = '/login-callback';

  static final router = GoRouter(
    initialLocation: onboarding,
    refreshListenable: AppAuthNotifier.instance,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final uri = state.uri;
      if (loc == loginCallback ||
          uri.path == loginCallback ||
          uri.path.startsWith('$loginCallback/')) {
        return home;
      }
      final bool hasSession = AppAuthNotifier.instance.isLoggedIn ||
          (SupabaseService.instance.isInitialized &&
              SupabaseService.instance.client.auth.currentSession != null);
      if (hasSession && (loc == onboarding || loc == login || loc == register)) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: loginCallback,
        redirect: (context, state) => home,
      ),
      GoRoute(
        path: ktmVerification,
        builder: (context, state) => const KtmVerificationView(),
      ),
      GoRoute(
        path: otpVerification,
        builder: (context, state) => const OtpVerificationView(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const MainNavigationView(),
      ),
      GoRoute(
        path: helpDetail,
        builder: (context, state) => const HelpDetailView(),
      ),
      GoRoute(
        path: sosForm,
        builder: (context, state) => const SosFormView(),
      ),
      GoRoute(
        path: sosActive,
        builder: (context, state) => const SosActiveTrackingView(),
      ),
      GoRoute(
        path: sosFinish,
        builder: (context, state) => const SosFinishDialogView(),
      ),
    ],
  );
}
