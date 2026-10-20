import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_remote_data_source_impl.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRemoteDataSourceImpl dataSource;

  const session = AuthSession(
    userId: 'user-1',
    email: 'user@example.com',
    accessToken: 'access-token',
  );

  setUp(() {
    dio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio);
  });

  group('sendOtp', () {
    test('sends POST request with normalized email', () async {
      when(
            () => dio.post(
          'auth/send-otp',
          data: {
            'email': 'user@example.com',
          },
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/send-otp'),
          statusCode: 200,
          data: {'success': true},
        ),
      );

      await dataSource.sendOtp(
        email: '  USER@EXAMPLE.COM  ',
      );

      verify(
            () => dio.post(
          'auth/send-otp',
          data: {
            'email': 'user@example.com',
          },
        ),
      ).called(1);
    });

    test('throws AuthApiException when API returns success false', () async {
      when(
            () => dio.post(
          'auth/send-otp',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/send-otp'),
          statusCode: 400,
          data: {
            'success': false,
            'message': 'ایمیل معتبر نیست',
          },
        ),
      );

      expect(
            () => dataSource.sendOtp(email: 'user@example.com'),
        throwsA(
          isA<AuthApiException>()
              .having(
                (error) => error.message,
            'message',
            'ایمیل معتبر نیست',
          )
              .having(
                (error) => error.statusCode,
            'statusCode',
            400,
          ),
        ),
      );
    });

    test('maps DioException with server message', () async {
      when(
            () => dio.post(
          'auth/send-otp',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/send-otp'),
          response: Response(
            requestOptions: RequestOptions(path: 'auth/send-otp'),
            statusCode: 409,
            data: {
              'message': 'این ایمیل قبلاً ثبت شده است',
            },
          ),
        ),
      );

      expect(
            () => dataSource.sendOtp(email: 'user@example.com'),
        throwsA(
          isA<AuthApiException>()
              .having(
                (error) => error.message,
            'message',
            'این ایمیل قبلاً ثبت شده است',
          )
              .having(
                (error) => error.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });

    test('maps DioException without response as network error', () async {
      when(
            () => dio.post(
          'auth/send-otp',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/send-otp'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
            () => dataSource.sendOtp(email: 'user@example.com'),
        throwsA(
          isA<AuthApiException>().having(
                (error) => error.message,
            'message',
            'ارتباط با سرور برقرار نشد. اتصال شبکه را بررسی کنید.',
          ),
        ),
      );
    });
  });

  group('verifyOtp', () {
    test('sends email and code and returns AuthSession', () async {
      when(
            () => dio.post(
          'auth/verify-otp',
          data: {
            'email': 'user@example.com',
            'code': '12345',
          },
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/verify-otp'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'token': 'access-token',
              'user': {
                'id': 'user-1',
                'email': 'user@example.com',
              },
            },
          },
        ),
      );

      final result = await dataSource.verifyOtp(
        email: '  USER@EXAMPLE.COM  ',
        code: ' 12345 ',
      );

      expect(result.userId, session.userId);
      expect(result.email, session.email);
      expect(result.accessToken, session.accessToken);

      verify(
            () => dio.post(
          'auth/verify-otp',
          data: {
            'email': 'user@example.com',
            'code': '12345',
          },
        ),
      ).called(1);
    });

    test('throws AuthApiException when API returns success false', () async {
      when(
            () => dio.post(
          'auth/verify-otp',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/verify-otp'),
          statusCode: 401,
          data: {
            'success': false,
            'message': 'کد تأیید نامعتبر است',
          },
        ),
      );

      expect(
            () => dataSource.verifyOtp(
          email: 'user@example.com',
          code: '12345',
        ),
        throwsA(
          isA<AuthApiException>()
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
    });

    test('throws AuthApiException when token is missing', () async {
      when(
            () => dio.post(
          'auth/verify-otp',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/verify-otp'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'user': {
                'id': 'user-1',
                'email': 'user@example.com',
              },
            },
          },
        ),
      );

      expect(
            () => dataSource.verifyOtp(
          email: 'user@example.com',
          code: '12345',
        ),
        throwsA(
          isA<AuthApiException>().having(
                (error) => error.message,
            'message',
            'پاسخ احراز هویت از سرور معتبر نیست.',
          ),
        ),
      );
    });

    test('maps DioException with server message', () async {
      when(
            () => dio.post(
          'auth/verify-otp',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/verify-otp'),
          response: Response(
            requestOptions: RequestOptions(path: 'auth/verify-otp'),
            statusCode: 422,
            data: {
              'message': 'کد وارد شده صحیح نیست',
            },
          ),
        ),
      );

      expect(
            () => dataSource.verifyOtp(
          email: 'user@example.com',
          code: '12345',
        ),
        throwsA(
          isA<AuthApiException>()
              .having(
                (error) => error.message,
            'message',
            'کد وارد شده صحیح نیست',
          )
              .having(
                (error) => error.statusCode,
            'statusCode',
            422,
          ),
        ),
      );
    });
  });

  group('getCurrentSession', () {
    test('sends bearer token and returns AuthSession', () async {
      when(
            () => dio.get(
          'auth/me',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/me'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'user-1',
              'email': 'user@example.com',
            },
          },
        ),
      );

      final result = await dataSource.getCurrentSession(
        accessToken: 'access-token',
      );

      expect(result.userId, 'user-1');
      expect(result.email, 'user@example.com');
      expect(result.accessToken, 'access-token');

      final captured = verify(
            () => dio.get(
          'auth/me',
          options: captureAny(named: 'options'),
        ),
      ).captured;

      final options = captured.single as Options;

      expect(
        options.headers?['Authorization'],
        'Bearer access-token',
      );
    });

    test('throws AuthApiException when API returns success false', () async {
      when(
            () => dio.get(
          'auth/me',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/me'),
          statusCode: 401,
          data: {
            'success': false,
            'message': 'نشست کاربر منقضی شده است',
          },
        ),
      );

      expect(
            () => dataSource.getCurrentSession(
          accessToken: 'access-token',
        ),
        throwsA(
          isA<AuthApiException>()
              .having(
                (error) => error.message,
            'message',
            'نشست کاربر منقضی شده است',
          )
              .having(
                (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('throws AuthApiException when user data is incomplete', () async {
      when(
            () => dio.get(
          'auth/me',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/me'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'user-1',
            },
          },
        ),
      );

      expect(
            () => dataSource.getCurrentSession(
          accessToken: 'access-token',
        ),
        throwsA(
          isA<AuthApiException>().having(
                (error) => error.message,
            'message',
            'اطلاعات کاربر از سرور دریافت نشد.',
          ),
        ),
      );
    });

    test('maps DioException without message to generic server error',
            () async {
          when(
                () => dio.get(
              'auth/me',
              options: any(named: 'options'),
            ),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: 'auth/me'),
              response: Response(
                requestOptions: RequestOptions(path: 'auth/me'),
                statusCode: 500,
                data: {},
              ),
            ),
          );

          expect(
                () => dataSource.getCurrentSession(
              accessToken: 'access-token',
            ),
            throwsA(
              isA<AuthApiException>()
                  .having(
                    (error) => error.message,
                'message',
                'درخواست ناموفق بود. دوباره تلاش کنید.',
              )
                  .having(
                    (error) => error.statusCode,
                'statusCode',
                500,
              ),
            ),
          );
        });
  });

  group('logout', () {
    test('sends POST request with bearer token', () async {
      when(
            () => dio.post(
          'auth/logout',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: 'auth/logout'),
          statusCode: 200,
          data: {'success': true},
        ),
      );

      await dataSource.logout(
        accessToken: 'access-token',
      );

      final captured = verify(
            () => dio.post(
          'auth/logout',
          options: captureAny(named: 'options'),
        ),
      ).captured;

      final options = captured.single as Options;

      expect(
        options.headers?['Authorization'],
        'Bearer access-token',
      );
    });

    test('maps DioException to AuthApiException', () async {
      when(
            () => dio.post(
          'auth/logout',
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/logout'),
          response: Response(
            requestOptions: RequestOptions(path: 'auth/logout'),
            statusCode: 500,
            data: {
              'message': 'خطای سرور',
            },
          ),
        ),
      );

      expect(
            () => dataSource.logout(
          accessToken: 'access-token',
        ),
        throwsA(
          isA<AuthApiException>()
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
    });
  });
}