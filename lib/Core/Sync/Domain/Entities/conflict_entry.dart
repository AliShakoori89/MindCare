class ConflictEntry {
  final String outboxId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final int? baseVersion;
  final String conflictPayload;
  final DateTime createdAt;
  final String? lastError;

  const ConflictEntry({
    required this.outboxId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.baseVersion,
    required this.conflictPayload,
    required this.createdAt,
    required this.lastError,
  });
}
