import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pigment/pigment.dart';
import "dart:math" show pi;

class OBZoomablePhotoModal extends StatefulWidget {
  final String imageUrl;

  OBZoomablePhotoModal(this.imageUrl);

  @override
  State<StatefulWidget> createState() {
    return OBZoomablePhotoModalState();
  }
}

class OBZoomablePhotoModalState extends State<OBZoomablePhotoModal>
    with SingleTickerProviderStateMixin {
  late bool _isDismissible;
  late AnimationController _controller;
  Animation<Offset>? _offset;
  Animation<double>? _rotationAnimation;
  late double _rotationAngle;
  late double _rotationDirection;
  late double _posX;
  late double _posY;
  late double _velocityX;
  late double _velocityY;
  PointerDownEvent? startDragDetails;
  PointerMoveEvent? updateDragDetails;
  static const VELOCITY_THRESHOLD = 10.0;

  // THRESHOLD_SECOND_POINTER_EVENT:
  // max delta distance above which we classify that another pointer event has begin somewhere
  // else on the screen, as dist between two drag pointer events will not be above
  // this threshold (foreg. when scaling with two fingers, we ignore the other pointer to prevent a rebuild)
  static const THRESHOLD_SECOND_POINTER_EVENT = 50.0;

  // rate at which X and Y will increase while exiting the screen
  static const EXIT_RATE_MULTIPLIER = 50.0;
  static const CLOCKWISE = 1.0;
  static const ANTICLOCKWISE = -1.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _rotationAngle = 0.0;
    _rotationDirection = CLOCKWISE;
    _posX = 0.0;
    _velocityX = 0.0;
    _velocityY = 0.0;
    _posY = 0.0;
    _isDismissible = true;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      child: OBCupertinoPageScaffold(
          backgroundColor: Colors.black26,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Listener(
                child: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[_getPositionedZoomableImage()],
                ),
                onPointerDown: (PointerDownEvent details) {
                  if (startDragDetails == null) {
                    setState(() {
                      startDragDetails = details;
                    });
                  }
                },
                onPointerMove: (PointerMoveEvent updatedDetails) {
                  double deltaY = 0.0;
                  double deltaX = 0.0;
                  if (updateDragDetails == null && startDragDetails != null) {
                    deltaY = updatedDetails.position.dy -
                        startDragDetails!.position.dy;
                    deltaX = updatedDetails.position.dx -
                        startDragDetails!.position.dx;
                  } else if (updateDragDetails != null) {
                    deltaY = updatedDetails.position.dy -
                        updateDragDetails!.position.dy;
                    deltaX = updatedDetails.position.dx -
                        updateDragDetails!.position.dx;
                  }
                  _updateDragValues(deltaX, deltaY, updatedDetails);
                },
                onPointerUp: (PointerUpEvent details) {
                  _checkIsDismissible();
                },
              ),
              _buildCloseButton()
            ],
          )),
      onWillPop: _dismissModalNoPop,
    );
  }

  Widget _getPositionedZoomableImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: _posY != 0 ? _posY : 0,
      left: _posX != 0 ? _posX : 0,
      width: screenWidth,
      height: screenHeight,
      child: Transform.rotate(
        angle: _rotationAngle,
        child: PhotoView(
          backgroundDecoration: BoxDecoration(color: Colors.transparent),
          key: Key(widget.imageUrl),
          enableRotation: false,
          scaleStateChangedCallback: _photoViewScaleStateChangedCallback,
          imageProvider: AdvancedNetworkImage(widget.imageUrl,
              retryLimit: 0,
              useDiskCache: true,
              getRealUrl: () {
                return Future.delayed((Duration(milliseconds: 0)),() => widget.imageUrl);
              },
              cacheRule: CacheRule(
                maxAge: const Duration(days: 7),
                checksum: true,
              ),
              fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png'),
          maxScale: PhotoViewComputedScale.covered,
          minScale: PhotoViewComputedScale.contained,
        ),
      ),
    );
  }

  void _updateDragValues(
      double deltaX, double deltaY, PointerMoveEvent updatedDetails) {
    if (deltaX.abs() > THRESHOLD_SECOND_POINTER_EVENT ||
        deltaY.abs() > THRESHOLD_SECOND_POINTER_EVENT ||
        !_isDismissible) return;
    setState(() {
      _posX = _posX + deltaX;
      _posY = _posY + deltaY;
      updateDragDetails = updatedDetails;
    });
    _updateRotationValues();
    // Last reading of velocity is low (below threshold) as the finger leaves the screen,
    // which causes the dismiss to be cancelled, so we update it lazily.
    _updateVelocityLazily(deltaX, deltaY);
  }

  void _updateVelocityLazily(double deltaX, double deltaY) async {
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _velocityX = deltaX;
        _velocityY = deltaY;
      });
    });
  }

  void _setBackToOrginalPosition() {
    setState(() {
      _offset =
          Tween<Offset>(begin: Offset(_posX, _posY), end: Offset(0.0, 0.0))
              .chain(CurveTween(curve: Curves.easeInOutSine))
              .animate(_controller)
                ..addListener(() {
                  _posX = _offset!.value.dx;
                  _posY = _offset!.value.dy;
                  setState(() {});
                });
      startDragDetails = null;
      updateDragDetails = null;
    });
    _rotationAnimation = Tween<double>(begin: _rotationAngle, end: 0.0)
        .chain(CurveTween(curve: Curves.easeInOutCubic))
        .animate(_controller)
          ..addListener(() {
            _rotationAngle = _rotationAnimation!.value;
            setState(() {});
          });
    _controller.reset();
    _controller.forward();
  }

  void _checkIsDismissible() {
    if (_velocityX.abs() > VELOCITY_THRESHOLD ||
        _velocityY.abs() > VELOCITY_THRESHOLD) {
      _setTweensWithVelocity();
      _dismissModal();
    } else {
      _setBackToOrginalPosition();
    }
  }

  void _updateRotationValues() {
    if (startDragDetails == null) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenMid = screenWidth / 2;
    double maxRotationAngle = pi / 2;
    // Rotation increases proportional to distance from mid of screen
    double rotationRatio =
        (startDragDetails!.position.dx - screenMid).abs() / screenMid;

    if (startDragDetails!.position.dx < screenMid) {
      maxRotationAngle = -pi / 2;
    }
    // Rotation increases proportional to drag in Y direction
    double distanceRatio = _posY / screenHeight;

    double rotationDirection;
    if ((maxRotationAngle < 0 && _velocityY < 0) ||
        (maxRotationAngle > 0 && _velocityY > 0)) {
      rotationDirection = CLOCKWISE;
    } else {
      rotationDirection = ANTICLOCKWISE;
    }
    setState(() {
      _rotationAngle = distanceRatio * rotationRatio * maxRotationAngle;
      _rotationDirection = rotationDirection;
    });
  }

  void _setTweensWithVelocity() {
    setState(() {
      _offset = Tween<Offset>(
              begin: Offset(_posX, _posY),
              end: Offset(_velocityX * EXIT_RATE_MULTIPLIER,
                  _velocityY * EXIT_RATE_MULTIPLIER))
          .chain(CurveTween(curve: Curves.easeInOutSine))
          .animate(_controller)
            ..addListener(() {
              _posX = _offset!.value.dx + _velocityX / 2;
              _posY = _offset!.value.dy + _velocityY / 2;
              setState(() {});
            });

      _rotationAnimation = Tween<double>(
              begin: _rotationAngle, end: 1.5 * pi * _rotationDirection)
          .chain(CurveTween(curve: Curves.easeInOutCubic))
          .animate(_controller)
            ..addListener(() {
              _rotationAngle = _rotationAnimation!.value;
              setState(() {});
            });

      startDragDetails = null;
      updateDragDetails = null;
    });
    _controller.reset();
  }

  Future _dismissModal() async {
    await _controller.forward();
    Navigator.pop(context);
  }

  Future<bool> _dismissModalNoPop() async {
    _dismissModal();
    return false;
  }

  Widget _buildCloseButton() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: SafeArea(
          child: Column(
        children: <Widget>[
          GestureDetector(
            onTapDown: (tap) {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(50)),
              child: const OBIcon(
                OBIcons.close,
                size: OBIconSize.large,
                color: Colors.white,
              ),
            ),
          )
        ],
      )),
    );
  }

  void _photoViewScaleStateChangedCallback(PhotoViewScaleState state) {
    switch (state) {
      case PhotoViewScaleState.initial:
        _setIsDismissible(true);
        break;
      default:
        _setIsDismissible(false);
    }
  }

  void _setIsDismissible(bool isDismissible) {
    setState(() {
      this._isDismissible = isDismissible;
    });
  }

  void toggleIsDismissible() {
    _setIsDismissible(!_isDismissible);
  }
}
