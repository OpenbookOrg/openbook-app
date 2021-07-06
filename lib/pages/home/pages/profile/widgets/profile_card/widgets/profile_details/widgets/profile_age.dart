import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../../../provider.dart';

class OBProfileAge extends StatefulWidget {
  final User user;

  OBProfileAge(this.user);

  @override
  State<StatefulWidget> createState() {
    return OBProfileAgeState();
  }
}

class OBProfileAgeState extends State<OBProfileAge> {
  late LocalizationService _localizationService;
  late ToastService _toastService;
  late UtilsService _utilsService;
  late bool _needsBootstrap;
  static const MIN_AGE_IN_YEARS_FOR_ADULT = 1;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? age = widget.user.dateJoined;

    if (age == null) {
      return const SizedBox();
    }

    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _utilsService = openbookProvider.utilsService;
      _localizationService = openbookProvider.localizationService;
      _toastService = openbookProvider.toastService;
      _bootstrap();
      _needsBootstrap = false;
    }

    String shortenedAge = _utilsService.timeAgo(age, _localizationService);
    String formattedAgeDate = new DateFormat.yMMMMd().format(age);

    return GestureDetector(
      onTap: () async {
        _toastService.info(
            context: context,
            message: _localizationService.user__profile_okuna_age_toast(formattedAgeDate)
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          OBIcon(this._getIsUserBaby() ? OBIcons.okuna_age_baby : OBIcons.okuna_age_smile,
            customSize: 17.0,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: OBText(shortenedAge,
              maxLines: 1,
            ),
          )
        ],
      )
    );
  }

  bool _getIsUserBaby() {
    DateTime now = DateTime.now();
    Duration difference = now.difference(widget.user.dateJoined!);
    if ((difference.inDays / 365).floor() >= MIN_AGE_IN_YEARS_FOR_ADULT) {
      return false;
    }

    return true;
  }

  void _bootstrap() async {
    await _utilsService.initialiseDateFormatting(_localizationService);
  }

}
