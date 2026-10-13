import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_event.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_state.dart';

class JournalPage extends StatefulWidget {
  final String userId;

  const JournalPage({super.key, required this.userId});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    context.read<JournalBloc>().add(
      LoadJournalEntriesByUserIdEvent(widget.userId),
    );
  }

  Future<void> _openForm({JournalEntry? entry}) async {
    final result = await context.push<bool>(
      '/journal/${widget.userId}/form',
      extra: entry,
    );

    if (!mounted) return;

    if (result == true) {
      _loadEntries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یادداشت با موفقیت ذخیره شد.')),
      );
    }
  }

  Future<void> _confirmDelete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف یادداشت'),
        content: const Text('آیا از حذف این یادداشت اطمینان داری؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<JournalBloc>().add(DeleteJournalEntryEvent(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دفترچه یادداشت')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('یادداشت جدید'),
        ),
        body: BlocConsumer<JournalBloc, JournalState>(
          listener: (context, state) {
            if (state is JournalError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is JournalOperationSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));

              if (state.message == 'یادداشت با موفقیت حذف شد.') {
                _loadEntries();
              }
            }
          },
          builder: (context, state) {
            if (state is JournalInitial || state is JournalLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is JournalError) {
              return _ErrorView(onRetry: _loadEntries);
            }

            if (state is JournalEntriesLoaded) {
              if (state.entries.isEmpty) {
                return const _EmptyJournalView();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = state.entries[index];

                  return _JournalEntryCard(
                    entry: entry,
                    onEdit: () => _openForm(entry: entry),
                    onDelete: () => _confirmDelete(entry),
                  );
                },
              );
            }

            return const _EmptyJournalView();
          },
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt;
    final formattedDate =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                if (entry.mood != null)
                  Chip(
                    avatar: const Icon(Icons.mood, size: 18),
                    label: Text('حال روحی ${entry.mood}/5'),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (entry.tags != null && entry.tags!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: entry.tags!
                    .split(',')
                    .where((tag) => tag.trim().isNotEmpty)
                    .map(
                      (tag) => Chip(
                        label: Text(tag.trim()),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyJournalView extends StatelessWidget {
  const _EmptyJournalView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'هنوز یادداشتی ثبت نکرده‌ای',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'می‌توانی احساسات و اتفاقات روزت را اینجا بنویسی.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('دریافت یادداشت‌ها با خطا مواجه شد.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
          ],
        ),
      ),
    );
  }
}
