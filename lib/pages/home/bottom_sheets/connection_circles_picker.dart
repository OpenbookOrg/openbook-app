import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/circles_list.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/circles_horizontal_list/circles_horizontal_list.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBConnectionCirclesPickerBottomSheet extends StatefulWidget {
  final String title;
  final String actionLabel;
  final OnPickedCircles onPickedCircles;
  final List<Circle>? initialPickedCircles;

  const OBConnectionCirclesPickerBottomSheet(
      {Key? key,
      this.initialPickedCircles,
      required this.title,
      required this.actionLabel,
      required this.onPickedCircles})
      : super(key: key);

  @override
  OBConnectionCirclesPickerBottomSheetState createState() {
    return OBConnectionCirclesPickerBottomSheetState();
  }
}

class OBConnectionCirclesPickerBottomSheetState
    extends State<OBConnectionCirclesPickerBottomSheet> {
  late UserService _userService;
  late ModalService _modalService;

  late bool _needsBootstrap;

  late List<Circle> _circles;
  late List<Circle> _circleSearchResults;
  late List<Circle> _pickedCircles;
  late List<Circle> _disabledCircles;

  @override
  void initState() {
    super.initState();
    _circles = [];
    _circleSearchResults = [];
    _pickedCircles = widget.initialPickedCircles != null
        ? widget.initialPickedCircles!.toList()
        : [];
    _needsBootstrap = true;
    _disabledCircles = [];
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _modalService = openbookProvider.modalService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBRoundedBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OBText(
                  widget.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                OBButton(
                    size: OBButtonSize.small,
                    child: Text(widget.actionLabel),
                    onPressed: () async {
                      await widget.onPickedCircles(_pickedCircles);
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
          OBSearchBar(
            onSearch: _onSearch,
            hintText: 'Search circles...',
          ),
          const SizedBox(height: 10,),
          SizedBox(
            height: 110,
            child: OBCirclesHorizontalList(
              _circleSearchResults,
              previouslySelectedCircles: widget.initialPickedCircles,
              selectedCircles: _pickedCircles,
              disabledCircles: _disabledCircles,
              onCirclePressed: _onCirclePressed,
              onWantsToCreateANewCircle: _onWantsToCreateANewCircle,
            ),
          )
        ],
      ),
    );
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
  }

  void _setCircleSearchResults(List<Circle> circleSearchResults) {
    setState(() {
      _circleSearchResults = circleSearchResults;
    });
  }

  void _onWantsToCreateANewCircle() async {
    Circle? createdCircle =
        await _modalService.openCreateConnectionsCircle(context: context);
    if (createdCircle != null) {
      _addCircle(createdCircle);
      _addSelectedCircle(createdCircle);
    }
  }

  void _onCirclePressed(Circle pressedCircle) {
    if (_pickedCircles.contains(pressedCircle)) {
      // Remove
      _removeSelectedCircle(pressedCircle);
    } else {
      // Add
      _addSelectedCircle(pressedCircle);
    }
  }

  void _resetCircleSearchResults() {
    setState(() {
      _circleSearchResults = _circles.toList();
    });
  }

  void _bootstrap() async {
    CirclesList circleList = await _userService.getConnectionsCircles();
    // We assume the connections circle will always be the last one
    var connectionsCircles = circleList.circles!;
    Circle connectionsCircle = connectionsCircles.removeLast();
    connectionsCircles.insert(0, connectionsCircle);
    this._setCircles(connectionsCircles);
  }

  void _addCircle(Circle circle) {
    setState(() {
      _circles.add(circle);
      _circleSearchResults.add(circle);
    });
  }

  void _setCircles(List<Circle> circles) {
    var user = _userService.getLoggedInUser();
    setState(() {
      _circles = circles;
      _circleSearchResults = circles.toList();
      var connectionsCircle = _circles.firstWhere((Circle circle) {
        return circle.id == user!.connectionsCircleId;
      });
      _disabledCircles.removeWhere((Circle circle) {
        return !circles.contains(circle);
      });
      _pickedCircles.removeWhere((Circle circle) {
        return !circles.contains(circle);
      });
      _disabledCircles.add(connectionsCircle);
      _pickedCircles.add(connectionsCircle);
    });
  }

  void _addSelectedCircle(Circle circle) {
    setState(() {
      _pickedCircles.add(circle);
    });
  }

  void _removeSelectedCircle(Circle circle) {
    setState(() {
      _pickedCircles.remove(circle);
    });
  }
}

typedef Future<void> OnPickedCircles(List<Circle> circles);
