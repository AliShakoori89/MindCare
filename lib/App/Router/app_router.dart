import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Features/Authentication/Presentation/Pages/login_page.dart';
import 'package:mind_care/Features/Authentication/Presentation/Pages/register_page.dart';
import 'package:mind_care/Features/Authentication/Presentation/Pages/splash_page.dart';
import 'package:mind_care/Features/Daily_Checkin/Presentation/Pages/daily_check_in_page.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';
import 'package:mind_care/Features/Journal/Presentation/Pages/journal_form_page.dart';
import 'package:mind_care/Features/Journal/Presentation/Pages/journal_page.dart';
import 'package:mind_care/Features/Home/Presentation/Pages/home_dashboard_page.dart';

import '../../Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import '../../Features/Authentication/Presentation/Bloc/auth_state.dart';
import 'auth_router_notifier.dart';

final AuthBloc _authBloc = sl<AuthBloc>();

final AuthRouterNotifier _authRouterNotifier = AuthRouterNotifier(_authBloc);

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  refreshListenable: _authRouterNotifier,

  redirect: (context, state) {
    final authState = _authBloc.state;
    final location = state.matchedLocation;

    final isSplash = location == '/splash';

    final isAuthRoute = location == '/login' || location == '/register';

    final isProtectedRoute = !isSplash && !isAuthRoute;

    if (authState is Authenticated) {
      if (isSplash || isAuthRoute) {
        return '/';
      }

      return null;
    }

    if (authState is Unauthenticated || authState is OtpSent) {
      if (isProtectedRoute || isSplash) {
        return '/login';
      }

      return null;
    }

    if (authState is AuthInitial) {
      if (isProtectedRoute) {
        return '/splash';
      }

      return null;
    }

    if (authState is AuthLoading) {
      if (isProtectedRoute) {
        return '/login';
      }

      return null;
    }

    if (authState is AuthFailure) {
      if (isProtectedRoute) {
        return '/splash';
      }

      return null;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) {
        final email = state.extra as String?;

        return RegisterPage(email: email ?? '');
      },
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeDashboardPage(),
    ),
    GoRoute(
      path: '/daily-check-in',
      name: 'daily-check-in',
      builder: (context, state) => const DailyCheckInPage(),
    ),
    GoRoute(
      path: '/journal/:userId',
      name: 'journal',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;

        return BlocProvider(
          create: (_) => sl<JournalBloc>(),
          child: JournalPage(userId: userId),
        );
      },
      routes: [
        GoRoute(
          path: 'form',
          name: 'journal-form',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final extra = state.extra;
            final entry = extra is JournalEntry ? extra : null;

            return BlocProvider(
              create: (_) => sl<JournalBloc>(),
              child: JournalFormPage(userId: userId, entry: entry),
            );
          },
        ),
      ],
    ),
  ],
);
