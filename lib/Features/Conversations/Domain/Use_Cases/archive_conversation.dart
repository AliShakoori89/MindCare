import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';

class ArchiveConversation {
  final ConversationRepository _repository;

  ArchiveConversation(this._repository);

  Future<void> call(
      String id,
      ) {
    return _repository.archiveConversation(id);
  }
}