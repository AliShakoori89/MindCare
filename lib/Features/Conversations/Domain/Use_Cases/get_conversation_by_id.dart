import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class GetConversationById {
  final ConversationRepository _repository;

  GetConversationById(this._repository);

  Future<Conversation?> call(
      String id,
      ) {
    return _repository.getConversationById(id);
  }
}