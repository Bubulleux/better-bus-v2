import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'map_view.dart';

class MapLayout extends StatefulWidget {
  const MapLayout({
    this.topBar,
    required this.map,
    this.overlay,
    this.overlaySizable = true,
    super.key,
  });

  final NetworkMap map;
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
      _overlayHeight = widget.overlay == null ? 0 : _overlayHeight;
    }
  }



  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint) {
    _layoutHeight = constraint.maxHeight;
    if (!widget.overlaySizable && widget.overlay != null) {
      _overlayHeight = constraint.maxHeight;
    }

    final stack = Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        widget.map,
        widget.topBar ?? Container(),
        AnimatedPositioned(
          duration: Duration(milliseconds: 100),
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

    return handleDrag(
      Column(
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
      )
    );
  }

  Widget buildDragBar() {
    if (widget.overlay == null || !widget.overlaySizable) return Container();
    const r = Radius.circular(20);
    final padding = _overlayHeight.isNaN ?
    EdgeInsets.symmetric(vertical: 4) : EdgeInsets.only(bottom: 10, top: 8);

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 20,
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
      child: _overlayHeight.isNaN ?
      Container() :Container(
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
    print(vel);
    if (_overlayHeight / _layoutHeight > 0.8  || vel < -3000) {
      _overlayHeight = _layoutHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: layoutBuilder);
  }
}
