import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void updateConnectionStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
}
