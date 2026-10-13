import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';
import 'package:mind_care/Features/Journal/Presentation/Pages/journal_form_page.dart';
import 'package:mind_care/Features/Journal/Presentation/Pages/journal_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const JournalLauncherPage(),
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

class JournalLauncherPage extends StatefulWidget {
  const JournalLauncherPage({super.key});

  @override
  State<JournalLauncherPage> createState() => _JournalLauncherPageState();
}

class _JournalLauncherPageState extends State<JournalLauncherPage> {
  final _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _openJournal() {
    final userId = _userIdController.text.trim();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('شناسه کاربر را وارد کن.')));
      return;
    }

    context.pushNamed('journal', pathParameters: {'userId': userId});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('MindCare')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'همراه سلامت تو',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'برای ورود به دفترچه یادداشت، شناسه کاربر موجود در دیتابیس را وارد کن.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userIdController,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'شناسه کاربر',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _openJournal(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _openJournal,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('ورود به دفترچه یادداشت'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
