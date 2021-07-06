import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/profile_card.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_cover.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_nav_bar.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_posts_stream_status_indicator.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/posts_stream/posts_stream.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBProfilePage extends StatefulWidget {
  final OBProfilePageController? controller;
  final User user;

  OBProfilePage(
    this.user, {
    this.controller,
  });

  @override
  OBProfilePageState createState() {
    return OBProfilePageState();
  }
}

class OBProfilePageState extends State<OBProfilePage> {
  late User _user;
  late bool _needsBootstrap;
  late UserService _userService;
  late LocalizationService _localizationService;
  late OBPostsStreamController _obPostsStreamController;
  late bool _profileCommunityPostsVisible;
  late OBPostDisplayContext _postsDisplayContext;

  late List<Community> _recentlyExcludedCommunities;
  GlobalKey<RefreshIndicatorState> _protectedProfileRefreshIndicatorKey =
      GlobalKey();
  late bool _needsProtectedProfileBootstrap;

  @override
  void initState() {
    super.initState();
    _obPostsStreamController = OBPostsStreamController();
    _needsBootstrap = true;
    _needsProtectedProfileBootstrap = true;
    _user = widget.user;
    if (widget.controller != null) widget.controller!.attach(this);
    _profileCommunityPostsVisible =
        widget.user.getProfileCommunityPostsVisible();
    _recentlyExcludedCommunities = [];
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      bool isLoggedInUserProfile = _userService.isLoggedInUser(widget.user);
      _postsDisplayContext = isLoggedInUserProfile
          ? OBPostDisplayContext.ownProfilePosts
          : OBPostDisplayContext.foreignProfilePosts;
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBProfileNavBar(_user),
        child: OBPrimaryColorContainer(
          child: StreamBuilder(
              initialData: widget.user,
              stream: widget.user.updateSubject,
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                User? user = snapshot.data;
                if (user == null) return const SizedBox();

                if (_postsDisplayContext ==
                        OBPostDisplayContext.ownProfilePosts ||
                    user.visibility != UserVisibility.private ||
                    (user.isFollowing != null && user.isFollowing!)) {
                  return _buildVisibleProfileContent();
                }

                // User is private and its not us
                return _buildProtectedProfileContent();
              }),
        ));
  }

  Widget _buildVisibleProfileContent() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: OBPostsStream(
              streamIdentifier: 'profile_${widget.user.username}',
              displayContext: _postsDisplayContext,
              prependedItems: _buildProfileContentDetails(),
              controller: _obPostsStreamController,
              postBuilder: _buildPostsStreamPost as OBPostsStreamPostBuilder, // TODO: I don't understand why I have to do this.
              secondaryRefresher: _refreshUser,
              refresher: _refreshPosts,
              onScrollLoader: _loadMorePosts,
              onPostsRefreshed: _onPostsRefreshed,
              statusIndicatorBuilder: _buildPostsStreamStatusIndicator),
        ),
      ],
    );
  }

  Widget _buildProtectedProfileContent() {
    if (_needsProtectedProfileBootstrap) {
      Future.delayed(Duration(milliseconds: 100), () {
        _protectedProfileRefreshIndicatorKey.currentState?.show();
      });
      _needsProtectedProfileBootstrap = false;
    }

    List<Widget> profileDetails = _buildProfileContentDetails();

    profileDetails.addAll([
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: _buildPrivateProfileContentAlert(),
      )
    ]);

    return RefreshIndicator(
      displacement: 40,
      key: _protectedProfileRefreshIndicatorKey,
      onRefresh: _refreshUser,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: profileDetails,
        ),
      ),
    );
  }

  Widget _buildPrivateProfileContentAlert() {
    return OBAlert(
        child: Row(
      children: [
        OBIcon(
          OBIcons.visibilityPrivate,
          size: OBIconSize.large,
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OBText(
                _localizationService.user__protected_account_title,
                size: OBTextSize.large,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              OBSecondaryText(
                _localizationService
                    .user__protected_account_desc(widget.user.username!),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                stream: widget.user.updateSubject,
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.data == null ||
                      snapshot.data!.isFollowRequested == null)
                    return const SizedBox();
                  User user = snapshot.data!;
                  return OBSecondaryText((user.isFollowRequested == true
                      ? _localizationService
                          .user__protected_account_instructions_complete
                      : _localizationService
                          .user__protected_account_instructions(
                              getFollowButtonText())));
                },
              ),
            ],
          ),
        )
      ],
    ));
  }

  List<Widget> _buildProfileContentDetails() {
    return [
      OBProfileCover(_user),
      OBProfileCard(
        _user,
        onUserProfileUpdated: _onUserProfileUpdated,
        onExcludedCommunitiesAdded: _onExcludedCommunitiesAdded,
        onExcludedCommunityRemoved: _onExcludedCommunityRemoved,
      )
    ];
  }

  Widget _buildPostsStreamStatusIndicator(
      {required BuildContext context,
      required OBPostsStreamStatus streamStatus,
      required List<Widget> streamPrependedItems,
      required Function streamRefresher}) {
    return OBProfilePostsStreamStatusIndicator(
        user: widget.user,
        streamRefresher: streamRefresher as VoidCallback,
        streamPrependedItems: streamPrependedItems,
        streamStatus: streamStatus);
  }

  Widget _buildPostsStreamPost({
    required BuildContext context,
    required Post post,
    required String postIdentifier,
    required OBPostDisplayContext displayContext,
    required ValueChanged<Post> onPostDeleted,
  }) {
    return _recentlyExcludedCommunities.contains(post.community)
        ? const SizedBox()
        : OBPost(
            post,
            key: Key(postIdentifier),
            onPostDeleted: onPostDeleted,
            displayContext: displayContext,
            inViewId: postIdentifier,
            onPostCommunityExcludedFromProfilePosts:
                _onPostCommunityExcludedFromProfilePosts,
          );
  }

  String getFollowButtonText() {
    return widget.user.isFollowed != null && widget.user.isFollowed!
        ? _localizationService.user__follow_button_follow_back_text
        : _localizationService.user__follow_button_follow_text;
  }

  void _onPostCommunityExcludedFromProfilePosts(Community community) {
    _addRecentlyExcludedCommunity(community);
  }

  void _onUserProfileUpdated() {
    if (_profileCommunityPostsVisible !=
        _user.getProfileCommunityPostsVisible()) {
      _refreshPosts();
    }
  }

  void _onExcludedCommunitiesAdded(List<Community> excludedCommunities) {
    excludedCommunities.forEach((excludedCommunity) {
      _addRecentlyExcludedCommunity(excludedCommunity);
    });
  }

  void _onExcludedCommunityRemoved(Community excludedCommunity) {
    _obPostsStreamController.refresh();
  }

  void scrollToTop() {
    _obPostsStreamController.scrollToTop();
  }

  Future<void> _refreshUser() async {
    var user = await _userService.getUserWithUsername(_user.username!);
    _setUser(user);
  }

  Future<List<Post>> _refreshPosts() async {
    return (await _userService.getTimelinePosts(username: _user.username))
        .posts ?? [];
  }

  Future<List<Post>> _loadMorePosts(List<Post> posts) async {
    Post lastPost = posts.last;

    return (await _userService.getTimelinePosts(
            maxId: lastPost.id, username: _user.username))
        .posts ?? [];
  }

  void _onPostsRefreshed(List<Post> posts) {
    _clearRecentlyExcludedCommunity();
  }

  void _setUser(User user) {
    setState(() {
      _user = user;
    });
  }

  void _clearRecentlyExcludedCommunity() {
    setState(() {
      _recentlyExcludedCommunities = [];
    });
  }

  void _addRecentlyExcludedCommunity(Community community) {
    setState(() {
      _recentlyExcludedCommunities.add(community);
    });
  }
}

class OBProfilePageController {
  OBProfilePageState? _timelinePageState;

  void attach(OBProfilePageState? profilePageState) {
    assert(profilePageState != null, 'Cannot attach to empty state');
    _timelinePageState = profilePageState;
  }

  void scrollToTop() {
    if (_timelinePageState != null) _timelinePageState!.scrollToTop();
  }
}

typedef void OnWantsToEditUserProfile(User user);
