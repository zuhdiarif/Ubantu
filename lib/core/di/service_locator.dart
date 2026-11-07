import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/barter_repository_impl.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/data/repositories/loyalty_repository_impl.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/data/repositories/profile_repository_impl.dart';
import 'package:ubantu/data/repositories/rating_repository_impl.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/data/repositories/service_order_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/data/services/supabase_barter_service.dart';
import 'package:ubantu/data/services/supabase_loyalty_service.dart';
import 'package:ubantu/data/services/supabase_mitra_service.dart';
import 'package:ubantu/data/services/supabase_notification_service.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/data/services/supabase_rating_service.dart';
import 'package:ubantu/data/services/supabase_schedule_service.dart';
import 'package:ubantu/data/services/supabase_sos_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';
import 'package:ubantu/data/repositories/barter_repository.dart';
import 'package:ubantu/data/repositories/chat_repository.dart';
import 'package:ubantu/data/repositories/loyalty_repository.dart';
import 'package:ubantu/data/repositories/mitra_repository.dart';
import 'package:ubantu/data/repositories/notification_repository.dart';
import 'package:ubantu/data/repositories/profile_repository.dart';
import 'package:ubantu/data/repositories/rating_repository.dart';
import 'package:ubantu/data/repositories/schedule_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';
import 'package:ubantu/data/repositories/sos_repository.dart';
import 'package:ubantu/data/repositories/task_repository.dart';
import 'package:ubantu/logic/accept_order_usecase.dart';
import 'package:ubantu/logic/complete_order_with_proof_usecase.dart';
import 'package:ubantu/logic/create_service_order_usecase.dart';
import 'package:ubantu/logic/get_active_orders_usecase.dart';
import 'package:ubantu/logic/get_tasks_usecase.dart';
import 'package:ubantu/logic/login_usecase.dart';
import 'package:ubantu/logic/submit_sos_usecase.dart';
import 'package:ubantu/logic/get_chat_messages_usecase.dart';
import 'package:ubantu/logic/get_chat_rooms_usecase.dart';
import 'package:ubantu/logic/send_chat_message_usecase.dart';
import 'package:ubantu/logic/update_order_status_usecase.dart';
import 'package:ubantu/logic/resend_signup_otp_usecase.dart';
import 'package:ubantu/logic/send_password_reset_otp_usecase.dart';
import 'package:ubantu/logic/update_password_usecase.dart';
import 'package:ubantu/logic/update_user_profile_usecase.dart';
import 'package:ubantu/logic/verify_recovery_otp_usecase.dart';
import 'package:ubantu/logic/verify_otp_usecase.dart';
import 'package:ubantu/logic/send_otp_usecase.dart';
import 'package:ubantu/data/services/ml_kit_text_recognition_service.dart';
import 'package:ubantu/data/repositories/text_recognition_service.dart';
import 'package:ubantu/logic/extract_ktm_data_usecase.dart';

class ServiceLocator {
  static ServiceLocator _instance = ServiceLocator._();

  static ServiceLocator get instance => _instance;

  late final MockTaskService mockTaskService;
  late final SupabaseTaskService supabaseTaskService;
  late final SupabaseOrderService supabaseOrderService;
  late final SupabaseSosService supabaseSosService;
  late final SupabaseStorageService supabaseStorageService;
  late final SupabaseLoyaltyService supabaseLoyaltyService;
  late final SupabaseProfileService supabaseProfileService;
  late final SupabaseBarterService supabaseBarterService;
  late final SupabaseScheduleService supabaseScheduleService;
  late final SupabaseRatingService supabaseRatingService;
  late final SupabaseMitraService supabaseMitraService;
  late final NotificationService notificationService;
  late final SupabaseNotificationService supabaseNotificationService;
  late final ITextRecognitionService textRecognitionService;

  late final IAuthRepository authRepository;
  late final ITaskRepository taskRepository;
  late final ISosRepository sosRepository;
  late final IServiceOrderRepository serviceOrderRepository;
  late final IChatRepository chatRepository;
  late final IMitraRepository mitraRepository;
  late final INotificationRepository notificationRepository;
  late final ILoyaltyRepository loyaltyRepository;
  late final IProfileRepository profileRepository;
  late final IBarterRepository barterRepository;
  late final IScheduleRepository scheduleRepository;
  late final IRatingRepository ratingRepository;

