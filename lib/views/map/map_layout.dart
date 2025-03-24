import 'dart:math';

import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'map_view.dart';

class MapLayout extends StatefulWidget {
  const MapLayout({
    this.topBar,
    required this.controller,
    this.overlay,
    this.overlaySizable = true,
    super.key,
  });

  final NetworkMapController controller;
  final Widget? topBar;
  final Widget? overlay;
  final bool overlaySizable;

  @override
  State<MapLayout> createState() => _MapLayoutState();
}

class _MapLayoutState extends State<MapLayout> {
  double _overlayHeight = 0;
  double _layoutHeight = double.infinity;

  bool get overlayFullScreen => _overlayHeight == _layoutHeight;

  @override
  void didUpdateWidget(covariant MapLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlay != oldWidget.overlay) {
      _overlayHeight = widget.overlay == null ? 0 : max(_overlayHeight, 200);
    }
  }

  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint) {
    _layoutHeight = constraint.maxHeight;
    var showButton = true;
    if (!widget.overlaySizable && widget.overlay != null) {
      _overlayHeight = constraint.maxHeight;
    }


    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
            bottom: _overlayHeight - _dragBarSize,
            child: NetworkMap(controller: widget.controller)),
        Positioned(
          bottom: _overlayHeight,
          right: 0,
          top: 0,
          child: showButton ? MapButtons(widget.controller) : Container(),
        ),
        widget.topBar ?? Container(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: _overlayHeight,
          child: buildBottom(),
        )
      ],
    );

    return SizedBox(
      height: constraint.maxHeight,
      child: stack,
    );
  }

  Widget buildBottom() {
    if (widget.overlay == null) return Container();
    Widget handleDrag(Widget child) => GestureDetector(
          onVerticalDragUpdate: handleVerticalDrag,
          onVerticalDragEnd: handleEndVerticalDrag,
          behavior: HitTestBehavior.translucent,
          child: child,
        );

    return handleDrag(Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildDragBar(),
        Expanded(
          child: Container(
            color: Colors.white,
            child: widget.overlay!,
          ),
        )
      ],
    ));
  }

  static const _dragBarSize = 20.0;

  Widget buildDragBar() {
    if (widget.overlay == null || !widget.overlaySizable) return Container();
    const r = Radius.circular(_dragBarSize);
    final padding = _overlayHeight.isNaN
        ? EdgeInsets.symmetric(vertical: 4)
        : EdgeInsets.only(bottom: 10, top: 8);

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _dragBarSize,
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
      child: _overlayHeight.isNaN
          ? Container()
          : Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.black.withAlpha(30)),
            ),
    );
  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    assert(!_overlayHeight.isNaN);
    setState(() {
      _overlayHeight -= detail.delta.dy;
      _overlayHeight = max(_overlayHeight, 100);
    });
  }

  void handleEndVerticalDrag(DragEndDetails detail) {
    final vel = detail.velocity.pixelsPerSecond.dy;
    if (_overlayHeight / _layoutHeight > 0.8 || vel < -3000) {
      _overlayHeight = _layoutHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: layoutBuilder);
  }
}
