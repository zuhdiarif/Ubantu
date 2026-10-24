import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';

class ToggleMitraStatusUseCase {
  final IMitraRepository _repository;

  ToggleMitraStatusUseCase(this._repository);

  Future<AppResult<bool>> execute(bool isOnline) {
    return _repository.toggleOnlineStatus(isOnline);
  }
}
