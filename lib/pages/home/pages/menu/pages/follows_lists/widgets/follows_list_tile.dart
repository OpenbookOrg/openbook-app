import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OBFollowsListTile extends StatefulWidget {
  final FollowsList followsList;
  final VoidCallback? onFollowsListDeletedCallback;

  OBFollowsListTile(
      {required this.followsList, Key? key, this.onFollowsListDeletedCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBFollowsListTileState();
  }
}

class OBFollowsListTileState extends State<OBFollowsListTile> {
  late bool _requestInProgress;
  late UserService _userService;
  late ToastService _toastService;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;
    var navigationService = provider.navigationService;

    Widget tile = Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
          onTap: () {
            navigationService.navigateToFollowsList(
                followsList: widget.followsList, context: context);
          },
          leading: OBEmoji(widget.followsList.emoji!),
          title: OBText(
            widget.followsList.name!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: OBSecondaryText(
              widget.followsList.followsCount.toString() + ' users')),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: _deleteFollowsList),
      ],
    );

    if (_requestInProgress) {
      tile = Opacity(opacity: 0.5, child: tile);
    }
    return tile;
  }

  void _deleteFollowsList() async {
    _setRequestInProgress(true);
    try {
      await _userService.deleteFollowsList(widget.followsList);
      // widget.post.decreaseCommentsCount();
      _setRequestInProgress(false);
      if (widget.onFollowsListDeletedCallback != null) {
        widget.onFollowsListDeletedCallback!();
      }
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
      _toastService.error(message: errorMessage ?? 'Unknown error', context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
