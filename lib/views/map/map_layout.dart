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
    drawerHeight.addListener(() => setState(() {

    }));

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    drawerController = MapDrawerController();
    setState(() {});
  }



  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint) {
    final map = NetworkMap(
      controller: widget.controller,
      layers: widget.mapLayers ?? [],
    );

    final drawer = MapDrawer(
      vsync: this,
      controller: drawerController,
      heightChange: drawerHeight,
      body: widget.overlayTitle != null || widget.body != null
          ? Column(
              children: [
                widget.overlayTitle ?? Container(),
                Expanded(child: widget.body ?? Container())
              ],
            )
          : null,
    );



    final drawerFullyOpened = drawerHeight.value.isInfinite;
    final botPadding = drawerHeight.value.isFinite ? drawerHeight.value :
    constraint.maxHeight - widget.topBarHeight! - _buttonHeight;
    
    // if (botPadding.isNaN) {
    //   return Column(
    //     children: [
    //       SizedBox(height: widget.topBarHeight,
    //       child: widget.topBar,),
    //       buildMapButton(),
    //       Expanded(child: drawer)
    //     ],
    //   );
    // }

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(bottom: botPadding, child: map),
        Positioned.fill(top: widget.topBarHeight! + _buttonHeight,child: drawer),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          height: widget.topBarHeight,
          child: widget.topBar ?? Container(),
        ),
        Positioned(
          bottom: botPadding,
          right: 0,
          // TODO: Fix IT height = 100 is bad
          height: 100,
          child: MapButtons(widget.controller),
        ),
        drawerFullyOpened ?
        Positioned(
          top: widget.topBarHeight,
          height: _buttonHeight,
          right: 0,
          left: 0,
          child: buildMapButton(),
        ) : Container(),
      ],
    );

    return SizedBox(
      height: constraint.maxHeight,
      child: stack,
    );
  }

  static const _buttonHeight = 40.0;

  Widget buildMapButton() {
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
