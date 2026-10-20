import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_local_data_source_impl.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';

class MockFlutterSecureStorage extends Mock
    implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late AuthLocalDataSourceImpl dataSource;

  const session = AuthSession(
    userId: 'user-1',
    email: 'user@example.com',
    accessToken: 'access-token',
  );

  setUp(() {
    storage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(storage);
  });

  group('saveSession', () {
    test('writes userId, email and accessToken to secure storage', () async {
      when(
            () => storage.write(
          key: 'auth_user_id',
          value: 'user-1',
        ),
      ).thenAnswer((_) async {});

      when(
            () => storage.write(
          key: 'auth_email',
          value: 'user@example.com',
        ),
      ).thenAnswer((_) async {});

      when(
            () => storage.write(
          key: 'auth_access_token',
          value: 'access-token',
        ),
      ).thenAnswer((_) async {});

      await dataSource.saveSession(session);

      verify(
            () => storage.write(
          key: 'auth_user_id',
          value: 'user-1',
        ),
      ).called(1);

      verify(
            () => storage.write(
          key: 'auth_email',
          value: 'user@example.com',
        ),
      ).called(1);

      verify(
            () => storage.write(
          key: 'auth_access_token',
          value: 'access-token',
        ),
      ).called(1);
    });
  });

  group('getSession', () {
    test('returns null when userId is missing', () async {
      when(
            () => storage.read(key: 'auth_user_id'),
      ).thenAnswer((_) async => null);

      when(
            () => storage.read(key: 'auth_email'),
      ).thenAnswer((_) async => 'user@example.com');

      when(
            () => storage.read(key: 'auth_access_token'),
      ).thenAnswer((_) async => 'access-token');

      final result = await dataSource.getSession();

      expect(result, isNull);
    });

    test('returns null when email is missing', () async {
      when(
            () => storage.read(key: 'auth_user_id'),
      ).thenAnswer((_) async => 'user-1');

      when(
            () => storage.read(key: 'auth_email'),
      ).thenAnswer((_) async => null);

      when(
            () => storage.read(key: 'auth_access_token'),
      ).thenAnswer((_) async => 'access-token');

      final result = await dataSource.getSession();

      expect(result, isNull);
    });

    test('returns null when accessToken is missing', () async {
      when(
            () => storage.read(key: 'auth_user_id'),
      ).thenAnswer((_) async => 'user-1');

      when(
            () => storage.read(key: 'auth_email'),
      ).thenAnswer((_) async => 'user@example.com');

      when(
            () => storage.read(key: 'auth_access_token'),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getSession();

      expect(result, isNull);
    });

    test('returns null when any stored value is empty', () async {
      when(
            () => storage.read(key: 'auth_user_id'),
      ).thenAnswer((_) async => '');

      when(
            () => storage.read(key: 'auth_email'),
      ).thenAnswer((_) async => 'user@example.com');

      when(
            () => storage.read(key: 'auth_access_token'),
      ).thenAnswer((_) async => 'access-token');

      final result = await dataSource.getSession();

      expect(result, isNull);
    });

    test('returns AuthSession when all values are valid', () async {
      when(
            () => storage.read(key: 'auth_user_id'),
      ).thenAnswer((_) async => 'user-1');

      when(
            () => storage.read(key: 'auth_email'),
      ).thenAnswer((_) async => 'user@example.com');

      when(
            () => storage.read(key: 'auth_access_token'),
      ).thenAnswer((_) async => 'access-token');

      final result = await dataSource.getSession();

      expect(result, isNotNull);
      expect(result!.userId, 'user-1');
      expect(result.email, 'user@example.com');
      expect(result.accessToken, 'access-token');
    });
  });

  group('clearSession', () {
    test('deletes userId, email and accessToken from secure storage',
            () async {
          when(
                () => storage.delete(key: 'auth_user_id'),
          ).thenAnswer((_) async {});

          when(
                () => storage.delete(key: 'auth_email'),
          ).thenAnswer((_) async {});

          when(
                () => storage.delete(key: 'auth_access_token'),
          ).thenAnswer((_) async {});

          await dataSource.clearSession();

          verify(
                () => storage.delete(key: 'auth_user_id'),
          ).called(1);

          verify(
                () => storage.delete(key: 'auth_email'),
          ).called(1);

          verify(
                () => storage.delete(key: 'auth_access_token'),
          ).called(1);
        });
  });
}