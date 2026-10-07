import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

class MessageMapper {
  static Message toDomain(db.Message message) {
    return Message(
      id: message.id,
      conversationId: message.conversationId,
      role: message.role,
      content: message.content,
      createdAt: message.createdAt,
    );
  }

  static db.MessagesCompanion toCompanion(Message message) {
    return db.MessagesCompanion(
      id: Value(message.id),
      conversationId: Value(message.conversationId),
      role: Value(message.role),
      content: Value(message.content),
      createdAt: Value(message.createdAt),
    );
  }
}