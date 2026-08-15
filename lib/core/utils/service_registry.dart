import 'package:ubantu/data/services/storage_service.dart';

class ServiceRegistry {
  static final ServiceRegistry instance = ServiceRegistry._internal();

  ServiceRegistry._internal();

  late final StorageService storageService = StorageService();
}
