import '../../../../Core/Data_Base/app_database.dart';
import '../Repositories/daily_check_in_repository.dart';

class CreateDailyCheckIn {
  final DailyCheckInRepository repository;

  CreateDailyCheckIn(this.repository);

  Future<void> call(DailyCheckIn dailyCheckIn) {
    return repository.createDailyCheckIn(dailyCheckIn);
  }
}