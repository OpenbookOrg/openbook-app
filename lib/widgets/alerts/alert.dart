import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

class OBAlert extends StatefulWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const OBAlert(
      {Key? key,
      this.child,
      this.height,
      this.width,
      this.padding,
      this.borderRadius,
      this.color})
      : super(key: key);

  @override
  OBAlertState createState() {
    return OBAlertState();
  }
}

class OBAlertState extends State<OBAlert> {
  late bool isVisible;

  @override
  void initState() {
    super.initState();
    isVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;
          var primaryColor =
              themeValueParserService.parseColor(theme!.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          return Container(
            padding: widget.padding ?? EdgeInsets.all(15),
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
                color: isDarkPrimaryColor
                    ? Color.fromARGB(20, 255, 255, 255)
                    : Color.fromARGB(10, 0, 0, 0),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10)),
            child: widget.child,
          );
        });
  }
}
