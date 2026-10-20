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

  const testSession = AuthSession(
    userId: 'user-1',
    email: 'user@example.com',
    accessToken: 'test-access-token',
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
      'emits AuthLoading then Unauthenticated when no session exists',
      build: () {
        when(() => getCurrentSession()).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(() => getCurrentSession()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading then Authenticated when a session exists',
      build: () {
        when(() => getCurrentSession())
            .thenAnswer((_) async => testSession);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having(
              (state) => state.session.userId,
          'userId',
          testSession.userId,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when loading the session throws AuthException',
      build: () {
        when(() => getCurrentSession()).thenThrow(
          const AuthException('خطا در دریافت نشست'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'خطا در دریافت نشست',
        ),
      ],
    );
  });

  group('SendOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading then OtpSent on success',
      build: () {
        when(() => sendOtp(email: 'user@example.com'))
            .thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested('user@example.com'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<OtpSent>()
            .having((state) => state.email, 'email', 'user@example.com'),
      ],
      verify: (_) {
        verify(() => sendOtp(email: 'user@example.com')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'trims the email and converts it to lowercase',
      build: () {
        when(() => sendOtp(email: 'User@Example.com'))
            .thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested('  User@Example.com  '),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<OtpSent>()
            .having((state) => state.email, 'email', 'user@example.com'),
      ],
      verify: (_) {
        verify(() => sendOtp(email: 'User@Example.com')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when sending OTP fails',
      build: () {
        when(() => sendOtp(email: 'user@example.com')).thenThrow(
          const AuthException('ارسال کد ناموفق بود'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested('user@example.com'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'ارسال کد ناموفق بود',
        ),
      ],
    );
  });

  group('VerifyOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading then Authenticated on success',
      build: () {
        when(
              () => verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).thenAnswer((_) async => testSession);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'user@example.com',
          code: '12345',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having(
              (state) => state.session.accessToken,
          'accessToken',
          testSession.accessToken,
        ),
      ],
      verify: (_) {
        verify(
              () => verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'trims email and OTP code before verification',
      build: () {
        when(
              () => verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).thenAnswer((_) async => testSession);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: ' user@example.com ',
          code: ' 12345 ',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(
              () => verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when OTP verification fails',
      build: () {
        when(
              () => verifyOtp(
            email: 'user@example.com',
            code: '00000',
          ),
        ).thenThrow(
          const AuthException('کد تأیید نامعتبر است'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'user@example.com',
          code: '00000',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'کد تأیید نامعتبر است',
        ),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading then Unauthenticated on success',
      build: () {
        when(() => logout()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(() => logout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when logout fails',
      build: () {
        when(() => logout()).thenThrow(
          const AuthException('خروج از حساب ناموفق بود'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
              (state) => state.message,
          'message',
          'خروج از حساب ناموفق بود',
        ),
      ],
    );
  });
}
