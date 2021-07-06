import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSlideRightRoute<T> extends PageRoute<T> {

  Key slidableKey;

  OBSlideRightRoute({
    required this.slidableKey,
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  })  : assert(builder != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  final bool opaque = false;

  @override
  Color get barrierColor => Color.fromARGB(0, 0, 0, 1);

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is MaterialPageRoute ||
        previousRoute is CupertinoPageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Dismissible(
          key: slidableKey,
          background: const DecoratedBox(
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            Navigator.pop(context);
          },
          child: Material(
            child: result,
          )),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: child);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  bool get barrierDismissible => false;
}
