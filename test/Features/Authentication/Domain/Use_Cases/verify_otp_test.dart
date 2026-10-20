import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Repositories/auth_repository.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/verify_otp.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late VerifyOtp useCase;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'token-123',
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = VerifyOtp(repository);
  });

  test('calls repository.verifyOtp with email and code', () async {
    when(
          () => repository.verifyOtp(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => session);

    final result = await useCase(
      email: 'test@example.com',
      code: '12345',
    );

    expect(result, same(session));

    verify(
          () => repository.verifyOtp(
        email: 'test@example.com',
        code: '12345',
      ),
    ).called(1);
  });
}