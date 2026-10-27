import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Core/Sync/Domain/Services/sync_manager.dart';
import 'package:mind_care/Core/Sync/Presentation/sync_listener.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_event.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSyncManager extends Mock implements SyncManager {}

enum AuthStateForTest { initial, second }

void main() {
  final sl = GetIt.instance;

  late MockAuthBloc authBloc;
  late MockSyncManager syncManager;

  const session = AuthSession(
    userId: 'user-1',
    email: 'user@example.com',
    accessToken: 'test-token',
  );

  setUp(() async {
    await sl.reset();

    authBloc = MockAuthBloc();
    syncManager = MockSyncManager();

    sl.registerSingleton<SyncManager>(syncManager);

    when(() => syncManager.pushChanges()).thenAnswer((_) async {});
    when(() => syncManager.pullChanges()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<void> pumpListener(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const SyncListener(
          child: MaterialApp(home: Scaffold(body: Text('MindCare'))),
        ),
      ),
    );
  }

  testWidgets('renders child and syncs when initially authenticated', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(Authenticated(session));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    await pumpListener(tester);
    await tester.pumpAndSettle();

    expect(find.text('MindCare'), findsOneWidget);

    verify(() => syncManager.pushChanges()).called(1);
    verify(() => syncManager.pullChanges()).called(1);
  });

  testWidgets('does not sync when initially unauthenticated', (tester) async {
    when(() => authBloc.state).thenReturn(Unauthenticated());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    await pumpListener(tester);
    await tester.pumpAndSettle();

    verifyNever(() => syncManager.pushChanges());
    verifyNever(() => syncManager.pullChanges());
  });

  testWidgets('does not sync twice for repeated authenticated state', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(Authenticated(session));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    await pumpListener(tester);
    await tester.pumpAndSettle();

    // Rebuild should not trigger another sync.
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const SyncListener(
          child: MaterialApp(home: Scaffold(body: Text('MindCare updated'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => syncManager.pushChanges()).called(1);
    verify(() => syncManager.pullChanges()).called(1);
  });


  testWidgets(
    'syncs the new user after the previous sync finishes',
        (tester) async {
      const secondSession = AuthSession(
        userId: 'user-2',
        email: 'second@example.com',
        accessToken: 'second-token',
      );

      var currentState = AuthStateForTest.initial;
      final authStates = StreamController<AuthState>.broadcast();
      final firstPushCompleter = Completer<void>();
      var pushCalls = 0;

      // Use a mutable state to simulate an account switch.
      when(() => authBloc.state).thenAnswer((_) {
        return currentState == AuthStateForTest.initial
            ? Authenticated(session)
            : Authenticated(secondSession);
      });

      when(() => authBloc.stream).thenAnswer((_) => authStates.stream);

      when(() => syncManager.pushChanges()).thenAnswer((_) {
        pushCalls++;

        if (pushCalls == 1) {
          return firstPushCompleter.future;
        }

        return Future<void>.value();
      });

      await pumpListener(tester);
      await tester.pump();

      expect(pushCalls, 1);

      // Switch to the second account while the first push is pending.
      currentState = AuthStateForTest.second;
      authStates.add(Authenticated(secondSession));
      await tester.pump();

      firstPushCompleter.complete();
      await tester.pumpAndSettle();

      expect(pushCalls, 2);
      verify(() => syncManager.pullChanges()).called(1);

      await authStates.close();
    },
  );

}
