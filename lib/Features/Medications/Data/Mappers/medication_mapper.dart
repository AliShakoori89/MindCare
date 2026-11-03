
import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import '../Models/medication_model.dart';

class MedicationMapper {
  static Medication toDomain(db.Medication medication) {
    return Medication(
      id: medication.id,
      userId: medication.userId,
      name: medication.name,
      genericName: medication.genericName,
      dosage: medication.dosage,
      unit: medication.unit,
      frequencyType: medication.frequencyType,
      frequencyValue: medication.frequencyValue,
      route: medication.route,
      startDate: medication.startDate,
      endDate: medication.endDate,
      status: medication.status,
      prescribedBy: medication.prescribedBy,
      notes: medication.notes,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
      deletedAt: medication.deletedAt,
    );
  }

  static db.MedicationsCompanion toCompanion(
      Medication medication,
      ) {
    return db.MedicationsCompanion(
      id: Value(medication.id),
      userId: Value(medication.userId),
      name: Value(medication.name),
      genericName: Value(medication.genericName),
      dosage: Value(medication.dosage),
      unit: Value(medication.unit),
      frequencyType: Value(medication.frequencyType),
      frequencyValue: Value(medication.frequencyValue),
      route: Value(medication.route),
      startDate: Value(medication.startDate),
      endDate: Value(medication.endDate),
      status: Value(medication.status),
      prescribedBy: Value(medication.prescribedBy),
      notes: Value(medication.notes),
      createdAt: Value(medication.createdAt),
      updatedAt: Value(medication.updatedAt),
      deletedAt: Value(medication.deletedAt),
    );
  }

  static db.MedicationsCompanion modelToCompanion(
      MedicationModel model,
      ) {
    return db.MedicationsCompanion(
      id: Value(model.id),
      userId: Value(model.userId),
      name: Value(model.name),
      genericName: Value(model.genericName),
      dosage: Value(model.dosage),
      unit: Value(model.unit),
      frequencyType: Value(model.frequencyType),
      frequencyValue: Value(model.frequencyValue),
      route: Value(model.route),
      startDate: Value(model.startDate),
      endDate: Value(model.endDate),
      status: Value(model.status),
      prescribedBy: Value(model.prescribedBy),
      notes: Value(model.notes),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
    );
  }
}
