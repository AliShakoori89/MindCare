import 'package:mind_care/Features/Messages/Data/Data_Sources/message_local_data_source.dart';
import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';

class MessageRepositoryImpl
    implements MessageRepository {
  final MessageLocalDataSource localDataSource;

  MessageRepositoryImpl(this.localDataSource);

  @override
  Future<void> createMessage(Message message) {
    return localDataSource.insertMessage(message);
  }

  @override
  Future<Message?> getMessageById(String id) {
    return localDataSource.getMessageById(id);
  }

  @override
  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      ) {
    return localDataSource.getMessagesByConversationId(
      conversationId,
    );
  }

  @override
  Future<void> updateMessage(Message message) {
    return localDataSource.updateMessage(message);
  }

  @override
  Future<void> deleteMessage(String id) {
    return localDataSource.deleteMessage(id);
  }
}