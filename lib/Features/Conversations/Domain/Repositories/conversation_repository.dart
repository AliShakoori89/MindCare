import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';

abstract interface class ConversationRepository {
  Future<void> createConversation(
      Conversation conversation,
      );

  Future<Conversation?> getConversationById(
      String id,
      );

  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      );

  Future<void> updateConversation(
      Conversation conversation,
      );

  Future<void> archiveConversation(
      String id,
      );
}