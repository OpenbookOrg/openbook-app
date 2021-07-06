import 'package:Okuna/libs/str_utils.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMyCommunitiesGroup extends StatefulWidget {
  final OBHttpListRefresher<Community> communityGroupListRefresher;
  final OBHttpListSearcher<Community>? communityGroupListSearcher;
  final OBHttpListItemBuilder<Community> communityGroupListItemBuilder;
  final OBHttpListItemBuilder<Community>? communitySearchResultListItemBuilder;
  final OBHttpListOnScrollLoader<Community> communityGroupListOnScrollLoader;
  final OBMyCommunitiesGroupFallbackBuilder? noGroupItemsFallbackBuilder;
  final OBMyCommunitiesGroupController? controller;
  final String groupItemName;
  final String groupName;
  final int maxGroupListPreviewItems;
  final String title;

  const OBMyCommunitiesGroup({
    Key? key,
    required this.communityGroupListRefresher,
    required this.communityGroupListOnScrollLoader,
    required this.groupItemName,
    required this.groupName,
    required this.title,
    required this.maxGroupListPreviewItems,
    required this.communityGroupListItemBuilder,
    this.communityGroupListSearcher,
    this.communitySearchResultListItemBuilder,
    this.noGroupItemsFallbackBuilder,
    this.controller,
  }) : super(key: key);

  @override
  OBMyCommunitiesGroupState createState() {
    return OBMyCommunitiesGroupState();
  }
}

class OBMyCommunitiesGroupState extends State<OBMyCommunitiesGroup> {
  late bool _needsBootstrap;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late List<Community> _communityGroupList;
  late bool _refreshInProgress;
  CancelableOperation? _refreshOperation;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller!.attach(this);
    _needsBootstrap = true;
    _communityGroupList = [];
    _refreshInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    int listItemCount =
        _communityGroupList.length < widget.maxGroupListPreviewItems
            ? _communityGroupList.length
            : widget.maxGroupListPreviewItems;

    if (listItemCount == 0) {
      if (widget.noGroupItemsFallbackBuilder != null && !_refreshInProgress) {
        return widget.noGroupItemsFallbackBuilder!(
            context, _refreshJoinedCommunities);
      }
      return const SizedBox();
    }

    List<Widget> columnItems = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: OBText(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      ListView.separated(
          key: Key(widget.groupName + 'communitiesGroup'),
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: _buildCommunitySeparator,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shrinkWrap: true,
          itemCount: listItemCount,
          itemBuilder: _buildGroupListPreviewItem),
    ];

    if (_communityGroupList.length > widget.maxGroupListPreviewItems) {
      columnItems.add(_buildSeeAllButton());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnItems,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller != null) widget.controller!.detach();
    if (_refreshOperation != null) _refreshOperation!.cancel();
  }

  Widget _buildSeeAllButton() {
    return GestureDetector(
      onTap: _onWantsToSeeAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OBSecondaryText(_localizationService.user__groups_see_all(widget.groupName),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 5,
            ),
            OBIcon(OBIcons.seeMore, themeColor: OBIconThemeColor.secondaryText)
          ],
        ),
      ),
    );
  }

  Widget _buildGroupListPreviewItem(BuildContext context, index) {
    Community community = _communityGroupList[index];
    return widget.communityGroupListItemBuilder(context, community);
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  void _bootstrap() {
    _refreshJoinedCommunities();
  }

  Future<void> _refreshJoinedCommunities() async {
    if (_refreshOperation != null) _refreshOperation!.cancel();
    _setRefreshInProgress(true);
    try {
      _refreshOperation =
          CancelableOperation.fromFuture(widget.communityGroupListRefresher());

      List<Community> groupCommunities = await _refreshOperation!.value;

      _setCommunityGroupList(groupCommunities);
    } catch (error) {
      _onError(error);
    } finally {
      _refreshOperation = null;
      _setRefreshInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onWantsToSeeAll() {
    _navigationService.navigateToBlankPageWithWidget(
        context: context,
        key: Key('obMyCommunitiesGroup' + widget.groupItemName),
        navBarTitle: toCapital(widget.groupName),
        widget: _buildSeeAllGroupItemsPage());
  }

  Widget _buildSeeAllGroupItemsPage() {
    return Column(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
          child: OBHttpList<Community>(
              separatorBuilder: _buildCommunitySeparator,
              listItemBuilder: widget.communityGroupListItemBuilder,
              listRefresher: widget.communityGroupListRefresher,
              listSearcher: widget.communityGroupListSearcher,
              searchResultListItemBuilder: widget.communitySearchResultListItemBuilder,
              listOnScrollLoader: widget.communityGroupListOnScrollLoader,
              resourcePluralName: widget.groupName,
              resourceSingularName: widget.groupItemName),
        )),
      ],
    );
  }

  void _setCommunityGroupList(List<Community> communities) {
    setState(() {
      _communityGroupList = communities;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

class OBMyCommunitiesGroupController {
  OBMyCommunitiesGroupState? _state;

  void attach(OBMyCommunitiesGroupState state) {
    this._state = state;
  }

  void detach() {
    this._state = null;
  }

  Future<void> refresh() {
    if (_state == null) return Future.value();
    return _state!._refreshJoinedCommunities();
  }
}

typedef Future<void> OBMyCommunitiesGroupRetry();

typedef Widget OBMyCommunitiesGroupFallbackBuilder(
    BuildContext context, OBMyCommunitiesGroupRetry retry);
