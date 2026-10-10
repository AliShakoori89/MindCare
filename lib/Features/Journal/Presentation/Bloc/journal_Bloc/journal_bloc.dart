import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Use_Cases/create_journal_entry.dart';
import '../../../Domain/Use_Cases/delete_journal_entry.dart';
import '../../../Domain/Use_Cases/get_journal_entries_by_user_id.dart';
import '../../../Domain/Use_Cases/get_journal_entry_by_id.dart';
import '../../../Domain/Use_Cases/update_journal_entry.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final CreateJournalEntry createJournalEntry;
  final GetJournalEntryById getJournalEntryById;
  final GetJournalEntriesByUserId getJournalEntriesByUserId;
  final UpdateJournalEntry updateJournalEntry;
  final DeleteJournalEntry deleteJournalEntry;

  JournalBloc({
    required this.createJournalEntry,
    required this.getJournalEntryById,
    required this.getJournalEntriesByUserId,
    required this.updateJournalEntry,
    required this.deleteJournalEntry,
  }) : super(JournalInitial()) {
    on<CreateJournalEntryEvent>((event, emit) async {
      await _execute(
        emit,
            () => createJournalEntry(event.entry),
        'یادداشت با موفقیت ثبت شد.',
      );
    });

    on<LoadJournalEntryByIdEvent>((event, emit) async {
      emit(JournalLoading());

      try {
        final entry = await getJournalEntryById(event.id);

        if (entry == null) {
          emit(JournalEntryNotFound());
        } else {
          emit(JournalEntryLoaded(entry));
        }
      } catch (error) {
        emit(JournalError(error.toString()));
      }
    });

    on<LoadJournalEntriesByUserIdEvent>((event, emit) async {
      emit(JournalLoading());

      try {
        final entries = await getJournalEntriesByUserId(event.userId);
        emit(JournalEntriesLoaded(entries));
      } catch (error) {
        emit(JournalError(error.toString()));
      }
    });

    on<UpdateJournalEntryEvent>((event, emit) async {
      await _execute(
        emit,
            () => updateJournalEntry(event.entry),
        'یادداشت با موفقیت ویرایش شد.',
      );
    });

    on<DeleteJournalEntryEvent>((event, emit) async {
      await _execute(
        emit,
            () => deleteJournalEntry(event.id),
        'یادداشت با موفقیت حذف شد.',
      );
    });
  }

  Future<void> _execute(
      Emitter<JournalState> emit,
      Future<void> Function() action,
      String successMessage,
      ) async {
    emit(JournalLoading());

    try {
      await action();
      emit(JournalOperationSuccess(successMessage));
    } catch (error) {
      emit(JournalError(error.toString()));
    }
  }
}