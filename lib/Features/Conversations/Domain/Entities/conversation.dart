class Conversation {
  final String id;
  final String userId;

  final String? title;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  const Conversation({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}