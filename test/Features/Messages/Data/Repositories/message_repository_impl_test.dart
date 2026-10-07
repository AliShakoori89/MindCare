import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conversations_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/messages_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Messages/Data/Data_Sources/message_local_data_source.dart';
import 'package:mind_care/Features/Messages/Data/Repositories/message_repository_impl.dart';
import 'package:mind_care/Features/Messages/Domain/Entities/message.dart';

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late ConversationsDao conversationsDao;
  late MessagesDao messagesDao;
  late MessageLocalDataSource localDataSource;
  late MessageRepositoryImpl repository;

  const userId = 'user-1';
  const conversationId = 'conversation-1';

  final message = Message(
    id: 'message-1',
    conversationId: conversationId,
    role: 'user',
    content: 'Hello',
    createdAt: DateTime(2026, 10, 1, 10),
  );

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conversationsDao = ConversationsDao(database);
    messagesDao = MessagesDao(database);

    localDataSource = MessageLocalDataSourceImpl(
      messagesDao,
    );

    repository = MessageRepositoryImpl(
      localDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> createUser() async {
    final now = DateTime(2026, 10, 1);

    await usersDao.insertUser(
      db.UsersCompanion.insert(
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
      db.ConversationsCompanion.insert(
        id: conversationId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  group('createMessage', () {
    test(
      'should create a message successfully',
          () async {
        await createConversation();

        await repository.createMessage(message);

        final result =
        await repository.getMessageById(
          message.id,
        );

        expect(result, isNot(equals(null)));
        expect(result!.id, message.id);
        expect(result.conversationId, conversationId);
        expect(result.role, 'user');
        expect(result.content, 'Hello');
      },
    );
  });

  group('getMessageById', () {
    test(
      'should return message when it exists',
          () async {
        await createConversation();

        await repository.createMessage(message);

        final result =
        await repository.getMessageById(
          message.id,
        );

        expect(result, isNot(equals(null)));
        expect(result!.id, message.id);
      },
    );

    test(
      'should return null when message does not exist',
          () async {
        final result =
        await repository.getMessageById(
          'message-404',
        );

        expect(result, equals(null));
      },
    );
  });

  group('getMessagesByConversationId', () {
    test(
      'should return messages for conversation',
          () async {
        await createConversation();

        await repository.createMessage(
          message,
        );

        await repository.createMessage(
          Message(
            id: 'message-2',
            conversationId: conversationId,
            role: 'assistant',
            content: 'Hello! How can I help you?',
            createdAt: DateTime(2026, 10, 1, 11),
          ),
        );

        final result =
        await repository
            .getMessagesByConversationId(
          conversationId,
        );

        expect(result.length, 2);
        expect(result[0].id, 'message-1');
        expect(result[1].id, 'message-2');
      },
    );
  });

  group('updateMessage', () {
    test(
      'should update an existing message',
          () async {
        await createConversation();

        await repository.createMessage(
          message,
        );

        final updatedMessage = message.copyWith(
          role: 'assistant',
          content: 'Updated content',
        );

        await repository.updateMessage(
          updatedMessage,
        );

        final result =
        await repository.getMessageById(
          message.id,
        );

        expect(result, isNot(equals(null)));
        expect(result!.role, 'assistant');
        expect(result.content, 'Updated content');
      },
    );
  });

  group('deleteMessage', () {
    test(
      'should delete an existing message',
          () async {
        await createConversation();

        await repository.createMessage(
          message,
        );

        await repository.deleteMessage(
          message.id,
        );

        final result =
        await repository.getMessageById(
          message.id,
        );

        expect(result, equals(null));
      },
    );
  });
}