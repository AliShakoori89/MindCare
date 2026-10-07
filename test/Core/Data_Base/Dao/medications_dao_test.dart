import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/medications_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late MedicationsDao dao;

  const userId = 'user-1';

  MedicationsCompanion createMedication({
    String id = 'medication-1',
    String name = 'Aspirin',
    String status = 'active',
  }) {
    final now = DateTime.now();

    return MedicationsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      genericName: const Value('Acetylsalicylic Acid'),
      dosage: const Value('100'),
      unit: const Value('mg'),
      frequencyType: const Value('daily'),
      frequencyValue: const Value('1'),
      route: const Value('oral'),
      startDate: Value(now),
      endDate: const Value(null),
      status: Value(status),
      prescribedBy: const Value('Dr. Test'),
      notes: const Value('Test medication'),
      createdAt: Value(now),
      updatedAt: Value(now),
      deletedAt: const Value(null),
    );
  }

  Future<void> createUser() async {
    await database.into(database.users).insert(
      UsersCompanion.insert(
        id: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    dao = database.medicationsDao;
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'insertMedication should insert medication',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(),
      );

      final result = await dao.getMedicationById(
        'medication-1',
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, 'medication-1');
      expect(result.name, 'Aspirin');
      expect(result.userId, userId);
    },
  );

  test(
    'getMedicationById should return null when medication does not exist',
        () async {
      final result = await dao.getMedicationById(
        'not-exist',
      );

      expect(result, equals(null));
    },
  );

  test(
    'getMedicationsByUserId should return active medications',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(
          id: 'medication-1',
          name: 'Aspirin',
        ),
      );

      await dao.insertMedication(
        createMedication(
          id: 'medication-2',
          name: 'Ibuprofen',
        ),
      );

      final result = await dao.getMedicationsByUserId(
        userId,
      );

      expect(result, hasLength(2));

      expect(
        result.map((e) => e.name),
        containsAll([
          'Aspirin',
          'Ibuprofen',
        ]),
      );
    },
  );

  test(
    'getMedicationsByUserId should not return soft-deleted medications',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(
          id: 'medication-1',
        ),
      );

      await dao.deleteMedication(
        'medication-1',
      );

      final result = await dao.getMedicationsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );

  test(
    'getMedicationById should not return soft-deleted medication',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(),
      );

      await dao.deleteMedication(
        'medication-1',
      );

      final result = await dao.getMedicationById(
        'medication-1',
      );

      expect(result, equals(null));
    },
  );

  test(
    'deleteMedication should soft delete medication',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(),
      );

      final deletedCount = await dao.deleteMedication(
        'medication-1',
      );

      expect(deletedCount, 1);

      final rawResult = await (database.select(
        database.medications,
      )..where(
            (medication) =>
            medication.id.equals('medication-1'),
      ))
          .getSingle();

      expect(
        rawResult.deletedAt,
        isNot(equals(null)),
      );
    },
  );

  test(
    'updateMedication should update medication',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(
          name: 'Aspirin',
        ),
      );

      final updated = createMedication(
        name: 'Updated Aspirin',
        status: 'inactive',
      );

      await dao.updateMedication(updated);

      final result = await dao.getMedicationById(
        'medication-1',
      );

      expect(result, isNot(equals(null)));
      expect(result!.name, 'Updated Aspirin');
      expect(result.status, 'inactive');
    },
  );

  test(
    'insertMedication should fail when user does not exist',
        () async {
      expect(
            () => dao.insertMedication(
          createMedication(),
        ),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'deleting user should cascade delete medications',
        () async {
      await createUser();

      await dao.insertMedication(
        createMedication(),
      );

      await (database.delete(database.users)
        ..where(
              (user) => user.id.equals(userId),
        ))
          .go();

      final result = await (database.select(
        database.medications,
      )..where(
            (medication) =>
            medication.id.equals('medication-1'),
      ))
          .get();

      expect(result, isEmpty);
    },
  );
}