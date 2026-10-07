import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';

sealed class PatientProfileEvent {
  const PatientProfileEvent();
}

final class CreatePatientProfileEvent extends PatientProfileEvent {
  final PatientProfile profile;

  const CreatePatientProfileEvent(this.profile);
}

final class GetPatientProfileByIdEvent extends PatientProfileEvent {
  final String id;

  const GetPatientProfileByIdEvent(this.id);
}

final class GetPatientProfileByUserIdEvent extends PatientProfileEvent {
  final String userId;

  const GetPatientProfileByUserIdEvent(this.userId);
}

final class UpdatePatientProfileEvent extends PatientProfileEvent {
  final PatientProfile profile;

  const UpdatePatientProfileEvent(this.profile);
}

final class DeletePatientProfileEvent extends PatientProfileEvent {
  final String id;

  const DeletePatientProfileEvent(this.id);
}