import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/service_order_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/accept_order_usecase.dart';
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
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/usecases/update_order_status_usecase.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  ServiceLocator._internal();

  late final MockTaskService mockTaskService = MockTaskService();
  late final SupabaseOrderService supabaseOrderService = SupabaseOrderService();

  late final IAuthRepository authRepository = AuthRepositoryImpl();
  late final ITaskRepository taskRepository =
      TaskRepositoryImpl(mockService: mockTaskService);
  late final ISosRepository sosRepository = SosRepositoryImpl();
  late final IServiceOrderRepository serviceOrderRepository =
      ServiceOrderRepositoryImpl(service: supabaseOrderService);
  late final IChatRepository chatRepository = ChatRepositoryImpl();
  late final IMitraRepository mitraRepository = MitraRepositoryImpl();

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
  late final GetChatRoomsUseCase getChatRoomsUseCase =
      GetChatRoomsUseCase(chatRepository);
  late final GetChatMessagesUseCase getChatMessagesUseCase =
      GetChatMessagesUseCase(chatRepository);
  late final SendChatMessageUseCase sendChatMessageUseCase =
      SendChatMessageUseCase(chatRepository);
}
