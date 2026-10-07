import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

sealed class MessageEvent {
  const MessageEvent();
}

final class CreateMessageEvent extends MessageEvent {
  final Message message;

  const CreateMessageEvent(this.message);
}

final class GetMessageByIdEvent extends MessageEvent {
  final String id;

  const GetMessageByIdEvent(this.id);
}

final class GetMessagesByConversationIdEvent extends MessageEvent {
  final String conversationId;

  const GetMessagesByConversationIdEvent(this.conversationId);
}

final class UpdateMessageEvent extends MessageEvent {
  final Message message;

  const UpdateMessageEvent(this.message);
}

final class DeleteMessageEvent extends MessageEvent {
  final String id;

  const DeleteMessageEvent(this.id);
}