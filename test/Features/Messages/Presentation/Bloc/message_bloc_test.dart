import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';
import 'package:mind_care/Features/Messages/Domain/Repositories/message_repository.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/create_message.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/delete_message.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/get_message_by_id.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/get_messages_by_conversation_id.dart';
import 'package:mind_care/Features/Messages/Domain/Use_Cases/update_message.dart';
import 'package:mind_care/Features/Messages/Presentation/Bloc/message_bloc.dart';
import 'package:mind_care/Features/Messages/Presentation/Bloc/message_event.dart';
import 'package:mind_care/Features/Messages/Presentation/Bloc/message_state.dart';

class FakeMessageRepository implements MessageRepository {
  final List<Message> messages = [];

  bool shouldThrow = false;

  @override
  Future<void> createMessage(Message message) async {
    if (shouldThrow) {
      throw Exception('Create message failed');
    }

    messages.add(message);
  }

  @override
  Future<Message?> getMessageById(String id) async {
    if (shouldThrow) {
      throw Exception('Get message failed');
    }

    try {
      return messages.firstWhere(
            (message) => message.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Message>> getMessagesByConversationId(
      String conversationId,
      ) async {
    if (shouldThrow) {
      throw Exception('Get messages failed');
    }

    return messages
        .where(
          (message) =>
      message.conversationId == conversationId,
    )
        .toList();
  }

  @override
  Future<void> updateMessage(Message message) async {
    if (shouldThrow) {
      throw Exception('Update message failed');
    }

    final index = messages.indexWhere(
          (item) => item.id == message.id,
    );

    if (index == -1) {
      throw Exception('Message not found');
    }

    messages[index] = message;
  }

  @override
  Future<void> deleteMessage(String id) async {
    if (shouldThrow) {
      throw Exception('Delete message failed');
    }

    final index = messages.indexWhere(
          (message) => message.id == id,
    );

    if (index == -1) {
      throw Exception('Message not found');
    }

    messages.removeAt(index);
  }
}

void main() {
  late FakeMessageRepository repository;

  late CreateMessage createMessage;
  late GetMessageById getMessageById;
  late GetMessagesByConversationId getMessagesByConversationId;
  late UpdateMessage updateMessage;
  late DeleteMessage deleteMessage;

  late MessageBloc bloc;

  final message = Message(
    id: 'message-1',
    conversationId: 'conversation-1',
    role: 'user',
    content: 'Hello',
    createdAt: DateTime(2026, 10, 1, 10),
  );

  setUp(() {
    repository = FakeMessageRepository();

    createMessage = CreateMessage(repository);
    getMessageById = GetMessageById(repository);
    getMessagesByConversationId =
        GetMessagesByConversationId(repository);
    updateMessage = UpdateMessage(repository);
    deleteMessage = DeleteMessage(repository);

    bloc = MessageBloc(
      createMessage,
      getMessageById,
      getMessagesByConversationId,
      updateMessage,
      deleteMessage,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('initial state', () {
    test('should be MessageInitial', () {
      expect(
        bloc.state,
        isA<MessageInitial>(),
      );
    });
  });

  group('CreateMessageEvent', () {
    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Created] when creation succeeds',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          CreateMessageEvent(message),
        );
      },
      expect: () => [
        const MessageLoading(),
        const MessageCreated(),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when creation fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          CreateMessageEvent(message),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageError>(),
      ],
    );
  });

  group('GetMessageByIdEvent', () {
    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Loaded] when message exists',
      build: () {
        repository.messages.add(message);
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMessageByIdEvent('message-1'),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageLoaded>().having(
              (state) => state.message.id,
          'message id',
          'message-1',
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when message does not exist',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const GetMessageByIdEvent('message-404'),
        );
      },
      expect: () => [
        const MessageLoading(),
        const MessageError('Message not found'),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when getting message fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMessageByIdEvent('message-1'),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageError>(),
      ],
    );
  });

  group('GetMessagesByConversationIdEvent', () {
    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Loaded] when messages are found',
      build: () {
        repository.messages.add(message);

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMessagesByConversationIdEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessagesLoaded>().having(
              (state) => state.messages.length,
          'messages length',
          1,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Loaded] with empty list when no messages exist',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const GetMessagesByConversationIdEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessagesLoaded>().having(
              (state) => state.messages,
          'messages',
          isEmpty,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when getting messages fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMessagesByConversationIdEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageError>(),
      ],
    );
  });

  group('UpdateMessageEvent', () {
    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Updated] when update succeeds',
      build: () {
        repository.messages.add(message);

        return bloc;
      },
      act: (bloc) {
        final updatedMessage = message.copyWith(
          role: 'assistant',
          content: 'Updated content',
        );

        bloc.add(
          UpdateMessageEvent(updatedMessage),
        );
      },
      expect: () => [
        const MessageLoading(),
        const MessageUpdated(),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when update fails',
      build: () {
        repository.shouldThrow = true;

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          UpdateMessageEvent(message),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageError>(),
      ],
    );
  });

  group('DeleteMessageEvent', () {
    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Deleted] when deletion succeeds',
      build: () {
        repository.messages.add(message);

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const DeleteMessageEvent('message-1'),
        );
      },
      expect: () => [
        const MessageLoading(),
        const MessageDeleted(),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [Loading, Error] when deletion fails',
      build: () {
        repository.shouldThrow = true;

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const DeleteMessageEvent('message-1'),
        );
      },
      expect: () => [
        const MessageLoading(),
        isA<MessageError>(),
      ],
    );
  });
}