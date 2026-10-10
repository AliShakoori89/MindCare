import '../Repositories/daily_check_in_repository.dart';

class DeleteDailyCheckIn {
  final DailyCheckInRepository repository;

  DeleteDailyCheckIn(this.repository);

  Future<void> call(String id) {
    return repository.deleteDailyCheckIn(id);
  }
}