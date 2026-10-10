class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final int? mood;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    this.mood,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? content,
    int? mood,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}