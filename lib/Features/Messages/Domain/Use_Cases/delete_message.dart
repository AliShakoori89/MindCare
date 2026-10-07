import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class DeleteMessage {
  final MessageRepository repository;

  DeleteMessage(this.repository);

  Future<void> call(String id) {
    return repository.deleteMessage(id);
  }
}