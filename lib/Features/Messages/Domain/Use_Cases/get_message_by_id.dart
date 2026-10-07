import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class GetMessageById {
  final MessageRepository repository;

  GetMessageById(this.repository);

  Future<Message?> call(String id) {
    return repository.getMessageById(id);
  }
}