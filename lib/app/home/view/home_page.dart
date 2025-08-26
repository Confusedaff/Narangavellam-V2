import 'package:app_ui/app_ui.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:narangavellam/app/home/provider/home_provider.dart';
import 'package:narangavellam/app/user_profile/widgets/user_profile_create_post.dart';
import 'package:narangavellam/chats/view/chats_page.dart';
import 'package:narangavellam/feed/post/video/widgets/video_player_inherited_widget.dart';
import 'package:narangavellam/navigation/navigation.dart';
import 'package:narangavellam/stories/stories.dart';
import 'package:stories_repository/stories_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return HomeView(navigationShell: navigationShell);
  }
}

class HomeView extends StatefulWidget {
  const HomeView({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late VideoPlayerState _videoPlayerState;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1)
      ..addListener(_onPageScroll);
    _videoPlayerState = VideoPlayerState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeProvider().setPageController(_pageController);
    });
  }

  void _onPageScroll() {
    _pageController.position.isScrollingNotifier.addListener(_isPageScrolling);
  }

  void _isPageScrolling() {
    final isScrolling =
        _pageController.position.isScrollingNotifier.value == true;
    final mainPageView = _pageController.page == 1;
    final navigationBarIndex = widget.navigationShell.currentIndex;
    final isFeed = !isScrolling && mainPageView && navigationBarIndex == 0;
    final isTimeline = !isScrolling && mainPageView && navigationBarIndex == 1;
    final isReels = !isScrolling && mainPageView && navigationBarIndex == 3;

    if (isScrolling) {
      _videoPlayerState.stopAll();
    }
    switch ((isFeed, isTimeline, isReels)) {
      case (true, false, false):
        _videoPlayerState.playFeed();
      case (false, true, false):
        _videoPlayerState.playTimeline();
      case (false, false, true):
        _videoPlayerState.playReels();
      case _:
        _videoPlayerState.stopAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.navigationShell.currentIndex == 0 &&
        !HomeProvider().enablePageView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeProvider().togglePageView();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isZoomOpen = context.watch<ZoomStateProvider>().isZoomOpen;

    return BlocProvider(
      create: (context) => CreateStoriesBloc(
         storiesRepository: context.read<StoriesRepository>(),
          firebaseRemoteConfigRepository:
          context.read<FirebaseRemoteConfigRepository>(),
      )..add(const CreateStoriesIsFeatureAvailableSubscriptionRequested()),
      child: VideoPlayerInheritedWidget(
        videoPlayerState: _videoPlayerState,
        child: ListenableBuilder(
          listenable: HomeProvider(),
          builder: (context, child) {
            return PageView.builder(
              itemCount: 3,
              controller: _pageController,
              physics: isZoomOpen || !HomeProvider().enablePageView
                  ? const NeverScrollableScrollPhysics()
                  : null,
              onPageChanged: (page) {
                if (page == 1 && widget.navigationShell.currentIndex != 0) {
                  HomeProvider().togglePageView(enable: false);
                }
              },
              itemBuilder: (context, index) {
                return switch (index) {
                  0 => UserProfileCreatePost(
                      canPop: false,
                      onPopInvoked: () => HomeProvider().animateToPage(1),
                      onBackButtonTap: () => HomeProvider().animateToPage(1),
                    ),
                  2 => const ChatsPage(),
                  _ => AppScaffold(
                      body: widget.navigationShell,
                      bottomNavigationBar:
                          BottomNavBar(navigationShell: widget.navigationShell),
                    ),
                };
              },
            );
          },
        ),
      ),
    );
  }
}
