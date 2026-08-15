import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/login_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final IAuthRepository _repository;

  AuthProvider({IAuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl(),
        _loginUseCase = LoginUseCase(repository ?? AuthRepositoryImpl());

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _loginUseCase.execute(email, password);
    if (result.isSuccess) {
      _currentUser = result.data;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}
