import 'dart:math';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/drawer/drawer.dart';
import 'package:better_bus_v2/views/drawer/drawer_controller.dart';
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
    this.overlayTitle,
    this.body,
    this.overlaySizable = true,
    super.key,
  });

  final NetworkMapController controller;
  final Widget? topBar;
  final double? topBarHeight;
  final Widget? overlayTitle;
  final Widget? body;
  final List<Widget>? mapLayers;
  final bool overlaySizable;

  @override
  State<MapLayout> createState() => _MapLayoutState();
}

class _MapLayoutState extends State<MapLayout>
  with SingleTickerProviderStateMixin {

  ValueNotifier<double> drawerHeight = ValueNotifier(0);
  late final MapDrawerController drawerController;

  @override
  void initState() {
    super.initState();
    assert(widget.topBar != null && widget.topBarHeight != null);
    widget.controller.setCamPadding(EdgeInsets.only(top: widget.topBarHeight!) +
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10));
    drawerHeight.addListener(() {
      if (mounted) setState(() {});
    });


  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    drawerController = MapDrawerController();
    setState(() {});
  }

  static const btnChild = Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Icon(Icons.map),
      Text(
        AppString.seeOnMaps,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ],
  );


  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint) {
    final map = NetworkMap(
      controller: widget.controller,
      layers: widget.mapLayers ?? [],
    );

    final drawerFullyOpened = drawerHeight.value.isInfinite;
    final botPadding = drawerHeight.value.isFinite ? drawerHeight.value : 0.0;

    final drawer = MapDrawer(
      vsync: this,
      controller: drawerController,
      heightChange: drawerHeight,
      body: widget.overlayTitle != null || widget.body != null
          ? Column(
              children: [
                !drawerFullyOpened ? widget.overlayTitle ?? Container() : Container(),
                Expanded(child: widget.body ?? Container())
              ],
            )
          : null,
      btnChild: btnChild,
    );


    // constraint.maxHeight - widget.topBarHeight! - _buttonHeight;

    final overlay = Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: drawerFullyOpened ? Colors.white : Colors.white.withAlpha(0),
            height: widget.topBarHeight!,
            child: widget.topBar,
          ),
          // drawerFullyOpened ? buildOpenMapBtn(): Container(),
          Expanded(child: drawer),
        ]
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(bottom: botPadding - MapDrawerState.dragBarHeight, child: map),
        Positioned(
          bottom: botPadding,
          right: 0,
          // TODO: Fix IT height = 100 is bad
          height: 100,
          child: MapButtons(widget.controller),
        ),
        Positioned.fill(child: overlay),
      ],
    );

    return SizedBox(
      height: constraint.maxHeight,
      child: stack,
    );
  }

  static const _buttonHeight = 40.0;

  Widget buildOpenMapBtn() {
    final color = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: openMap,
      child: Container(
        height: _buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(color: color.withAlpha(170), boxShadow: [
          const BoxShadow(
            color: Colors.black,
          ),
          BoxShadow(
              color: color, spreadRadius: -3, blurRadius: _buttonHeight / 4),
        ]),
        alignment: Alignment.center,
        child: const Opacity(
          opacity: 0.8,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.map),
              Text(
                AppString.seeOnMaps,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  void openMap() {
    print("Map open");
    drawerController.lowerDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constrain) {
      return layoutBuilder(ctx, constrain);
    });
  }
}
