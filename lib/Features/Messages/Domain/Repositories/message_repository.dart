import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

abstract interface class MessageRepository {
  Future<void> createMessage(Message message);

  Future<Message?> getMessageById(String id);

  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      );

  Future<void> updateMessage(Message message);

  Future<void> deleteMessage(String id);
}