import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/medications_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_local_data_source.dart';
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_local_data_source_impl.dart';
import 'package:mind_care/Features/Medications/Data/Repositories/medication_repository_impl.dart';
import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart'
as domain;

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late MedicationsDao medicationsDao;
  late MedicationLocalDataSource localDataSource;
  late MedicationRepositoryImpl repository;

  const userId = 'user-1';
  const medicationId = 'medication-1';

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  domain.Medication createMedication({
    String name = 'Aspirin',
    String status = 'active',
  }) {
    return domain.Medication(
      id: medicationId,
      userId: userId,
      name: name,
      genericName: 'Acetylsalicylic Acid',
      dosage: '100',
      unit: 'mg',
      frequencyType: 'daily',
      frequencyValue: '1',
      route: 'oral',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      status: status,
      prescribedBy: 'Dr. Test',
      notes: 'Test medication',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Future<void> createUser() async {
    await usersDao.insertUser(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    medicationsDao = MedicationsDao(database);

    localDataSource = MedicationLocalDataSourceImpl(
      medicationsDao,
    );

    repository = MedicationRepositoryImpl(
      localDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createMedication should persist the medication',
        () async {
      await createUser();

      final medication = createMedication();

      await repository.createMedication(
        medication,
      );

      final result = await repository.getMedicationById(
        medicationId,
      );

      expect(result, isNotNull);
      expect(result?.id, medicationId);
      expect(result?.userId, userId);
      expect(result?.name, 'Aspirin');
      expect(result?.dosage, '100');
      expect(result?.unit, 'mg');
      expect(result?.route, 'oral');
    },
  );

  test(
    'getMedicationById should return null when medication does not exist',
        () async {
      final result = await repository.getMedicationById(
        medicationId,
      );

      expect(result, isNull);
    },
  );

  test(
    'getMedicationsByUserId should return medications',
        () async {
      await createUser();

      final medication = createMedication();

      await repository.createMedication(
        medication,
      );

      final result = await repository.getMedicationsByUserId(
        userId,
      );

      expect(result, hasLength(1));
      expect(result.first.id, medicationId);
      expect(result.first.userId, userId);
      expect(result.first.name, 'Aspirin');
    },
  );

  test(
    'getMedicationsByUserId should return empty list when user has no medications',
        () async {
      await createUser();

      final result = await repository.getMedicationsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );

  test(
    'updateMedication should update the medication',
        () async {
      await createUser();

      await repository.createMedication(
        createMedication(),
      );

      final updatedMedication = createMedication(
        name: 'Ibuprofen',
        status: 'inactive',
      );

      await repository.updateMedication(
        updatedMedication,
      );

      final result = await repository.getMedicationById(
        medicationId,
      );

      expect(result, isNotNull);
      expect(result?.name, 'Ibuprofen');
      expect(result?.status, 'inactive');
    },
  );

  test(
    'deleteMedication should soft delete the medication',
        () async {
      await createUser();

      await repository.createMedication(
        createMedication(),
      );

      await repository.deleteMedication(
        medicationId,
      );

      final result = await repository.getMedicationById(
        medicationId,
      );

      expect(result, isNull);
    },
  );

  test(
    'deleted medication should not be returned by getMedicationsByUserId',
        () async {
      await createUser();

      await repository.createMedication(
        createMedication(),
      );

      await repository.deleteMedication(
        medicationId,
      );

      final result = await repository.getMedicationsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );
}