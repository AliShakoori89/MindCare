import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';

sealed class MedicationState {
  const MedicationState();
}

final class MedicationInitial extends MedicationState {
  const MedicationInitial();
}

final class MedicationLoading extends MedicationState {
  const MedicationLoading();
}

final class MedicationCreated extends MedicationState {
  const MedicationCreated();
}

final class MedicationLoaded extends MedicationState {
  final Medication medication;

  const MedicationLoaded(this.medication);
}

final class MedicationsLoaded extends MedicationState {
  final List<Medication> medications;

  const MedicationsLoaded(this.medications);
}

final class MedicationUpdated extends MedicationState {
  const MedicationUpdated();
}

final class MedicationDeleted extends MedicationState {
  const MedicationDeleted();
}

final class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);
}