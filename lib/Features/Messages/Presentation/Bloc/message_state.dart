import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

sealed class MessageState {
  const MessageState();
}

final class MessageInitial extends MessageState {
  const MessageInitial();
}

final class MessageLoading extends MessageState {
  const MessageLoading();
}

final class MessageCreated extends MessageState {
  const MessageCreated();
}

final class MessageLoaded extends MessageState {
  final Message message;

  const MessageLoaded(this.message);
}

final class MessagesLoaded extends MessageState {
  final List<Message> messages;

  const MessagesLoaded(this.messages);
}

final class MessageUpdated extends MessageState {
  const MessageUpdated();
}

final class MessageDeleted extends MessageState {
  const MessageDeleted();
}

final class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);
}