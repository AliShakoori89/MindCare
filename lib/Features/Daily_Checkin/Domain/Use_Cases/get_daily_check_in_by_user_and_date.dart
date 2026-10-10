import '../../../../Core/Data_Base/app_database.dart';
import '../Repositories/daily_check_in_repository.dart';

class GetDailyCheckInByUserAndDate {
  final DailyCheckInRepository repository;

  GetDailyCheckInByUserAndDate(this.repository);

  Future<DailyCheckIn?> call(String userId, DateTime date) {
    return repository.getDailyCheckInByUserAndDate(userId, date);
  }
}