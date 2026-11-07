import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/mitra_profile_model.dart';
import 'package:ubantu/data/repositories/mitra_repository.dart';

class GetMitraProfileUseCase {
  final IMitraRepository _repository;

  GetMitraProfileUseCase(this._repository);

  Future<AppResult<MitraProfileModel>> execute() {
    return _repository.getMitraProfile();
  }
}
