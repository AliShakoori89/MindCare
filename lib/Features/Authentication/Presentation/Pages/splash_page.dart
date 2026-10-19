
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../Bloc/auth_bloc.dart';
import '../Bloc/auth_event.dart';
import '../Bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthStarted());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                context.go('/');
              } else if (state is Unauthenticated) {
                context.go('/login');
              }
            },
            builder: (context, state) {
              if (state is AuthFailure) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 52,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'برقراری ارتباط با سرور ممکن نیست.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthStarted());
                        },
                        child: const Text('تلاش مجدد'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('رفتن به صفحه ورود'),
                      ),
                    ],
                  ),
                );
              }

              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 64,
                    color: Colors.teal,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'MindCare',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
