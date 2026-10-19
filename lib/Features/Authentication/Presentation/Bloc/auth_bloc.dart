
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Data/Data_Sources/auth_remote_data_source_impl.dart';
import '../../Domain/Use_Cases/get_current_session.dart';
import '../../Domain/Use_Cases/logout.dart';
import '../../Domain/Use_Cases/send_otp.dart';
import '../../Domain/Use_Cases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final GetCurrentSession getCurrentSession;
  final Logout logout;

  AuthBloc(
      this.sendOtp,
      this.verifyOtp,
      this.getCurrentSession,
      this.logout,
      ) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthStarted(
      AuthStarted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final session = await getCurrentSession();

      if (session == null) {
        emit(Unauthenticated());
      } else {
        emit(Authenticated(session));
      }
    } catch (error) {
      emit(AuthFailure(_errorMessage(error)));
    }
  }

  Future<void> _onSendOtpRequested(
      SendOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await sendOtp(email: event.email.trim());
      emit(OtpSent(email: event.email.trim().toLowerCase()));
    } catch (error) {
      emit(AuthFailure(_errorMessage(error)));
    }
  }

  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final session = await verifyOtp(
        email: event.email.trim(),
        code: event.code.trim(),
      );

      emit(Authenticated(session));
    } catch (error) {
      emit(AuthFailure(_errorMessage(error)));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await logout();
      emit(Unauthenticated());
    } catch (error) {
      // The repository clears local credentials in its finally block.
      // Still allow the UI to report that server logout could not be confirmed.
      emit(AuthFailure(_errorMessage(error)));
    }
  }

  String _errorMessage(Object error) {
    if (error is AuthApiException) {
      return error.message;
    }

    return 'خطای غیرمنتظره‌ای رخ داد. دوباره تلاش کنید.';
  }
}
