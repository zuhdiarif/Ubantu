import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/ui/auth/password_reset_provider.dart';
import 'package:ubantu/ui/aktivitas/aktivitas_view.dart';
import 'package:ubantu/ui/auth/forgot_password_view.dart';
import 'package:ubantu/ui/aktivitas/help_detail_view.dart';
import 'package:ubantu/ui/auth/ktm_verification_view.dart';
import 'package:ubantu/ui/auth/login_view.dart';
import 'package:ubantu/ui/home/main_navigation_view.dart';
import 'package:ubantu/ui/notification/notification_view.dart';
import 'package:ubantu/ui/onboarding/onboarding_view.dart';
import 'package:ubantu/ui/auth/otp_verification_view.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_form_view.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_in_progress_view.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_selesai_view.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_view.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_waiting_view.dart';
import 'package:ubantu/ui/bersih_kos/bersih_kos_form_view.dart';
import 'package:ubantu/ui/bersih_kos/bersih_kos_in_progress_view.dart';
import 'package:ubantu/ui/bersih_kos/bersih_kos_selesai_view.dart';
import 'package:ubantu/ui/bersih_kos/bersih_kos_view.dart';
import 'package:ubantu/ui/bersih_kos/bersih_kos_waiting_view.dart';
import 'package:ubantu/ui/pindah_kos/pindah_kos_form_view.dart';
import 'package:ubantu/ui/pindah_kos/pindah_kos_in_progress_view.dart';
import 'package:ubantu/ui/pindah_kos/pindah_kos_selesai_view.dart';
import 'package:ubantu/ui/pindah_kos/pindah_kos_view.dart';
import 'package:ubantu/ui/pindah_kos/pindah_kos_waiting_view.dart';
import 'package:ubantu/ui/auth/register_view.dart';
import 'package:ubantu/ui/sos/sos_active_tracking_view.dart';
import 'package:ubantu/ui/sos/sos_finish_dialog_view.dart';
import 'package:ubantu/ui/sos/sos_form_view.dart';
import 'package:ubantu/data/models/chat_room_model.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/task_model.dart';
import 'package:ubantu/ui/aktivitas/bantuan_detail_view.dart';
import 'package:ubantu/ui/chat/chat_room_view.dart';
import 'package:ubantu/ui/chat/inbox_view.dart';
import 'package:ubantu/ui/mitra/mitra_active_order_view.dart';
import 'package:ubantu/ui/mitra/mitra_category_registration_view.dart';
import 'package:ubantu/ui/mitra/mitra_dashboard_view.dart';
import 'package:ubantu/ui/mitra/mitra_earnings_view.dart';
import 'package:ubantu/ui/mitra/mitra_performance_view.dart';

class AppAuthNotifier extends ChangeNotifier {
  static final AppAuthNotifier instance = AppAuthNotifier._();
  AppAuthNotifier._();

  bool _isLoggedIn = false;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _isOAuthCallbackPending = false;
  bool get isOAuthCallbackPending => _isOAuthCallbackPending;

  void setOAuthCallbackPending(bool value) {
    _isOAuthCallbackPending = value;
  }
  bool get isLoggedIn => _isLoggedIn;

  void initLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notify();
    }
  }

  void bindAuthStateListener({Stream<AuthState>? authStream}) {
    _authStateSubscription?.cancel();
    if (SupabaseService.instance.isInitialized &&
        SupabaseService.instance.client.auth.currentSession != null) {
      _isLoggedIn = true;
    }
    final resolvedStream = authStream ??
        (SupabaseService.instance.isInitialized
            ? SupabaseService.instance.client.auth.onAuthStateChange
            : null);
    if (resolvedStream == null) return;
    _authStateSubscription = resolvedStream.listen((state) {
      if (state.session != null) {
        _isOAuthCallbackPending = false;
        setLoggedIn(true);
      } else if (state.event == AuthChangeEvent.signedOut) {
        _isOAuthCallbackPending = false;
        ServiceLocator.instance.clearSessionCaches();
        setLoggedIn(false);
      }
    });
  }

  void cancelAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
  }

  void notify() {
    try {
      if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
    } catch (_) {}
    notifyListeners();
  }
}

class AppRouter {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String ktmVerification = '/ktm-verification';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String helpDetail = '/help-detail';
  static const String sosForm = '/sos-form';
  static const String sosActive = '/sos-active';
  static const String sosFinish = '/sos-finish';
  static const String loginCallback = '/login-callback';
  static const String pindahKos = '/pindah-kos';
  static const String pindahKosForm = '/pindah-kos/form';
  static const String pindahKosWaiting = '/pindah-kos/waiting';
  static const String pindahKosInProgress = '/pindah-kos/in-progress';
  static const String pindahKosSelesai = '/pindah-kos/selesai';
  static const String bersihKos = '/bersih-kos';
  static const String bersihKosForm = '/bersih-kos/form';
  static const String bersihKosWaiting = '/bersih-kos/waiting';
  static const String bersihKosInProgress = '/bersih-kos/in-progress';
  static const String bersihKosSelesai = '/bersih-kos/selesai';
  static const String antarJemput = '/antar-jemput';
  static const String antarJemputForm = '/antar-jemput/form';
  static const String antarJemputWaiting = '/antar-jemput/waiting';
  static const String antarJemputInProgress = '/antar-jemput/in-progress';
  static const String antarJemputSelesai = '/antar-jemput/selesai';
  static const String chatInbox = '/chat';
  static const String chatRoom = '/chat/room';
  static const String mitraDashboard = '/mitra/dashboard';
  static const String mitraActiveOrder = '/mitra/active-order';
  static const String mitraEarnings = '/mitra/earnings';
  static const String mitraPerformance = '/mitra/performance';
  static const String mitraRegister = '/mitra/register';
  static const String bantuanDetail = '/bantuan-detail';
  static const String notificationHistory = '/notification-history';
  static const String aktivitas = '/aktivitas';

