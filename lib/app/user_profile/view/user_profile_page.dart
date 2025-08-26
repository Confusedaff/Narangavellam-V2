import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:narangavellam/app/bloc/app_bloc.dart';
import 'package:narangavellam/app/user_profile/bloc/user_profile_bloc.dart';
import 'package:narangavellam/app/user_profile/widgets/user_profile_create_post.dart';
import 'package:narangavellam/app/user_profile/widgets/user_profile_header.dart';
import 'package:narangavellam/app/user_profile/widgets/user_profile_props.dart';
import 'package:narangavellam/feed/post/widgets/widgets.dart';
import 'package:narangavellam/l10n/l10n.dart';
import 'package:narangavellam/selector/locale/view/locale_selector.dart';
import 'package:narangavellam/selector/theme/view/theme_selector.dart';
import 'package:narangavellam/stories/bloc/create_stories_bloc.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:user_repository/user_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    required this.userId, 
    this.props = const UserProfileProps.build(), 
    super.key,});

  final String userId;
  final UserProfileProps props;

 @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserProfileBloc(
            userId: userId,
            postsRepository: context.read<PostsRepository>(),
            userRepository: context.read<UserRepository>(),
          )
            ..add(const UserProfileSubscriptionRequested())
            ..add(const UserProfilePostsCountSubscriptionRequested())
            ..add(const UserProfileFollowingsCountSubscriptionRequested())
            ..add(const UserProfileFollowersCountSubscriptionRequested()),
        ),
      ],
      child: UserProfileView(userId: userId, props:props),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({
    required this.userId,
    required this.props,
    super.key,});

  final String userId;
  final UserProfileProps props;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late ScrollController _nestedScrollController;

  UserProfileProps get props => widget.props;

  @override
  void initState() {
    _nestedScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promoAction = 
    props.promoBlockAction as NavigateToSponsoredPostAuthorProfileAction?;
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return AppScaffold(
      floatingActionButton: !props.isSponsored
    ? null
    : PromoFloatingAction(
        url: promoAction!.promoUrl,
        promoImageUrl: promoAction.promoPreviewImageUrl,
        title: context.l10n.learnMoreAboutUserPromoText,
        subtitle: context.l10n.visitUserPromoWebsiteText,
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _nestedScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    UserProfileAppBar(sponsoredPost: props.sponsoredPost,),
                    if (!user.isAnonymous || props.sponsoredPost != null) ...[
                      UserProfileHeader(
                        userId: widget.userId, sponsoredPost: props.sponsoredPost,
                      ),
                      SliverPersistentHeader(
                        pinned: !ModalRoute.of(context)!.isFirst,
                        delegate: const _UserProfileTabBarDelegate(
                        TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                        tabs: [
                        Tab(
                          icon: Icon(Icons.grid_on),
                          iconMargin: EdgeInsets.zero,
                        ),
                        Tab(
                          icon: Icon(Icons.person),
                          iconMargin: EdgeInsets.zero,
                        ),
                      ],
                      ),
                      ),
                      ),
                    ],
                  ],
                ),
              ),
            ];
          },
          body:TabBarView(children: [
            UserPostPage(sponsoredPost: props.sponsoredPost,),
            const UserProfileMentionedPostPage(),
          ],),
        ),
      ),
    );
  }
}

class _UserProfileTabBarDelegate extends SliverPersistentHeaderDelegate{
  const _UserProfileTabBarDelegate(this.tabBar);

  final TabBar tabBar;

   @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_UserProfileTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({required this.sponsoredPost,super.key});

