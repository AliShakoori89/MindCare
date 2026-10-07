import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class CreateMessage {
  final MessageRepository repository;

  CreateMessage(this.repository);

  Future<void> call(Message message) {
    return repository.createMessage(message);
  }
}