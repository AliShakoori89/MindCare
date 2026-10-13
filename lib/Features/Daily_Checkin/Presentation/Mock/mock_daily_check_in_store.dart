
class MockDailyCheckIn {
  const MockDailyCheckIn({
    required this.mood,
    required this.energy,
    required this.stress,
    required this.sleepQuality,
    required this.sleepDuration,
    required this.note,
    required this.createdAt,
  });

  final int mood;
  final int energy;
  final int stress;
  final int sleepQuality;
  final double sleepDuration;
  final String note;
  final DateTime createdAt;

  String get moodLabel {
    switch (mood) {
      case 1:
        return 'خیلی بد';
      case 2:
        return 'بد';
      case 3:
        return 'معمولی';
      case 4:
        return 'خوب';
      case 5:
        return 'عالی';
      default:
        return 'ثبت نشده';
    }
  }
}

class MockDailyCheckInStore {
  MockDailyCheckInStore._();

  static final MockDailyCheckInStore instance =
  MockDailyCheckInStore._();

  MockDailyCheckIn? _latest;

  MockDailyCheckIn? get latest => _latest;

  void save(MockDailyCheckIn checkIn) {
    _latest = checkIn;
  }
}
