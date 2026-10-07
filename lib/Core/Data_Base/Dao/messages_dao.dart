import 'package:drift/drift.dart';

import '../Tables/messages.dart';
import '../app_database.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Future<void> insertMessage(
      MessagesCompanion message,
      ) {
    return into(messages).insert(message);
  }

  Future<Message?> getMessageById(
      String id,
      ) {
    return (select(messages)
      ..where(
            (message) => message.id.equals(id),
      ))
        .getSingleOrNull();
  }

  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      ) {
    return (select(messages)
      ..where(
            (message) =>
            message.conversationId.equals(conversationId),
      )
      ..orderBy([
            (message) =>
            OrderingTerm.asc(message.createdAt),
      ]))
        .get();
  }

  Future<bool> updateMessage(
      MessagesCompanion message,
      ) {
    return update(messages).replace(message);
  }

  Future<int> deleteMessage(
      String id,
      ) {
    return (delete(messages)
      ..where(
            (message) => message.id.equals(id),
      ))
        .go();
  }
}