import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/auth_models.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isPendingVerification;
  final String? error;
  final String? debugResetCode;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.isPendingVerification = false,
    this.error,
    this.debugResetCode,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isLoggedIn,
    bool? isPendingVerification,
    String? error,
    String? debugResetCode,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPendingVerification: isPendingVerification ?? this.isPendingVerification,
      error: error,
      debugResetCode: debugResetCode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isPendingVerification: false);
    final result = await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    if (result['success'] == true) {
      final user = await _repository.getMe();
      state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
        isPendingVerification: result['pending'] == true,
      );
      return false;
    }
  }

  Future<bool> register({
    required String phoneNumber,
    required String fullName,
    required String studentId,
    required String course,
    required int yearOfStudy,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.register(
      phoneNumber: phoneNumber,
      fullName: fullName,
      studentId: studentId,
      course: course,
      yearOfStudy: yearOfStudy,
      password: password,
    );
    if (result['success'] == true) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['error']);
      return false;
    }
  }

  Future<bool> forgotPassword({required String phoneNumber}) async {
    state = state.copyWith(isLoading: true, error: null, debugResetCode: null);
    final result = await _repository.forgotPassword(phoneNumber: phoneNumber);
    state = state.copyWith(
      isLoading: false,
      error: result['success'] == true ? null : result['error'],
      debugResetCode: result['success'] == true ? result['debugCode'] : null,
    );
    return result['success'] == true;
  }

  Future<bool> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.resetPassword(
      phoneNumber: phoneNumber,
      code: code,
      newPassword: newPassword,
    );
    state = state.copyWith(
      isLoading: false,
      error: result['success'] == true ? null : result['error'],
    );
    return result['success'] == true;
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getMe();
      state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoggedIn: false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
