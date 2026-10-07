import 'package:mind_care/Core/Data_Base/Dao/messages_dao.dart';
import 'package:mind_care/Features/Messages/Data/Mappers/message_mapper.dart';
import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

abstract interface class MessageLocalDataSource {
  Future<void> insertMessage(Message message);

  Future<Message?> getMessageById(String id);

  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      );

  Future<void> updateMessage(Message message);

  Future<void> deleteMessage(String id);
}

class MessageLocalDataSourceImpl
    implements MessageLocalDataSource {
  final MessagesDao messagesDao;

  MessageLocalDataSourceImpl(this.messagesDao);

  @override
  Future<void> insertMessage(Message message) {
    return messagesDao.insertMessage(
      MessageMapper.toCompanion(message),
    );
  }

  @override
  Future<Message?> getMessageById(String id) async {
    final result = await messagesDao.getMessageById(id);

    if (result == null) {
      return null;
    }

    return MessageMapper.toDomain(result);
  }

  @override
  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      ) async {
    final results =
    await messagesDao.getMessagesByConversationId(
      conversationId,
    );

    return results
        .map(MessageMapper.toDomain)
        .toList();
  }

  @override
  Future<void> updateMessage(Message message) async {
    await messagesDao.updateMessage(
      MessageMapper.toCompanion(message),
    );
  }

  @override
  Future<void> deleteMessage(String id) async {
    await messagesDao.deleteMessage(id);
  }
}