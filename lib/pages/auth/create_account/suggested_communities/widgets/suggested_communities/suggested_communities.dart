import 'package:Okuna/models/communities_list.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/actions/join_community_button.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSuggestedCommunities extends StatefulWidget {
  final VoidCallback? onNoSuggestions;

  const OBSuggestedCommunities({this.onNoSuggestions});

  @override
  OBSuggestedCommunitiesState createState() {
    return OBSuggestedCommunitiesState();
  }
}

class OBSuggestedCommunitiesState extends State<OBSuggestedCommunities>
    with AutomaticKeepAliveClientMixin {
  late bool _needsBootstrap;
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late List<Community> _suggestedCommunities;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _suggestedCommunities = [];
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return _suggestedCommunities.isEmpty
        ? _requestInProgress ? _buildProgressIndicator() : const SizedBox()
        : _buildSuggestedCommunities();
  }

  Widget _buildProgressIndicator() {
    return Container(
      child: Center(
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSuggestedCommunities() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: _buildCommunitySeparator,
            padding: const EdgeInsets.only(bottom: 20),
            shrinkWrap: true,
            itemCount: _suggestedCommunities.length,
            itemBuilder: _buildCommunity)
      ],
    );
  }

  Widget _buildCommunity(BuildContext context, index) {
    Community community = _suggestedCommunities[index];

    //bool communityIsJoined = _selectedCommunities?.contains(community);

    return OBCommunityTile(
      community,
      size: OBCommunityTileSize.normal,
      trailing: OBJoinCommunityButton(community, communityThemed: false,),
    );
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  void _bootstrap() {
    _fetchSuggestedCommunities();
  }

  Future<void> _fetchSuggestedCommunities() async {
    debugPrint('Fetching suggested communities');
    _setRequestInProgress(true);
    try {
      CommunitiesList suggestedCommunitiesList =
      await _userService.getSuggestedCommunities();
      _setSuggestedCommunities(suggestedCommunitiesList.communities);
      if (widget.onNoSuggestions != null &&
          suggestedCommunitiesList.communities?.isEmpty == true) widget.onNoSuggestions!();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setSuggestedCommunities(List<Community>? communities) {
    setState(() {
      _suggestedCommunities = communities ?? [];
    });
  }

  void _setRequestInProgress(bool refreshInProgress) {
    setState(() {
      _requestInProgress = refreshInProgress;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
