import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';

sealed class MedicationEvent {
  const MedicationEvent();
}

final class CreateMedicationEvent extends MedicationEvent {
  final Medication medication;

  const CreateMedicationEvent(this.medication);
}

final class GetMedicationByIdEvent extends MedicationEvent {
  final String id;

  const GetMedicationByIdEvent(this.id);
}

final class GetMedicationsByUserIdEvent extends MedicationEvent {
  final String userId;

  const GetMedicationsByUserIdEvent(this.userId);
}

final class UpdateMedicationEvent extends MedicationEvent {
  final Medication medication;

  const UpdateMedicationEvent(this.medication);
}

final class DeleteMedicationEvent extends MedicationEvent {
  final String id;

  const DeleteMedicationEvent(this.id);
}