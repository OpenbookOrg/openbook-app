import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/circles_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/new_post_data_uploader.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/circle_selectable_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSharePostWithCirclesPage extends StatefulWidget {
  final OBNewPostData createPostData;

  const OBSharePostWithCirclesPage({Key? key, required this.createPostData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBSharePostWithCirclesPageState();
  }
}

class OBSharePostWithCirclesPageState
    extends State<OBSharePostWithCirclesPage> {
  late UserService _userService;
  late LocalizationService _localizationService;

  late bool _needsBootstrap;

  late List<Circle> _circles;
  late List<Circle> _circleSearchResults;
  late List<Circle> _selectedCircles;
  late List<Circle> _disabledCircles;
  late Circle _fakeWorldCircle;
  Circle? _connectionsCircle;
  late bool _fakeWorldCircleSelected;

  late String _circleSearchQuery;

  @override
  void initState() {
    super.initState();
    _fakeWorldCircleSelected = false;
    _circles = [];
    _circleSearchResults = _circles.toList();
    _selectedCircles = [];
    _circleSearchQuery = '';
    _disabledCircles = [];
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _localizationService = openbookProvider.localizationService;

    if (_needsBootstrap) {
      _bootstrap();
      _fakeWorldCircle =
          Circle(id: 1, name: _localizationService.trans('post__world_circle_name'), color: '#023ca7', usersCount: 7700000000);
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: _buildAvailableAudience(),
        ));
  }

  Widget _buildAvailableAudience() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBSearchBar(
          onSearch: _onSearch,
          hintText: _localizationService.trans('post__search_circles'),
        ),
        Expanded(
            child: _circleSearchResults.length == 0 &&
                    _circleSearchQuery.isNotEmpty
                ? _buildNoResults()
                : _buildSearchResults())
      ],
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    return OBThemedNavigationBar(
      title: _localizationService.trans('post__share_to_circles'),
      trailing: OBButton(
        size: OBButtonSize.small,
        type: OBButtonType.primary,
        isDisabled: _selectedCircles.length == 0 && !_fakeWorldCircleSelected,
        onPressed: createPost,
        child: Text(_localizationService.trans('post__share')),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
        itemCount: _circleSearchResults.length,
        itemBuilder: (BuildContext context, int index) {
          Circle circle = _circleSearchResults[index];
          bool isSelected = _selectedCircles.contains(circle);
          bool isDisabled = _disabledCircles.contains(circle);

          return OBCircleSelectableTile(
            circle,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onCirclePressed: _onCirclePressed,
          );
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
                _localizationService.post__no_circles_for(_circleSearchQuery),
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

  Future<void> createPost() async {
    List<Circle> selectedCircles;

    if (_fakeWorldCircleSelected) {
      selectedCircles = [];
    } else if (_selectedCircles.contains(_connectionsCircle)) {
      selectedCircles = [ _connectionsCircle! ];
    } else {
      selectedCircles = _selectedCircles;
    }

    widget.createPostData.setCircles(selectedCircles);

    Navigator.pop(context, widget.createPostData);
  }

  void _onCirclePressed(Circle pressedCircle) {
    if (_selectedCircles.contains(pressedCircle)) {
      // Remove
      if (pressedCircle == _fakeWorldCircle) {
        // Enable all other circles
        _setDisabledCircles([]);
        _setSelectedCircles([]);
        _setFakeWorldCircleSelected(false);
      } else if (pressedCircle == _connectionsCircle) {
        _setDisabledCircles([]);
        _setSelectedCircles([]);
      } else {
        _removeSelectedCircle(pressedCircle);
      }
    } else {
      // Add
      if (pressedCircle == _fakeWorldCircle) {
        // Add all circles
        _setSelectedCircles(_circles.toList());
        var disabledCircles = _circles.toList();
        disabledCircles.remove(_fakeWorldCircle);
        _setDisabledCircles(disabledCircles);
        _setFakeWorldCircleSelected(true);
      } else if (pressedCircle == _connectionsCircle) {
        var circles = _circles.toList();
        circles.remove(_fakeWorldCircle);
        _setSelectedCircles(circles);
        circles = circles.toList();
        circles.remove(_connectionsCircle);
        _setDisabledCircles(circles);
      } else {
        _addSelectedCircle(pressedCircle);
      }
    }
  }

  void _onSearch(String searchString) {
    if (searchString.length == 0) {
      _resetCircleSearchResults();
      return;
    }

    String standarisedSearchStr = searchString.toLowerCase();

    List<Circle> results = _circles.where((Circle circle) {
      return circle.name!.toLowerCase().contains(standarisedSearchStr);
    }).toList();

    _setCircleSearchResults(results);
    _setCircleSearchQuery(searchString);
  }

  void _bootstrap() async {
    CirclesList circleList = await _userService.getConnectionsCircles();
    this._setCircles(circleList.circles!);
  }

  void _resetCircleSearchResults() {
    setState(() {
      _circleSearchResults = _circles.toList();
    });
  }

  void _setCircles(List<Circle> circles) {
    var user = _userService.getLoggedInUser();
    setState(() {
      _circles = circles;
      // Move connections circle to top
      _connectionsCircle = _circles
          .firstWhere((circle) => circle.id == user!.connectionsCircleId);
      _circles.remove(_connectionsCircle);
      _circles.insert(0, _connectionsCircle!);
      // Add fake world circle
      _circles.insert(0, _fakeWorldCircle);
      _selectedCircles = [];
      _circleSearchResults = circles.toList();
    });
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

  void _setCircleSearchResults(List<Circle> circleSearchResults) {
    setState(() {
      _circleSearchResults = circleSearchResults;
    });
  }

  void _setCircleSearchQuery(String searchQuery) {
    setState(() {
      _circleSearchQuery = searchQuery;
    });
  }

  void _setFakeWorldCircleSelected(bool fakeWorldCircleSelected) {
    setState(() {
      _fakeWorldCircleSelected = fakeWorldCircleSelected;
    });
  }
}