    final PostSponsoredBlock? sponsoredPost;

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc bloc) => bloc.isOwner);
    final user$ = context.select((UserProfileBloc b) => b.state.user);
    final user = sponsoredPost == null
    ? user$
    : user$.isAnonymous
        ? sponsoredPost!.author.toUser
        : user$;

    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        pinned: !ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
        title: Row(
          children: [
            Flexible(
              flex: 12,
              child: Text(
                // ignore: unnecessary_string_interpolations
                '${user.displayUsername}',
                style: context.titleLarge?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Assets.icons.verifiedUser.svg(
                width: AppSize.iconSizeSmall,
                height: AppSize.iconSizeSmall,
              ),
            ),
          ],
        ),
        actions: [
          if (!isOwner)
            const UserProfileActions()
          else ...[
            const UserProfileAddMediaButton(),
            if (ModalRoute.of(context)?.isFirst ?? false) ...const [
              Gap.h(AppSpacing.md),
              UserProfileSettingsButton(),
            ],
          ],
        ],
      ),
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.showListOptionsModal(
        options: [
          ModalOption(child: const LocaleModalOption()),
          ModalOption(child: const ThemeSelectorModalOption()),
          ModalOption(child: const LogoutModalOption()),
        ],
      ).then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(
          context.adaptiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children:[
          const ListTile(title: Text('Language')),
          ListTile(
            title: const Text('Theme'),
              onTap: () => context.push('/settings/theme'),
            ),
          ListTile(
            title: const Text('Log Out'),
            onTap: () => context.confirmAction(
            fn: () {
            context.pop();
            context.read<AppBloc>().add(const AppLogoutRequested());
            },
            title: context.l10n.logOutText,
            content: context.l10n.logOutConfirmationText,
            noText: context.l10n.cancelText,
            yesText: context.l10n.logOutText,
              ),
            ),
        ],
      ),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final enableStory =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);
    return Tappable(
      onTap: () => context
          .showListOptionsModal(
        title: l10n.createText,
        options: createMediaModalOptions(
          context: context,
          reelLabel: l10n.reelText,
          postLabel: l10n.postText,
          storyLabel: l10n.storyText,
          enableStory: enableStory,
          goTo: (route, {extra}) => context.pushNamed(route, extra: extra),
          onCreateReelTap: () => PickImage().pickVideo(
             context,
              onMediaPicked: (context, details) => context.pushNamed(
              'publish_post',
              extra: CreatePostProps(
              details: details,
              pickVideo: true,
            ),
          ),
        ),
      ),
    )
       .then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}

class UserPostPage extends StatefulWidget {
  const UserPostPage({this.sponsoredPost,super.key});

  final PostSponsoredBlock? sponsoredPost;

  @override
  State<UserPostPage> createState() => _UserPostPageState();
}

class _UserPostPageState extends State<UserPostPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
 Widget build(BuildContext context) {
  super.build(context);

  return CustomScrollView(
    cacheExtent: 2760,
    slivers: [
      SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      BetterStreamBuilder<List<PostBlock>>(
        initialData: const <PostBlock>[],
        stream: context.read<UserProfileBloc>().userPosts(),
        comparator: const ListEquality<PostBlock>().equals,
        builder: (context, blocks) {
          if (blocks.isEmpty && widget.sponsoredPost == null) {
            return const EmptyPosts();
          }
          return SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 120,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: widget.sponsoredPost != null ? 1 : blocks.length,
            itemBuilder: (context, index) {
              final block = widget.sponsoredPost ?? blocks[index];
              final multiMedia = block.media.length > 1;

              return PostPopup(
                block: block,
                index: index,
                builder: (_) => PostSmall(
                  key: ValueKey(block.id),
                  pinned: false,
                  isReel: block.isReel,
                  multiMedia: multiMedia,
                  mediaUrl: block.firstMediaUrl!,
                  imageThumbnailBuilder: (_, url) => ImageAttachmentThumbnail(
                    image: Attachment(imageUrl: url),
                    fit: BoxFit.cover,
                    ),
                  ),
              );
              },
            );
          },
        ),
      ],
    );
  }
}

class UserProfileMentionedPostPage extends StatefulWidget {
  const UserProfileMentionedPostPage({super.key});

  @override
  State<UserProfileMentionedPostPage> createState() => _UserProfileMentionedPostPageState();
}

class _UserProfileMentionedPostPageState extends State<UserProfileMentionedPostPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const EmptyPosts(icon: Icons.person_pin_outlined),
        ],
      ); 
    }
}

class LogoutModalOption extends StatelessWidget {
  const LogoutModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.confirmAction(
        fn: () {
          context.pop();
          context.read<AppBloc>().add(const AppLogoutRequested());
        },
        title: context.l10n.logOutText,
        content: context.l10n.logOutConfirmationText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.logOutText,
      ),
      child: ListTile(
        title: Text(
          context.l10n.logOutText,
          style: context.bodyLarge?.apply(color: AppColors.red),
        ),
        leading: const Icon(Icons.logout, color: AppColors.red),
      ),
    );
  }
}
