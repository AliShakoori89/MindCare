import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Domain/Repositories/auth_repository.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/send_otp.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SendOtp useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SendOtp(repository);
  });

  test('calls repository.sendOtp with the given email', () async {
    when(
          () => repository.sendOtp(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    await useCase(email: 'test@example.com');

    verify(
          () => repository.sendOtp(email: 'test@example.com'),
    ).called(1);
  });
}