import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/get_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/login_usecase.dart';
import 'package:ubantu/domain/usecases/submit_sos_usecase.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  ServiceLocator._internal();

  late final MockTaskService mockTaskService = MockTaskService();

  late final IAuthRepository authRepository = AuthRepositoryImpl();
  late final ITaskRepository taskRepository =
      TaskRepositoryImpl(taskService: mockTaskService);
  late final ISosRepository sosRepository = SosRepositoryImpl();

  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final GetTasksUseCase getTasksUseCase = GetTasksUseCase(taskRepository);
  late final SubmitSosUseCase submitSosUseCase = SubmitSosUseCase(sosRepository);
}
