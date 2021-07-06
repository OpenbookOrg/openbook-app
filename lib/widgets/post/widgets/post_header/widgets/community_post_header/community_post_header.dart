import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/pages/home/bottom_sheets/post_actions.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/avatars/community_avatar.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/post/widgets/post_header/widgets/community_post_header/widgets/community_post_creator_identifier.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted? onPostDeleted;
  final ValueChanged<Post>? onPostReported;
  final bool hasActions;
  final OBPostDisplayContext? displayContext;

  // What are we using these 2 for?
  final Function? onCommunityExcluded;
  final Function? onUndoCommunityExcluded;

  final ValueChanged<Community>? onPostCommunityExcludedFromProfilePosts;

  const OBCommunityPostHeader(this._post,
      {Key? key,
      required this.onPostDeleted,
      this.onPostReported,
      this.hasActions = true,
      this.onCommunityExcluded,
      this.onUndoCommunityExcluded,
      this.displayContext = OBPostDisplayContext.timelinePosts,
      this.onPostCommunityExcludedFromProfilePosts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var navigationService = openbookProvider.navigationService;
    var bottomSheetService = openbookProvider.bottomSheetService;
    var localizationService = openbookProvider.localizationService;
    var utilsService = openbookProvider.utilsService;

    return StreamBuilder(
        stream: _post.community?.updateSubject,
        initialData: _post.community,
        builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
          Community community = snapshot.data!;

          return displayContext == OBPostDisplayContext.ownProfilePosts ||
                  displayContext == OBPostDisplayContext.foreignProfilePosts
              ? _buildCommunityHighlightHeader(
                  context: context,
                  community: community,
                  navigationService: navigationService,
                  bottomSheetService: bottomSheetService,
                  utilsService: utilsService,
                  localizationService: localizationService)
              : _buildUserHighlightHeader(
                  context: context,
                  community: community,
                  navigationService: navigationService,
                  bottomSheetService: bottomSheetService);
        });
  }

  Widget _buildCommunityHighlightHeader(
      {BuildContext? context,
      Community? community,
      NavigationService? navigationService,
      BottomSheetService? bottomSheetService,
      UtilsService? utilsService,
      LocalizationService? localizationService}) {
    String created = utilsService!.timeAgo(_post.created!, localizationService!);

    return ListTile(
        leading: OBCommunityAvatar(
          community: community!,
          size: OBAvatarSize.medium,
          onPressed: () {
            navigationService!.navigateToCommunity(
                community: community, context: context!);
          },
        ),
        trailing: hasActions
            ? IconButton(
                icon: const OBIcon(OBIcons.moreVertical),
                onPressed: () {
                  bottomSheetService!.showPostActions(
                      context: context!,
                      post: _post,
                      displayContext: displayContext ?? OBPostDisplayContext.timelinePosts,
                      onCommunityExcluded: onCommunityExcluded,
                      onUndoCommunityExcluded: onUndoCommunityExcluded,
                      onPostCommunityExcludedFromProfilePosts:
                          onPostCommunityExcludedFromProfilePosts,
                      onPostDeleted: onPostDeleted,
                      onPostReported: onPostReported);
                })
            : null,
        title: GestureDetector(
          onTap: () {
            navigationService!.navigateToCommunity(
                community: community, context: context!);
          },
          child: OBText(
            community.title!,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            navigationService!.navigateToCommunity(
                community: community, context: context!);
          },
          child: Row(
            children: <Widget>[
              Expanded(
                child: OBSecondaryText(
                  'c/' + community.name! + ' · $created',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildUserHighlightHeader(
      {BuildContext? context,
      Community? community,
      NavigationService? navigationService,
      BottomSheetService? bottomSheetService}) {
    return ListTile(
      leading: OBAvatar(
        avatarUrl: _post.creator!.getProfileAvatar(),
        size: OBAvatarSize.medium,
        onPressed: () {
          navigationService!.navigateToUserProfile(
              user: _post.creator!, context: context!);
        },
      ),
      trailing: hasActions
          ? IconButton(
              icon: const OBIcon(OBIcons.moreVertical),
              onPressed: () {
                bottomSheetService!.showPostActions(
                    context: context!,
                    post: _post,
                    displayContext: displayContext ?? OBPostDisplayContext.timelinePosts,
                    onCommunityExcluded: onCommunityExcluded,
                    onUndoCommunityExcluded: onUndoCommunityExcluded,
                    onPostCommunityExcludedFromProfilePosts:
                        onPostCommunityExcludedFromProfilePosts,
                    onPostDeleted: onPostDeleted,
                    onPostReported: onPostReported);
              })
          : null,
      title: GestureDetector(
        onTap: () {
          navigationService!.navigateToCommunity(
              community: community!, context: context!);
        },
        child: Row(
          children: <Widget>[
            OBCommunityAvatar(
              borderRadius: 4,
              customSize: 16,
              community: community!,
              onPressed: () {
                navigationService!.navigateToCommunity(
                    community: community, context: context!);
              },
              size: OBAvatarSize.extraSmall,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: OBText(
                'c/' + community.name!,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      subtitle: OBCommunityPostCreatorIdentifier(
        post: _post,
        onUsernamePressed: () {
          navigationService!.navigateToUserProfile(
              user: _post.creator!, context: context!);
        },
      ),
    );
  }
}
