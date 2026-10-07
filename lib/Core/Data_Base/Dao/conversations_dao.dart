import 'package:drift/drift.dart';

import '../Tables/conversations.dart';
import '../app_database.dart';

part 'conversations_dao.g.dart';

@DriftAccessor(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.db);

  Future<void> insertConversation(
      ConversationsCompanion conversation,
      ) {
    return into(conversations).insert(conversation);
  }

  Future<Conversation?> getConversationById(
      String id,
      ) {
    return (select(conversations)
      ..where(
            (conversation) =>
        conversation.id.equals(id) &
        conversation.archivedAt.isNull(),
      ))
        .getSingleOrNull();
  }

  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      ) {
    return (select(conversations)
      ..where(
            (conversation) =>
        conversation.userId.equals(userId) &
        conversation.archivedAt.isNull(),
      )
      ..orderBy([
            (conversation) =>
            OrderingTerm.desc(conversation.updatedAt),
      ]))
        .get();
  }

  Future<bool> updateConversation(
      ConversationsCompanion conversation,
      ) {
    return update(conversations).replace(conversation);
  }

  Future<int> archiveConversation(
      String id,
      ) {
    final now = DateTime.now();

    return (update(conversations)
      ..where(
            (conversation) =>
        conversation.id.equals(id) &
        conversation.archivedAt.isNull(),
      ))
        .write(
      ConversationsCompanion(
        archivedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}