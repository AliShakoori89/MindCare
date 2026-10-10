import '../../../../../Core/Data_Base/app_database.dart';

abstract class DailyCheckInState {
  const DailyCheckInState();
}

class DailyCheckInInitial extends DailyCheckInState {
  const DailyCheckInInitial();
}

class DailyCheckInLoading extends DailyCheckInState {
  const DailyCheckInLoading();
}

class DailyCheckInOperationSuccess extends DailyCheckInState {
  final String message;

  const DailyCheckInOperationSuccess(this.message);
}

class DailyCheckInLoaded extends DailyCheckInState {
  final DailyCheckIn dailyCheckIn;

  const DailyCheckInLoaded(this.dailyCheckIn);
}

class DailyCheckInsLoaded extends DailyCheckInState {
  final List<DailyCheckIn> dailyCheckIns;

  const DailyCheckInsLoaded(this.dailyCheckIns);
}

class DailyCheckInNotFound extends DailyCheckInState {
  const DailyCheckInNotFound();
}

class DailyCheckInError extends DailyCheckInState {
  final String message;

  const DailyCheckInError(this.message);
}