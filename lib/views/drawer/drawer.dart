import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MapDrawer extends StatefulWidget {
  const MapDrawer({
    required this.vsync,
    this.body,
    this.sizeable = true,
    this.onHeightChanged,
    this.heightChange,
    super.key,
  });

  final Widget? body;
  final bool sizeable;
  final ValueChanged<double>? onHeightChanged;
  final ValueListenable<double>? heightChange;
  final TickerProvider vsync;

  @override
  State<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer>
    with SingleTickerProviderStateMixin {
  double _overlayHeight = 0;
  late final AnimationController animationController;
  Animation<double>? animation;
  double _widgetHeight = double.nan;

  // Tween<double> _overlayHeightTween = Tween(begin: 0, end: 0);

  bool get overlayFullScreen => _overlayHeight == _widgetHeight;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: widget.vsync);
    setDrawerHeight(0, animate: false);
  }

  @override
  void didUpdateWidget(covariant MapDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.body == null) {
      setDrawerHeight(0);
    }
    if (_overlayHeight < 200 && widget.body != null) {
      setDrawerHeight(300);
    }
  }

  void setDrawerHeight(double h, {bool animate = true}) {
    animation = Tween(begin: animate ? _overlayHeight : h, end: h).animate(animationController);
    animation!.addListener(() {
      // widget.heightChange!.value = 0;
      widget.onHeightChanged?.call(animation!.value);
    });
    _overlayHeight = h;
    if (animate) {
      animationController.duration = Duration(milliseconds: 200);
      animationController.forward(from: 0);
    }
    setState(() {});
  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    assert(!_overlayHeight.isNaN);
    setDrawerHeight(_overlayHeight - detail.delta.dy, animate: false);
  }

  void handleEndVerticalDrag(DragEndDetails detail) {
    final vel = detail.velocity.pixelsPerSecond.dy;
    if (_overlayHeight / _widgetHeight > 0.8 || vel < -3000) {
      setDrawerHeight(_widgetHeight);
    }
  }

  static const _dragBarSize = 20.0;

  Widget handleDrag(Widget child) => GestureDetector(
        onVerticalDragUpdate: handleVerticalDrag,
        onVerticalDragEnd: handleEndVerticalDrag,
        behavior: HitTestBehavior.translucent,
        child: child,
      );

  Widget buildDrawer(Widget child) {
    const r = Radius.circular(_dragBarSize);
    final padding = _overlayHeight.isNaN
        ? const EdgeInsets.symmetric(vertical: 4)
        : const EdgeInsets.only(bottom: 10, top: 8);

    return handleDrag(Container(
      padding: padding,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: r),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                spreadRadius: 1,
                offset: Offset(2, -1))
          ]),
      child: widget.sizeable
          ? Column(
              children: [
                Container(
                  width: 80,
                  height: 5,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraint) {
        _widgetHeight = constraint.maxHeight;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: animation!,
              builder: (BuildContext context, Widget? child) => Container(
                height: animation?.value ?? 0,
                child: child,
              ),
              child: buildDrawer(widget.body ?? Container()),
            ),
          ],
        );
      },
    );
  }
}
