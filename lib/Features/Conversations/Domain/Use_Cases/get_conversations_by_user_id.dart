import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class GetConversationsByUserId {
  final ConversationRepository _repository;

  GetConversationsByUserId(this._repository);

  Future<List<Conversation>> call(
      String userId,
      ) {
    return _repository.getConversationsByUserId(userId);
  }
}