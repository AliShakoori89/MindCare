import '../../../../Core/Data_Base/app_database.dart';
import '../Repositories/daily_check_in_repository.dart';

class UpdateDailyCheckIn {
  final DailyCheckInRepository repository;

  UpdateDailyCheckIn(this.repository);

  Future<void> call(DailyCheckIn dailyCheckIn) {
    return repository.updateDailyCheckIn(dailyCheckIn);
  }
}