import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';

sealed class ConversationEvent {
  const ConversationEvent();
}

final class CreateConversationEvent extends ConversationEvent {
  final Conversation conversation;

  const CreateConversationEvent(this.conversation);
}

final class GetConversationByIdEvent extends ConversationEvent {
  final String id;

  const GetConversationByIdEvent(this.id);
}

final class GetConversationsByUserIdEvent extends ConversationEvent {
  final String userId;

  const GetConversationsByUserIdEvent(this.userId);
}

final class UpdateConversationEvent extends ConversationEvent {
  final Conversation conversation;

  const UpdateConversationEvent(this.conversation);
}

final class ArchiveConversationEvent extends ConversationEvent {
  final String id;

  const ArchiveConversationEvent(this.id);
}