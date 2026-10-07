import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conversations_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Conversations/Data/Data_Sources/conversation_local_data_source.dart';
import 'package:mind_care/Features/Conversations/Data/Data_Sources/conversation_local_data_source_impl.dart';
import 'package:mind_care/Features/Conversations/Data/Repositories/conversation_repository_impl.dart';
import 'package:mind_care/Features/Conversations/Domain/Entities/conversation.dart'
as domain;

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late ConversationsDao conversationsDao;
  late ConversationLocalDataSource localDataSource;
  late ConversationRepositoryImpl repository;

  const userId = 'user-1';
  const conversationId = 'conversation-1';

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  domain.Conversation createConversation({
    String? title = 'Test Conversation',
    DateTime? conversationUpdatedAt,
    DateTime? archivedAt,
  }) {
    return domain.Conversation(
      id: conversationId,
      userId: userId,
      title: title,
      createdAt: createdAt,
      updatedAt:
      conversationUpdatedAt ?? updatedAt,
      archivedAt: archivedAt,
    );
  }

  Future<void> createUser() async {
    await usersDao.insertUser(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conversationsDao = ConversationsDao(database);

    localDataSource = ConversationLocalDataSourceImpl(
      conversationsDao,
    );

    repository = ConversationRepositoryImpl(
      localDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createConversation should persist the conversation',
        () async {
      await createUser();

      final conversation = createConversation();

      await repository.createConversation(
        conversation,
      );

      final result =
      await repository.getConversationById(
        conversationId,
      );

      expect(result, isNot(equals(null)));
      expect(result?.id, conversationId);
      expect(result?.userId, userId);
      expect(result?.title, 'Test Conversation');
    },
  );

  test(
    'getConversationById should return null when conversation does not exist',
        () async {
      final result =
      await repository.getConversationById(
        conversationId,
      );

      expect(result, equals(null));
    },
  );

  test(
    'getConversationsByUserId should return conversations',
        () async {
      await createUser();

      final conversation =
      createConversation();

      await repository.createConversation(
        conversation,
      );

      final result =
      await repository.getConversationsByUserId(
        userId,
      );

      expect(result.length, 1);
      expect(result.first.id, conversationId);
      expect(result.first.userId, userId);
      expect(result.first.title, 'Test Conversation');
    },
  );

  test(
    'getConversationsByUserId should return empty list when user has no conversations',
        () async {
      await createUser();

      final result =
      await repository.getConversationsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );

  test(
    'updateConversation should update the conversation',
        () async {
      await createUser();

      await repository.createConversation(
        createConversation(
          title: 'Old Title',
        ),
      );

      final updatedConversation =
      createConversation(
        title: 'New Title',
        conversationUpdatedAt:
        DateTime(2026, 1, 5),
      );

      await repository.updateConversation(
        updatedConversation,
      );

      final result =
      await repository.getConversationById(
        conversationId,
      );

      expect(result, isNot(equals(null)));
      expect(result?.title, 'New Title');
      expect(
        result?.updatedAt,
        DateTime(2026, 1, 5),
      );
    },
  );

  test(
    'archiveConversation should archive the conversation',
        () async {
      await createUser();

      await repository.createConversation(
        createConversation(),
      );

      await repository.archiveConversation(
        conversationId,
      );

      final result =
      await repository.getConversationById(
        conversationId,
      );

      expect(result, equals(null));
    },
  );

  test(
    'archived conversation should not be returned by getConversationsByUserId',
        () async {
      await createUser();

      await repository.createConversation(
        createConversation(),
      );

      await repository.archiveConversation(
        conversationId,
      );

      final result =
      await repository.getConversationsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );
}