import 'dart:math';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_buttons.dart';
import 'package:flutter/material.dart';

import 'map_view.dart';

class MapLayout extends StatefulWidget {
  const MapLayout({
    required this.controller,
    this.topBar,
    this.topBarHeight,
    this.mapLayers,
    this.overlay,
    this.overlaySizable = true,
    super.key,
  });

  final NetworkMapController controller;
  final Widget? topBar;
  final double? topBarHeight;
  final Widget? overlay;
  final List<Widget>? mapLayers;
  final bool overlaySizable;

  @override
  State<MapLayout> createState() => _MapLayoutState();
}

class _MapLayoutState extends State<MapLayout> {
  double _overlayHeight = 0;
  Tween<double> _overlayHeightTween = Tween(begin: 0, end: 0);
  double _layoutHeight = double.infinity;
  late final AnimationController animationController;

  bool get overlayFullScreen => _overlayHeight == _layoutHeight;

  @override
  void initState() {
    super.initState();
    assert(widget.topBar != null && widget.topBarHeight != null);
    widget.controller.setCamPadding(
        EdgeInsets.only(top: widget.topBarHeight!,
        bottom: _dragBarSize) + const EdgeInsets.symmetric(horizontal: 20, vertical: 10));
  }

  @override
  void didUpdateWidget(covariant MapLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlay != oldWidget.overlay) {
      _overlayHeight = widget.overlay == null ? 0 : max(_overlayHeight, 200);
    }
  }


  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint, double overlayHeight) {
    _layoutHeight = constraint.maxHeight;
    var showButton = true;
    if (!widget.overlaySizable && widget.overlay != null) {
      _overlayHeight = constraint.maxHeight;
    }

    final botMaxHeight = constraint.maxHeight - widget.topBarHeight! - _buttonHeight;
    final fullscreen = overlayHeight >= botMaxHeight;
    final finalOverlay = Column(
      children: [
        SizedBox(
          height: widget.topBarHeight,
          child: widget.topBar,
        ),
        fullscreen ? buildMapButton() : const Spacer(),
        SizedBox(
          height: min(overlayHeight, botMaxHeight),
          child: widget.overlay,
        )
      ],
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
            bottom: overlayHeight - _dragBarSize,
            child: NetworkMap(
              controller: widget.controller,
              layers: widget.mapLayers ?? [],
            )),
        Positioned.fill(
          top: constraint.maxHeight - overlayHeight - _dragBarSize,
            child: buildDrawer()
        ),
        Positioned.fill(child: finalOverlay),
        Positioned(
          bottom: overlayHeight + _dragBarSize,
          right: 0,
          // TODO: Fix IT height = 100 is bad
          height: 100,
          child: showButton ? MapButtons(widget.controller) : Container(),
        ),
        // Positioned(
        //   top: 0,
        //   right: 0,
        //   left: 0,
        //   height: widget.topBarHeight!,
        //   child: widget.topBar!,
        // ),
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   height: _overlayHeight,
        //   child: buildBottom(),
        // )
      ],
    );

    return SizedBox(
      height: constraint.maxHeight,
      child: stack,
    );
  }


  static const _buttonHeight = 40.0;
  Widget buildMapButton() {
    final color =Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: openMap,
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
              color: color,
              spreadRadius: -3,
              blurRadius: _buttonHeight /4
            ),
          ]
        ),
        alignment: Alignment.center,
        child: const Opacity(
          opacity: 0.8,
          child:  Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.map),
              Text(AppString.seeOnMaps, style: TextStyle(fontWeight: FontWeight.bold),)
            ],
          ),
        ),
      ),
    );
  }

  void openMap() {
    setState(() {
      if (widget.overlay != null) {
        _overlayHeightTween = Tween(begin: _overlayHeight, end: 400);
        _overlayHeight = _overlayHeightTween.end!;
      }
    });
  }

  Widget buildBottom() {
    if (widget.overlay == null) return Container();

    return handleDrag(Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildDrawer(),
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

  Widget handleDrag(Widget child) => GestureDetector(
    onVerticalDragUpdate: handleVerticalDrag,
    onVerticalDragEnd: handleEndVerticalDrag,
    behavior: HitTestBehavior.translucent,
    child: child,
  );

  Widget buildDrawer() {
    if (widget.overlay == null || !widget.overlaySizable) return Container();
    const r = Radius.circular(_dragBarSize);
    final padding = _overlayHeight.isNaN
        ? const EdgeInsets.symmetric(vertical: 4)
        : const EdgeInsets.only(bottom: 10, top: 8);

    return handleDrag(Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
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
      ),
    );
  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    assert(!_overlayHeight.isNaN);
    _overlayHeightTween = Tween(begin: _overlayHeight, end: _overlayHeight);
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
    return LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constrain) {
      return TweenAnimationBuilder(
        tween: _overlayHeightTween,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 300),
        builder: (BuildContext ctx, double h, _) => layoutBuilder(ctx, constrain, h) ,
      );
    });
  }
}
