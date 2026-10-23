import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';

class GetMitraProfileUseCase {
  final IMitraRepository _repository;

  GetMitraProfileUseCase(this._repository);

  Future<AppResult<MitraProfileModel>> execute() {
    return _repository.getMitraProfile();
  }
}