  late final LoginUseCase loginUseCase;
  late final GetTasksUseCase getTasksUseCase;
  late final SubmitSosUseCase submitSosUseCase;
  late final CreateServiceOrderUseCase createServiceOrderUseCase;
  late final GetActiveOrdersUseCase getActiveOrdersUseCase;
  late final AcceptOrderUseCase acceptOrderUseCase;
  late final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  late final CompleteOrderWithProofUseCase completeOrderWithProofUseCase;
  late final GetChatRoomsUseCase getChatRoomsUseCase;
  late final GetChatMessagesUseCase getChatMessagesUseCase;
  late final SendChatMessageUseCase sendChatMessageUseCase;
  late final SendOtpUseCase sendOtpUseCase;
  late final VerifyOtpUseCase verifyOtpUseCase;
  late final ResendSignupOtpUseCase resendSignupOtpUseCase;
  late final SendPasswordResetOtpUseCase sendPasswordResetOtpUseCase;
  late final VerifyRecoveryOtpUseCase verifyRecoveryOtpUseCase;
  late final UpdatePasswordUseCase updatePasswordUseCase;
  late final UpdateUserProfileUseCase updateUserProfileUseCase;
  late final ExtractKtmDataUseCase extractKtmDataUseCase;

  ServiceLocator._({
    IAuthRepository? authRepository,
    ITaskRepository? taskRepository,
    ISosRepository? sosRepository,
    IServiceOrderRepository? serviceOrderRepository,
    IChatRepository? chatRepository,
    IMitraRepository? mitraRepository,
    INotificationRepository? notificationRepository,
    ILoyaltyRepository? loyaltyRepository,
    IProfileRepository? profileRepository,
    IBarterRepository? barterRepository,
    IScheduleRepository? scheduleRepository,
    IRatingRepository? ratingRepository,
    ITextRecognitionService? textRecognitionService,
  }) {
    mockTaskService = MockTaskService();
    supabaseTaskService = SupabaseTaskService();
    supabaseOrderService = SupabaseOrderService();
    supabaseSosService = SupabaseSosService();
    supabaseStorageService = SupabaseStorageService();
    supabaseLoyaltyService = SupabaseLoyaltyService();
    supabaseProfileService = SupabaseProfileService();
    supabaseBarterService = SupabaseBarterService();
    supabaseScheduleService = SupabaseScheduleService();
    supabaseRatingService = SupabaseRatingService();
    supabaseMitraService = SupabaseMitraService();
    notificationService = NotificationService();
    supabaseNotificationService = SupabaseNotificationService();
    this.textRecognitionService =
        textRecognitionService ?? MlKitTextRecognitionService();

    this.authRepository = authRepository ?? AuthRepositoryImpl();
    this.taskRepository = taskRepository ??
        TaskRepositoryImpl(
          mockService: mockTaskService,
          remoteService: supabaseTaskService,
        );
    this.sosRepository =
        sosRepository ?? SosRepositoryImpl(service: supabaseSosService);
    this.serviceOrderRepository = serviceOrderRepository ??
        ServiceOrderRepositoryImpl(
          service: supabaseOrderService,
          storageService: supabaseStorageService,
        );
    this.chatRepository = chatRepository ?? ChatRepositoryImpl();
    this.mitraRepository = mitraRepository ??
        MitraRepositoryImpl(mitraService: supabaseMitraService);
    this.notificationRepository = notificationRepository ??
        NotificationRepositoryImpl(
          service: notificationService,
          remoteService: supabaseNotificationService,
        );
    this.loyaltyRepository = loyaltyRepository ??
        LoyaltyRepositoryImpl(remoteService: supabaseLoyaltyService);
    this.profileRepository = profileRepository ??
        ProfileRepositoryImpl(
          remoteService: supabaseProfileService,
          storageService: supabaseStorageService,
        );
    this.barterRepository = barterRepository ??
        BarterRepositoryImpl(remoteService: supabaseBarterService);
    this.scheduleRepository = scheduleRepository ??
        ScheduleRepositoryImpl(
          remoteService: supabaseScheduleService,
          orderService: supabaseOrderService,
        );
    this.ratingRepository = ratingRepository ??
        RatingRepositoryImpl(remoteService: supabaseRatingService);

    loginUseCase = LoginUseCase(this.authRepository);
    getTasksUseCase = GetTasksUseCase(this.taskRepository);
    submitSosUseCase = SubmitSosUseCase(this.sosRepository);
    createServiceOrderUseCase =
        CreateServiceOrderUseCase(this.serviceOrderRepository);
    getActiveOrdersUseCase =
        GetActiveOrdersUseCase(this.serviceOrderRepository);
    acceptOrderUseCase = AcceptOrderUseCase(this.serviceOrderRepository);
    updateOrderStatusUseCase =
        UpdateOrderStatusUseCase(this.serviceOrderRepository);
    completeOrderWithProofUseCase =
        CompleteOrderWithProofUseCase(this.serviceOrderRepository);
    getChatRoomsUseCase = GetChatRoomsUseCase(this.chatRepository);
    getChatMessagesUseCase = GetChatMessagesUseCase(this.chatRepository);
    sendChatMessageUseCase = SendChatMessageUseCase(this.chatRepository);
    sendOtpUseCase = SendOtpUseCase(this.authRepository);
    verifyOtpUseCase = VerifyOtpUseCase(this.authRepository);
    resendSignupOtpUseCase = ResendSignupOtpUseCase(this.authRepository);
    sendPasswordResetOtpUseCase =
        SendPasswordResetOtpUseCase(this.authRepository);
    verifyRecoveryOtpUseCase =
        VerifyRecoveryOtpUseCase(this.authRepository);
    updatePasswordUseCase = UpdatePasswordUseCase(this.authRepository);
    updateUserProfileUseCase = UpdateUserProfileUseCase(this.authRepository);
    extractKtmDataUseCase = ExtractKtmDataUseCase(this.textRecognitionService);
  }

