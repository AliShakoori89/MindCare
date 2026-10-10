import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Core/Data_Base/Dao/daily_check_ins_dao.dart';
import 'package:mind_care/Features/Daily_Checkin/Data/Data_Sources/daily_check_in_local_data_source.dart';
import 'package:mind_care/Features/Daily_Checkin/Data/Repositories/daily_check_in_repository_impl.dart';

void main() {
  late db.AppDatabase database;
  late DailyCheckInRepositoryImpl repository;

  final now = DateTime(2026, 10, 5, 10);

  setUp(() async {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());

    final dao = DailyCheckInsDao(database);
    final localDataSource = DailyCheckInLocalDataSourceImpl(dao);

    repository = DailyCheckInRepositoryImpl(localDataSource);

    // ایجاد کاربر برای رعایت Foreign Key جدول DailyCheckIns
    await database
        .into(database.users)
        .insert(
          db.UsersCompanion(
            id: const Value('user-1'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  db.DailyCheckIn createCheckIn({
    String id = 'check-in-1',
    String userId = 'user-1',
    DateTime? date,
    int? mood = 4,
    int? anxiety = 2,
    int? energy = 3,
    int? stress = 2,
    int? sleepDurationMinutes = 420,
    int? sleepQuality = 4,
    String? activityLevel = 'moderate',
    String? note = 'Feeling good',
  }) {
    return db.DailyCheckIn(
      id: id,
      userId: userId,
      date: date ?? DateTime(2026, 10, 5),
      mood: mood,
      anxiety: anxiety,
      energy: energy,
      stress: stress,
      sleepDurationMinutes: sleepDurationMinutes,
      sleepQuality: sleepQuality,
      activityLevel: activityLevel,
      note: note,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  group('DailyCheckInRepositoryImpl', () {
    test('should create and retrieve a daily check-in by id', () async {
      final checkIn = createCheckIn();

      await repository.createDailyCheckIn(checkIn);

      final result = await repository.getDailyCheckInById(checkIn.id);

      expect(result, isNot(equals(null)));
      expect(result!.id, checkIn.id);
      expect(result.userId, checkIn.userId);
      expect(result.mood, checkIn.mood);
      expect(result.anxiety, checkIn.anxiety);
      expect(result.note, checkIn.note);
    });

    test('should return null when check-in does not exist', () async {
      final result = await repository.getDailyCheckInById('missing-id');

      expect(result, equals(null));
    });

    test('should retrieve a check-in by user id and date', () async {
      final date = DateTime(2026, 10, 5);
      final checkIn = createCheckIn(date: date);

      await repository.createDailyCheckIn(checkIn);

      final result = await repository.getDailyCheckInByUserAndDate(
        'user-1',
        date,
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, checkIn.id);
      expect(result.date, date);
    });

    test('should return null for an unmatched user and date', () async {
      await repository.createDailyCheckIn(createCheckIn());

      final result = await repository.getDailyCheckInByUserAndDate(
        'user-1',
        DateTime(2026, 10, 6),
      );

      expect(result, equals(null));
    });

    test('should retrieve user check-ins ordered by date descending', () async {
      final olderCheckIn = createCheckIn(
        id: 'check-in-old',
        date: DateTime(2026, 10, 3),
      );

      final newerCheckIn = createCheckIn(
        id: 'check-in-new',
        date: DateTime(2026, 10, 5),
      );

      await repository.createDailyCheckIn(olderCheckIn);
      await repository.createDailyCheckIn(newerCheckIn);

      final results = await repository.getDailyCheckInsByUserId('user-1');

      expect(results, hasLength(2));
      expect(results.first.id, 'check-in-new');
      expect(results.last.id, 'check-in-old');
    });

    test('should return an empty list when user has no check-ins', () async {
      final results = await repository.getDailyCheckInsByUserId('user-1');

      expect(results, isEmpty);
    });

    test('should update an existing check-in', () async {
      final checkIn = createCheckIn();

      await repository.createDailyCheckIn(checkIn);

      final updatedCheckIn = checkIn.copyWith(
        mood: const Value<int?>(5),
        note: const Value<String?>('Feeling much better'),
        updatedAt: now.add(const Duration(hours: 1)),
      );

      await repository.updateDailyCheckIn(updatedCheckIn);

      final result = await repository.getDailyCheckInById(checkIn.id);

      expect(result, isNot(equals(null)));
      expect(result!.mood, 5);
      expect(result.note, 'Feeling much better');
      expect(result.updatedAt, now.add(const Duration(hours: 1)));
    });

    test('should soft-delete a check-in', () async {
      final checkIn = createCheckIn();

      await repository.createDailyCheckIn(checkIn);
      await repository.deleteDailyCheckIn(checkIn.id);

      final result = await repository.getDailyCheckInById(checkIn.id);

      final history = await repository.getDailyCheckInsByUserId('user-1');

      expect(result, equals(null));
      expect(history, isEmpty);
    });

    test('should normalize date when creating a check-in', () async {
      final checkIn = createCheckIn(date: DateTime(2026, 10, 5, 14, 30));

      await repository.createDailyCheckIn(checkIn);

      final result = await repository.getDailyCheckInById(checkIn.id);

      expect(result, isNot(equals(null)));
      expect(result!.date, DateTime(2026, 10, 5));
    });

    test('should find a check-in regardless of the query time', () async {
      final checkIn = createCheckIn(date: DateTime(2026, 10, 5, 14, 30));

      await repository.createDailyCheckIn(checkIn);

      final result = await repository.getDailyCheckInByUserAndDate(
        'user-1',
        DateTime(2026, 10, 5, 21, 45),
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, checkIn.id);
    });
  });
}
