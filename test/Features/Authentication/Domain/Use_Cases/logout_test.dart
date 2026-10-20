import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Features/Authentication/Domain/Repositories/auth_repository.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/logout.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late Logout useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = Logout(repository);
  });

  test('calls repository.logout', () async {
    when(
          () => repository.logout(),
    ).thenAnswer((_) async {});

    await useCase();

    verify(
          () => repository.logout(),
    ).called(1);
  });
}