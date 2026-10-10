import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Use_Cases/create_daily_check_in.dart';
import '../../../Domain/Use_Cases/delete_daily_check_in.dart';
import '../../../Domain/Use_Cases/get_daily_check_in_by_id.dart';
import '../../../Domain/Use_Cases/get_daily_check_in_by_user_and_date.dart';
import '../../../Domain/Use_Cases/get_daily_check_ins_by_user_id.dart';
import '../../../Domain/Use_Cases/update_daily_check_in.dart';
import 'daily_check_in_event.dart';
import 'daily_check_in_state.dart';

class DailyCheckInBloc
    extends Bloc<DailyCheckInEvent, DailyCheckInState> {
  final CreateDailyCheckIn createDailyCheckIn;
  final GetDailyCheckInById getDailyCheckInById;
  final GetDailyCheckInByUserAndDate
  getDailyCheckInByUserAndDate;
  final GetDailyCheckInsByUserId getDailyCheckInsByUserId;
  final UpdateDailyCheckIn updateDailyCheckIn;
  final DeleteDailyCheckIn deleteDailyCheckIn;

  DailyCheckInBloc({
    required this.createDailyCheckIn,
    required this.getDailyCheckInById,
    required this.getDailyCheckInByUserAndDate,
    required this.getDailyCheckInsByUserId,
    required this.updateDailyCheckIn,
    required this.deleteDailyCheckIn,
  }) : super(const DailyCheckInInitial()) {
    on<CreateDailyCheckInEvent>(_onCreate);
    on<LoadDailyCheckInByIdEvent>(_onLoadById);
    on<LoadDailyCheckInByUserAndDateEvent>(_onLoadByUserAndDate);
    on<LoadDailyCheckInsByUserIdEvent>(_onLoadByUserId);
    on<UpdateDailyCheckInEvent>(_onUpdate);
    on<DeleteDailyCheckInEvent>(_onDelete);
  }

  Future<void> _onCreate(
      CreateDailyCheckInEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    await _execute(
      emit,
          () => createDailyCheckIn(event.dailyCheckIn),
      'Check-in created successfully.',
    );
  }

  Future<void> _onLoadById(
      LoadDailyCheckInByIdEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    emit(const DailyCheckInLoading());

    try {
      final result = await getDailyCheckInById(event.id);

      if (result == null) {
        emit(const DailyCheckInNotFound());
      } else {
        emit(DailyCheckInLoaded(result));
      }
    } catch (error) {
      emit(DailyCheckInError(error.toString()));
    }
  }

  Future<void> _onLoadByUserAndDate(
      LoadDailyCheckInByUserAndDateEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    emit(const DailyCheckInLoading());

    try {
      final result = await getDailyCheckInByUserAndDate(
        event.userId,
        event.date,
      );

      if (result == null) {
        emit(const DailyCheckInNotFound());
      } else {
        emit(DailyCheckInLoaded(result));
      }
    } catch (error) {
      emit(DailyCheckInError(error.toString()));
    }
  }

  Future<void> _onLoadByUserId(
      LoadDailyCheckInsByUserIdEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    emit(const DailyCheckInLoading());

    try {
      final result =
      await getDailyCheckInsByUserId(event.userId);

      emit(DailyCheckInsLoaded(result));
    } catch (error) {
      emit(DailyCheckInError(error.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateDailyCheckInEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    await _execute(
      emit,
          () => updateDailyCheckIn(event.dailyCheckIn),
      'Check-in updated successfully.',
    );
  }

  Future<void> _onDelete(
      DeleteDailyCheckInEvent event,
      Emitter<DailyCheckInState> emit,
      ) async {
    await _execute(
      emit,
          () => deleteDailyCheckIn(event.id),
      'Check-in deleted successfully.',
    );
  }

  Future<void> _execute(
      Emitter<DailyCheckInState> emit,
      Future<void> Function() operation,
      String successMessage,
      ) async {
    emit(const DailyCheckInLoading());

    try {
      await operation();
      emit(DailyCheckInOperationSuccess(successMessage));
    } catch (error) {
      emit(DailyCheckInError(error.toString()));
    }
  }
}