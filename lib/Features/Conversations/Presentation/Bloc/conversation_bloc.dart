import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/archive_conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/create_conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/get_conversation_by_id.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/get_conversations_by_user_id.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/update_conversation.dart';

import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc
    extends Bloc<ConversationEvent, ConversationState> {
  final CreateConversation _createConversation;
  final GetConversationById _getConversationById;
  final GetConversationsByUserId _getConversationsByUserId;
  final UpdateConversation _updateConversation;
  final ArchiveConversation _archiveConversation;

  ConversationBloc(
      this._createConversation,
      this._getConversationById,
      this._getConversationsByUserId,
      this._updateConversation,
      this._archiveConversation,
      ) : super(const ConversationInitial()) {
    on<CreateConversationEvent>(_onCreateConversation);
    on<GetConversationByIdEvent>(_onGetConversationById);
    on<GetConversationsByUserIdEvent>(
      _onGetConversationsByUserId,
    );
    on<UpdateConversationEvent>(_onUpdateConversation);
    on<ArchiveConversationEvent>(_onArchiveConversation);
  }

  Future<void> _onCreateConversation(
      CreateConversationEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(const ConversationLoading());

    try {
      await _createConversation(event.conversation);

      emit(const ConversationCreated());
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onGetConversationById(
      GetConversationByIdEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(const ConversationLoading());

    try {
      final conversation =
      await _getConversationById(event.id);

      if (conversation == null) {
        emit(
          const ConversationError(
            'Conversation not found',
          ),
        );

        return;
      }

      emit(
        ConversationLoaded(conversation),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onGetConversationsByUserId(
      GetConversationsByUserIdEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(const ConversationLoading());

    try {
      final conversations =
      await _getConversationsByUserId(event.userId);

      emit(
        ConversationsLoaded(conversations),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onUpdateConversation(
      UpdateConversationEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(const ConversationLoading());

    try {
      await _updateConversation(event.conversation);

      emit(const ConversationUpdated());
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onArchiveConversation(
      ArchiveConversationEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(const ConversationLoading());

    try {
      await _archiveConversation(event.id);

      emit(const ConversationArchived());
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}