import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/app/router/app_router.dart';
import 'package:mind_care/app/theme/app_theme.dart';

import '../Core/DI/injection.dart';
import '../Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import '../Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider(create: (_) => sl<JournalBloc>()),
      ],
      child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MindCare',
          theme: AppTheme.light(),
          routerConfig: appRouter,

          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
        )
    );
  }
}
