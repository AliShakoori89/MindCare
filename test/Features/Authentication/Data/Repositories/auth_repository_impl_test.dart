import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_local_data_source.dart';
import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_remote_data_source.dart';
import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_remote_data_source_impl.dart';
import 'package:mind_care/Features/Authentication/Data/Repositories/auth_repository_impl.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Failures/auth_exception.dart';

class MockAuthRemoteDataSource extends Mock
    implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock
    implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late AuthRepositoryImpl repository;

  const session = AuthSession(
    userId: 'user-1',
    email: 'user@example.com',
    accessToken: 'access-token',
  );

  setUpAll(() {
    registerFallbackValue(session);
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();

    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    when(() => localDataSource.clearSession())
        .thenAnswer((_) async {});
  });

  group('sendOtp', () {
    test('calls remote data source with the provided email', () async {
      when(
            () => remoteDataSource.sendOtp(
          email: 'user@example.com',
        ),
      ).thenAnswer((_) async {});

      await repository.sendOtp(
        email: 'user@example.com',
      );

      verify(
            () => remoteDataSource.sendOtp(
          email: 'user@example.com',
        ),
      ).called(1);
    });

    test('maps AuthApiException to AuthException', () async {
      when(
            () => remoteDataSource.sendOtp(
          email: 'user@example.com',
        ),
      ).thenThrow(
        const AuthApiException(
          'ایمیل قبلاً ثبت شده است',
          statusCode: 409,
        ),
      );

      expect(
            () => repository.sendOtp(
          email: 'user@example.com',
        ),
        throwsA(
          isA<AuthException>()
              .having(
                (error) => error.message,
            'message',
            'ایمیل قبلاً ثبت شده است',
          )
              .having(
                (error) => error.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });
  });

  group('verifyOtp', () {
    test(
      'gets session from remote and saves it locally',
          () async {
        when(
              () => remoteDataSource.verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).thenAnswer((_) async => session);

        when(
              () => localDataSource.saveSession(session),
        ).thenAnswer((_) async {});

        final result = await repository.verifyOtp(
          email: 'user@example.com',
          code: '12345',
        );

        expect(result, same(session));

        verify(
              () => remoteDataSource.verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).called(1);

        verify(
              () => localDataSource.saveSession(session),
        ).called(1);
      },
    );

    test(
      'maps AuthApiException and does not save the session',
          () async {
        when(
              () => remoteDataSource.verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
        ).thenThrow(
          const AuthApiException(
            'کد تأیید نامعتبر است',
            statusCode: 401,
          ),
        );

        expect(
              () => repository.verifyOtp(
            email: 'user@example.com',
            code: '12345',
          ),
          throwsA(
            isA<AuthException>()
                .having(
                  (error) => error.message,
              'message',
              'کد تأیید نامعتبر است',
            )
                .having(
                  (error) => error.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        verifyNever(
              () => localDataSource.saveSession(any()),
        );
      },
    );
  });

  group('getCurrentSession', () {
    test(
      'returns null without calling remote when no local session exists',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => null);

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verify(
              () => localDataSource.getSession(),
        ).called(1);

        verifyNever(
              () => remoteDataSource.getCurrentSession(
            accessToken: any(named: 'accessToken'),
          ),
        );
      },
    );

    test(
      'validates the saved session against the remote server',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: 'access-token',
          ),
        ).thenAnswer((_) async => session);

        final result = await repository.getCurrentSession();

        expect(result, same(session));

        verify(
              () => localDataSource.getSession(),
        ).called(1);

        verify(
              () => remoteDataSource.getCurrentSession(
            accessToken: 'access-token',
          ),
        ).called(1);
      },
    );

    test(
      'clears local session and returns null when server returns 401',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: 'access-token',
          ),
        ).thenThrow(
          const AuthApiException(
            'توکن منقضی شده است',
            statusCode: 401,
          ),
        );

        when(
              () => localDataSource.clearSession(),
        ).thenAnswer((_) async {});

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verify(
              () => localDataSource.clearSession(),
        ).called(1);
      },
    );

    test(
      'clears local session and returns null when server returns 403',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: 'access-token',
          ),
        ).thenThrow(
          const AuthApiException(
            'دسترسی غیرمجاز',
            statusCode: 403,
          ),
        );

        when(
              () => localDataSource.clearSession(),
        ).thenAnswer((_) async {});

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verify(
              () => localDataSource.clearSession(),
        ).called(1);
      },
    );

    test(
      'maps non-authentication AuthApiException',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: 'access-token',
          ),
        ).thenThrow(
          const AuthApiException(
            'خطای سرور',
            statusCode: 500,
          ),
        );

        expect(
              () => repository.getCurrentSession(),
          throwsA(
            isA<AuthException>()
                .having(
                  (error) => error.message,
              'message',
              'خطای سرور',
            )
                .having(
                  (error) => error.statusCode,
              'statusCode',
              500,
            ),
          ),
        );

        verifyNever(
              () => localDataSource.clearSession(),
        );
      },
    );
  });

  group('logout', () {
    test(
      'calls remote logout and always clears local session',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.logout(
            accessToken: 'access-token',
          ),
        ).thenAnswer((_) async {});

        when(
              () => localDataSource.clearSession(),
        ).thenAnswer((_) async {});

        await repository.logout();

        verify(
              () => remoteDataSource.logout(
            accessToken: 'access-token',
          ),
        ).called(1);

        verify(
              () => localDataSource.clearSession(),
        ).called(1);
      },
    );

    test(
      'clears local session even when remote logout fails',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => session);

        when(
              () => remoteDataSource.logout(
            accessToken: 'access-token',
          ),
        ).thenThrow(
          const AuthApiException(
            'خطای سرور',
            statusCode: 500,
          ),
        );

        when(
              () => localDataSource.clearSession(),
        ).thenAnswer((_) async {});

        await repository.logout();

        verify(
              () => remoteDataSource.logout(
            accessToken: 'access-token',
          ),
        ).called(1);

        verify(
              () => localDataSource.clearSession(),
        ).called(1);
      },
    );

    test(
      'clears local session without remote logout when no session exists',
          () async {
        when(
              () => localDataSource.getSession(),
        ).thenAnswer((_) async => null);

        when(
              () => localDataSource.clearSession(),
        ).thenAnswer((_) async {});

        await repository.logout();

        verify(
              () => localDataSource.getSession(),
        ).called(1);

        verifyNever(
              () => remoteDataSource.logout(
            accessToken: any(named: 'accessToken'),
          ),
        );

        verify(
              () => localDataSource.clearSession(),
        ).called(1);
      },
    );
  });
}