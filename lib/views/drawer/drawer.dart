import 'dart:math';

import 'package:better_bus_v2/views/drawer/drawer_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef CloseButtonBuilder = Widget Function(BuildContext context, VoidCallback onClick);

class MapDrawer extends StatefulWidget {
  const MapDrawer({
    required this.vsync,
    required this.controller,
    this.body,
    this.sizeable = true,
    this.onHeightChanged,
    required this.heightChange,
    this.btnChild,
    super.key,
  });

  final MapDrawerController controller;
  final Widget? body;
  final bool sizeable;
  final ValueChanged<double>? onHeightChanged;
  final ValueNotifier<double> heightChange;
  final TickerProvider vsync;
  final Widget? btnChild;

  @override
  State<MapDrawer> createState() => MapDrawerState();
}

class MapDrawerState extends State<MapDrawer> {
  double _overlayHeight = 0;
  late final AnimationController animationController;
  Animation<double>? animation;
  double _widgetHeight = 500;

  // Tween<double> _overlayHeightTween = Tween(begin: 0, end: 0);

  bool get overlayFullScreen => _overlayHeight == _widgetHeight;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: widget.vsync);
    widget.controller.setState(this);
  }
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("Nice");
    if (widget.body == null) {
      setDrawerHeight(0);
    } else {
      setDrawerHeight(max(_overlayHeight, 200));
    }
  }

  void setDrawerHeight(double? h, {bool animate = true}) {
    animation = Tween(begin: animate ? _overlayHeight : h, end: h ?? _widgetHeight)
        .animate(animationController);

    animation!.addListener(() {
      widget.heightChange.value = animation!.value;
    });

    _overlayHeight = h ?? _widgetHeight;
    _overlayHeight = min(_widgetHeight, max(0, _overlayHeight));
    animationController.duration =
        animate ? Duration(milliseconds: 200) : Duration.zero;
    animationController.forward(from: 0).then((_) =>
      widget.heightChange.value = h ?? double.infinity);

  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    assert(!_overlayHeight.isNaN);
    setDrawerHeight(_overlayHeight - detail.delta.dy, animate: false);
  }

  void handleEndVerticalDrag(DragEndDetails detail) {
    final vel = detail.velocity.pixelsPerSecond.dy;
    if (_overlayHeight / _widgetHeight > 0.8 || vel < -3000) {
      setDrawerHeight(null);
      print(_widgetHeight);
    }
  }

  static const dragBarHeight = 20.0;

  Widget handleDrag(Widget child) => GestureDetector(
        onVerticalDragUpdate: handleVerticalDrag,
        onVerticalDragEnd: handleEndVerticalDrag,
        behavior: HitTestBehavior.translucent,
        child: child,
      );

  Widget buildDrawer(Widget child) {
    const r = Radius.circular(dragBarHeight);
    final padding =  overlayFullScreen
        ? const EdgeInsets.symmetric(vertical: 2)
        : const EdgeInsets.only(bottom: 10, top: 8);

    return handleDrag(Container(
      padding: padding,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top:  overlayFullScreen ? Radius.zero : r),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                spreadRadius: 1,
                offset: Offset(2, -1))
          ]),
      child: widget.sizeable
          ? Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: overlayFullScreen ? 0 : 5,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(r),
                  ),
                ),
                Expanded(child: child)
              ],
            )
          : child,
    ));
  }

  static const _buttonHeight = 40.0;
  Widget buildBtn() {
    final color = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => setDrawerHeight(400),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: overlayFullScreen ? 1 : 0,
        child: Container(
          height: _buttonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
              color: color.withAlpha(170),
              boxShadow: [
            const BoxShadow(
              color: Colors.black,
            ),
            BoxShadow(
                color: color, spreadRadius: -3, blurRadius: _buttonHeight / 4),
          ]),
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.8,
            child: widget.btnChild ?? Container(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.body != null && _overlayHeight < 200) {
      setDrawerHeight(200);
    }

    return Column(
      children: [
        buildBtn(),
        Expanded(child: LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints constraint) {
            _widgetHeight = constraint.maxHeight;

            return Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: animation!,
                builder: (BuildContext context, Widget? child) => Container(
                  height: animation?.value ?? 0,
                  child: child,
                ),
                child: buildDrawer(widget.body ?? Container()),
              ),
            );
          },

        ))
      ],
    );
  }
}
