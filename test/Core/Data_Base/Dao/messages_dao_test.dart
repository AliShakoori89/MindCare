import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conversations_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/messages_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late ConversationsDao conversationsDao;
  late MessagesDao messagesDao;

  const userId = 'user-1';
  const conversationId = 'conversation-1';

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conversationsDao = ConversationsDao(database);
    messagesDao = MessagesDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> createUser() async {
    final now = DateTime(2026, 10, 1);

    await usersDao.insertUser(
      UsersCompanion.insert(
        id: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> createConversation() async {
    await createUser();

    final now = DateTime(2026, 10, 1);

    await conversationsDao.insertConversation(
      ConversationsCompanion.insert(
        id: conversationId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }


  MessagesCompanion buildMessage({
    String id = 'message-1',
    String conversationId = conversationId,
    String role = 'user',
    String content = 'Hello',
    DateTime? createdAt,
  }) {
    return MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: createdAt ?? DateTime(2026, 10, 1, 10),
    );
  }

  group('insertMessage', () {
    test('should insert a message successfully', () async {
      await createConversation();

      await messagesDao.insertMessage(
        buildMessage(),
      );

      final result = await messagesDao.getMessageById(
        'message-1',
      );

      expect(result, isNot(equals(null)));
      expect(result!.id, 'message-1');
      expect(result.conversationId, conversationId);
      expect(result.role, 'user');
      expect(result.content, 'Hello');
    });
  });

  group('getMessageById', () {
    test('should return message when it exists', () async {
      await createConversation();

      await messagesDao.insertMessage(
        buildMessage(
          id: 'message-1',
          content: 'First message',
        ),
      );

      final result = await messagesDao.getMessageById(
        'message-1',
      );

      expect(result, isNot(equals(null)));
      expect(result!.content, 'First message');
    });

    test('should return null when message does not exist', () async {
      final result = await messagesDao.getMessageById(
        'message-404',
      );

      expect(result, equals(null));
    });
  });

  group('getMessagesByConversationId', () {
    test(
      'should return messages belonging to the conversation',
          () async {
        await createConversation();

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-1',
            content: 'First message',
          ),
        );

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-2',
            content: 'Second message',
          ),
        );

        final result =
        await messagesDao.getMessagesByConversationId(
          conversationId,
        );

        expect(result.length, 2);
        expect(result[0].id, 'message-1');
        expect(result[1].id, 'message-2');
      },
    );

    test(
      'should return messages ordered by createdAt ascending',
          () async {
        await createConversation();

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-3',
            content: 'Third message',
            createdAt: DateTime(2026, 10, 1, 12),
          ),
        );

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-1',
            content: 'First message',
            createdAt: DateTime(2026, 10, 1, 10),
          ),
        );

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-2',
            content: 'Second message',
            createdAt: DateTime(2026, 10, 1, 11),
          ),
        );

        final result =
        await messagesDao.getMessagesByConversationId(
          conversationId,
        );

        expect(result.length, 3);
        expect(result[0].id, 'message-1');
        expect(result[1].id, 'message-2');
        expect(result[2].id, 'message-3');
      },
    );
  });

  group('updateMessage', () {
    test('should update an existing message', () async {
      await createConversation();

      await messagesDao.insertMessage(
        buildMessage(
          id: 'message-1',
          content: 'Old content',
        ),
      );

      final updated = buildMessage(
        id: 'message-1',
        content: 'Updated content',
        role: 'assistant',
      );

      final result = await messagesDao.updateMessage(
        updated,
      );

      expect(result, isTrue);

      final message = await messagesDao.getMessageById(
        'message-1',
      );

      expect(result, isNot(equals(null)));
      expect(message!.content, 'Updated content');
      expect(message.role, 'assistant');
    });
  });

  group('deleteMessage', () {
    test('should delete an existing message', () async {
      await createConversation();

      await messagesDao.insertMessage(
        buildMessage(
          id: 'message-1',
        ),
      );

      final deletedRows = await messagesDao.deleteMessage(
        'message-1',
      );

      expect(deletedRows, 1);

      final result = await messagesDao.getMessageById(
        'message-1',
      );

      expect(result, equals(null));
    });
  });

  group('foreign key', () {
    test(
      'should reject message with invalid conversationId',
          () async {
        expect(
              () => messagesDao.insertMessage(
            buildMessage(
              conversationId: 'conversation-404',
            ),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('cascade delete', () {
    test(
      'should delete messages when conversation is deleted',
          () async {
        await createConversation();

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-1',
          ),
        );

        await messagesDao.insertMessage(
          buildMessage(
            id: 'message-2',
          ),
        );

        final beforeDelete =
        await messagesDao.getMessagesByConversationId(
          conversationId,
        );

        expect(beforeDelete.length, 2);

        await (database.delete(database.conversations)
          ..where(
                (conversation) =>
                conversation.id.equals(conversationId),
          ))
            .go();

        final afterDelete =
        await messagesDao.getMessagesByConversationId(
          conversationId,
        );

        expect(afterDelete, isEmpty);

        final message = await messagesDao.getMessageById(
          'message-1',
        );

        expect(message, equals(null));
      },
    );
  });
}