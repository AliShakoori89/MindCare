sealed class AuthEvent {}

final class AuthStarted extends AuthEvent {}

final class SendOtpRequested extends AuthEvent {
  final String email;

  SendOtpRequested(this.email);
}

final class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;

  VerifyOtpRequested({
    required this.email,
    required this.code,
  });
}

final class LogoutRequested extends AuthEvent {}