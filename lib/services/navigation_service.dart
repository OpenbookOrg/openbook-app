import 'dart:math';

import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/reactions_emoji_count.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/pages/home/modals/accept_guidelines/pages/confirm_reject_guidelines.dart';
import 'package:Okuna/pages/home/modals/confirm_block_user.dart';
import 'package:Okuna/pages/home/modals/post_comment_reactions/post_comment_reactions.dart';
import 'package:Okuna/pages/home/modals/post_reactions/post_reactions.dart';
import 'package:Okuna/pages/home/modals/save_post/pages/share_post/pages/share_post_with_circles.dart';
import 'package:Okuna/pages/home/modals/save_post/pages/share_post/pages/share_post_with_community.dart';
import 'package:Okuna/pages/home/modals/save_post/pages/share_post/share_post.dart';
import 'package:Okuna/pages/home/pages/community/community.dart';
import 'package:Okuna/pages/home/pages/community/pages/community_members.dart';
import 'package:Okuna/pages/home/pages/community/pages/community_rules.dart';
import 'package:Okuna/pages/home/pages/community/pages/community_staff/community_staff.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/manage_community.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_administrators/community_administrators.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_administrators/modals/add_community_administrator/pages/confirm_add_community_administrator.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_banned_users/community_banned_users.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_banned_users/modals/ban_community_user/pages/confirm_ban_community_user.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_closed_posts/community_closed_posts.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_moderators/community_moderators.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/community_moderators/modals/add_community_moderator/pages/confirm_add_community_moderator.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/delete_community.dart';
import 'package:Okuna/pages/home/pages/community/pages/manage_community/pages/leave_community.dart';
import 'package:Okuna/pages/home/pages/hashtag/hashtag.dart';
import 'package:Okuna/pages/home/pages/menu/pages/privacy_policy.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/about.dart';
import 'package:Okuna/pages/home/pages/menu/pages/community_guidelines.dart';
import 'package:Okuna/pages/home/pages/menu/pages/connections_circle/connections_circle.dart';
import 'package:Okuna/pages/home/pages/menu/pages/connections_circles/connections_circles.dart';
import 'package:Okuna/pages/home/pages/menu/pages/delete_account/delete_account.dart';
import 'package:Okuna/pages/home/pages/menu/pages/delete_account/pages/confirm_delete_account.dart';
import 'package:Okuna/pages/home/pages/menu/pages/followers.dart';
import 'package:Okuna/pages/home/pages/menu/pages/following.dart';
import 'package:Okuna/pages/home/pages/menu/pages/follows_list/follows_list.dart';
import 'package:Okuna/pages/home/pages/menu/pages/follows_lists/follows_lists.dart';
import 'package:Okuna/pages/home/pages/menu/pages/my_moderation_penalties/my_moderation_penalties.dart';
import 'package:Okuna/pages/home/pages/menu/pages/my_moderation_tasks/my_moderation_tasks.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/account_settings/account_settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/account_settings/pages/blocked_users.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/account_settings/pages/user_language_settings/user_language_settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/application_settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/developer_settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/terms_of_use.dart';
import 'package:Okuna/pages/home/pages/profile/pages/edit_profile/manage_profile.dart';
import 'package:Okuna/pages/home/pages/profile/pages/edit_profile/pages/profile_posts_excluded_communities/profile_posts_excluded_communities.dart';
import 'package:Okuna/pages/home/pages/profile/pages/follow_requests.dart';
import 'package:Okuna/pages/home/pages/search/widgets/top_posts/pages/top_posts_settings/pages/top_posts_excluded_communities.dart';
import 'package:Okuna/pages/home/pages/search/widgets/top_posts/pages/top_posts_settings/top_posts_settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/settings.dart';
import 'package:Okuna/pages/home/pages/menu/pages/useful_links.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/pages/user_invite_detail.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/user_invites.dart';
import 'package:Okuna/pages/home/pages/menu/pages/themes/themes.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/moderated_objects.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/moderated_object_community_review.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/moderated_object_global_review.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_reports_preview/pages/moderated_object_reports.dart';
import 'package:Okuna/pages/home/pages/notifications/pages/notifications_settings.dart';
import 'package:Okuna/pages/home/pages/post/post.dart';
import 'package:Okuna/pages/home/pages/post_comments/post_comments_page.dart';
import 'package:Okuna/pages/home/pages/post_comments/post_comments_page_controller.dart';
import 'package:Okuna/pages/home/pages/profile/profile.dart';
import 'package:Okuna/pages/home/pages/report_object/pages/confirm_report_object.dart';
import 'package:Okuna/pages/home/pages/report_object/report_object.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/new_post_data_uploader.dart';
import 'package:Okuna/widgets/routes/slide_right_route.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  var rng = new Random();

  Future navigateToUserProfile(
      {required User user, required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('userProfileRoute'),
          builder: (BuildContext context) {
            return OBProfilePage(
              user,
            );
          }),
    );
  }

  Future navigateToCommunity(
      {required Community community, required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('communityRoute'),
          builder: (BuildContext context) {
            return OBCommunityPage(
              community,
            );
          }),
    );
  }

  Future navigateToCommunityStaffPage(
      {required BuildContext context, required Community community}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('CommunityStaffPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityStaffPage(
              community: community,
            );
          }),
    );
  }

  Future navigateToCommunityRulesPage(
      {required BuildContext context, required Community community}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('communityRulesPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityRulesPage(
              community: community,
            );
          }),
    );
  }

  Future<bool?> navigateToConfirmAddCommunityAdministrator(
      {required Community community,
      required User user,
      required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute(
          slidableKey: _getKeyRandomisedWithWord(
              'confirmAddCommunityAdministratorRoute'),
          builder: (BuildContext context) {
            return OBConfirmAddCommunityAdministrator(
              community: community,
              user: user,
            );
          }),
    );
  }

  Future<bool?> navigateToConfirmDeleteAccount(
      {required String userPassword, required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute(
          slidableKey: _getKeyRandomisedWithWord('confirmDeleteAccountRoute'),
          builder: (BuildContext context) {
            return OBConfirmDeleteAccount(
              userPassword: userPassword,
            );
          }),
    );
  }

  Future<Object?> navigateToDeleteAccount({required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute(
          slidableKey: _getKeyRandomisedWithWord('deleteAccountRoute'),
          builder: (BuildContext context) {
            return OBDeleteAccountPage();
          }),
    );
  }

  Future<bool?> navigateToConfirmAddCommunityModerator(
      {required Community community,
      required User user,
      required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<bool>(
          slidableKey: _getKeyRandomisedWithWord(
              'confirmAddCommunityModeratorPageRoute'),
          builder: (BuildContext context) {
            return OBConfirmAddCommunityModerator(
              community: community,
              user: user,
            );
          }),
    );
  }

  Future<bool?> navigateToConfirmBanCommunityUser(
      {required Community community,
      required User user,
      required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<bool>(
          slidableKey:
              _getKeyRandomisedWithWord('confirmBanCommunityUserPageRoute'),
          builder: (BuildContext context) {
            return OBConfirmBanCommunityUser(
              community: community,
              user: user,
            );
          }),
    );
  }

  Future<void> navigateToManageCommunity(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('navigateToManageCommunityPageRoute'),
          builder: (BuildContext context) {
            return OBManageCommunityPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToLeaveCommunity(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('leaveCommunityPageRoute'),
          builder: (BuildContext context) {
            return OBLeaveCommunityPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToDeleteCommunity(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('deleteCommunityPageRoute'),
          builder: (BuildContext context) {
            return OBDeleteCommunityPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToCommunityAdministrators(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('communityAdministratorsPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityAdministratorsPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToCommunityMembers(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('communityMembersPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityMembersPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToCommunityModerators(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('communityModeratorsPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityModeratorsPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToCommunityBannedUsers(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('communityBannedUsersPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityBannedUsersPage(
              community: community,
            );
          }),
    );
  }

  Future<void> navigateToCommunityClosedPosts(
      {required Community community, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('communityClosedPostsPageRoute'),
          builder: (BuildContext context) {
            return OBCommunityClosedPostsPage(
              community,
            );
          }),
    );
  }

  Future navigateToCommentPost(
      {required Post post, required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute<dynamic>(
            slidableKey: _getKeyRandomisedWithWord('commentPostPageRoute'),
            builder: (BuildContext context) {
              return OBPostCommentsPage(
                  pageType: PostCommentsPageType.comments,
                  post: post,
                  showPostPreview: true,
                  autofocusCommentInput: true);
            }));
  }

  Future<void> navigateToPostComments(
      {required Post post, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('postCommentsPageRoute'),
          builder: (BuildContext context) {
            return OBPostCommentsPage(
                post: post,
                showPostPreview: true,
                pageType: PostCommentsPageType.comments,
                autofocusCommentInput: false);
          }),
    );
  }

  Future<void> navigateToPostCommentReplies(
      {required Post post,
      required PostComment postComment,
      required BuildContext context,
      Function(PostComment)? onReplyDeleted,
      Function(PostComment)? onReplyAdded}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('postCommentRepliesPageRoute'),
          builder: (BuildContext context) {
            return OBPostCommentsPage(
                pageType: PostCommentsPageType.replies,
                post: post,
                showPostPreview: true,
                postComment: postComment,
                onCommentDeleted: onReplyDeleted,
                onCommentAdded: onReplyAdded,
                autofocusCommentInput: false);
          }),
    );
  }

  Future<void> navigateToPostCommentsLinked(
      {required PostComment postComment, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('postCommentsLinkedPageRoute'),
          builder: (BuildContext context) {
            return OBPostCommentsPage(
                post: postComment.post,
                showPostPreview: true,
                pageType: PostCommentsPageType.comments,
                linkedPostComment: postComment,
                autofocusCommentInput: false);
          }),
    );
  }

  Future<void> navigateToPostCommentRepliesLinked(
      {required PostComment postComment,
      required PostComment parentComment,
      required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('postCommentRepliesLinkedPageRoute'),
          builder: (BuildContext context) {
            return OBPostCommentsPage(
                post: postComment.post,
                postComment: parentComment,
                showPostPreview: true,
                pageType: PostCommentsPageType.replies,
                linkedPostComment: postComment,
                autofocusCommentInput: false);
          }),
    );
  }

  Future navigateToPost({required Post post, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('postPageRoute'),
          builder: (BuildContext context) {
            return OBPostPage(post);
          }),
    );
  }

  Future navigateToSettingsPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('settingsPageRoute'),
          builder: (BuildContext context) {
            return OBSettingsPage();
          }),
    );
  }

  Future navigateToFollowersPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('followersPageRoute'),
          builder: (BuildContext context) {
            return OBFollowersPage();
          }),
    );
  }

  Future navigateToFollowingPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('followingPageRoute'),
          builder: (BuildContext context) {
            return OBFollowingPage();
          }),
    );
  }

  Future navigateToAccountSettingsPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('accountSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBAccountSettingsPage();
          }),
    );
  }

  Future navigateToDeveloperSettingsPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('developerSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBDeveloperSettingsPage();
          }),
    );
  }

  Future navigateToApplicationSettingsPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('applicationSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBApplicationSettingsPage();
          }),
    );
  }

  Future navigateToAboutPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('aboutPage'),
          builder: (BuildContext context) {
            return OBAboutPage();
          }),
    );
  }

  Future navigateToThemesPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('themesPageRoute'),
          builder: (BuildContext context) {
            return OBThemesPage();
          }),
    );
  }

  Future navigateToUsefulLinksPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('usefulLinksPageRoute'),
          builder: (BuildContext context) {
            return OBUsefulLinksPage();
          }),
    );
  }

  Future navigateToCommunityGuidelinesPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('communityGuidelinesPage'),
          builder: (BuildContext context) {
            return OBCommunityGuidelinesPage();
          }),
    );
  }

  Future navigateToPrivacyPolicyPage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('privacyPolicyPage'),
          builder: (BuildContext context) {
            return OBPrivacyPolicyPage();
          }),
    );
  }

  Future navigateToTermsOfUsePage({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('termsOfUsePage'),
          builder: (BuildContext context) {
            return OBTermsOfUsePage();
          }),
    );
  }

  Future navigateToConfirmRejectGuidelinesPage(
      {required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('confirmRejectGuidelinesPageRoute'),
          builder: (BuildContext context) {
            return OBConfirmRejectGuidelines();
          }),
    );
  }

  Future<OBNewPostData?> navigateToSharePost(
      {required BuildContext context,
      required OBNewPostData createPostData}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<OBNewPostData>(
          slidableKey: _getKeyRandomisedWithWord('sharePostPageRoute'),
          builder: (BuildContext context) {
            return OBSharePostPage(
              createPostData: createPostData,
            );
          }),
    );
  }

  Future<OBNewPostData?> navigateToSharePostWithCircles(
      {required BuildContext context,
      required OBNewPostData createPostData}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<OBNewPostData>(
          slidableKey:
              _getKeyRandomisedWithWord('sharePostWithCirclesPageRoute'),
          builder: (BuildContext context) {
            return OBSharePostWithCirclesPage(
              createPostData: createPostData,
            );
          }),
    );
  }

  Future<OBNewPostData?> navigateToSharePostWithCommunity(
      {required BuildContext context,
      required OBNewPostData createPostData}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<OBNewPostData>(
          slidableKey:
              _getKeyRandomisedWithWord('sharePostWithCommunityPageRoute'),
          builder: (BuildContext context) {
            return OBSharePostWithCommunityPage(
              createPostData: createPostData,
            );
          }),
    );
  }

  Future navigateToFollowsLists({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('navigateToFollowsLists'),
          builder: (BuildContext context) {
            return OBFollowsListsPage();
          }),
    );
  }

  Future navigateToUserInvites({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('userInvitesPageRoute'),
          builder: (BuildContext context) {
            return OBUserInvitesPage();
          }),
    );
  }

  Future navigateToShareInvite(
      {required BuildContext context, required UserInvite userInvite}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('shareInvitePageRoute'),
          builder: (BuildContext context) {
            return OBUserInviteDetailPage(
                userInvite: userInvite, showEdit: false);
          }),
    );
  }

  Future navigateToInviteDetailPage(
      {required BuildContext context, required UserInvite userInvite}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('inviteDetailPageRoute'),
          builder: (BuildContext context) {
            return OBUserInviteDetailPage(
                userInvite: userInvite, showEdit: true);
          }),
    );
  }

  Future navigateToConnectionsCircles({required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('connectionsCirclesPageRoute'),
          builder: (BuildContext context) {
            return OBConnectionsCirclesPage();
          }),
    );
  }

  Future navigateToConnectionsCircle(
      {required Circle connectionsCircle, required BuildContext context}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('connectionsCirclePageRoute'),
          builder: (BuildContext context) {
            return OBConnectionsCirclePage(connectionsCircle);
          }),
    );
  }

  Future navigateToFollowsList({
    required FollowsList followsList,
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('followsListPageRoute'),
          builder: (BuildContext context) {
            return OBFollowsListPage(followsList);
          }),
    );
  }

  Future<void> navigateToPostReactions(
      {required Post post,
      required List<ReactionsEmojiCount?> reactionsEmojiCounts,
      required BuildContext context,
      Emoji? reactionEmoji}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('postReactionsPageRoute'),
          builder: (BuildContext context) {
            return OBPostReactionsModal(
              post: post,
              reactionsEmojiCounts: reactionsEmojiCounts,
              reactionEmoji: reactionEmoji,
            );
          }),
    );
  }

  Future<void> navigateToPostCommentReactions(
      {required PostComment postComment,
      required Post post,
      required List<ReactionsEmojiCount?> reactionsEmojiCounts,
      required BuildContext context,
      Emoji? reactionEmoji}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('postCommentReactionsPageRoute'),
          builder: (BuildContext context) {
            return OBPostCommentReactionsModal(
              post: post,
              postComment: postComment,
              reactionsEmojiCounts: reactionsEmojiCounts,
              reactionEmoji: reactionEmoji,
            );
          }),
    );
  }

  Future<void> navigateToNotificationsSettings({
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('notificationsSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBNotificationsSettingsPage();
          }),
    );
  }

  Future<void> navigateToUserLanguageSettings({
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('userLanguageSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBUserLanguageSettingsPage();
          }),
    );
  }

  Future<void> navigateToBlockedUsers({
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('blockedUsersPageRoute'),
          builder: (BuildContext context) {
            return OBBlockedUsersPage();
          }),
    );
  }

  Future<void> navigateToTopPostsExcludedCommunities({
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: Key('topPostsExcludedCommunitiesPageRoute'),
          builder: (BuildContext context) {
            return OBTopPostsExcludedCommunitiesPage();
          }),
    );
  }

  Future<void> navigateToTopPostsSettings({
    required BuildContext context,
  }) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: Key('topPostsSettingsPageRoute'),
          builder: (BuildContext context) {
            return OBTopPostsSettingsPage();
          }),
    );
  }

  Future<void> navigateToConfirmBlockUser(
      {required BuildContext context, required User user}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('confirmBlockUserPageRoute'),
          builder: (BuildContext context) {
            return OBConfirmBlockUserModal(
              user: user,
            );
          }),
    );
  }

  Future<bool?> navigateToConfirmReportObject(
      {required BuildContext context,
      required dynamic object,
      Map<String, dynamic>? extraData,
      required ModerationCategory category}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<bool>(
          slidableKey:
              _getKeyRandomisedWithWord('confirmReportObjectPageRoute'),
          builder: (BuildContext context) {
            return OBConfirmReportObject(
              extraData: extraData,
              object: object,
              category: category,
            );
          }),
    );
  }

  Future<dynamic> navigateToReportObject(
      {required BuildContext context,
      required dynamic object,
      Map<String, dynamic>? extraData,
      ValueChanged<dynamic>? onObjectReported}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('reportObjectPageRoute'),
          builder: (BuildContext context) {
            return OBReportObjectPage(
              object: object,
              extraData: extraData,
              onObjectReported: onObjectReported,
            );
          }),
    );
  }

  Future<dynamic> navigateToCommunityModeratedObjects(
      {required BuildContext context, required Community community}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('communityModeratedObjectsPageRoute'),
          builder: (BuildContext context) {
            return OBModeratedObjectsPage(
              community: community,
            );
          }),
    );
  }

  Future<dynamic> navigateToGlobalModeratedObjects(
      {required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('globalModeratedObjectsPageRoute'),
          builder: (BuildContext context) {
            return OBModeratedObjectsPage();
          }),
    );
  }

  Future<dynamic> navigateToModeratedObjectReports(
      {required BuildContext context,
      required ModeratedObject moderatedObject}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('moderatedObjectReports'),
          builder: (BuildContext context) {
            return OBModeratedObjectReportsPage(
              moderatedObject: moderatedObject,
            );
          }),
    );
  }

  Future<dynamic> navigateToModeratedObjectGlobalReview(
      {required BuildContext context,
      required ModeratedObject moderatedObject}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('moderatedObjectGlobalReviewPageRoute'),
          builder: (BuildContext context) {
            return OBModeratedObjectGlobalReviewPage(
              moderatedObject: moderatedObject,
            );
          }),
    );
  }

  Future<dynamic> navigateToModeratedObjectCommunityReview(
      {required BuildContext context,
      required Community? community,
      required ModeratedObject moderatedObject}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord(
              'moderatedObjectCommunityReviewPageRoute'),
          builder: (BuildContext context) {
            return OBModeratedObjectCommunityReviewPage(
              community: community!,
              moderatedObject: moderatedObject,
            );
          }),
    );
  }

  Future<dynamic> navigateToMyModerationTasksPage(
      {required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('myModerationTasksPageRoute'),
          builder: (BuildContext context) {
            return OBMyModerationTasksPage();
          }),
    );
  }

  Future<dynamic> navigateToMyModerationPenaltiesPage(
      {required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('myModerationPenaltiesPageRoute'),
          builder: (BuildContext context) {
            return OBMyModerationPenaltiesPage();
          }),
    );
  }

  Future<void> navigateToBlankPageWithWidget(
      {required BuildContext context,
      required String navBarTitle,
      required Key key,
      required Widget widget}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey:
              _getKeyRandomisedWithWord('blankPageWithWidgetPageRoute'),
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: OBThemedNavigationBar(
                title: navBarTitle,
              ),
              child: OBPrimaryColorContainer(
                child: widget,
              ),
            );
          }),
    );
  }

  Future navigateToHashtag(
      {required Hashtag hashtag,
      String? rawHashtagName,
      required BuildContext context}) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: _getKeyRandomisedWithWord('hashtagRoute'),
          builder: (BuildContext context) {
            return OBHashtagPage(
                hashtag: hashtag, rawHashtagName: rawHashtagName ?? '');
          }),
    );
  }

  Future<void> navigateToProfilePostsExcludedCommunities(
      {required BuildContext context,
      ValueChanged<Community>? onExcludedCommunityRemoved,
      ValueChanged<List<Community>>? onExcludedCommunitiesAdded}) {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: Key('profilePostsExcludedCommunitiesPageRoute'),
          builder: (BuildContext context) {
            return OBProfilePostsExcludedCommunitiesPage(
              onExcludedCommunitiesAdded: onExcludedCommunitiesAdded,
              onExcludedCommunityRemoved: onExcludedCommunityRemoved,
            );
          }),
    );
  }

  Future<dynamic> navigateToManageProfile({
    required User user,
    required BuildContext context,
    VoidCallback? onUserProfileUpdated,
    ValueChanged<Community>? onExcludedCommunityRemoved,
    ValueChanged<List<Community>>? onExcludedCommunitiesAdded,
  }) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: Key('excludeCommunitiesFromProfilePostsPage'),
          builder: (BuildContext context) {
            return OBManageProfilePage(
              user,
              onUserProfileUpdated: onUserProfileUpdated,
              onExcludedCommunitiesAdded: onExcludedCommunitiesAdded,
              onExcludedCommunityRemoved: onExcludedCommunityRemoved,
            );
          }),
    );
  }

  Future<dynamic> navigateToFollowRequests({
    required BuildContext context,
  }) async {
    return Navigator.push(
      context,
      OBSlideRightRoute<dynamic>(
          slidableKey: Key('excludeCommunitiesFromProfilePostsPage'),
          builder: (BuildContext context) {
            return OBFollowRequestsPage();
          }),
    );
  }

  Key _getKeyRandomisedWithWord(String word) {
    return Key(word + rng.nextInt(1000).toString());
  }
}