  static void resetForTesting({
    IAuthRepository? authRepository,
    ITaskRepository? taskRepository,
    ISosRepository? sosRepository,
    IServiceOrderRepository? serviceOrderRepository,
    IChatRepository? chatRepository,
    IMitraRepository? mitraRepository,
    INotificationRepository? notificationRepository,
    ILoyaltyRepository? loyaltyRepository,
    IProfileRepository? profileRepository,
    IBarterRepository? barterRepository,
    IScheduleRepository? scheduleRepository,
    IRatingRepository? ratingRepository,
    ITextRecognitionService? textRecognitionService,
  }) {
    _instance = ServiceLocator._(
      authRepository: authRepository,
      taskRepository: taskRepository,
      sosRepository: sosRepository,
      serviceOrderRepository: serviceOrderRepository,
      chatRepository: chatRepository,
      mitraRepository: mitraRepository,
      notificationRepository: notificationRepository,
      loyaltyRepository: loyaltyRepository,
      profileRepository: profileRepository,
      barterRepository: barterRepository,
      scheduleRepository: scheduleRepository,
      ratingRepository: ratingRepository,
      textRecognitionService: textRecognitionService,
    );
  }

  final List<void Function()> _providerResetCallbacks = [];

  void registerProviderResetCallback(void Function() callback) {
    if (!_providerResetCallbacks.contains(callback)) {
      _providerResetCallbacks.add(callback);
    }
  }

  void clearSessionCaches() {
    final repos = [
      authRepository,
      taskRepository,
      sosRepository,
      serviceOrderRepository,
      chatRepository,
      mitraRepository,
      notificationRepository,
      loyaltyRepository,
      profileRepository,
      barterRepository,
      scheduleRepository,
      ratingRepository,
    ];
    for (final repo in repos) {
      if (repo is SessionScoped) {
        repo.clearSessionCache();
      }
    }
    for (final callback in List<void Function()>.from(_providerResetCallbacks)) {
      try {
        callback();
      } catch (_) {}
    }
  }
}
