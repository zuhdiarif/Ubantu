import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/service_order_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/data/services/supabase_sos_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/accept_order_usecase.dart';
import 'package:ubantu/domain/usecases/complete_order_with_proof_usecase.dart';
import 'package:ubantu/domain/usecases/create_service_order_usecase.dart';
import 'package:ubantu/domain/usecases/get_active_orders_usecase.dart';
import 'package:ubantu/domain/usecases/get_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/login_usecase.dart';
import 'package:ubantu/domain/usecases/submit_sos_usecase.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/usecases/get_chat_messages_usecase.dart';
import 'package:ubantu/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:ubantu/domain/usecases/send_chat_message_usecase.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/data/services/supabase_notification_service.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';
import 'package:ubantu/domain/usecases/update_order_status_usecase.dart';

import 'package:ubantu/domain/usecases/resend_signup_otp_usecase.dart';
import 'package:ubantu/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:ubantu/domain/usecases/update_password_usecase.dart';
import 'package:ubantu/domain/usecases/update_user_profile_usecase.dart';
import 'package:ubantu/domain/usecases/verify_recovery_otp_usecase.dart';
import 'package:ubantu/domain/usecases/verify_otp_usecase.dart';
import 'package:ubantu/domain/usecases/send_otp_usecase.dart';
import 'package:ubantu/data/services/ml_kit_text_recognition_service.dart';
import 'package:ubantu/domain/repositories/text_recognition_service.dart';
import 'package:ubantu/domain/usecases/extract_ktm_data_usecase.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  ServiceLocator._internal();

  late final MockTaskService mockTaskService = MockTaskService();
  late final SupabaseTaskService supabaseTaskService = SupabaseTaskService();
  late final SupabaseOrderService supabaseOrderService = SupabaseOrderService();
  late final SupabaseSosService supabaseSosService = SupabaseSosService();
  late final SupabaseStorageService supabaseStorageService = SupabaseStorageService();

  late final IAuthRepository authRepository = AuthRepositoryImpl();
  late final ITaskRepository taskRepository =
      TaskRepositoryImpl(
        mockService: mockTaskService,
        remoteService: supabaseTaskService,
      );
  late final ISosRepository sosRepository =
      SosRepositoryImpl(service: supabaseSosService);
  late final IServiceOrderRepository serviceOrderRepository =
      ServiceOrderRepositoryImpl(service: supabaseOrderService);
  late final IChatRepository chatRepository = ChatRepositoryImpl();
  late final IMitraRepository mitraRepository = MitraRepositoryImpl();
  late final NotificationService notificationService = NotificationService();
  late final SupabaseNotificationService supabaseNotificationService =
      SupabaseNotificationService();
  late final INotificationRepository notificationRepository =
      NotificationRepositoryImpl(
        service: notificationService,
        remoteService: supabaseNotificationService,
      );

  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final GetTasksUseCase getTasksUseCase = GetTasksUseCase(taskRepository);
  late final SubmitSosUseCase submitSosUseCase = SubmitSosUseCase(sosRepository);
  late final CreateServiceOrderUseCase createServiceOrderUseCase =
      CreateServiceOrderUseCase(serviceOrderRepository);
  late final GetActiveOrdersUseCase getActiveOrdersUseCase =
      GetActiveOrdersUseCase(serviceOrderRepository);
  late final AcceptOrderUseCase acceptOrderUseCase =
      AcceptOrderUseCase(serviceOrderRepository);
  late final UpdateOrderStatusUseCase updateOrderStatusUseCase =
      UpdateOrderStatusUseCase(serviceOrderRepository);
  late final CompleteOrderWithProofUseCase completeOrderWithProofUseCase =
      CompleteOrderWithProofUseCase(serviceOrderRepository);
  late final GetChatRoomsUseCase getChatRoomsUseCase =
      GetChatRoomsUseCase(chatRepository);
  late final GetChatMessagesUseCase getChatMessagesUseCase =
      GetChatMessagesUseCase(chatRepository);
  late final SendChatMessageUseCase sendChatMessageUseCase =
      SendChatMessageUseCase(chatRepository);
  late final SendOtpUseCase sendOtpUseCase = SendOtpUseCase(authRepository);
  late final VerifyOtpUseCase verifyOtpUseCase = VerifyOtpUseCase(authRepository);
  late final ResendSignupOtpUseCase resendSignupOtpUseCase =
      ResendSignupOtpUseCase(authRepository);
  late final SendPasswordResetOtpUseCase sendPasswordResetOtpUseCase =
      SendPasswordResetOtpUseCase(authRepository);
  late final VerifyRecoveryOtpUseCase verifyRecoveryOtpUseCase =
      VerifyRecoveryOtpUseCase(authRepository);
  late final UpdatePasswordUseCase updatePasswordUseCase =
      UpdatePasswordUseCase(authRepository);
  late final UpdateUserProfileUseCase updateUserProfileUseCase =
      UpdateUserProfileUseCase(authRepository);
  late final ITextRecognitionService textRecognitionService =
      MlKitTextRecognitionService();
  late final ExtractKtmDataUseCase extractKtmDataUseCase =
      ExtractKtmDataUseCase(textRecognitionService);
}
