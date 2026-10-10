import 'package:mind_care/Core/Data_Base/Dao/daily_check_ins_dao.dart';
import '../../../../Core/Data_Base/app_database.dart';
import '../Mappers/daily_check_in_mapper.dart';


abstract interface class DailyCheckInLocalDataSource {
  Future<void> insertDailyCheckIn(DailyCheckIn dailyCheckIn);

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

class DailyCheckInLocalDataSourceImpl
    implements DailyCheckInLocalDataSource {
  final DailyCheckInsDao dailyCheckInsDao;

  DailyCheckInLocalDataSourceImpl(this.dailyCheckInsDao);

  @override
  Future<void> insertDailyCheckIn(DailyCheckIn dailyCheckIn) {
    return dailyCheckInsDao.insertDailyCheckIn(
      DailyCheckInMapper.toCompanion(dailyCheckIn),
    );
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInById(String id) async {
    final result = await dailyCheckInsDao.getDailyCheckInById(id);

    if (result == null) {
      return null;
    }

    return DailyCheckInMapper.toDomain(result);
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
      String userId,
      DateTime date,
      ) async {
    final result =
    await dailyCheckInsDao.getDailyCheckInByUserAndDate(
      userId,
      date,
    );

    if (result == null) {
      return null;
    }

    return DailyCheckInMapper.toDomain(result);
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(
      String userId,
      ) async {
    final results =
    await dailyCheckInsDao.getDailyCheckInsByUserId(userId);

    return results.map(DailyCheckInMapper.toDomain).toList();
  }

  @override
  Future<void> updateDailyCheckIn(DailyCheckIn dailyCheckIn) async {
    await dailyCheckInsDao.updateDailyCheckIn(
      DailyCheckInMapper.toCompanion(dailyCheckIn),
    );
  }

  @override
  Future<void> deleteDailyCheckIn(String id) async {
    await dailyCheckInsDao.deleteDailyCheckIn(id);
  }
}