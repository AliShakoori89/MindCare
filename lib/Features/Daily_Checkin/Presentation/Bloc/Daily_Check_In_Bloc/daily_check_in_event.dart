import '../../../../../Core/Data_Base/app_database.dart';

abstract class DailyCheckInEvent {
  const DailyCheckInEvent();
}

class CreateDailyCheckInEvent extends DailyCheckInEvent {
  final DailyCheckIn dailyCheckIn;

  const CreateDailyCheckInEvent(this.dailyCheckIn);
}

class LoadDailyCheckInByIdEvent extends DailyCheckInEvent {
  final String id;

  const LoadDailyCheckInByIdEvent(this.id);
}

class LoadDailyCheckInByUserAndDateEvent
    extends DailyCheckInEvent {
  final String userId;
  final DateTime date;

  const LoadDailyCheckInByUserAndDateEvent({
    required this.userId,
    required this.date,
  });
}

class LoadDailyCheckInsByUserIdEvent
    extends DailyCheckInEvent {
  final String userId;

  const LoadDailyCheckInsByUserIdEvent(this.userId);
}

class UpdateDailyCheckInEvent extends DailyCheckInEvent {
  final DailyCheckIn dailyCheckIn;

  const UpdateDailyCheckInEvent(this.dailyCheckIn);
}

class DeleteDailyCheckInEvent extends DailyCheckInEvent {
  final String id;

  const DeleteDailyCheckInEvent(this.id);
}