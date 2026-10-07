import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class UpdateConversation {
  final ConversationRepository _repository;

  UpdateConversation(this._repository);

  Future<void> call(
      Conversation conversation,
      ) {
    return _repository.updateConversation(conversation);
  }
}