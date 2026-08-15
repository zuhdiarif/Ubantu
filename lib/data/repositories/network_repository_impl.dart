import 'package:ubantu/data/services/connectivity_service.dart';
import 'package:ubantu/domain/repositories/network_repository.dart';

class NetworkRepositoryImpl implements INetworkRepository {
  final ConnectivityService _service;

  NetworkRepositoryImpl({ConnectivityService? service})
      : _service = service ?? ConnectivityService();

  @override
  bool isConnected() => _service.isOnline;

  @override
  void setConnectionStatus(bool online) {
    _service.updateConnectionStatus(online);
  }
}
