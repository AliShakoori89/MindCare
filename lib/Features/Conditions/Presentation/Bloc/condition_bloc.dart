import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Domain/Use_Cases/create_condition.dart';
import '../../Domain/Use_Cases/delete_condition.dart';
import '../../Domain/Use_Cases/get_condition_by_id.dart';
import '../../Domain/Use_Cases/get_conditions_by_user_id.dart';
import '../../Domain/Use_Cases/update_condition.dart';
import 'condition_event.dart';
import 'condition_state.dart';

class ConditionBloc extends Bloc<ConditionEvent, ConditionState> {
  final CreateCondition _createCondition;
  final GetConditionById _getConditionById;
  final GetConditionsByUserId _getConditionsByUserId;
  final UpdateCondition _updateCondition;
  final DeleteCondition _deleteCondition;

  ConditionBloc({
    required this._createCondition,
    required this._getConditionById,
    required this._getConditionsByUserId,
    required this._updateCondition,
    required this._deleteCondition,
  }) : super(const ConditionInitial()) {
    on<CreateConditionEvent>(_onCreateCondition);
    on<GetConditionByIdEvent>(_onGetConditionById);
    on<GetConditionsByUserIdEvent>(_onGetConditionsByUserId);
    on<UpdateConditionEvent>(_onUpdateCondition);
    on<DeleteConditionEvent>(_onDeleteCondition);
  }

  Future<void> _onCreateCondition(
      CreateConditionEvent event,
      Emitter<ConditionState> emit,
      ) async {
    emit(const ConditionLoading());

    try {
      await _createCondition(event.condition);

      emit(const ConditionCreated());
    } catch (e) {
      emit(ConditionError(e.toString()));
    }
  }

  Future<void> _onGetConditionById(
      GetConditionByIdEvent event,
      Emitter<ConditionState> emit,
      ) async {
    emit(const ConditionLoading());

    try {
      final condition = await _getConditionById(event.id);

      if (condition == null) {
        emit(
          const ConditionError('Condition not found'),
        );
        return;
      }

      emit(ConditionLoaded(condition));
    } catch (e) {
      emit(ConditionError(e.toString()));
    }
  }

  Future<void> _onGetConditionsByUserId(
      GetConditionsByUserIdEvent event,
      Emitter<ConditionState> emit,
      ) async {
    emit(const ConditionLoading());

    try {
      final conditions =
      await _getConditionsByUserId(event.userId);

      emit(ConditionsLoaded(conditions));
    } catch (e) {
      emit(ConditionError(e.toString()));
    }
  }

  Future<void> _onUpdateCondition(
      UpdateConditionEvent event,
      Emitter<ConditionState> emit,
      ) async {
    emit(const ConditionLoading());

    try {
      await _updateCondition(event.condition);

      emit(const ConditionUpdated());
    } catch (e) {
      emit(ConditionError(e.toString()));
    }
  }

  Future<void> _onDeleteCondition(
      DeleteConditionEvent event,
      Emitter<ConditionState> emit,
      ) async {
    emit(const ConditionLoading());

    try {
      await _deleteCondition(event.id);

      emit(const ConditionDeleted());
    } catch (e) {
      emit(ConditionError(e.toString()));
    }
  }
}