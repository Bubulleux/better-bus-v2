import 'dart:math';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
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

  bool offline = false;

  @override
  void initState() {
    super.initState();
    assert(widget.topBar != null && widget.topBarHeight != null);
    setCamPadding();

    drawerHeight.addListener(() {
      if (mounted) setState(() {});
      setCamPadding();
    });

    widget.controller.provider.connStatus.isConnected().then((connected) {
      if (connected) return;
      print("Not connecteccd");
      drawerController.lockOpen();
      setState(() {
        offline = true;
      });
      widget.controller.provider.connStatus.onConnected(() => setState(() {
        drawerController.unLock();
        offline = false;
      }));
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
      SizedBox(width: 10,),
      Text(
        AppString.seeOnMaps,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ],
  );

  static const noInternetInfo = Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Icon(Icons.signal_wifi_connected_no_internet_4),
      SizedBox(width: 10,),
      Text(
        AppString.offline,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ],
  );

  void setCamPadding() {
    if (drawerHeight.value.isInfinite) {
      widget.controller.setCamPadding(EdgeInsets.zero);
      return;
    }

    widget.controller.setCamPadding(EdgeInsets.only(top: widget.topBarHeight!, bottom: drawerHeight.value));
  }

  Widget layoutBuilder(BuildContext ctx, BoxConstraints constraint) {
    Widget map = NetworkMap(
      controller: widget.controller,
      layers: widget.mapLayers ?? [],
    );
    if (AppProvider.of(context).offline) {
      map = Container();
    }

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
      btnChild: offline ?  noInternetInfo : btnChild,
    );


    // constraint.maxHeight - widget.topBarHeight! - _buttonHeight;

    final overlay = Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
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
        Positioned.fill(child: map),
        Positioned.fill(child: overlay),
      ],
    );

    return SizedBox(
      height: constraint.maxHeight,
      child: stack,
    );
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constrain) {
      return layoutBuilder(ctx, constrain);
    });
  }
}
