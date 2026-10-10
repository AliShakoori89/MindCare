import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;

class DailyCheckInMapper {
  static db.DailyCheckIn toDomain(db.DailyCheckIn dailyCheckIn) {
    return db.DailyCheckIn(
      id: dailyCheckIn.id,
      userId: dailyCheckIn.userId,
      date: dailyCheckIn.date,
      mood: dailyCheckIn.mood,
      anxiety: dailyCheckIn.anxiety,
      energy: dailyCheckIn.energy,
      stress: dailyCheckIn.stress,
      sleepDurationMinutes: dailyCheckIn.sleepDurationMinutes,
      sleepQuality: dailyCheckIn.sleepQuality,
      activityLevel: dailyCheckIn.activityLevel,
      note: dailyCheckIn.note,
      createdAt: dailyCheckIn.createdAt,
      updatedAt: dailyCheckIn.updatedAt,
      deletedAt: dailyCheckIn.deletedAt,
    );
  }

  static db.DailyCheckInsCompanion toCompanion(
      db.DailyCheckIn dailyCheckIn,
      ) {
    return db.DailyCheckInsCompanion(
      id: Value(dailyCheckIn.id),
      userId: Value(dailyCheckIn.userId),
      date: Value(dailyCheckIn.date),
      mood: Value(dailyCheckIn.mood),
      anxiety: Value(dailyCheckIn.anxiety),
      energy: Value(dailyCheckIn.energy),
      stress: Value(dailyCheckIn.stress),
      sleepDurationMinutes: Value(
        dailyCheckIn.sleepDurationMinutes,
      ),
      sleepQuality: Value(dailyCheckIn.sleepQuality),
      activityLevel: Value(dailyCheckIn.activityLevel),
      note: Value(dailyCheckIn.note),
      createdAt: Value(dailyCheckIn.createdAt),
      updatedAt: Value(dailyCheckIn.updatedAt),
      deletedAt: Value(dailyCheckIn.deletedAt),
    );
  }
}