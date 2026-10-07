import 'package:mind_care/Core/Data_Base/Dao/conversations_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

import 'conversation_local_data_source.dart';

class ConversationLocalDataSourceImpl
    implements ConversationLocalDataSource {
  final ConversationsDao _dao;

  ConversationLocalDataSourceImpl(this._dao);

  @override
  Future<void> insertConversation(
      ConversationsCompanion conversation,
      ) {
    return _dao.insertConversation(conversation);
  }

  @override
  Future<Conversation?> getConversationById(
      String id,
      ) {
    return _dao.getConversationById(id);
  }

  @override
  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      ) {
    return _dao.getConversationsByUserId(userId);
  }

  @override
  Future<bool> updateConversation(
      ConversationsCompanion conversation,
      ) {
    return _dao.updateConversation(conversation);
  }

  @override
  Future<int> archiveConversation(
      String id,
      ) {
    return _dao.archiveConversation(id);
  }
}