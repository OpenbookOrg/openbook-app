import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBFadingHighlightedBox extends StatefulWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const OBFadingHighlightedBox(
      {Key? key, this.child, this.padding, this.borderRadius})
      : super(key: key);

  @override
  OBFadingHighlightedBoxState createState() {
    return OBFadingHighlightedBoxState();
  }
}

class OBFadingHighlightedBoxState extends State<OBFadingHighlightedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
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

          final highlightedColor = isDarkPrimaryColor
              ? Color.fromARGB(30, 255, 255, 255)
              : Color.fromARGB(10, 0, 0, 0);

          Animatable<Color?> background = TweenSequence<Color?>(
            [
              TweenSequenceItem(
                weight: 1.0,
                tween: ColorTween(
                  begin: highlightedColor,
                  end: Colors.transparent,
                ),
              ),
            ],
          );

          return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                Color? color = background
                    .evaluate(AlwaysStoppedAnimation(_controller.value));

                return Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    color: color,
                  ),
                  child: widget.child,
                );
              });
        });
  }
}
