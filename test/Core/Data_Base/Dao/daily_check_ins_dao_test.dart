import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/daily_check_ins_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late DailyCheckInsDao dailyCheckInsDao;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    dailyCheckInsDao = DailyCheckInsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<String> createUser() async {
    final userId = 'user-1';
    final now = DateTime.now();

    await usersDao.insertUser(
      UsersCompanion.insert(
        id: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return userId;
  }

  DailyCheckInsCompanion createDailyCheckIn({
    required String id,
    required String userId,
    required DateTime date,
    int? mood,
    int? anxiety,
    int? energy,
    int? stress,
    int? sleepDurationMinutes,
    int? sleepQuality,
    String? activityLevel,
    String? note,
  }) {
    final now = DateTime.now();

    return DailyCheckInsCompanion.insert(
      id: id,
      userId: userId,
      date: date,
      mood: Value(mood),
      anxiety: Value(anxiety),
      energy: Value(energy),
      stress: Value(stress),
      sleepDurationMinutes: Value(sleepDurationMinutes),
      sleepQuality: Value(sleepQuality),
      activityLevel: Value(activityLevel),
      note: Value(note),
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'insertDailyCheckIn should insert a daily check-in',
        () async {
      final userId = await createUser();
      final date = DateTime(2026, 10, 10);

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: date,
          mood: 8,
          anxiety: 3,
          energy: 7,
          stress: 4,
          sleepDurationMinutes: 420,
          sleepQuality: 8,
          activityLevel: 'moderate',
          note: 'Feeling good today',
        ),
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInById(
        'check-in-1',
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, 'check-in-1');
      expect(result.userId, userId);
      expect(result.mood, 8);
      expect(result.anxiety, 3);
      expect(result.energy, 7);
      expect(result.stress, 4);
      expect(result.sleepDurationMinutes, 420);
      expect(result.sleepQuality, 8);
      expect(result.activityLevel, 'moderate');
      expect(result.note, 'Feeling good today');
    },
  );

  test(
    'getDailyCheckInById should return null when check-in does not exist',
        () async {
      final result =
      await dailyCheckInsDao.getDailyCheckInById(
        'missing-id',
      );

      expect(result, equals(null));
    },
  );

  test(
    'getDailyCheckInByUserAndDate should return check-in for user and date',
        () async {
      final userId = await createUser();
      final date = DateTime(2026, 10, 10);

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: date,
          mood: 9,
        ),
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInByUserAndDate(
        userId,
        date,
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, 'check-in-1');
      expect(result.mood, 9);
    },
  );

  test(
    'getDailyCheckInByUserAndDate should return null for different date',
        () async {
      final userId = await createUser();
      final date = DateTime(2026, 10, 10);

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: date,
        ),
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInByUserAndDate(
        userId,
        DateTime(2026, 10, 11),
      );

      expect(result, equals(null));
    },
  );

  test(
    'getDailyCheckInsByUserId should return only user check-ins',
        () async {
      final userId = await createUser();

      await usersDao.insertUser(
        UsersCompanion.insert(
          id: 'user-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: DateTime(2026, 10, 10),
        ),
      );

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-2',
          userId: 'user-2',
          date: DateTime(2026, 10, 11),
        ),
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInsByUserId(
        userId,
      );

      expect(result.length, 1);
      expect(result.first.id, 'check-in-1');
    },
  );

  test(
    'getDailyCheckInsByUserId should return check-ins ordered by date descending',
        () async {
      final userId = await createUser();

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-old',
          userId: userId,
          date: DateTime(2026, 10, 1),
        ),
      );

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-new',
          userId: userId,
          date: DateTime(2026, 10, 10),
        ),
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInsByUserId(
        userId,
      );

      expect(result.length, 2);
      expect(result[0].id, 'check-in-new');
      expect(result[1].id, 'check-in-old');
    },
  );

  test(
    'updateDailyCheckIn should update an existing check-in',
        () async {
      final userId = await createUser();
      final date = DateTime(2026, 10, 10);
      final now = DateTime.now();

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: date,
          mood: 5,
        ),
      );

      final updated = DailyCheckInsCompanion(
        id: const Value('check-in-1'),
        userId: Value(userId),
        date: Value(date),
        mood: const Value(9),
        anxiety: const Value(2),
        energy: const Value(8),
        stress: const Value(3),
        sleepDurationMinutes: const Value(480),
        sleepQuality: const Value(9),
        activityLevel: const Value('high'),
        note: const Value('Updated note'),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      final result =
      await dailyCheckInsDao.updateDailyCheckIn(updated);

      expect(result, isTrue);

      final checkIn =
      await dailyCheckInsDao.getDailyCheckInById(
        'check-in-1',
      );

      expect(checkIn!.mood, 9);
      expect(checkIn.anxiety, 2);
      expect(checkIn.energy, 8);
      expect(checkIn.note, 'Updated note');
    },
  );

  test(
    'deleteDailyCheckIn should soft delete the check-in',
        () async {
      final userId = await createUser();

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: DateTime(2026, 10, 10),
        ),
      );

      final affectedRows =
      await dailyCheckInsDao.deleteDailyCheckIn(
        'check-in-1',
      );

      expect(affectedRows, 1);

      final result =
      await dailyCheckInsDao.getDailyCheckInById(
        'check-in-1',
      );

      expect(result, equals(null));
    },
  );

  test(
    'getDailyCheckInsByUserId should not return soft deleted check-ins',
        () async {
      final userId = await createUser();

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: DateTime(2026, 10, 10),
        ),
      );

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-2',
          userId: userId,
          date: DateTime(2026, 10, 11),
        ),
      );

      await dailyCheckInsDao.deleteDailyCheckIn(
        'check-in-1',
      );

      final result =
      await dailyCheckInsDao.getDailyCheckInsByUserId(
        userId,
      );

      expect(result.length, 1);
      expect(result.first.id, 'check-in-2');
    },
  );

  test(
    'insertDailyCheckIn should reject duplicate user and date',
        () async {
      final userId = await createUser();
      final date = DateTime(2026, 10, 10);

      await dailyCheckInsDao.insertDailyCheckIn(
        createDailyCheckIn(
          id: 'check-in-1',
          userId: userId,
          date: date,
        ),
      );

      expect(
            () => dailyCheckInsDao.insertDailyCheckIn(
          createDailyCheckIn(
            id: 'check-in-2',
            userId: userId,
            date: date,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'insertDailyCheckIn should reject invalid user foreign key',
        () async {
      expect(
            () => dailyCheckInsDao.insertDailyCheckIn(
          createDailyCheckIn(
            id: 'check-in-1',
            userId: 'unknown-user',
            date: DateTime(2026, 10, 10),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    },
  );
}