import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class CreateConversation {
  final ConversationRepository _repository;

  CreateConversation(this._repository);

  Future<void> call(
      Conversation conversation,
      ) {
    return _repository.createConversation(conversation);
  }
}