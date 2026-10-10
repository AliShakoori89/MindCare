import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Repositories/daily_check_in_repository.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/create_daily_check_in.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/delete_daily_check_in.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_id.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_user_and_date.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_ins_by_user_id.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/update_daily_check_in.dart';

class FakeDailyCheckInRepository implements DailyCheckInRepository {
  final Map<String, DailyCheckIn> _items = {};

  @override
  Future<void> createDailyCheckIn(DailyCheckIn dailyCheckIn) async {
    _items[dailyCheckIn.id] = dailyCheckIn;
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInById(String id) async {
    return _items[id];
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
    String userId,
    DateTime date,
  ) async {
    for (final item in _items.values) {
      if (item.userId == userId && item.date == date) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(String userId) async {
    final results = _items.values
        .where((item) => item.userId == userId)
        .toList();

    results.sort((a, b) => b.date.compareTo(a.date));

    return results;
  }

  @override
  Future<void> updateDailyCheckIn(DailyCheckIn dailyCheckIn) async {
    if (_items.containsKey(dailyCheckIn.id)) {
      _items[dailyCheckIn.id] = dailyCheckIn;
    }
  }

  @override
  Future<void> deleteDailyCheckIn(String id) async {
    _items.remove(id);
  }
}

void main() {
  late FakeDailyCheckInRepository repository;

  final date = DateTime(2026, 10, 5);
  final now = DateTime(2026, 10, 5, 10);

  DailyCheckIn createCheckIn({
    String id = 'check-in-1',
    String userId = 'user-1',
    DateTime? date,
    int? mood = 4,
    String? note = 'Feeling good',
  }) {
    return DailyCheckIn(
      id: id,
      userId: userId,
      date: date ?? DateTime(2026, 10, 5),
      mood: mood,
      anxiety: 2,
      energy: 3,
      stress: 2,
      sleepDurationMinutes: 420,
      sleepQuality: 4,
      activityLevel: 'moderate',
      note: note,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  setUp(() {
    repository = FakeDailyCheckInRepository();
  });

  group('DailyCheckIn UseCases', () {
    test('CreateDailyCheckIn should create a check-in', () async {
      final useCase = CreateDailyCheckIn(repository);
      final checkIn = createCheckIn();

      await useCase(checkIn);

      final result = await repository.getDailyCheckInById(checkIn.id);

      expect(result, isNotNull);
      expect(result!.id, checkIn.id);
      expect(result.mood, 4);
    });

    test('GetDailyCheckInById should return the requested check-in', () async {
      final useCase = GetDailyCheckInById(repository);
      final checkIn = createCheckIn();

      await repository.createDailyCheckIn(checkIn);

      final result = await useCase(checkIn.id);

      expect(result, isNotNull);
      expect(result!.id, checkIn.id);
    });

    test(
      'GetDailyCheckInByUserAndDate should return the matching check-in',
      () async {
        final useCase = GetDailyCheckInByUserAndDate(repository);
        final checkIn = createCheckIn(date: date);

        await repository.createDailyCheckIn(checkIn);

        final result = await useCase('user-1', date);

        expect(result, isNotNull);
        expect(result!.id, checkIn.id);
      },
    );

    test(
      'GetDailyCheckInsByUserId should return only the user check-ins',
      () async {
        final useCase = GetDailyCheckInsByUserId(repository);

        await repository.createDailyCheckIn(
          createCheckIn(id: 'check-in-1', userId: 'user-1'),
        );
        await repository.createDailyCheckIn(
          createCheckIn(id: 'check-in-2', userId: 'user-2'),
        );

        final results = await useCase('user-1');

        expect(results, hasLength(1));
        expect(results.first.userId, 'user-1');
      },
    );

    test('UpdateDailyCheckIn should update an existing check-in', () async {
      final useCase = UpdateDailyCheckIn(repository);

      await repository.createDailyCheckIn(createCheckIn());

      final updatedCheckIn = createCheckIn(
        mood: 5,
        note: 'Feeling much better',
      );

      await useCase(updatedCheckIn);

      final result = await repository.getDailyCheckInById(updatedCheckIn.id);

      expect(result, isNotNull);
      expect(result!.mood, 5);
      expect(result.note, 'Feeling much better');
    });

    test('DeleteDailyCheckIn should delete the requested check-in', () async {
      final useCase = DeleteDailyCheckIn(repository);

      await repository.createDailyCheckIn(createCheckIn());

      await useCase('check-in-1');

      final result = await repository.getDailyCheckInById('check-in-1');

      expect(result, isNull);
    });
  });
}
