import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';

sealed class ConversationState {
  const ConversationState();
}

final class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

final class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

final class ConversationCreated extends ConversationState {
  const ConversationCreated();
}

final class ConversationLoaded extends ConversationState {
  final Conversation conversation;

  const ConversationLoaded(this.conversation);
}

final class ConversationsLoaded extends ConversationState {
  final List<Conversation> conversations;

  const ConversationsLoaded(this.conversations);
}

final class ConversationUpdated extends ConversationState {
  const ConversationUpdated();
}

final class ConversationArchived extends ConversationState {
  const ConversationArchived();
}

final class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);
}