import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_event.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_state.dart';

class JournalFormPage extends StatefulWidget {
  final String userId;
  final JournalEntry? entry;

  const JournalFormPage({super.key, required this.userId, this.entry});

  @override
  State<JournalFormPage> createState() => _JournalFormPageState();
}

class _JournalFormPageState extends State<JournalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;

  int? _mood;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _tagsController = TextEditingController(text: widget.entry?.tags ?? '');
    _mood = widget.entry?.mood;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final previousEntry = widget.entry;

    final entry = JournalEntry(
      id: previousEntry?.id ?? now.microsecondsSinceEpoch.toString(),
      userId: widget.userId,
      content: _contentController.text.trim(),
      mood: _mood,
      tags: _normalizeTags(_tagsController.text),
      createdAt: previousEntry?.createdAt ?? now,
      updatedAt: now,
      deletedAt: previousEntry?.deletedAt,
    );

    final bloc = context.read<JournalBloc>();

    if (_isEditing) {
      bloc.add(UpdateJournalEntryEvent(entry));
    } else {
      bloc.add(CreateJournalEntryEvent(entry));
    }
  }

  String? _normalizeTags(String value) {
    final tags = value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .join(',');

    return tags.isEmpty ? null : tags;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'ویرایش یادداشت' : 'یادداشت جدید'),
        ),
        body: BlocConsumer<JournalBloc, JournalState>(
          listener: (context, state) {
            if (state is JournalOperationSuccess) {
              context.pop(true);
            }

            if (state is JournalError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isLoading = state is JournalLoading;

            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'امروز چه احساسی داری؟',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(5, (index) {
                        final value = index + 1;

                        return ChoiceChip(
                          label: Text('$value از ۵'),
                          selected: _mood == value,
                          onSelected: isLoading
                              ? null
                              : (_) {
                                  setState(() => _mood = value);
                                },
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _contentController,
                      enabled: !isLoading,
                      minLines: 6,
                      maxLines: 12,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'یادداشت روزانه',
                        hintText: 'هر چیزی که دوست داری بنویس...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'متن یادداشت را وارد کن.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _tagsController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'برچسب‌ها',
                        hintText: 'مثلاً خانواده، کار، آرامش',
                        helperText: 'برچسب‌ها را با کاما جدا کن.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: isLoading ? null : _save,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isLoading ? 'در حال ذخیره...' : 'ذخیره یادداشت',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
