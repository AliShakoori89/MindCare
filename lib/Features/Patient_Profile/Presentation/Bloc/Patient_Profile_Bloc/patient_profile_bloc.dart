import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';

import 'patient_profile_event.dart';
import 'patient_profile_state.dart';

class PatientProfileBloc
    extends Bloc<PatientProfileEvent, PatientProfileState> {
  final CreatePatientProfile _createPatientProfile;
  final GetPatientProfileById _getPatientProfileById;
  final GetPatientProfileByUserId _getPatientProfileByUserId;
  final UpdatePatientProfile _updatePatientProfile;
  final DeletePatientProfile _deletePatientProfile;

  PatientProfileBloc(
      this._createPatientProfile,
      this._getPatientProfileById,
      this._getPatientProfileByUserId,
      this._updatePatientProfile,
      this._deletePatientProfile,
      ) : super(const PatientProfileInitial()) {
    on<CreatePatientProfileEvent>(_onCreatePatientProfile);
    on<GetPatientProfileByIdEvent>(_onGetPatientProfileById);
    on<GetPatientProfileByUserIdEvent>(_onGetPatientProfileByUserId);
    on<UpdatePatientProfileEvent>(_onUpdatePatientProfile);
    on<DeletePatientProfileEvent>(_onDeletePatientProfile);
  }

  Future<void> _onCreatePatientProfile(
      CreatePatientProfileEvent event,
      Emitter<PatientProfileState> emit,
      ) async {
    emit(const PatientProfileLoading());

    try {
      await _createPatientProfile(event.profile);

      emit(PatientProfileCreated(event.profile));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> _onGetPatientProfileById(
      GetPatientProfileByIdEvent event,
      Emitter<PatientProfileState> emit,
      ) async {
    emit(const PatientProfileLoading());

    try {
      final profile = await _getPatientProfileById(event.id);

      if (profile == null) {
        emit(
          const PatientProfileError(
            'Patient profile not found.',
          ),
        );
        return;
      }

      emit(PatientProfileLoaded(profile));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> _onGetPatientProfileByUserId(
      GetPatientProfileByUserIdEvent event,
      Emitter<PatientProfileState> emit,
      ) async {
    emit(const PatientProfileLoading());

    try {
      final profile = await _getPatientProfileByUserId(
        event.userId,
      );

      if (profile == null) {
        emit(
          const PatientProfileError(
            'Patient profile not found.',
          ),
        );
        return;
      }

      emit(PatientProfileLoaded(profile));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> _onUpdatePatientProfile(
      UpdatePatientProfileEvent event,
      Emitter<PatientProfileState> emit,
      ) async {
    emit(const PatientProfileLoading());

    try {
      await _updatePatientProfile(event.profile);

      emit(PatientProfileUpdated(event.profile));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> _onDeletePatientProfile(
      DeletePatientProfileEvent event,
      Emitter<PatientProfileState> emit,
      ) async {
    emit(const PatientProfileLoading());

    try {
      await _deletePatientProfile(event.id);

      emit(const PatientProfileDeleted());
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }
}