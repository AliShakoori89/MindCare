
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/create_journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/delete_journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/get_journal_entries_by_user_id.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/get_journal_entry_by_id.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/update_journal_entry.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_bloc.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_event.dart';
import 'package:mind_care/Features/Journal/Presentation/Bloc/journal_Bloc/journal_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Repositories/journal_repository.dart';

class MockJournalRepository extends Mock implements JournalRepository {}

class FakeJournalEntry extends Fake implements JournalEntry {}

void main() {
  late MockJournalRepository repository;
  late JournalBloc bloc;

  final now = DateTime(2026, 1, 1);

  final entry = JournalEntry(
    id: 'entry-1',
    userId: 'user-1',
    content: 'امروز حس خوبی داشتم.',
    mood: 4,
    tags: 'روزانه',
    createdAt: now,
    updatedAt: now,
  );

  setUpAll(() {
    registerFallbackValue(FakeJournalEntry());
  });

  setUp(() {
    repository = MockJournalRepository();

    bloc = JournalBloc(
      createJournalEntry: CreateJournalEntry(repository),
      getJournalEntryById: GetJournalEntryById(repository),
      getJournalEntriesByUserId: GetJournalEntriesByUserId(repository),
      updateJournalEntry: UpdateJournalEntry(repository),
      deleteJournalEntry: DeleteJournalEntry(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('JournalBloc', () {
    blocTest<JournalBloc, JournalState>(
      'emits loading and success when creating an entry',
      build: () {
        when(() => repository.createJournalEntry(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(CreateJournalEntryEvent(entry)),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalOperationSuccess>().having(
              (state) => state.message,
          'message',
          'یادداشت با موفقیت ثبت شد.',
        ),
      ],
      verify: (_) {
        verify(() => repository.createJournalEntry(entry)).called(1);
      },
    );

    blocTest<JournalBloc, JournalState>(
      'emits loading and the requested entry',
      build: () {
        when(() => repository.getJournalEntryById('entry-1'))
            .thenAnswer((_) async => entry);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadJournalEntryByIdEvent('entry-1')),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalEntryLoaded>().having(
              (state) => state.entry.id,
          'entry id',
          'entry-1',
        ),
      ],
    );

    blocTest<JournalBloc, JournalState>(
      'emits not found when the entry does not exist',
      build: () {
        when(() => repository.getJournalEntryById('missing'))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadJournalEntryByIdEvent('missing')),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalEntryNotFound>(),
      ],
    );

    blocTest<JournalBloc, JournalState>(
      'emits loading and user entries',
      build: () {
        when(() => repository.getJournalEntriesByUserId('user-1'))
            .thenAnswer((_) async => [entry]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadJournalEntriesByUserIdEvent('user-1')),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalEntriesLoaded>().having(
              (state) => state.entries.length,
          'entries count',
          1,
        ),
      ],
    );

    blocTest<JournalBloc, JournalState>(
      'emits loading and success when updating an entry',
      build: () {
        when(() => repository.updateJournalEntry(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateJournalEntryEvent(entry)),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalOperationSuccess>().having(
              (state) => state.message,
          'message',
          'یادداشت با موفقیت ویرایش شد.',
        ),
      ],
    );

    blocTest<JournalBloc, JournalState>(
      'emits loading and success when deleting an entry',
      build: () {
        when(() => repository.deleteJournalEntry('entry-1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteJournalEntryEvent('entry-1')),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalOperationSuccess>().having(
              (state) => state.message,
          'message',
          'یادداشت با موفقیت حذف شد.',
        ),
      ],
    );

    blocTest<JournalBloc, JournalState>(
      'emits error when creating an entry fails',
      build: () {
        when(() => repository.createJournalEntry(any()))
            .thenThrow(Exception('Database error'));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateJournalEntryEvent(entry)),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalError>(),
      ],
    );
  });
}
