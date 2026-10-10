import '../../../../Core/Data_Base/app_database.dart';

abstract interface class DailyCheckInRepository {
  Future<void> createDailyCheckIn(DailyCheckIn dailyCheckIn);

  Future<DailyCheckIn?> getDailyCheckInById(String id);

  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
      String userId,
      DateTime date,
      );

  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(
      String userId,
      );

  Future<void> updateDailyCheckIn(DailyCheckIn dailyCheckIn);

  Future<void> deleteDailyCheckIn(String id);
}