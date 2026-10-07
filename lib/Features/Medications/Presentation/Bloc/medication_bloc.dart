import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Domain/Use_Cases/create_medication.dart';
import '../../Domain/Use_Cases/delete_medication.dart';
import '../../Domain/Use_Cases/get_medication_by_id.dart';
import '../../Domain/Use_Cases/get_medications_by_user_id.dart';
import '../../Domain/Use_Cases/update_medication.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc
    extends Bloc<MedicationEvent, MedicationState> {
  final CreateMedication _createMedication;
  final GetMedicationById _getMedicationById;
  final GetMedicationsByUserId _getMedicationsByUserId;
  final UpdateMedication _updateMedication;
  final DeleteMedication _deleteMedication;

  MedicationBloc(
      this._createMedication,
      this._getMedicationById,
      this._getMedicationsByUserId,
      this._updateMedication,
      this._deleteMedication,
      ) : super(const MedicationInitial()) {
    on<CreateMedicationEvent>(_onCreateMedication);
    on<GetMedicationByIdEvent>(_onGetMedicationById);
    on<GetMedicationsByUserIdEvent>(_onGetMedicationsByUserId);
    on<UpdateMedicationEvent>(_onUpdateMedication);
    on<DeleteMedicationEvent>(_onDeleteMedication);
  }

  Future<void> _onCreateMedication(
      CreateMedicationEvent event,
      Emitter<MedicationState> emit,
      ) async {
    emit(const MedicationLoading());

    try {
      await _createMedication(event.medication);

      emit(const MedicationCreated());
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onGetMedicationById(
      GetMedicationByIdEvent event,
      Emitter<MedicationState> emit,
      ) async {
    emit(const MedicationLoading());

    try {
      final medication =
      await _getMedicationById(event.id);

      if (medication == null) {
        emit(const MedicationError(
          'Medication not found',
        ));
        return;
      }

      emit(MedicationLoaded(medication));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onGetMedicationsByUserId(
      GetMedicationsByUserIdEvent event,
      Emitter<MedicationState> emit,
      ) async {
    emit(const MedicationLoading());

    try {
      final medications =
      await _getMedicationsByUserId(event.userId);

      emit(MedicationsLoaded(medications));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onUpdateMedication(
      UpdateMedicationEvent event,
      Emitter<MedicationState> emit,
      ) async {
    emit(const MedicationLoading());

    try {
      await _updateMedication(event.medication);

      emit(const MedicationUpdated());
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onDeleteMedication(
      DeleteMedicationEvent event,
      Emitter<MedicationState> emit,
      ) async {
    emit(const MedicationLoading());

    try {
      await _deleteMedication(event.id);

      emit(const MedicationDeleted());
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }
}