  static bool hasOAuthCallbackParams(Uri uri) {
    return uri.queryParameters.containsKey('code') ||
        uri.fragment.contains('access_token') ||
        uri.queryParameters.containsKey('access_token') ||
        AppAuthNotifier.instance.isOAuthCallbackPending;
  }

  static bool hasActiveSession() {
    return AppAuthNotifier.instance.isLoggedIn ||
        (SupabaseService.instance.isInitialized &&
            SupabaseService.instance.client.auth.currentSession != null);
  }

  static final router = GoRouter(
    initialLocation: onboarding,
    refreshListenable: AppAuthNotifier.instance,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final uri = state.uri;
      final bool hasSession = hasActiveSession();
      if (loc == loginCallback ||
          uri.path == loginCallback ||
          uri.path.startsWith('$loginCallback/')) {
        if (hasSession) {
          return home;
        }
        if (hasOAuthCallbackParams(uri) &&
            !uri.queryParameters.containsKey('error')) {
          return null;
        }
        return login;
      }
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
        redirect: (context, state) {
          if (hasActiveSession()) return home;
          if (hasOAuthCallbackParams(state.uri) &&
              !state.uri.queryParameters.containsKey('error')) {
            return null;
          }
          return login;
        },
        builder: (context, state) => const OAuthCallbackLoadingView(),
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
        path: forgotPassword,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => PasswordResetProvider(),
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const MainNavigationView(),
      ),
      GoRoute(
        path: helpDetail,
        builder: (context, state) => HelpDetailView(task: state.extra as TaskModel?),
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
      GoRoute(
        path: pindahKos,
        builder: (context, state) => const PindahKosView(),
      ),
      GoRoute(
        path: pindahKosForm,
        builder: (context, state) => const PindahKosFormView(),
      ),
      GoRoute(
        path: pindahKosWaiting,
        builder: (context, state) => const PindahKosWaitingView(),
      ),
      GoRoute(
        path: pindahKosInProgress,
        builder: (context, state) => const PindahKosInProgressView(),
      ),
      GoRoute(
        path: pindahKosSelesai,
        builder: (context, state) => const PindahKosSelesaiView(),
      ),
      GoRoute(
        path: bersihKos,
        builder: (context, state) => const BersihKosView(),
      ),
      GoRoute(
        path: bersihKosForm,
        builder: (context, state) => const BersihKosFormView(),
      ),
      GoRoute(
        path: bersihKosWaiting,
        builder: (context, state) => const BersihKosWaitingView(),
      ),
      GoRoute(
        path: bersihKosInProgress,
        builder: (context, state) => const BersihKosInProgressView(),
      ),
      GoRoute(
        path: bersihKosSelesai,
        builder: (context, state) => const BersihKosSelesaiView(),
      ),
      GoRoute(
        path: antarJemput,
        builder: (context, state) => const AntarJemputView(),
      ),
      GoRoute(
        path: antarJemputForm,
        builder: (context, state) => const AntarJemputFormView(),
      ),
      GoRoute(
        path: antarJemputWaiting,
        builder: (context, state) => const AntarJemputWaitingView(),
      ),
      GoRoute(
        path: antarJemputInProgress,
        builder: (context, state) => const AntarJemputInProgressView(),
      ),
      GoRoute(
        path: antarJemputSelesai,
        builder: (context, state) => const AntarJemputSelesaiView(),
      ),
      GoRoute(
        path: chatInbox,
        builder: (context, state) => const InboxView(),
      ),
      GoRoute(
        path: chatRoom,
        builder: (context, state) {
          final room = state.extra is ChatRoomModel
              ? state.extra as ChatRoomModel
              : null;
          return ChatRoomView(initialRoom: room);
        },
      ),
      GoRoute(
        path: mitraDashboard,
        builder: (context, state) => const MitraDashboardView(),
      ),
      GoRoute(
        path: mitraActiveOrder,
        builder: (context, state) => const MitraActiveOrderView(),
      ),
      GoRoute(
        path: mitraEarnings,
        builder: (context, state) => const MitraEarningsView(),
      ),
      GoRoute(
        path: mitraPerformance,
        builder: (context, state) => const MitraPerformanceView(),
      ),
      GoRoute(
        path: mitraRegister,
        builder: (context, state) => const MitraCategoryRegistrationView(),
      ),
      GoRoute(
        path: bantuanDetail,
        builder: (context, state) {
          final order = state.extra is ServiceOrderModel
              ? state.extra as ServiceOrderModel
              : null;
          return BantuanDetailView(order: order);
        },
      ),
      GoRoute(
        path: notificationHistory,
        builder: (context, state) => const NotificationView(),
      ),
      GoRoute(
        path: aktivitas,
        builder: (context, state) => const AktivitasView(),
      ),
    ],
  );
}

class OAuthCallbackLoadingView extends StatefulWidget {
  final Duration timeoutDuration;

  const OAuthCallbackLoadingView({
    super.key,
    this.timeoutDuration = const Duration(seconds: 4),
  });

  @override
  State<OAuthCallbackLoadingView> createState() =>
      _OAuthCallbackLoadingViewState();
}

class _OAuthCallbackLoadingViewState extends State<OAuthCallbackLoadingView> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(widget.timeoutDuration, () {
      if (mounted && !AppRouter.hasActiveSession()) {
        AppAuthNotifier.instance.setOAuthCallbackPending(false);
        context.go(AppRouter.login);
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
