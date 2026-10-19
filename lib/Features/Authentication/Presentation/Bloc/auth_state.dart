import '../../Domain/Entities/auth_session.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class OtpSent extends AuthState {
  final String email;
  final int? expiresIn;

  OtpSent({
    required this.email,
    this.expiresIn,
  });
}

final class Authenticated extends AuthState {
  final AuthSession session;

  Authenticated(this.session);
}

final class Unauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}