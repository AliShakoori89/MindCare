import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conversations_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late ConversationsDao conversationsDao;

  const userId = 'user-1';

  final createdAt = DateTime(2026, 1, 1);

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conversationsDao = ConversationsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> createUser() async {
    await usersDao.insertUser(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
  }

  Future<void> createConversation({
    String id = 'conversation-1',
    String? title = 'First Conversation',
    DateTime? conversationCreatedAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) async {
    await conversationsDao.insertConversation(
      db.ConversationsCompanion.insert(
        id: id,
        userId: userId,
        title: title == null
            ? const Value.absent()
            : Value(title),
        createdAt:
        conversationCreatedAt ?? DateTime(2026, 1, 1),
        updatedAt:
        updatedAt ?? DateTime(2026, 1, 1),
        archivedAt: archivedAt == null
            ? const Value.absent()
            : Value(archivedAt),
      ),
    );
  }

  test('insertConversation should insert conversation', () async {
    await createUser();

    await createConversation();

    final result = await conversationsDao.getConversationById(
      'conversation-1',
    );

    expect(result, isNot(equals(null)));
    expect(result?.id, 'conversation-1');
    expect(result?.userId, userId);
    expect(result?.title, 'First Conversation');
  });

  test(
    'getConversationById should return null when conversation does not exist',
        () async {
      final result = await conversationsDao.getConversationById(
        'conversation-1',
      );

      expect(result, equals(null));
    },
  );

  test(
    'getConversationsByUserId should return active conversations ordered by updatedAt descending',
        () async {
      await createUser();

      await createConversation(
        id: 'conversation-1',
        title: 'Old Conversation',
        updatedAt: DateTime(2026, 1, 1),
      );

      await createConversation(
        id: 'conversation-2',
        title: 'New Conversation',
        updatedAt: DateTime(2026, 1, 3),
      );

      await createConversation(
        id: 'conversation-3',
        title: 'Middle Conversation',
        updatedAt: DateTime(2026, 1, 2),
      );

      final result =
      await conversationsDao.getConversationsByUserId(userId);

      expect(result.length, 3);

      expect(result[0].id, 'conversation-2');
      expect(result[1].id, 'conversation-3');
      expect(result[2].id, 'conversation-1');
    },
  );

  test(
    'getConversationsByUserId should hide archived conversations',
        () async {
      await createUser();

      await createConversation(
        id: 'conversation-1',
        title: 'Active Conversation',
      );

      await createConversation(
        id: 'conversation-2',
        title: 'Archived Conversation',
        archivedAt: DateTime(2026, 1, 2),
      );

      final result =
      await conversationsDao.getConversationsByUserId(userId);

      expect(result.length, 1);
      expect(result.first.id, 'conversation-1');
    },
  );

  test(
    'getConversationById should return null for archived conversation',
        () async {
      await createUser();

      await createConversation(
        id: 'conversation-1',
        archivedAt: DateTime(2026, 1, 2),
      );

      final result = await conversationsDao.getConversationById(
        'conversation-1',
      );

      expect(result, equals(null));
    },
  );

  test(
    'archiveConversation should set archivedAt',
        () async {
      await createUser();

      await createConversation();

      final affectedRows =
      await conversationsDao.archiveConversation(
        'conversation-1',
      );

      expect(affectedRows, 1);

      final rawResult =
      await (database.select(database.conversations)
        ..where(
              (conversation) =>
              conversation.id.equals('conversation-1'),
        ))
          .getSingle();

      expect(
        rawResult.archivedAt,
        isNot(equals(null)),
      );
    },
  );

  test(
    'updateConversation should update conversation',
        () async {
      await createUser();

      await createConversation(
        title: 'Old Title',
      );

      final updatedConversation =
      db.ConversationsCompanion(
        id: const Value('conversation-1'),
        userId: const Value(userId),
        title: const Value('New Title'),
        createdAt: Value(createdAt),
        updatedAt: Value(
          DateTime(2026, 1, 5),
        ),
        archivedAt: const Value.absent(),
      );

      final result =
      await conversationsDao.updateConversation(
        updatedConversation,
      );

      expect(result, isTrue);

      final conversation =
      await conversationsDao.getConversationById(
        'conversation-1',
      );

      expect(conversation, isNot(equals(null)));
      expect(conversation?.title, 'New Title');
      expect(
        conversation?.updatedAt,
        DateTime(2026, 1, 5),
      );
    },
  );

  test(
    'insertConversation should fail when user does not exist',
        () async {
        await expectLater(
            () => createConversation(),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'deleting user should cascade delete conversations',
        () async {
      await createUser();

      await createConversation(
        id: 'conversation-1',
      );

      await createConversation(
        id: 'conversation-2',
      );

      await usersDao.deleteUser(userId);

      final result =
      await (database.select(database.conversations)
        ..where(
              (conversation) =>
              conversation.userId.equals(userId),
        ))
          .get();

      expect(result, isEmpty);
    },
  );
}