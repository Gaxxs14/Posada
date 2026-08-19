import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isInitialLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isInitialLoading = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isInitialLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthState()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    try {
      final user = await _repo.checkAuthStatus();
      state = state.copyWith(user: user, isInitialLoading: false);
    } catch (_) {
      state = state.copyWith(isInitialLoading: false, clearUser: true);
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final user = await _repo.login(identifier, password);
      state = state.copyWith(user: user, isSubmitting: false);
      return true;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final user = await _repo.register(
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      state = state.copyWith(user: user, isSubmitting: false);
      return true;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isInitialLoading: false, user: null);
  }
}
