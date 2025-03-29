import 'package:equatable/equatable.dart';
import 'package:chinese_lens/features/auth/domain/entities/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [status, user, errorMessage, isLoading];

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AuthState.unknown() {
    return const AuthState(
      status: AuthStatus.unknown,
      isLoading: true,
    );
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
      isLoading: false,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isLoading: true,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: message,
      isLoading: false,
    );
  }
}
