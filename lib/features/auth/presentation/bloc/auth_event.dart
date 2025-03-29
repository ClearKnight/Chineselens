import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// 应用启动时检查认证状态
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LogInRequested extends AuthEvent {
  final String email;
  final String password;

  const LogInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

// Google登录事件
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class UserStreamRequested extends AuthEvent {
  const UserStreamRequested();
}

class VerifyEmailRequested extends AuthEvent {
  const VerifyEmailRequested();
}

class UpdateUserProfileRequested extends AuthEvent {
  final String? name;
  final String? photoUrl;

  const UpdateUserProfileRequested({
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, photoUrl];
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}
