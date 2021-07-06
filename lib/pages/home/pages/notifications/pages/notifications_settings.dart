import 'package:Okuna/models/user_notifications_settings.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/push_notifications/push_notifications.dart';
import 'package:Okuna/widgets/fields/toggle_field.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBNotificationsSettingsPage extends StatefulWidget {
  @override
  OBNotificationsSettingsPageState createState() {
    return OBNotificationsSettingsPageState();
  }
}

class OBNotificationsSettingsPageState
    extends State<OBNotificationsSettingsPage> {
  late UserService _userService;
  late PushNotificationsService _pushNotificationsService;
  late ToastService _toastService;
  late LocalizationService _localizationService;

  late bool _needsBootstrap;
  late bool _bootstrapInProgress;

  UserNotificationsSettings? currentNotificationsSettings;

  late bool _pushNotifications;

  late bool _postCommentNotifications;
  late bool _postCommentReactionNotifications;
  late bool _postCommentReplyNotifications;
  late bool _postCommentUserMentionNotifications;
  late bool _postUserMentionNotifications;
  late bool _postReactionNotifications;
  late bool _followNotifications;
  late bool _followRequestNotifications;
  late bool _followRequestApprovedNotifications;
  late bool _connectionRequestNotifications;
  late bool _communityInviteNotifications;
  late bool _communityNewPostNotifications;
  late bool _userNewPostNotifications;

  @override
  void initState() {
    super.initState();
    _pushNotifications = true;
    _needsBootstrap = true;
    _bootstrapInProgress = true;
    _postCommentNotifications = true;
    _postCommentReactionNotifications = true;
    _postCommentReplyNotifications = true;
    _postReactionNotifications = true;
    _followNotifications = true;
    _followRequestNotifications = true;
    _followRequestApprovedNotifications = true;
    _connectionRequestNotifications = true;
    _communityInviteNotifications = true;
    _communityNewPostNotifications = true;
    _userNewPostNotifications = true;
    _postUserMentionNotifications = true;
    _postCommentUserMentionNotifications = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _pushNotificationsService = openbookProvider.pushNotificationsService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(
          title: _localizationService.trans('notifications__settings_title'),
        ),
        child: OBPrimaryColorContainer(
          child: SingleChildScrollView(
              child: _bootstrapInProgress
                  ? _buildBootstrapInProgressIndicator()
                  : _buildToggles()),
        ));
  }

  Widget _buildBootstrapInProgressIndicator() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.all(20),
              child: const OBProgressIndicator(),
            )
          ],
        )
      ],
    );
  }

  Widget _buildToggles() {
    const Widget listItemSeparator = SizedBox(
      height: 10,
    );

    List<Widget> toggles = [
      OBToggleField(
        key: Key('All'),
        value: _pushNotifications,
        title: _localizationService.trans('notifications__general_title'),
        subtitle:
            OBText(_localizationService.trans('notifications__general_desc')),
        onChanged: _setPushNotifications,
        onTap: _togglePushNotifications,
        hasDivider: false,
      ),
    ];

    if (_pushNotifications) {
      toggles.addAll([
        OBDivider(),
        OBToggleField(
          key: Key('Follow'),
          value: _followNotifications,
          title: _localizationService.trans('notifications__follow_title'),
          subtitle:
              OBText(_localizationService.trans('notifications__follow_desc')),
          onChanged: _setFollowNotifications,
          onTap: _toggleFollowNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Follow request'),
          value: _followRequestNotifications,
          title: _localizationService.notifications__follow_request_title,
          subtitle: OBText(
              _localizationService.notifications__follow_request_desc),
          onChanged: _setFollowRequestNotifications,
          onTap: _toggleFollowRequestNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Follow request approved'),
          value: _followRequestApprovedNotifications,
          title: _localizationService.notifications__follow_request_approved_title,
          subtitle: OBText(
              _localizationService.notifications__follow_request_approved_title_desc),
          onChanged: _setFollowRequestApprovedNotifications,
          onTap: _toggleFollowRequestApprovedNotifications,
          hasDivider: false,
        ),
        listItemSeparator,
        OBToggleField(
          key: Key('Connection request'),
          value: _connectionRequestNotifications,
          title: _localizationService.trans('notifications__connection_title'),
          subtitle: OBText(
              _localizationService.trans('notifications__connection_desc')),
          onChanged: _setConnectionRequestNotifications,
          onTap: _toggleConnectionRequestNotifications,
          hasDivider: false,
        ),
        listItemSeparator,
        OBToggleField(
          key: Key('Post comments'),
          value: _postCommentNotifications,
          title: _localizationService.trans('notifications__comment_title'),
          subtitle:
              OBText(_localizationService.trans('notifications__comment_desc')),
          onChanged: _setPostCommentNotifications,
          onTap: _togglePostCommentNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Post comments replies'),
          value: _postCommentReplyNotifications,
          title:
              _localizationService.trans('notifications__comment_reply_title'),
          subtitle: OBText(
              _localizationService.trans('notifications__comment_reply_desc')),
          onChanged: _setPostCommentReplyNotifications,
          onTap: _togglePostCommentReplyNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Post comment user mentions'),
          value: _postCommentUserMentionNotifications,
          title: _localizationService.notifications__comment_user_mention_title,
          subtitle: OBText(
              _localizationService.notifications__comment_user_mention_desc),
          onChanged: _setPostCommentUserMentionNotifications,
          onTap: _togglePostCommentUserMentionNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Post user mentions'),
          value: _postUserMentionNotifications,
          title: _localizationService.notifications__post_user_mention_title,
          subtitle: OBText(
              _localizationService.notifications__post_user_mention_desc),
          onChanged: _setPostUserMentionNotifications,
          onTap: _togglePostUserMentionNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Post comment reactions'),
          value: _postCommentReactionNotifications,
          title: _localizationService
              .trans('notifications__comment_reaction_title'),
          subtitle: OBText(_localizationService
              .trans('notifications__comment_reaction_desc')),
          onChanged: _setPostCommentReactionNotifications,
          onTap: _togglePostCommentReactionNotifications,
          hasDivider: false,
        ),
        listItemSeparator,
        OBToggleField(
          key: Key('Post reaction'),
          value: _postReactionNotifications,
          title:
              _localizationService.trans('notifications__post_reaction_title'),
          subtitle: OBText(
            _localizationService.trans('notifications__post_reaction_desc'),
          ),
          onChanged: _setPostReactionNotifications,
          onTap: _togglePostReactionNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Community invite'),
          value: _communityInviteNotifications,
          title: _localizationService
              .trans('notifications__community_invite_title'),
          subtitle: OBText(_localizationService
              .trans('notifications__community_invite_desc')),
          onChanged: _setCommunityInviteNotifications,
          onTap: _toggleCommunityInviteNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('Community new post'),
          value: _communityNewPostNotifications,
          title: _localizationService.notifications__community_new_post_title,
          subtitle: OBText(_localizationService
              .notifications__community_new_post_desc),
          onChanged: _setCommunityNewPostNotifications,
          onTap: _toggleCommunityNewPostNotifications,
          hasDivider: false,
        ),
        OBToggleField(
          key: Key('User new post'),
          value: _userNewPostNotifications,
          title: _localizationService.notifications__user_new_post_title,
          subtitle: OBText(_localizationService
              .notifications__user_new_post_desc),
          onChanged: _setUserNewPostNotifications,
          onTap: _toggleUserNewPostNotifications,
          hasDivider: false,
        )
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 40),
            child: Column(children: toggles)),
      ],
    );
  }

  void _togglePushNotifications() {
    _setPushNotifications(!_pushNotifications);
  }

  Future _setPushNotifications(bool pushNotifications) async {
    setState(() {
      _pushNotifications = pushNotifications;
    });

    return pushNotifications
        ? _pushNotificationsService.subscribeToPushNotifications()
        : _pushNotificationsService.unsubscribeFromPushNotifications();
  }

  void _toggleConnectionRequestNotifications() {
    _setConnectionRequestNotifications(!_connectionRequestNotifications);
  }

  void _setConnectionRequestNotifications(bool newValue) {
    setState(() {
      _connectionRequestNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleFollowNotifications() {
    _setFollowNotifications(!_followNotifications);
  }

  void _setFollowNotifications(bool newValue) {
    setState(() {
      _followNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleFollowRequestNotifications() {
    _setFollowRequestNotifications(!_followRequestNotifications);
  }

  void _setFollowRequestNotifications(bool newValue) {
    setState(() {
      _followRequestNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleFollowRequestApprovedNotifications() {
    _setFollowRequestApprovedNotifications(!_followRequestApprovedNotifications);
  }

  void _setFollowRequestApprovedNotifications(bool newValue) {
    setState(() {
      _followRequestApprovedNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleCommunityInviteNotifications() {
    _setCommunityInviteNotifications(!_communityInviteNotifications);
  }

  void _setCommunityInviteNotifications(bool newValue) {
    setState(() {
      _communityInviteNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleCommunityNewPostNotifications() {
    _setCommunityNewPostNotifications(!_communityNewPostNotifications);
  }

  void _setCommunityNewPostNotifications(bool newValue) {
    setState(() {
      _communityNewPostNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _toggleUserNewPostNotifications() {
    _setUserNewPostNotifications(!_userNewPostNotifications);
  }

  void _setUserNewPostNotifications(bool newValue) {
    setState(() {
      _userNewPostNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostCommentNotifications() {
    _setPostCommentNotifications(!_postCommentNotifications);
  }

  void _setPostCommentNotifications(bool newValue) {
    setState(() {
      _postCommentNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostCommentReactionNotifications() {
    _setPostCommentReactionNotifications(!_postCommentReactionNotifications);
  }

  void _setPostCommentReactionNotifications(bool newValue) {
    setState(() {
      _postCommentReactionNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostCommentReplyNotifications() {
    _setPostCommentReplyNotifications(!_postCommentReplyNotifications);
  }

  void _setPostCommentReplyNotifications(bool newValue) {
    setState(() {
      _postCommentReplyNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostCommentUserMentionNotifications() {
    _setPostCommentUserMentionNotifications(
        !_postCommentUserMentionNotifications);
  }

  void _setPostCommentUserMentionNotifications(bool newValue) {
    setState(() {
      _postCommentUserMentionNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostUserMentionNotifications() {
    _setPostUserMentionNotifications(!_postUserMentionNotifications);
  }

  void _setPostUserMentionNotifications(bool newValue) {
    setState(() {
      _postUserMentionNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _togglePostReactionNotifications() {
    _setPostReactionNotifications(!_postReactionNotifications);
  }

  void _setPostReactionNotifications(bool newValue) {
    setState(() {
      _postReactionNotifications = newValue;
    });

    _submitNotificationsSettings();
  }

  void _bootstrap() async {
    await Future.wait([
      _refreshNotificationsSettings(),
      _refreshPushNotifications(),
    ]);
    _setBootstrapInProgress(false);
  }

  Future _refreshPushNotifications() async {
    bool isSubscribedToPushNotifications =
        await _pushNotificationsService.isSubscribedToPushNotifications();

    setState(() {
      _pushNotifications = isSubscribedToPushNotifications;
    });
  }

  Future _refreshNotificationsSettings() async {
    try {
      UserNotificationsSettings notificationsSettings =
          await _userService.getAuthenticatedUserNotificationsSettings();

      _setNotificationsSettings(notificationsSettings);
    } catch (error) {
      _onError(error);
    }
  }

  void _submitNotificationsSettings() {
    try {
      _userService.updateAuthenticatedUserNotificationsSettings(
          followNotifications: _followNotifications,
          followRequestNotifications: _followRequestNotifications,
          followRequestApprovedNotifications: _followRequestApprovedNotifications,
          postCommentNotifications: _postCommentNotifications,
          postCommentReplyNotifications: _postCommentReplyNotifications,
          postCommentUserMentionNotifications: _postCommentUserMentionNotifications,
          postUserMentionNotifications: _postUserMentionNotifications,
          postCommentReactionNotifications: _postCommentReactionNotifications,
          postReactionNotifications: _postReactionNotifications,
          connectionRequestNotifications: _connectionRequestNotifications,
          communityNewPostNotifications: _communityNewPostNotifications,
          userNewPostNotifications: _userNewPostNotifications,
          communityInviteNotifications: _communityInviteNotifications);
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(
          message: _localizationService.trans('error__unknown_error'),
          context: context);
      throw error;
    }
  }

  void _setNotificationsSettings(
      UserNotificationsSettings notificationSettings) {
    setState(() {
      _connectionRequestNotifications =
          notificationSettings.connectionRequestNotifications ?? false;
      _postCommentNotifications = notificationSettings.postCommentNotifications ?? false;
      _postCommentReactionNotifications =
          notificationSettings.postCommentReactionNotifications ?? false;
      _postCommentUserMentionNotifications =
          notificationSettings.postCommentUserMentionNotifications ?? false;
      _postUserMentionNotifications =
          notificationSettings.postUserMentionNotifications ?? false;
      _postCommentReplyNotifications =
          notificationSettings.postCommentReplyNotifications ?? false;
      _postReactionNotifications =
          notificationSettings.postReactionNotifications ?? false;
      _followNotifications = notificationSettings.followNotifications ?? false;
      _followRequestNotifications = notificationSettings.followRequestNotifications ?? false;
      _followRequestApprovedNotifications = notificationSettings.followRequestApprovedNotifications ?? false;
      _communityInviteNotifications =
          notificationSettings.communityInviteNotifications ?? false;
      _communityNewPostNotifications =
          notificationSettings.communityNewPostNotifications ?? false;
      _userNewPostNotifications =
          notificationSettings.userNewPostNotifications ?? false;
    });
  }

  void _setBootstrapInProgress(bool bootstrapInProgress) {
    setState(() {
      _bootstrapInProgress = bootstrapInProgress;
    });
  }
}
