import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/moderated_objects.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/fields/checkbox_field.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/moderated_object_status_circle.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../provider.dart';

class OBModeratedObjectsFiltersModal extends StatefulWidget {
  final OBModeratedObjectsPageController moderatedObjectsPageController;

  const OBModeratedObjectsFiltersModal(
      {Key? key, required this.moderatedObjectsPageController})
      : super(key: key);

  @override
  OBModeratedObjectsFiltersModalState createState() {
    return OBModeratedObjectsFiltersModalState();
  }
}

class OBModeratedObjectsFiltersModalState
    extends State<OBModeratedObjectsFiltersModal> {
  late bool _requestInProgress;
  late LocalizationService _localizationService;

  late List<ModeratedObjectType> _types;
  late List<ModeratedObjectType> _selectedTypes;
  List<ModeratedObjectStatus> _statuses = [
    ModeratedObjectStatus.approved,
    ModeratedObjectStatus.rejected,
    ModeratedObjectStatus.pending,
  ];
  late List<ModeratedObjectStatus> _selectedStatuses;
  late bool _onlyVerified;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;

    OBModeratedObjectsFilters currentFilters =
        widget.moderatedObjectsPageController.getFilters()!;

    if (widget.moderatedObjectsPageController.hasCommunity()) {
      _types = [
        ModeratedObjectType.post,
        ModeratedObjectType.postComment,
      ];
    } else {
      _types = [
        ModeratedObjectType.post,
        ModeratedObjectType.postComment,
        ModeratedObjectType.community,
        ModeratedObjectType.user,
        ModeratedObjectType.hashtag,
      ];
    }

    _selectedTypes = currentFilters.types.toList();
    _selectedStatuses = currentFilters.statuses.toList();

    _onlyVerified = currentFilters.onlyVerified;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    _localizationService = provider.localizationService;

    return CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            Expanded(
              child: _buildFilters(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      type: OBButtonType.highlight,
                      child: Text(_localizationService.trans('moderation__filters_reset')),
                      onPressed: _onWantsToResetFilters,
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
    String text = _localizationService.trans('moderation__filters_apply');
    int filterCount = _countFilters();
    if (filterCount > 0) {
      String friendlyCount = filterCount.toString();
      text += ' ($friendlyCount)';
    }
    return Text(text);
  }

  Widget _buildFilters() {
    return ListView(
      children: <Widget>[
        OBTileGroupTitle(
          title: _localizationService.trans('moderation__filters_type')
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _buildTypeListTile,
          shrinkWrap: true,
          itemCount: _types.length,
        ),
        OBTileGroupTitle(
          title: _localizationService.trans('moderation__filters_status')
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _buildStatusListTile,
          shrinkWrap: true,
          itemCount: _statuses.length,
        ),
        OBTileGroupTitle(
          title: _localizationService.trans('moderation__filters_other')
        ),
        _buildIsVerifiedListTile()
      ],
    );
  }

  Widget _buildTypeListTile(BuildContext context, int index) {
    ModeratedObjectType type = _types[index];
    String typeString = ModeratedObject.factory
        .convertTypeToHumanReadableString(type, capitalize: true) ?? '';
    return OBCheckboxField(
      titleStyle: TextStyle(fontWeight: FontWeight.normal),
      onTap: () {
        _onTypePressed(type);
      },
      title: typeString,
      value: _selectedTypes.contains(type),
    );
  }

  Widget _buildStatusListTile(BuildContext context, int index) {
    ModeratedObjectStatus status = _statuses[index];
    String statusString = ModeratedObject.factory
        .convertStatusToHumanReadableString(status, capitalize: true) ?? '';
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: OBModeratedObjectStatusCircle(
            status: status,
          ),
        ),
        Expanded(
          child: OBCheckboxField(
            titleStyle: TextStyle(fontWeight: FontWeight.normal),
            onTap: () {
              _onStatusPressed(status);
            },
            title: statusString,
            value: _selectedStatuses.contains(status),
          ),
        )
      ],
    );
  }

  Widget _buildIsVerifiedListTile() {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: OBIcon(OBIcons.verify),
        ),
        Expanded(
          child: OBCheckboxField(
            titleStyle: TextStyle(fontWeight: FontWeight.normal),
            title: _localizationService.trans('moderation__filters_verified'),
            value: _onlyVerified,
            onTap: () {
              setState(() {
                _onlyVerified = !_onlyVerified;
              });
            },
          ),
        )
      ],
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
        title: _localizationService.trans('moderation__filters_title'));
  }

  void _onWantsToApplyFilters() async {
    _setRequestInProgress(true);
    await widget.moderatedObjectsPageController.setFilters(
        OBModeratedObjectsFilters(
            types: _selectedTypes,
            statuses: _selectedStatuses,
            onlyVerified: _onlyVerified));
    _setRequestInProgress(false);
    Navigator.pop(context);
  }

  void _onWantsToResetFilters() async {
    OBModeratedObjectsFilters _defaultFilters =
        OBModeratedObjectsFilters.makeDefault(
            isGlobalModeration:
                !widget.moderatedObjectsPageController.hasCommunity());
    setState(() {
      _selectedTypes = _defaultFilters.types;
      _selectedStatuses = _defaultFilters.statuses;
      _onlyVerified = _defaultFilters.onlyVerified;
    });
  }

  void _onTypePressed(ModeratedObjectType pressedType) {
    if (_selectedTypes.contains(pressedType)) {
      if (_selectedTypes.length == 1) return;
      // Remove
      _removeSelectedType(pressedType);
    } else {
      // Add
      _addSelectedType(pressedType);
    }
  }

  void _addSelectedType(ModeratedObjectType type) {
    setState(() {
      _selectedTypes.add(type);
    });
  }

  void _removeSelectedType(ModeratedObjectType type) {
    setState(() {
      _selectedTypes.remove(type);
    });
  }

  void _onStatusPressed(ModeratedObjectStatus pressedStatus) {
    if (_selectedStatuses.contains(pressedStatus)) {
      if (_selectedStatuses.length == 1) return;
      // Remove
      _removeSelectedStatus(pressedStatus);
    } else {
      // Add
      _addSelectedStatus(pressedStatus);
    }
  }

  void _addSelectedStatus(ModeratedObjectStatus status) {
    setState(() {
      _selectedStatuses.add(status);
    });
  }

  void _removeSelectedStatus(ModeratedObjectStatus status) {
    setState(() {
      _selectedStatuses.remove(status);
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  int _countFilters() {
    return _selectedStatuses.length +
        _selectedTypes.length +
        (_onlyVerified ? 1 : 0);
  }
}
