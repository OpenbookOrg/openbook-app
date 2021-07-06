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
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBModeratedObjectGlobalReviewPage extends StatefulWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectGlobalReviewPage(
      {Key? key, required this.moderatedObject})
      : super(key: key);

  @override
  OBModeratedObjectGlobalReviewPageState createState() {
    return OBModeratedObjectGlobalReviewPageState();
  }
}

class OBModeratedObjectGlobalReviewPageState
    extends State<OBModeratedObjectGlobalReviewPage> {
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
    _requestInProgress = false;
    _logsController = OBModeratedObjectLogsController();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.moderation__global_review_title,
      ),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  OBTileGroupTitle(
                    title: _localizationService.moderation__global_review_object_text,
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
                    isEditable: _isEditable,
                    onStatusChanged: _onStatusChanged,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _buildPrimaryActions(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return StreamBuilder(
      stream: widget.moderatedObject.updateSubject,
      initialData: widget.moderatedObject,
      builder: (BuildContext context, AsyncSnapshot<ModeratedObject> snapshot) {
        List<Widget> actions = [];

        if (snapshot.data?.verified == true) {
          actions.add(Expanded(
            child: OBButton(
              size: OBButtonSize.large,
              type: OBButtonType.danger,
              child: Row(
                children: <Widget>[
                  const OBIcon(
                    OBIcons.unverify,
                    color: Colors.white,
                    customSize: 18,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(_localizationService.moderation__global_review_unverify_text)
                ],
              ),
              onPressed: _onWantsToUnverifyModeratedObject,
              isLoading: _requestInProgress,
            ),
          ));
        } else {
          actions.add(Expanded(
            child: OBButton(
              size: OBButtonSize.large,
              child: Row(
                children: <Widget>[
                  const OBIcon(
                    OBIcons.verify,
                    color: Colors.white,
                    customSize: 18,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(_localizationService.moderation__global_review_verify_text)
                ],
              ),
              onPressed: _onWantsToVerifyModeratedObject,
              isLoading: _requestInProgress,
              color: Pigment.fromString('#5e9bff'),
            ),
          ));
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: actions,
        );
      },
    );
  }

  void _onDescriptionChanged(String newDescription) {
    _refreshLogs();
  }

  void _onCategoryChanged(ModerationCategory newCategory) {
    _refreshLogs();
  }

  void _onStatusChanged(ModeratedObjectStatus newStatus) {
    _refreshLogs();
  }

  void _refreshLogs() {
    _logsController.refreshLogs();
  }

  void _onWantsToVerifyModeratedObject() async {
    _setRequestInProgress(true);
    try {
      _requestOperation = CancelableOperation.fromFuture(
          _userService.verifyModeratedObject(widget.moderatedObject));
      await _requestOperation?.value;
      widget.moderatedObject.setIsVerified(true);
      _updateIsEditable();
      _refreshLogs();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onWantsToUnverifyModeratedObject() async {
    _setRequestInProgress(true);

    try {
      _requestOperation = CancelableOperation.fromFuture(
          _userService.unverifyModeratedObject(widget.moderatedObject));
      await _requestOperation?.value;
      widget.moderatedObject.setIsVerified(false);
      _updateIsEditable();
      _refreshLogs();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _bootstrap() {
    _isEditable = !(widget.moderatedObject.verified ?? false);
  }

  void _updateIsEditable() {
    setState(() {
      _isEditable = !(widget.moderatedObject.verified ?? false);
    });
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

  void _setRequestInProgress(requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
