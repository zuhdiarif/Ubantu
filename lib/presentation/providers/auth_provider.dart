import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/login_usecase.dart';
import 'package:ubantu/domain/usecases/sign_in_with_google_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final IAuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider({IAuthRepository? repository})
      : this._internal(repository ?? AuthRepositoryImpl());

  AuthProvider._internal(IAuthRepository repository)
      : _repository = repository,
        _loginUseCase = LoginUseCase(repository),
        _signInWithGoogleUseCase = SignInWithGoogleUseCase(repository) {
    _currentUser = _repository.getCurrentUser();
    if (_currentUser != null) {
      AppAuthNotifier.instance.setLoggedIn(true);
    }
    _initAuthListener();
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    if (SupabaseService.instance.isInitialized) {
      _authSubscription =
          SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _currentUser = _repository.getCurrentUser();
          AppAuthNotifier.instance.setLoggedIn(true);
        } else if (data.event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          AppAuthNotifier.instance.setLoggedIn(false);
        }
        notifyListeners();
      });
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase.execute(email, password);
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = result.data;
      AppAuthNotifier.instance.setLoggedIn(true);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _signInWithGoogleUseCase.execute();
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = _repository.getCurrentUser();
      AppAuthNotifier.instance.setLoggedIn(true);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _errorMessage = null;
    AppAuthNotifier.instance.setLoggedIn(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
