import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/presentation/views/help_detail_view.dart';
import 'package:ubantu/presentation/views/ktm_verification_view.dart';
import 'package:ubantu/presentation/views/login_view.dart';
import 'package:ubantu/presentation/views/main_navigation_view.dart';
import 'package:ubantu/presentation/views/onboarding_view.dart';
import 'package:ubantu/presentation/views/otp_verification_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_form_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_in_progress_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_selesai_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_waiting_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_form_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_in_progress_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_selesai_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_waiting_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_form_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_in_progress_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_selesai_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_waiting_view.dart';
import 'package:ubantu/presentation/views/register_view.dart';
import 'package:ubantu/presentation/views/sos_active_tracking_view.dart';
import 'package:ubantu/presentation/views/sos_finish_dialog_view.dart';
import 'package:ubantu/presentation/views/sos_form_view.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/views/bantuan_detail_view.dart';
import 'package:ubantu/presentation/views/chat/chat_room_view.dart';
import 'package:ubantu/presentation/views/chat/inbox_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_active_order_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_category_registration_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_dashboard_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_earnings_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_performance_view.dart';

class AppAuthNotifier extends ChangeNotifier {
  static final AppAuthNotifier instance = AppAuthNotifier._();
  AppAuthNotifier._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notify();
    }
  }

  void notify() {
    try {
      if (WidgetsBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
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
    ],
  );
}
