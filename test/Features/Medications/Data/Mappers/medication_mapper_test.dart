
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Medications/Data/Mappers/medication_mapper.dart';
import 'package:mind_care/Features/Medications/Data/Models/medication_model.dart';
import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart'
as domain;

void main() {
  final startDate = DateTime(2025, 1, 1);
  final endDate = DateTime(2025, 12, 31);
  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 2);
  final deletedAt = DateTime(2026, 1, 3);

  group('MedicationMapper.toDomain', () {
    test('should map database medication to domain medication', () {
      final databaseMedication = db.Medication(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        genericName: 'Metformin',
        dosage: '500',
        unit: 'mg',
        frequencyType: 'daily',
        frequencyValue: '2',
        route: 'oral',
        startDate: startDate,
        endDate: endDate,
        status: 'active',
        prescribedBy: 'Dr. Test',
        notes: 'Test medication',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        version: 1,
      );

      final result = MedicationMapper.toDomain(databaseMedication);

      expect(result.id, 'medication-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Metformin');
      expect(result.genericName, 'Metformin');
      expect(result.dosage, '500');
      expect(result.unit, 'mg');
      expect(result.frequencyType, 'daily');
      expect(result.frequencyValue, '2');
      expect(result.route, 'oral');
      expect(result.startDate, startDate);
      expect(result.endDate, endDate);
      expect(result.status, 'active');
      expect(result.prescribedBy, 'Dr. Test');
      expect(result.notes, 'Test medication');
      expect(result.createdAt, createdAt);
      expect(result.updatedAt, updatedAt);
      expect(result.deletedAt, deletedAt);
    });

    test('should preserve null optional fields', () {
      final databaseMedication = db.Medication(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        genericName: null,
        dosage: null,
        unit: null,
        frequencyType: 'daily',
        frequencyValue: null,
        route: 'oral',
        startDate: null,
        endDate: null,
        status: 'active',
        prescribedBy: null,
        notes: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
        version: 1,
      );

      final result = MedicationMapper.toDomain(databaseMedication);

      expect(result.genericName, isNull);
      expect(result.dosage, isNull);
      expect(result.unit, isNull);
      expect(result.frequencyValue, isNull);
      expect(result.startDate, isNull);
      expect(result.endDate, isNull);
      expect(result.prescribedBy, isNull);
      expect(result.notes, isNull);
      expect(result.deletedAt, isNull);
    });
  });

  group('MedicationMapper.toCompanion', () {
    test('should map domain medication to database companion', () {
      final medication = domain.Medication(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        genericName: 'Metformin',
        dosage: '500',
        unit: 'mg',
        frequencyType: 'daily',
        frequencyValue: '2',
        route: 'oral',
        startDate: startDate,
        endDate: endDate,
        status: 'active',
        prescribedBy: 'Dr. Test',
        notes: 'Test medication',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

      final result = MedicationMapper.toCompanion(medication);

      expect(result.id.value, 'medication-1');
      expect(result.userId.value, 'user-1');
      expect(result.name.value, 'Metformin');
      expect(result.genericName.value, 'Metformin');
      expect(result.dosage.value, '500');
      expect(result.unit.value, 'mg');
      expect(result.frequencyType.value, 'daily');
      expect(result.frequencyValue.value, '2');
      expect(result.route.value, 'oral');
      expect(result.startDate.value, startDate);
      expect(result.endDate.value, endDate);
      expect(result.status.value, 'active');
      expect(result.prescribedBy.value, 'Dr. Test');
      expect(result.notes.value, 'Test medication');
      expect(result.createdAt.value, createdAt);
      expect(result.updatedAt.value, updatedAt);
      expect(result.deletedAt.value, deletedAt);
    });

    test('should preserve null optional fields', () {
      final medication = domain.Medication(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        frequencyType: 'daily',
        route: 'oral',
        status: 'active',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final result = MedicationMapper.toCompanion(medication);

      expect(result.genericName.value, isNull);
      expect(result.dosage.value, isNull);
      expect(result.unit.value, isNull);
      expect(result.frequencyValue.value, isNull);
      expect(result.startDate.value, isNull);
      expect(result.endDate.value, isNull);
      expect(result.prescribedBy.value, isNull);
      expect(result.notes.value, isNull);
      expect(result.deletedAt.value, isNull);
    });
  });

  group('MedicationMapper.modelToCompanion', () {
    test('should map medication model to database companion', () {
      final model = MedicationModel(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        genericName: 'Metformin',
        dosage: '500',
        unit: 'mg',
        frequencyType: 'daily',
        frequencyValue: '2',
        route: 'oral',
        startDate: startDate,
        endDate: endDate,
        status: 'active',
        prescribedBy: 'Dr. Test',
        notes: 'Test medication',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

      final result = MedicationMapper.modelToCompanion(model);

      expect(result.id.value, 'medication-1');
      expect(result.userId.value, 'user-1');
      expect(result.name.value, 'Metformin');
      expect(result.genericName.value, 'Metformin');
      expect(result.dosage.value, '500');
      expect(result.unit.value, 'mg');
      expect(result.frequencyType.value, 'daily');
      expect(result.frequencyValue.value, '2');
      expect(result.route.value, 'oral');
      expect(result.startDate.value, startDate);
      expect(result.endDate.value, endDate);
      expect(result.status.value, 'active');
      expect(result.prescribedBy.value, 'Dr. Test');
      expect(result.notes.value, 'Test medication');
      expect(result.createdAt.value, createdAt);
      expect(result.updatedAt.value, updatedAt);
      expect(result.deletedAt.value, deletedAt);
    });

    test('should preserve null optional fields', () {
      final model = MedicationModel(
        id: 'medication-1',
        userId: 'user-1',
        name: 'Metformin',
        frequencyType: 'daily',
        route: 'oral',
        status: 'active',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final result = MedicationMapper.modelToCompanion(model);

      expect(result.genericName.value, isNull);
      expect(result.dosage.value, isNull);
      expect(result.unit.value, isNull);
      expect(result.frequencyValue.value, isNull);
      expect(result.startDate.value, isNull);
      expect(result.endDate.value, isNull);
      expect(result.prescribedBy.value, isNull);
      expect(result.notes.value, isNull);
      expect(result.deletedAt.value, isNull);
    });
  });
}
