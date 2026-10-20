
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Failures/auth_exception.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/logout.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/send_otp.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/verify_otp.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_event.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_state.dart';

class MockSendOtp extends Mock implements SendOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockSendOtp sendOtp;
  late MockVerifyOtp verifyOtp;
  late MockGetCurrentSession getCurrentSession;
  late MockLogout logout;

  late AuthBloc authBloc;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'access-token',
  );

  setUp(() {
    sendOtp = MockSendOtp();
    verifyOtp = MockVerifyOtp();
    getCurrentSession = MockGetCurrentSession();
    logout = MockLogout();

    authBloc = AuthBloc(
      sendOtp,
      verifyOtp,
      getCurrentSession,
      logout,
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when restoring session fails unexpectedly',
      build: () {
        when(() => getCurrentSession())
            .thenThrow(Exception('Network error'));

        return authBloc;
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'خطای غیرمنتظره‌ای رخ داد. دوباره تلاش کنید.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated when no session exists',
      build: () {
        when(() => getCurrentSession())
            .thenAnswer((_) async => null);

        return authBloc;
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );
  });

  group('SendOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when sending OTP fails',
      build: () {
        when(() => sendOtp(email: 'test@example.com'))
            .thenThrow(
          const AuthException(
            'ارسال کد تأیید ناموفق بود.',
            statusCode: 500,
          ),
        );

        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested('test@example.com'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'ارسال کد تأیید ناموفق بود.',
        ),
      ],
    );
  });

  group('VerifyOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated when OTP verification succeeds',
      build: () {
        when(
              () => verifyOtp(
            email: 'test@example.com',
            code: '123456',
          ),
        ).thenAnswer((_) async => session);

        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'test@example.com',
          code: '123456',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having(
              (state) => state.session,
          'session',
          session,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure with the original message on AuthException',
      build: () {
        when(
              () => verifyOtp(
            email: 'test@example.com',
            code: '000000',
          ),
        ).thenThrow(
          const AuthException(
            'کد تأیید نامعتبر است.',
            statusCode: 400,
          ),
        );

        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'test@example.com',
          code: '000000',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'کد تأیید نامعتبر است.',
        ),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when logout fails',
      build: () {
        when(() => logout()).thenThrow(
          const AuthException(
            'خروج از حساب با خطا مواجه شد.',
            statusCode: 500,
          ),
        );

        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'خروج از حساب با خطا مواجه شد.',
        ),
      ],
    );
  });
}
