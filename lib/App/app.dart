import 'package:flutter/material.dart';
import 'package:mind_care/app/router/app_router.dart';
import 'package:mind_care/app/theme/app_theme.dart';

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MindCare',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
