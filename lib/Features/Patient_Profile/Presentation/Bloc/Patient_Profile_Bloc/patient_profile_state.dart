import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';

sealed class PatientProfileState {
  const PatientProfileState();
}

final class PatientProfileInitial extends PatientProfileState {
  const PatientProfileInitial();
}

final class PatientProfileLoading extends PatientProfileState {
  const PatientProfileLoading();
}

final class PatientProfileLoaded extends PatientProfileState {
  final PatientProfile profile;

  const PatientProfileLoaded(this.profile);
}

final class PatientProfileCreated extends PatientProfileState {
  final PatientProfile profile;

  const PatientProfileCreated(this.profile);
}

final class PatientProfileUpdated extends PatientProfileState {
  final PatientProfile profile;

  const PatientProfileUpdated(this.profile);
}

final class PatientProfileDeleted extends PatientProfileState {
  const PatientProfileDeleted();
}

final class PatientProfileError extends PatientProfileState {
  final String message;

  const PatientProfileError(this.message);
}