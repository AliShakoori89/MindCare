import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';

class ConversationMapper {
  static Conversation toDomain(
      db.Conversation conversation,
      ) {
    return Conversation(
      id: conversation.id,
      userId: conversation.userId,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      archivedAt: conversation.archivedAt,
    );
  }

  static db.ConversationsCompanion toCompanion(
      Conversation conversation,
      ) {
    return db.ConversationsCompanion(
      id: Value(conversation.id),
      userId: Value(conversation.userId),
      title: Value(conversation.title),
      createdAt: Value(conversation.createdAt),
      updatedAt: Value(conversation.updatedAt),
      archivedAt: Value(conversation.archivedAt),
    );
  }
}