import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class UpdateMessage {
  final MessageRepository repository;

  UpdateMessage(this.repository);

  Future<void> call(Message message) {
    return repository.updateMessage(message);
  }
}