import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/network_repository_impl.dart';
import 'package:ubantu/domain/repositories/network_repository.dart';

class ConnectivityProvider extends ChangeNotifier {
  final INetworkRepository _repository;

  ConnectivityProvider({INetworkRepository? repository})
      : _repository = repository ?? NetworkRepositoryImpl();

  bool get isOnline => _repository.isConnected();

  void updateConnectionStatus(bool online) {
    _repository.setConnectionStatus(online);
    notifyListeners();
  }
}
