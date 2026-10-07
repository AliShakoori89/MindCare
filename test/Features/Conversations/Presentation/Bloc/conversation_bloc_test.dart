import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Repositories/conversation_repository.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/archive_conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/create_conversation.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/get_conversation_by_id.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/get_conversations_by_user_id.dart';
import 'package:mind_care/Features/Conversations/Domain/Use_Cases/update_conversation.dart';
import 'package:mind_care/Features/Conversations/Presentation/Bloc/conversation_bloc.dart';
import 'package:mind_care/Features/Conversations/Presentation/Bloc/conversation_event.dart';
import 'package:mind_care/Features/Conversations/Presentation/Bloc/conversation_state.dart';

class FakeConversationRepository
    implements ConversationRepository {
  final List<Conversation> conversations = [];

  bool shouldThrow = false;

  @override
  Future<void> createConversation(
      Conversation conversation,
      ) async {
    if (shouldThrow) {
      throw Exception('Create conversation failed');
    }

    conversations.add(conversation);
  }

  @override
  Future<Conversation?> getConversationById(
      String id,
      ) async {
    if (shouldThrow) {
      throw Exception('Get conversation failed');
    }

    try {
      return conversations.firstWhere(
            (conversation) => conversation.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Conversation>> getConversationsByUserId(
      String userId,
      ) async {
    if (shouldThrow) {
      throw Exception('Get conversations failed');
    }

    return conversations
        .where(
          (conversation) =>
      conversation.userId == userId &&
          conversation.archivedAt == null,
    )
        .toList();
  }

  @override
  Future<void> updateConversation(
      Conversation conversation,
      ) async {
    if (shouldThrow) {
      throw Exception('Update conversation failed');
    }

    final index = conversations.indexWhere(
          (item) => item.id == conversation.id,
    );

    if (index == -1) {
      throw Exception('Conversation not found');
    }

    conversations[index] = conversation;
  }

  @override
  Future<void> archiveConversation(
      String id,
      ) async {
    if (shouldThrow) {
      throw Exception('Archive conversation failed');
    }

    final index = conversations.indexWhere(
          (conversation) => conversation.id == id,
    );

    if (index == -1) {
      throw Exception('Conversation not found');
    }

    final conversation = conversations[index];

    conversations[index] = conversation.copyWith(
      archivedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  late FakeConversationRepository repository;

  late CreateConversation createConversation;
  late GetConversationById getConversationById;
  late GetConversationsByUserId getConversationsByUserId;
  late UpdateConversation updateConversation;
  late ArchiveConversation archiveConversation;

  late ConversationBloc bloc;

  final conversation = Conversation(
    id: 'conversation-1',
    userId: 'user-1',
    title: 'First Conversation',
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  setUp(() {
    repository = FakeConversationRepository();

    createConversation = CreateConversation(repository);

    getConversationById = GetConversationById(repository);

    getConversationsByUserId =
        GetConversationsByUserId(repository);

    updateConversation = UpdateConversation(repository);

    archiveConversation = ArchiveConversation(repository);

    bloc = ConversationBloc(
      createConversation,
      getConversationById,
      getConversationsByUserId,
      updateConversation,
      archiveConversation,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('initial state', () {
    test('should be ConversationInitial', () {
      expect(
        bloc.state,
        isA<ConversationInitial>(),
      );
    });
  });

  group('CreateConversationEvent', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Created] when creation succeeds',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          CreateConversationEvent(conversation),
        );
      },
      expect: () => [
        const ConversationLoading(),
        const ConversationCreated(),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when creation fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          CreateConversationEvent(conversation),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationError>(),
      ],
    );
  });

  group('GetConversationByIdEvent', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Loaded] when conversation exists',
      build: () {
        repository.conversations.add(conversation);
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetConversationByIdEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationLoaded>().having(
              (state) => state.conversation.id,
          'conversation id',
          'conversation-1',
        ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when conversation does not exist',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const GetConversationByIdEvent(
            'conversation-404',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        const ConversationError(
          'Conversation not found',
        ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when getting conversation fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetConversationByIdEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationError>(),
      ],
    );
  });

  group('GetConversationsByUserIdEvent', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Loaded] when conversations are found',
      build: () {
        repository.conversations.add(conversation);
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetConversationsByUserIdEvent(
            'user-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationsLoaded>().having(
              (state) => state.conversations.length,
          'conversations length',
          1,
        ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Loaded] with empty list when no conversations exist',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const GetConversationsByUserIdEvent(
            'user-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationsLoaded>().having(
              (state) => state.conversations,
          'conversations',
          isEmpty,
        ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when getting conversations fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetConversationsByUserIdEvent(
            'user-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationError>(),
      ],
    );
  });

  group('UpdateConversationEvent', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Updated] when update succeeds',
      build: () {
        repository.conversations.add(conversation);
        return bloc;
      },
      act: (bloc) {
        final updatedConversation = conversation.copyWith(
          title: 'Updated Conversation',
          updatedAt: DateTime(2026, 10, 2),
        );

        bloc.add(
          UpdateConversationEvent(
            updatedConversation,
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        const ConversationUpdated(),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when update fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          UpdateConversationEvent(conversation),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationError>(),
      ],
    );
  });

  group('ArchiveConversationEvent', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Archived] when archive succeeds',
      build: () {
        repository.conversations.add(conversation);
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const ArchiveConversationEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        const ConversationArchived(),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [Loading, Error] when archive fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const ArchiveConversationEvent(
            'conversation-1',
          ),
        );
      },
      expect: () => [
        const ConversationLoading(),
        isA<ConversationError>(),
      ],
    );
  });
}