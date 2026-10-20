import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Repositories/auth_repository.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetCurrentSession useCase;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'token-123',
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentSession(repository);
  });

  test('returns the current session from repository', () async {
    when(
          () => repository.getCurrentSession(),
    ).thenAnswer((_) async => session);

    final result = await useCase();

    expect(result, same(session));

    verify(
          () => repository.getCurrentSession(),
    ).called(1);
  });

  test('returns null when repository has no current session', () async {
    when(
          () => repository.getCurrentSession(),
    ).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);

    verify(
          () => repository.getCurrentSession(),
    ).called(1);
  });
}