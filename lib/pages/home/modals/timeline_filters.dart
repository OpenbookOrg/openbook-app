import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/circles_list.dart';
import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/models/follows_lists_list.dart';
import 'package:Okuna/pages/home/pages/timeline/timeline.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:Okuna/widgets/tiles/circle_selectable_tile.dart';
import 'package:Okuna/widgets/tiles/follows_list_selectable_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTimelineFiltersModal extends StatefulWidget {
  final OBTimelinePageController timelinePageController;

  const OBTimelineFiltersModal({Key? key, required this.timelinePageController})
      : super(key: key);

  @override
  OBTimelineFiltersModalState createState() {
    return OBTimelineFiltersModalState();
  }
}

class OBTimelineFiltersModalState extends State<OBTimelineFiltersModal> {
  late UserService _userService;
  late LocalizationService _localizationService;

  late bool _requestInProgress;
  late bool _needsBootstrap;

  String? _searchQuery;

  late List<Circle> _circles;
  late List<Circle> _selectedCircles;
  List<Circle>? _disabledCircles;
  late List<Circle> _circlesSearchResults;
  Circle? _connectionsCircle;

  late List<FollowsList> _followsLists;
  late List<FollowsList> _selectedFollowsLists;
  late List<FollowsList> _followsListsSearchResults;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
    _circles = [];
    _selectedCircles = widget.timelinePageController.getFilteredCircles();
    _circlesSearchResults = [];
    _followsLists = [];
    _selectedFollowsLists =
        widget.timelinePageController.getFilteredFollowsLists();
    _followsListsSearchResults = [];
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            OBSearchBar(
              onSearch: _onSearch,
              hintText: _localizationService.trans('user__timeline_filters_search_desc'),
            ),
            Expanded(
              child: _circlesSearchResults.isNotEmpty ||
                      _followsListsSearchResults.isNotEmpty ||
                      _requestInProgress
                  ? _buildSearchResults()
                  : _buildNoResults(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      type: OBButtonType.highlight,
                      child: Text(_localizationService.trans('user__timeline_filters_clear_all')),
                      onPressed: _onWantsToClearFilters,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      child: _buildApplyFiltersText(),
                      onPressed: _onWantsToApplyFilters,
                      isLoading: _requestInProgress,
                    ),
                  )
                ],
              ),
            )
          ],
        )));
  }

  Widget _buildApplyFiltersText() {
    String text = _localizationService.trans('user__timeline_filters_apply_all');
    int filterCount = _selectedCircles.length + _selectedFollowsLists.length;
    if (filterCount > 0) {
      String friendlyCount = filterCount.toString();
      text += ' ($friendlyCount)';
    }
    return Text(text);
  }

  Widget _buildSearchResults() {
    return ListView.builder(
        itemCount:
            _circlesSearchResults.length + _followsListsSearchResults.length,
        itemBuilder: (BuildContext context, int index) {
          bool isCircle = index < _circlesSearchResults.length;
          if (isCircle) {
            Circle circle = _circlesSearchResults[index];
            bool isSelected = _selectedCircles.contains(circle);
            bool isDisabled = _disabledCircles?.contains(circle) ?? false;

            Widget circleTile = OBCircleSelectableTile(
              circle,
              isSelected: isSelected,
              isDisabled: isDisabled,
              onCirclePressed: _onCirclePressed,
            );

            if (index == 0) {
              circleTile = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OBTileGroupTitle(
                    title: _localizationService.trans('user__timeline_filters_circles'),
                  ),
                  circleTile
                ],
              );
            }
            return circleTile;
          }

          int listsIndex = index - _circlesSearchResults.length;

          FollowsList followsList = _followsListsSearchResults[listsIndex];
          bool isSelected = _selectedFollowsLists.contains(followsList);

          Widget listTile = OBFollowsListSelectableTile(
            followsList,
            isSelected: isSelected,
            onFollowsListPressed: _onFollowsListPressed,
          );

          if (index == _circlesSearchResults.length) {
            listTile = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OBTileGroupTitle(
                  title: _localizationService.trans('user__timeline_filters_lists'),
                ),
                listTile
              ],
            );
          }
          return listTile;
        });
  }

  Widget _buildNoResults() {
    return SizedBox(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const OBIcon(OBIcons.sad, customSize: 30.0),
              const SizedBox(
                height: 20.0,
              ),
              OBText(
                _localizationService.user__timeline_filters_no_match(_searchQuery ?? ''),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    return OBThemedNavigationBar(
        leading: GestureDetector(
          child: const OBIcon(OBIcons.close),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: _localizationService.trans('user__timeline_filters_title'));
  }

  void _onWantsToApplyFilters() async {
    _setRequestInProgress(true);
    await widget.timelinePageController.setPostFilters(
        circles: _selectedCircles, followsLists: _selectedFollowsLists);
    _setRequestInProgress(false);
    Navigator.pop(context);
  }

  void _onWantsToClearFilters() async {
    setState(() {
      _selectedFollowsLists = [];
      _selectedCircles = [];
    });
  }

  void _onSearch(String searchString) {
    if (searchString.length == 0) {
      _resetSearchResults();
      return;
    }

    String standarisedSearchStr = searchString.toLowerCase();
    _searchCircles(standarisedSearchStr);
    _searchFollowsLists(standarisedSearchStr);
    _setSearchQuery(searchString);
  }

  void _searchCircles(String standarisedSearchStr) {
    List<Circle> results = _circles.where((Circle circle) {
      return circle.name!.toLowerCase().contains(standarisedSearchStr);
    }).toList();

    _setCirclesSearchResults(results);
  }

  void _searchFollowsLists(String standarisedSearchStr) {
    List<FollowsList> results = _followsLists.where((FollowsList followsList) {
      return followsList.name!.toLowerCase().contains(standarisedSearchStr);
    }).toList();
    _setFollowsListsSearchResults(results);
  }

  void _resetSearchResults() {
    setState(() {
      _circlesSearchResults = _circles.toList();
      _followsListsSearchResults = _followsLists.toList();
    });
  }

  void _onCirclePressed(Circle pressedCircle) {
    if (_selectedCircles.contains(pressedCircle)) {
      // Remove
      if (pressedCircle == _connectionsCircle) {
        _setSelectedCircles([]);
        _updateDisabledCircles();
      } else {
        _removeSelectedCircle(pressedCircle);
      }
    } else {
      // Add
      if (pressedCircle == _connectionsCircle) {
        _setSelectedCircles(_circles.toList());
        _updateDisabledCircles();
      } else {
        _addSelectedCircle(pressedCircle);
      }
    }
  }

  void _setDisabledCircles(List<Circle> disabledCircles) {
    setState(() {
      _disabledCircles = disabledCircles;
    });
  }

  void _setSelectedCircles(List<Circle> selectedCircles) {
    setState(() {
      _selectedCircles = selectedCircles;
    });
  }

  void _addSelectedCircle(Circle circle) {
    setState(() {
      _selectedCircles.add(circle);
    });
  }

  void _removeSelectedCircle(Circle circle) {
    setState(() {
      _selectedCircles.remove(circle);
    });
  }

  void _setCircles(List<Circle> circles) {
    var user = _userService.getLoggedInUser()!;
    setState(() {
      _circles = circles;
      // Find connections circle and move it to the top
      _connectionsCircle = _circles
          .firstWhere((circle) => circle.id == user.connectionsCircleId);
      _circles.remove(_connectionsCircle);
      _circles.insert(0, _connectionsCircle!);
    });
  }

  void _setCirclesSearchResults(List<Circle> circlesSearchResults) {
    setState(() {
      _circlesSearchResults = circlesSearchResults;
    });
  }

  void _onFollowsListPressed(FollowsList pressedFollowsList) {
    if (_selectedFollowsLists.contains(pressedFollowsList)) {
      // Remove
      _removeSelectedFollowsList(pressedFollowsList);
    } else {
      // Add
      _addSelectedFollowsList(pressedFollowsList);
    }
  }

  void _addSelectedFollowsList(FollowsList followsList) {
    setState(() {
      _selectedFollowsLists.add(followsList);
    });
  }

  void _removeSelectedFollowsList(FollowsList followsList) {
    setState(() {
      _selectedFollowsLists.remove(followsList);
    });
  }

  void _setFollowsLists(List<FollowsList> followsLists) {
    setState(() {
      _followsLists = followsLists;
    });
  }

  void _setFollowsListsSearchResults(
      List<FollowsList> followsListsSearchResults) {
    setState(() {
      _followsListsSearchResults = followsListsSearchResults;
    });
  }

  void _setSearchQuery(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _updateDisabledCircles() {
    if (_selectedCircles.contains(_connectionsCircle)) {
      var circles = _circles.toList();
      circles.remove(_connectionsCircle);
      _setDisabledCircles(circles);
    }
    else {
      _setDisabledCircles([]);
    }
  }

  void _bootstrap() async {
    _setRequestInProgress(true);
    var results = await Future.wait(
        [_userService.getConnectionsCircles(), _userService.getFollowsLists()]);

    CirclesList circlesList = results[0] as CirclesList;
    FollowsListsList followsList = results[1] as FollowsListsList;

    _setCircles(circlesList.circles!);
    _setCirclesSearchResults(circlesList.circles!);
    _updateDisabledCircles();
    _setFollowsLists(followsList.lists!);
    _setFollowsListsSearchResults(followsList.lists!);
    _setRequestInProgress(false);
  }
}
