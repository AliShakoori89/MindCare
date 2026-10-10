class DailyCheckIn {
  final String id;
  final String userId;
  final DateTime date;
  final int? mood;
  final int? anxiety;
  final int? energy;
  final int? stress;
  final int? sleepDurationMinutes;
  final int? sleepQuality;
  final String? activityLevel;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const DailyCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    this.mood,
    this.anxiety,
    this.energy,
    this.stress,
    this.sleepDurationMinutes,
    this.sleepQuality,
    this.activityLevel,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  DailyCheckIn copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? mood,
    int? anxiety,
    int? energy,
    int? stress,
    int? sleepDurationMinutes,
    int? sleepQuality,
    String? activityLevel,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      anxiety: anxiety ?? this.anxiety,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      sleepDurationMinutes:
      sleepDurationMinutes ?? this.sleepDurationMinutes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      activityLevel: activityLevel ?? this.activityLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}