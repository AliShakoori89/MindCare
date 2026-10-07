import 'package:bloc/bloc.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/create_message.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/delete_message.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/get_message_by_id.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/get_messages_by_conversation_id.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/update_message.dart';
import 'package:mind_care/Features/Messages/Presentation/Bloc/message_event.dart';
import 'package:mind_care/Features/Messages/Presentation/Bloc/message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final CreateMessage createMessage;
  final GetMessageById getMessageById;
  final GetMessagesByConversationId getMessagesByConversationId;
  final UpdateMessage updateMessage;
  final DeleteMessage deleteMessage;

  MessageBloc(
      this.createMessage,
      this.getMessageById,
      this.getMessagesByConversationId,
      this.updateMessage,
      this.deleteMessage,
      ) : super(const MessageInitial()) {
    on<CreateMessageEvent>(_onCreateMessage);
    on<GetMessageByIdEvent>(_onGetMessageById);
    on<GetMessagesByConversationIdEvent>(
      _onGetMessagesByConversationId,
    );
    on<UpdateMessageEvent>(_onUpdateMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
  }

  Future<void> _onCreateMessage(
      CreateMessageEvent event,
      Emitter<MessageState> emit,
      ) async {
    emit(const MessageLoading());

    try {
      await createMessage(event.message);
      emit(const MessageCreated());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onGetMessageById(
      GetMessageByIdEvent event,
      Emitter<MessageState> emit,
      ) async {
    emit(const MessageLoading());

    try {
      final message = await getMessageById(event.id);

      if (message == null) {
        emit(const MessageError('Message not found'));
        return;
      }

      emit(MessageLoaded(message));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onGetMessagesByConversationId(
      GetMessagesByConversationIdEvent event,
      Emitter<MessageState> emit,
      ) async {
    emit(const MessageLoading());

    try {
      final messages =
      await getMessagesByConversationId(
        event.conversationId,
      );

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onUpdateMessage(
      UpdateMessageEvent event,
      Emitter<MessageState> emit,
      ) async {
    emit(const MessageLoading());

    try {
      await updateMessage(event.message);
      emit(const MessageUpdated());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onDeleteMessage(
      DeleteMessageEvent event,
      Emitter<MessageState> emit,
      ) async {
    emit(const MessageLoading());

    try {
      await deleteMessage(event.id);
      emit(const MessageDeleted());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}