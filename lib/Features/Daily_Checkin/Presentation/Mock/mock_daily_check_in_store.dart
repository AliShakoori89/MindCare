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

  MockDailyCheckIn copyWith({
    int? mood,
    int? energy,
    int? stress,
    int? sleepQuality,
    double? sleepDuration,
    String? note,
    DateTime? createdAt,
  }) {
    return MockDailyCheckIn(
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MockDailyCheckInStore {
  MockDailyCheckInStore._();

  static final MockDailyCheckInStore instance =
  MockDailyCheckInStore._();

  MockDailyCheckIn? _today;

  MockDailyCheckIn? get today => _today;

  bool get hasTodayCheckIn {
    if (_today == null) return false;

    return _isSameDay(_today!.createdAt, DateTime.now());
  }

  void save(MockDailyCheckIn checkIn) {
    _today = checkIn;
  }

  void update(MockDailyCheckIn checkIn) {
    if (!hasTodayCheckIn) {
      throw StateError(
        'There is no daily check-in for today.',
      );
    }

    _today = checkIn;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}