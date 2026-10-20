import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_event.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_state.dart';
import 'package:mind_care/Features/Authentication/Presentation/Pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(AuthStarted());
  });

  setUp(() {
    authBloc = MockAuthBloc();

    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
  });

  testWidgets(
    'shows validation error when email is invalid',
        (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'invalid-email',
      );

      await tester.tap(find.text('ارسال کد تأیید'));
      await tester.pump();

      expect(
        find.text('ایمیل معتبر نیست.'),
        findsOneWidget,
      );

    },
  );

  testWidgets(
    'shows validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.tap(find.text('ارسال کد تأیید'));
      await tester.pump();

      expect(
        find.text('ایمیل را وارد کنید.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'dispatches SendOtpRequested when email is valid',
        (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        '  test@example.com  ',
      );

      await tester.tap(find.text('ارسال کد تأیید'));
      await tester.pump();

      final capturedEvents = verify(
            () => authBloc.add(captureAny()),
      ).captured;

      expect(capturedEvents, hasLength(1));
      expect(capturedEvents.single, isA<SendOtpRequested>());

      final event = capturedEvents.single as SendOtpRequested;

      expect(event.email, 'test@example.com');
    },
  );

  testWidgets(
    'shows loading indicator when AuthBloc is loading',
        (tester) async {
      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: AuthLoading(),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'disables submit button when AuthBloc is loading',
        (tester) async {
      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: AuthLoading(),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'shows error message when AuthBloc emits AuthFailure',
        (tester) async {
      whenListen(
        authBloc,
        Stream<AuthState>.fromIterable([
          AuthFailure('خطا در ارسال کد تأیید'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('خطا در ارسال کد تأیید'),
        findsOneWidget,
      );
    },
  );
}
