import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class GetMessagesByConversationId {
  final MessageRepository repository;

  GetMessagesByConversationId(this.repository);

  Future<List<Message>> call(String conversationId) {
    return repository.getMessagesByConversationId(
      conversationId,
    );
  }
}