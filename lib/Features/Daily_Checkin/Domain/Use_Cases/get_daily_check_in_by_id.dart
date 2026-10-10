import '../../../../Core/Data_Base/app_database.dart';
import '../Repositories/daily_check_in_repository.dart';

class GetDailyCheckInById {
  final DailyCheckInRepository repository;

  GetDailyCheckInById(this.repository);

  Future<DailyCheckIn?> call(String id) {
    return repository.getDailyCheckInById(id);
  }
}