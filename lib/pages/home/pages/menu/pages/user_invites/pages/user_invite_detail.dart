import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/widgets/user_invite_detail_header.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:Okuna/services/user_invites_api.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:share/share.dart';

class OBUserInviteDetailPage extends StatefulWidget {
  final UserInvite userInvite;
  final bool showEdit;

  OBUserInviteDetailPage({
    required this.userInvite,
    this.showEdit = false
  });

  @override
  State<OBUserInviteDetailPage> createState() {
    return OBUserInviteDetailPageState();
  }
}

class OBUserInviteDetailPageState extends State<OBUserInviteDetailPage> {
  late ToastService _toastService;
  late ModalService _modalService;
  late LocalizationService _localizationService;
  late UserInvitesApiService _userInvitesApiService;
  late StringTemplateService _stringTemplateService;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    _toastService = provider.toastService;
    _modalService = provider.modalService;
    _localizationService = provider.localizationService;
    _userInvitesApiService = provider.userInvitesApiService;
    _stringTemplateService = provider.stringTemplateService;

    if (_needsBootstrap) {
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          title: _localizationService.user__invites_invite_text,
          trailing: _buildNavigationBarTrailingItem(),
        ),
        child: OBPrimaryColorContainer(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OBUserInviteDetailHeader(widget.userInvite),
                    Expanded(
                      child: ListView(
                          padding: EdgeInsets.zero,
                          children: _buildActionsList())
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildActionsList() {
    if (widget.userInvite.createdUser != null) {
      return [
        const SizedBox()
      ];
    }

    return [
      ListTile(
        leading: const OBIcon(OBIcons.chat),
        title: OBText(_localizationService.user__invites_share_yourself),
        subtitle: OBSecondaryText(
          _localizationService.user__invites_share_yourself_desc,
        ),
        onTap: () {
          String apiURL = _userInvitesApiService.apiURL;
          String token = widget.userInvite.token!;
          Share.share(getShareMessageForInviteWithToken(token, apiURL));
        },
      ),
      ListTile(
        leading: const OBIcon(OBIcons.email),
        title: OBText(_localizationService.user__invites_share_email),
        subtitle: OBSecondaryText(
          _localizationService.user__invites_share_email_desc,
        ),
        onTap: () async {
         await _modalService.openSendUserInviteEmail(
              context: context,
              userInvite: widget.userInvite);
          Navigator.of(context).pop();
        },
      )
    ];
  }

  String getShareMessageForInviteWithToken(String token, String apiURL) {
    const IOS_DOWNLOAD_LINK = UserInvite.IOS_DOWNLOAD_LINK;
    const TESTFLIGHT_DOWNLOAD_LINK = UserInvite.TESTFLIGHT_DOWNLOAD_LINK;
    const ANDROID_DOWNLOAD_LINK = UserInvite.ANDROID_DOWNLOAD_LINK;

    String inviteLink = _stringTemplateService.parse(UserInvite.INVITE_LINK, {'token': token, 'apiURL': apiURL});

    String message = _localizationService.user__invite_someone_message(
        IOS_DOWNLOAD_LINK,
        TESTFLIGHT_DOWNLOAD_LINK,
        ANDROID_DOWNLOAD_LINK,
        inviteLink);

    return message;
  }

  Widget _buildNavigationBarTrailingItem() {
    if (!widget.showEdit) return const SizedBox();
    return GestureDetector(
      onTap: () {
        _modalService.openEditUserInvite(
            userInvite: widget.userInvite,
            context: context);
      },
      child: OBPrimaryAccentText(_localizationService.user__invites_edit_text),
    );
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
}
