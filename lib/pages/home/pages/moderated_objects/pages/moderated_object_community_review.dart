import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_category/moderated_object_category.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_description/moderated_object_description.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/moderated_object_logs.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_reports_preview/moderated_object_reports_preview.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_status/moderated_object_status.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/widgets/moderated_object/widgets/moderated_object_preview.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectCommunityReviewPage extends StatefulWidget {
  final ModeratedObject moderatedObject;
  final Community community;

  const OBModeratedObjectCommunityReviewPage(
      {Key? key, required this.moderatedObject, required this.community})
      : super(key: key);

  @override
  OBModeratedObjectCommunityReviewPageState createState() {
    return OBModeratedObjectCommunityReviewPageState();
  }
}

class OBModeratedObjectCommunityReviewPageState
    extends State<OBModeratedObjectCommunityReviewPage> {
  late bool _requestInProgress;
  late bool _isEditable;

  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _needsBootstrap;

  CancelableOperation? _requestOperation;
  late OBModeratedObjectLogsController _logsController;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _isEditable = false;
    _logsController = OBModeratedObjectLogsController();
    _requestInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (_requestOperation != null) _requestOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.trans('moderation__community_review_title'),
      ),
      child: OBPrimaryColorContainer(
          child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                OBTileGroupTitle(
                  title:  _localizationService.trans('moderation__community_review_object'),
                ),
                OBModeratedObjectPreview(
                  moderatedObject: widget.moderatedObject,
                ),
                SizedBox(
                  height: 10,
                ),
                OBModeratedObjectDescription(
                    isEditable: _isEditable,
                    moderatedObject: widget.moderatedObject,
                    onDescriptionChanged: _onDescriptionChanged),
                OBModeratedObjectCategory(
                    isEditable: _isEditable,
                    moderatedObject: widget.moderatedObject,
                    onCategoryChanged: _onCategoryChanged),
                OBModeratedObjectStatus(
                  moderatedObject: widget.moderatedObject,
                  isEditable: false,
                ),
                OBModeratedObjectReportsPreview(
                  isEditable: _isEditable,
                  moderatedObject: widget.moderatedObject,
                ),
                OBModeratedObjectLogs(
                  moderatedObject: widget.moderatedObject,
                  controller: _logsController,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _buildPrimaryActions(),
          )
        ],
      )),
    );
  }

  Widget _buildPrimaryActions() {
    List<Widget> actions = [];

    if (widget.moderatedObject.verified == true) {
      actions.add(_buildVerifiedButton());
    } else if (widget.moderatedObject.status != ModeratedObjectStatus.pending) {
      if (widget.moderatedObject.status == ModeratedObjectStatus.approved) {
        actions.add(_buildRejectButton());
      } else if (widget.moderatedObject.status ==
          ModeratedObjectStatus.rejected) {
        actions.add(_buildApproveButton());
      }
    } else {
      actions.addAll([
        _buildRejectButton(),
        const SizedBox(
          width: 20,
        ),
        _buildApproveButton()
      ]);
    }

    return Row(
      children: actions,
    );
  }

  Widget _buildRejectButton() {
    return Expanded(
      child: OBButton(
        size: OBButtonSize.large,
        type: OBButtonType.danger,
        child: Text(_localizationService.trans('moderation__community_review_reject')),
        onPressed: _onWantsToRejectModeratedObject,
        isLoading: _requestInProgress,
      ),
    );
  }

  Widget _buildApproveButton() {
    return Expanded(
      child: OBButton(
        size: OBButtonSize.large,
        child: Text(_localizationService.trans('moderation__community_review_approve')),
        type: OBButtonType.success,
        onPressed: _onWantsToApproveModeratedObject,
        isLoading: _requestInProgress,
      ),
    );
  }

  Widget _buildVerifiedButton() {
    return Expanded(
      child: OBButton(
        size: OBButtonSize.large,
        type: OBButtonType.highlight,
        child: Text(_localizationService.trans('moderation__community_review_item_verified')),
        onPressed: null,
      ),
    );
  }

  void _onDescriptionChanged(String newDescription) {
    _refreshLogs();
  }

  void _onCategoryChanged(ModerationCategory newCategory) {
    _refreshLogs();
  }

  void _refreshLogs() {
    _logsController.refreshLogs();
  }

  void _onWantsToApproveModeratedObject() async {
    _setRequestInProgress(true);

    try {
      _requestOperation = CancelableOperation.fromFuture(
          _userService.approveModeratedObject(widget.moderatedObject));
      await _requestOperation?.value;
      widget.moderatedObject.setIsApproved();
      _updateIsEditable();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onWantsToRejectModeratedObject() async {
    _setRequestInProgress(true);

    try {
      _requestOperation = CancelableOperation.fromFuture(
          _userService.rejectModeratedObject(widget.moderatedObject));
      await _requestOperation?.value;
      widget.moderatedObject.setIsRejected();
      _updateIsEditable();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _setRequestInProgress(requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _bootstrap() {
    _isEditable =
        widget.moderatedObject.status == ModeratedObjectStatus.pending;
  }

  void _updateIsEditable() {
    setState(() {
      _isEditable =
          widget.moderatedObject.status == ModeratedObjectStatus.pending;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }
}
