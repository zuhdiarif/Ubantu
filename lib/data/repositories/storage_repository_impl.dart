import 'package:ubantu/data/services/storage_service.dart';
import 'package:ubantu/domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements IStorageRepository {
  final StorageService _storageService;

  StorageRepositoryImpl({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  @override
  Future<bool> saveString(String key, String value) {
    return _storageService.saveString(key, value);
  }

  @override
  Future<String?> getString(String key) {
    return _storageService.getString(key);
  }

  @override
  Future<bool> clear() {
    return _storageService.clear();
  }
}
