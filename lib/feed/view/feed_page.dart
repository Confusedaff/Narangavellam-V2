import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:narangavellam/feed/bloc/feed_bloc.dart';
import 'package:narangavellam/feed/post/view/post_view.dart';
import 'package:narangavellam/feed/widgets/divider_block.dart';
import 'package:narangavellam/feed/widgets/feed_app_bar.dart';
import 'package:narangavellam/feed/widgets/feed_item_loader.dart';
import 'package:narangavellam/feed/widgets/feed_page_controller.dart';
import 'package:narangavellam/l10n/l10n.dart';
import 'package:narangavellam/network_error/view/network_error.dart';
import 'package:narangavellam/stories/bloc/stories_bloc.dart';
import 'package:narangavellam/stories/widgets/stories_carousel.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(const StoriesFetchUserFollowingsStories()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late ScrollController _nestedScrollController;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedPageRequested(page: 0));
    _nestedScrollController = ScrollController();
    FeedPageController().init(
      nestedScrollController: _nestedScrollController,
      context: context,
    );
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: NestedScrollView(
        controller: _nestedScrollController,
        floatHeaderSlivers: true,
        headerSliverBuilder: (conetxt, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(conetxt),
              sliver: FeedAppBar(
                innerBoxIsScrolled: innerBoxIsScrolled,
              ),
            ),
          ];
        },
        body: const FeedBody(),
      ),
    );
  }
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final feedPageController = FeedPageController();
    return RefreshIndicator.adaptive(
      onRefresh: () async {
          await Future.wait([
            Future.microtask(
              () => context.read<FeedBloc>().add(const FeedRefreshRequested()),
            ), 
            Future.microtask(
                    () => context
                        .read<StoriesBloc>()
                        .add(const StoriesFetchUserFollowingsStories()),
                  ), 
          ]);
          feedPageController.markAnimationAsUnseen();
        },
      child: InViewNotifierCustomScrollView(
        //cacheExtent: 2760,
        initialInViewIds: const ['0'],
        isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
          return deltaTop < (0.5 * vpHeight) + 30.0 &&
              deltaBottom > (0.5 * vpHeight) - 80.0;
        },
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const StoriesCarousel(),
          const AppSliverDivider(),
          BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (previous, current) {
              if (previous.status == FeedStatus.populated &&
                  const ListEquality<InstaBlock>().equals(
                    previous.feed.feedPage.blocks,
                    current.feed.feedPage.blocks,
                  )) {
                return false;
              }
              if (previous.status == current.status) return false;
              return true;
            },
            builder: (context, state) {
              final feedPage = state.feed.feedPage;
              final hasMorePosts = feedPage.hasMore;
              final isFailure = state.status == FeedStatus.failure;

              return SliverList.builder(
                itemCount: state.feed.feedPage.totalBlocks,
                itemBuilder: (context, index) {
                  final block = feedPage.blocks[index];
                  return _buildBlock(
                    context: context,
                    index: index,
                    feedLength: feedPage.totalBlocks,
                    block: block,
                    feedPageController: feedPageController,
                    hasMorePosts: hasMorePosts,
                    isFailure: isFailure,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlock({
    required BuildContext context,
    required int index,
    required int feedLength,
    required InstaBlock block,
    required FeedPageController feedPageController,
    required bool hasMorePosts,
    required bool isFailure,
  }) {
    if (block is DividerHorizontalBlock) {
      return DividerBlock(feedPageController: feedPageController);
    }
    if (block is SectionHeaderBlock) {
      return switch (block.sectionType) {
        SectionHeaderBlockType.suggested => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  context.l10n.suggestedForYouText,
                  style: context.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppDivider(),
            ],
          ),
      };
    }
    if (index + 1 == feedLength) {
      if (isFailure) {
        if (!hasMorePosts) return const SizedBox.shrink();
        return NetworkError(
          onRetry: () {
            context.read<FeedBloc>().add(const FeedPageRequested());
          },
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(top: feedLength == 0 ? AppSpacing.md : 0),
          child: FeedLoaderItem(
            key: ValueKey(index),
            onPresented: () => hasMorePosts
                ? context.read<FeedBloc>().add(const FeedPageRequested())
                : context
                    .read<FeedBloc>()
                    .add(const FeedRecommendedPostsPageRequested()),
          ),
        );
      }
    }
    if (block is PostBlock) {
      return PostView(key: ValueKey(block.id), block: block, postIndex: index);
    }
    return Text('Unknown block type: ${block.type}');
  }
}
