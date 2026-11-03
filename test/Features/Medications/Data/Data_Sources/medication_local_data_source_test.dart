
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_local_data_source_impl.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late MedicationLocalDataSourceImpl dataSource;

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  MedicationsCompanion createMedication({
    String id = 'medication-1',
    String userId = 'user-1',
    String name = 'Metformin',
    String frequencyType = 'daily',
    String route = 'oral',
    String status = 'active',
    DateTime? deletedAt,
  }) {
    return MedicationsCompanion(
      id: drift.Value(id),
      userId: drift.Value(userId),
      name: drift.Value(name),
      genericName: const drift.Value('Metformin'),
      dosage: const drift.Value('500'),
      unit: const drift.Value('mg'),
      frequencyType: drift.Value(frequencyType),
      frequencyValue: const drift.Value('2'),
      route: drift.Value(route),
      startDate: drift.Value(DateTime(2026, 1, 1)),
      endDate: const drift.Value(null),
      status: drift.Value(status),
      prescribedBy: const drift.Value('Dr. Test'),
      notes: const drift.Value('Test medication'),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      deletedAt: drift.Value(deletedAt),
    );
  }

  Future<void> createUser({String id = 'user-1'}) async {
    await usersDao.insertUser(
      UsersCompanion.insert(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    usersDao = UsersDao(database);
    dataSource = MedicationLocalDataSourceImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('insertMedication', () {
    test('should insert medication into local database', () async {
      await createUser();

      await dataSource.insertMedication(createMedication());

      final result = await dataSource.getMedicationById('medication-1');

      expect(result, isNotNull);
      expect(result!.id, 'medication-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Metformin');
      expect(result.status, 'active');
    });

    test('should create pending outbox entry when inserting medication',
            () async {
          await createUser();

          await dataSource.insertMedication(createMedication());

          final entries = await database.outboxDao.getPendingEntries(
            userId: 'user-1',
          );

          expect(entries, hasLength(1));

          final entry = entries.first;

          expect(entry.entityType, 'medication');
          expect(entry.entityId, 'medication-1');
          expect(entry.operation, 'create');
          expect(entry.status, 'pending');
          expect(entry.attempts, 0);
          expect(entry.lastError, isNull);

          expect(entry.payload, contains('"name":"Metformin"'));
          expect(entry.payload, contains('"frequencyType":"daily"'));
          expect(entry.payload, contains('"route":"oral"'));
          expect(entry.payload, contains('"dosage":"500"'));
          expect(entry.payload, contains('"userId":"user-1"'));
        });
  });

  group('getMedicationById', () {
    test('should return medication when it exists', () async {
      await createUser();
      await dataSource.insertMedication(createMedication());

      final result = await dataSource.getMedicationById('medication-1');

      expect(result, isNotNull);
      expect(result!.id, 'medication-1');
    });

    test('should return null when medication does not exist', () async {
      await createUser();

      final result = await dataSource.getMedicationById('not-found');

      expect(result, isNull);
    });

    test('should not return soft-deleted medication', () async {
      await createUser();

      await dataSource.insertMedication(
        createMedication(deletedAt: DateTime(2026, 1, 2)),
      );

      final result = await dataSource.getMedicationById('medication-1');

      expect(result, isNull);
    });
  });

  group('getMedicationsByUserId', () {
    test('should return medications belonging to user', () async {
      await createUser();
      await createUser(id: 'user-2');

      await dataSource.insertMedication(createMedication());

      await dataSource.insertMedication(
        createMedication(
          id: 'medication-2',
          name: 'Aspirin',
        ),
      );

      await dataSource.insertMedication(
        createMedication(
          id: 'medication-3',
          userId: 'user-2',
        ),
      );

      final result = await dataSource.getMedicationsByUserId('user-1');

      expect(result, hasLength(2));
      expect(
        result.map((medication) => medication.id),
        containsAll(['medication-1', 'medication-2']),
      );
    });

    test('should return empty list when user has no medications', () async {
      await createUser();

      final result = await dataSource.getMedicationsByUserId('user-1');

      expect(result, isEmpty);
    });

    test('should not return soft-deleted medications', () async {
      await createUser();

      await dataSource.insertMedication(createMedication());

      await dataSource.insertMedication(
        createMedication(
          id: 'medication-2',
          deletedAt: DateTime(2026, 1, 2),
        ),
      );

      final result = await dataSource.getMedicationsByUserId('user-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'medication-1');
    });
  });

  group('updateMedication', () {
    test('should update existing medication', () async {
      await createUser();
      await dataSource.insertMedication(createMedication());

      final updatedMedication = createMedication(
        name: 'Updated Metformin',
        status: 'inactive',
      );

      final result = await dataSource.updateMedication(updatedMedication);

      expect(result, isTrue);

      final medication =
      await dataSource.getMedicationById('medication-1');

      expect(medication, isNotNull);
      expect(medication!.name, 'Updated Metformin');
      expect(medication.status, 'inactive');
    });

    test('should create pending outbox entry when updating medication',
            () async {
          await createUser();

          await dataSource.insertMedication(createMedication());

          await dataSource.updateMedication(
            createMedication(
              name: 'Updated Metformin',
              status: 'inactive',
            ),
          );

          final entries = await database.outboxDao.getPendingEntries(
            userId: 'user-1',
          );

          expect(entries, hasLength(2));

          final entry = entries.last;

          expect(entry.entityType, 'medication');
          expect(entry.entityId, 'medication-1');
          expect(entry.operation, 'update');
          expect(entry.status, 'pending');
          expect(entry.payload, contains('"name":"Updated Metformin"'));
          expect(entry.payload, contains('"status":"inactive"'));
        });

    test('should not create outbox entry when medication does not exist',
            () async {
          await createUser();

          final result = await dataSource.updateMedication(
            createMedication(),
          );

          expect(result, isFalse);

          final entries = await database.outboxDao.getPendingEntries(
            userId: 'user-1',
          );

          expect(entries, isEmpty);
        });
  });

  group('deleteMedication', () {
    test('should soft delete existing medication', () async {
      await createUser();

      await dataSource.insertMedication(createMedication());

      final result = await dataSource.deleteMedication(
        id: 'medication-1',
        userId: 'user-1',
      );

      expect(result, 1);

      final medication =
      await dataSource.getMedicationById('medication-1');

      expect(medication, isNull);
    });

    test('should create pending outbox entry when deleting medication',
            () async {
          await createUser();

          await dataSource.insertMedication(createMedication());

          final result = await dataSource.deleteMedication(
            id: 'medication-1',
            userId: 'user-1',
          );

          expect(result, 1);

          final entries = await database.outboxDao.getPendingEntries(
            userId: 'user-1',
          );

          expect(entries, hasLength(2));

          final entry = entries.last;

          expect(entry.entityType, 'medication');
          expect(entry.entityId, 'medication-1');
          expect(entry.operation, 'delete');
          expect(entry.status, 'pending');
          expect(entry.payload, contains('"userId":"user-1"'));
        });

    test('should return zero when medication does not exist', () async {
      await createUser();

      final result = await dataSource.deleteMedication(
        id: 'not-found',
        userId: 'user-1',
      );

      expect(result, 0);

      final entries = await database.outboxDao.getPendingEntries(
        userId: 'user-1',
      );

      expect(entries, isEmpty);
    });

    test('should not delete medication belonging to another user',
            () async {
          await createUser();
          await createUser(id: 'user-2');

          await dataSource.insertMedication(createMedication());

          final result = await dataSource.deleteMedication(
            id: 'medication-1',
            userId: 'user-2',
          );

          expect(result, 0);

          final medication =
          await dataSource.getMedicationById('medication-1');

          expect(medication, isNotNull);
          expect(medication!.userId, 'user-1');

          final entries = await database.outboxDao.getPendingEntries(
            userId: 'user-2',
          );

          expect(entries, isEmpty);
        });

    test('should not create duplicate delete entry', () async {
      await createUser();

      await dataSource.insertMedication(createMedication());

      await dataSource.deleteMedication(
        id: 'medication-1',
        userId: 'user-1',
      );

      final secondDelete = await dataSource.deleteMedication(
        id: 'medication-1',
        userId: 'user-1',
      );

      expect(secondDelete, 0);

      final entries = await database.outboxDao.getPendingEntries(
        userId: 'user-1',
      );

      expect(entries, hasLength(2));
      expect(
        entries.where((entry) => entry.operation == 'delete'),
        hasLength(1),
      );
    });
  });
}
