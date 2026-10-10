import '../../../../Core/Data_Base/app_database.dart';
import '../../Domain/Repositories/daily_check_in_repository.dart';
import '../Data_Sources/daily_check_in_local_data_source.dart';

class DailyCheckInRepositoryImpl implements DailyCheckInRepository {
  final DailyCheckInLocalDataSource localDataSource;

  DailyCheckInRepositoryImpl(this.localDataSource);

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Future<void> createDailyCheckIn(DailyCheckIn dailyCheckIn) {
    final normalizedCheckIn = dailyCheckIn.copyWith(
      date: _normalizeDate(dailyCheckIn.date),
    );

    return localDataSource.insertDailyCheckIn(normalizedCheckIn);
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInById(String id) {
    return localDataSource.getDailyCheckInById(id);
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
      String userId,
      DateTime date,
      ) {
    return localDataSource.getDailyCheckInByUserAndDate(
      userId,
      _normalizeDate(date),
    );
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(String userId) {
    return localDataSource.getDailyCheckInsByUserId(userId);
  }

  @override
  Future<void> updateDailyCheckIn(DailyCheckIn dailyCheckIn) {
    final normalizedCheckIn = dailyCheckIn.copyWith(
      date: _normalizeDate(dailyCheckIn.date),
    );

    return localDataSource.updateDailyCheckIn(normalizedCheckIn);
  }

  @override
  Future<void> deleteDailyCheckIn(String id) {
    return localDataSource.deleteDailyCheckIn(id);
  }
}