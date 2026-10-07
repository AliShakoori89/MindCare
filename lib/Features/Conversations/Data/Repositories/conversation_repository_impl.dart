import 'package:mind_care/Features/Conversations/Data/Data_Sources/conversation_local_data_source.dart';
import 'package:mind_care/Features/Conversations/Data/Mappers/conversation_mapper.dart';
import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class ConversationRepositoryImpl
    implements ConversationRepository {
  final ConversationLocalDataSource _localDataSource;

  ConversationRepositoryImpl(this._localDataSource);

  @override
  Future<void> createConversation(
      Conversation conversation,
      ) {
    return _localDataSource.insertConversation(
      ConversationMapper.toCompanion(conversation),
    );
  }

  @override
  Future<Conversation?> getConversationById(
      String id,
      ) async {
    final conversation =
    await _localDataSource.getConversationById(id);

    if (conversation == null) {
      return null;
    }

    return ConversationMapper.toDomain(conversation);
  }

  @override
  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      ) async {
    final conversations =
    await _localDataSource.getConversationsByUserId(userId);

    return conversations
        .map(ConversationMapper.toDomain)
        .toList();
  }

  @override
  Future<void> updateConversation(
      Conversation conversation,
      ) {
    return _localDataSource.updateConversation(
      ConversationMapper.toCompanion(conversation),
    );
  }

  @override
  Future<void> archiveConversation(
      String id,
      ) async {
    await _localDataSource.archiveConversation(id);
  }
}