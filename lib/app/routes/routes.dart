import 'dart:async';

import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_blocks/insta_blocks.dart' hide FeedPage, ReelsPage;
import 'package:narangavellam/app/app.dart';
import 'package:narangavellam/app/home/home.dart';
import 'package:narangavellam/app/view/app_init_utilities.dart';
import 'package:narangavellam/auth/view/auth_page.dart';
import 'package:narangavellam/chats/chat/view/chat_page.dart';
import 'package:narangavellam/chats/chat/widgets/chat_props.dart';
import 'package:narangavellam/feed/feed.dart';
import 'package:narangavellam/feed/post/widgets/widgets.dart';
import 'package:narangavellam/reels/reels.dart';
import 'package:narangavellam/search/view/search_page.dart';
import 'package:narangavellam/stories/stories.dart';
import 'package:narangavellam/timeline/timeline.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:stories_editor/stories_editor.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router(AppBloc appBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/route',
        builder: (context, state) => AppScaffold(
          body: Center(
            child: Text(
              'Route Page',
              style: context.headlineSmall,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/users/:user_id',
        name: 'user_profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['user_id']!;
          final props = state.extra as UserProfileProps?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => CreateStoriesBloc(
                storiesRepository: context.read<StoriesRepository>(),
                firebaseRemoteConfigRepository:
                context.read<FirebaseRemoteConfigRepository>(),
              ),
              child: UserProfilePage(
                userId: userId,
                props: props ?? const UserProfileProps.build(),
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
            path: '/chat/:chat_id',
            name: 'chat',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final chatId = state.pathParameters['chat_id']!;
              final props = state.extra! as ChatProps;

              return CustomTransitionPage(
                key: state.pageKey,
                child: ChatPage(chatId: chatId, chat: props.chat),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/posts/:id',
            name: 'post',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'];

              return CustomTransitionPage(
                key: state.pageKey,
                child: PostPreviewPage(id: id ?? ''),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                },
              );
            },
          ),
      GoRoute(
        path: '/posts/:post_id/edit',
        name: 'post_edit',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra! as PostBlock;

          return NoTransitionPage(child: PostEditPage(post: post));
        },
      ),
      GoRoute(
            path: '/stories/:user_id',
            name: 'stories',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final props = state.extra! as StoriesProps;

              return CustomTransitionPage(
                key: state.pageKey,
                child: StoriesPage(props: props),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                    child: child,
                  );
                },
              );
            },
          ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return HomePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/feed',
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  child: const FeedPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                );
              },
            ),
          ]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const TimelinePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOut)
                            .animate(animation),
                        child: child,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    name: 'search',
                    path: 'search',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final withResult = state.extra as bool?;

                      return NoTransitionPage(
                        key: state.pageKey,
                        child: SearchPage(withResult: withResult),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/create_media',
              redirect: (context, state) => null,
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reels',
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  child: const ReelsView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(curve: Curves.easeInOut)
                          .animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
          ]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user',
                pageBuilder: (context, state) {
                  final user =
                      context.select((AppBloc bloc) => bloc.state.user);

                  return CustomTransitionPage(
                    child: UserProfilePage(
                      userId: user.id,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'create_post',
                    name: 'create_post',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final pickVideo = state.extra as bool? ?? false;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: UserProfileCreatePost(
                          pickVideo: pickVideo,
                        ), //pickVideo: pickVideo),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        name: 'publish_post',
                        path: 'publish_post',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final props = state.extra! as CreatePostProps;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: CreatePostPage(props: props),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statistics',
                    name: 'user_statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id'] ??
                          context.read<AppBloc>().state.user.id;
                      final tabIndex = state.extra as int? ?? 0;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => UserProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          )
                            ..add(const UserProfileSubscriptionRequested())
                            ..add(
                              const UserProfileFollowingsCountSubscriptionRequested(),
                            )
                            ..add(
                              const UserProfileFollowersCountSubscriptionRequested(),
                            ),
                          child: UserProfileStatistics(tabIndex: tabIndex),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'edit_profile',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const UserProfileEdit(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'info/:label',
                        name: 'edit_profile_info',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final query = state.uri.queryParameters;
                          final label = state.pathParameters['label']!;
                          final appBarTitle = query['title']!;
                          final description = query['description'];
                          final infoValue = query['value'];
                          final infoType = state.extra as ProfileEditInfoType?;

                          return MaterialPage<void>(
                            fullscreenDialog: true,
                            child: ProfileInfoEditPage(
                              appBarTitle: appBarTitle,
                              description: description,
                              infoValue: infoValue,
                              infoLabel: label,
                              infoType: infoType!,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'create_stories',
                    name: 'create_stories',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final onDone = state.extra as dynamic Function(String)?;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: StoriesEditor(
                          onDone: onDone,
                          storiesEditorLocalizationDelegate:
                              storiesEditorLocalizationDelegate(context),
                          galleryThumbnailQuality: 900,
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.scaled,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: 'posts',
                    name: 'user_posts',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id']!;
                      final index =
                          (state.uri.queryParameters['index']!).parse.toInt();

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => UserProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          ),
                          child: UserProfilePosts(
                            userId: userId,
                            index: index,
                          ),
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authenticated = appBloc.state.status == AppStatus.authenticated;
      final authenticating = state.matchedLocation == '/auth';
      final isInFeed = state.matchedLocation == '/feed';

      if (isInFeed && !authenticated) return '/auth';
      if (!authenticated) return '/auth';
      if (authenticating && authenticated) return '/feed';

      return null;
    },
    refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
  );
}

/// ChangeNotifier to refresh GoRouter when AppBloc emits a new state
class GoRouterAppBlocRefreshStream extends ChangeNotifier {
  GoRouterAppBlocRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
