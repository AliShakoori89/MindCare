import '../../../../Core/Data_Base/app_database.dart';
import '../Repositories/daily_check_in_repository.dart';

class GetDailyCheckInsByUserId {
  final DailyCheckInRepository repository;

  GetDailyCheckInsByUserId(this.repository);

  Future<List<DailyCheckIn>> call(String userId) {
    return repository.getDailyCheckInsByUserId(userId);
  }
}