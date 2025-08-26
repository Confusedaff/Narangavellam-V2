import 'package:chats_repository/chats_repository.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:narangavellam/app/view/app.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository{}
class MockUser extends Mock implements User{}
class MockPostsRepository extends Mock implements PostsRepository{}
class MockFirebaseRemoteConfigRepository extends Mock implements FirebaseRemoteConfigRepository{}
class MockSearchRepository extends Mock implements SearchRepository{}
class MockStoriesRepository extends Mock implements StoriesRepository{}
class MockChatsRepository extends Mock implements ChatsRepository{}
class MocknotificationRepository extends Mock implements NotificationsRepository{}

void main() {
  group('App', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(
        App(
          user: MockUser(),
          userRepository: MockUserRepository(), 
          postsRepository: MockPostsRepository(), 
          firebaseRemoteConfigRepository: MockFirebaseRemoteConfigRepository(),
          searchRepository: MockSearchRepository(), 
          storiesRepository: MockStoriesRepository(), 
          chatsRepository: MockChatsRepository(), 
          notificationsRepository: MocknotificationRepository(), 
          ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
