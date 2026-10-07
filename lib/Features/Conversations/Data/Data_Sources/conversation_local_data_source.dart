import 'package:mind_care/Core/Data_Base/app_database.dart';

abstract interface class ConversationLocalDataSource {
  Future<void> insertConversation(
      ConversationsCompanion conversation,
      );

  Future<Conversation?> getConversationById(
      String id,
      );

  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      );

  Future<bool> updateConversation(
      ConversationsCompanion conversation,
      );

  Future<int> archiveConversation(
      String id,
      );
}