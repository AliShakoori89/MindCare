import 'package:drift/drift.dart';

import '../Tables/daily_check_ins.dart';
import '../app_database.dart';

part 'daily_check_ins_dao.g.dart';

@DriftAccessor(tables: [DailyCheckIns])
class DailyCheckInsDao extends DatabaseAccessor<AppDatabase>
    with _$DailyCheckInsDaoMixin {
  DailyCheckInsDao(super.db);

  Future<void> insertDailyCheckIn(
      DailyCheckInsCompanion dailyCheckIn,
      ) {
    return into(dailyCheckIns).insert(dailyCheckIn);
  }

  Future<DailyCheckIn?> getDailyCheckInById(
      String id,
      ) {
    return (select(dailyCheckIns)
      ..where(
            (dailyCheckIn) =>
        dailyCheckIn.id.equals(id) &
        dailyCheckIn.deletedAt.isNull(),
      ))
        .getSingleOrNull();
  }

  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
      String userId,
      DateTime date,
      ) {
    return (select(dailyCheckIns)
      ..where(
            (dailyCheckIn) =>
        dailyCheckIn.userId.equals(userId) &
        dailyCheckIn.date.equals(date) &
        dailyCheckIn.deletedAt.isNull(),
      ))
        .getSingleOrNull();
  }

  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(
      String userId,
      ) {
    return (select(dailyCheckIns)
      ..where(
            (dailyCheckIn) =>
        dailyCheckIn.userId.equals(userId) &
        dailyCheckIn.deletedAt.isNull(),
      )
      ..orderBy([
            (dailyCheckIn) =>
            OrderingTerm.desc(dailyCheckIn.date),
      ]))
        .get();
  }

  Future<bool> updateDailyCheckIn(
      DailyCheckInsCompanion dailyCheckIn,
      ) {
    return update(dailyCheckIns).replace(dailyCheckIn);
  }

  Future<int> deleteDailyCheckIn(
      String id,
      ) {
    final now = DateTime.now();

    return (update(dailyCheckIns)
      ..where(
            (dailyCheckIn) =>
        dailyCheckIn.id.equals(id) &
        dailyCheckIn.deletedAt.isNull(),
      ))
        .write(
      DailyCheckInsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}