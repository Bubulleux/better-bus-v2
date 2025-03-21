import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data_provider/gps_data_provider.dart';
import 'easter_eggs_layer.dart';
import 'place_layer.dart';
import 'position_layer.dart';
import 'route_layer.dart';
import 'stop_layer.dart';
import 'trip_layer.dart';

class NetworkMap extends StatefulWidget {
  const NetworkMap({
    this.width = double.infinity,
    this.height = double.infinity,
    required this.controller,
    this.layers = const [],
    this.showStation = true,
    this.route,
    this.input,
    this.overlay,
    this.overlayAsDrawer,
    super.key,
  });

  final double width;
  final double height;
  final NetworkMapController controller;
  final VitalisRoute? route;
  final bool showStation;
  final Widget? input;
  final Widget? overlay;
  final bool? overlayAsDrawer;

  final List<Widget> layers;

  @override
  State<NetworkMap> createState() => NetworkMapState();
}

class NetworkMapState extends State<NetworkMap> with TickerProviderStateMixin {
  late MapController controller;

  NetworkMapController get rootController => widget.controller;
  double _overlayHeight = double.nan;
  double _viewPortHeight = double.nan;
  double? _overleyVelocity = null;
  bool overlayOpened = false;

  @override
  void initState() {
    super.initState();
    controller = MapController();
    widget.controller.setWidgetState(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    update();
  }

  void update() {
    print("Update");
    if (!(widget.overlayAsDrawer ?? false)) {
      _overlayHeight = double.nan;
    }
    if (widget.overlay != null && (widget.overlayAsDrawer ?? false) && _overlayHeight.isNaN) {
      print("Height set");
        _overlayHeight = 200;
    }
    print("Fuck");
    setState(() {});
  }

  Widget buildDragBar() {
    if (widget.overlay == null) return Container();
    const r = Radius.circular(20);
    final padding = _overlayHeight.isNaN ?
        EdgeInsets.symmetric(vertical: 4) : EdgeInsets.only(bottom: 10, top: 8);

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
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
    _overleyVelocity = detail.velocity.pixelsPerSecond.dy;
  }

  Widget buildOverlay() {
    final enable = !_overlayHeight.isNaN;
    return GestureDetector(
      onVerticalDragUpdate: enable ? handleVerticalDrag : null,
      onVerticalDragEnd: enable ? handleEndVerticalDrag : null,
      key: ObjectKey(widget.overlay),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragBar(),
          // Expanded(
          //   child: Container(
          //     height: double.infinity,
          //     width: double.infinity,
          //     color: Colors.red,
          //   ),
          // )
          Container(
            color: Colors.white,
            child: widget.overlay ?? Container(),
          )
        ],
      ),
    );
  }

  Widget buildBottomLayout(BuildContext context, BoxConstraints constrains) {
    if (_overlayHeight.isNaN) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMapButtons(),
          widget.overlay != null ?
          buildOverlay() : Container()
        ],
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
            width: constrains.maxWidth,
            bottom: _overlayHeight,
            child: buildMapButtons()),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 50),
          height: _overlayHeight,
          width: constrains.maxWidth,
          child: buildOverlay(),
        )
      ],
    );
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: controller,
      options: const MapOptions(
        initialCenter: GpsDataProvider.cityLocation,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          // Plenty of other options available!
        ),
        ...(rootController.focusedStopTime != null
            ? [
                TripLayer(stopTime: rootController.focusedStopTime!),
                // BusLayer(
                //   key: Key(rootController.focusedStopTime!.hashCode.toString()),
                //   stopTime: rootController.focusedStopTime!,
                // controller: rootController,
                // )
              ]
            : []),
        StopsMapLayer(
          mapController: rootController,
          stops: rootController.stopsPos?.values.toList() ?? [],
          reports: rootController.reports,
          onStationClick: (station) => setState(() {
            rootController.focused = station;
          }),
          onStopClick: rootController.setStop,
          focusedStation: rootController.focusedStation,
          focusedStop: rootController.focusedStop,
        ),
        widget.route != null ? RouteLayer(route: widget.route!) : Container(),
        ...widget.layers,
        const EasterEggsLayer(),
        PositionLayer(
          positionUpdate: (v) => rootController.position = v,
        ),
        rootController.focusedPlace != null
            ? PlaceLayer(rootController.focusedPlace!)
            : Container(),
      ],
    );
  }

  Widget buildMapButtons() {
    return Row(
      children: [
        //ElevatedButton(onPressed: test, child: const Text("OUI")),
        const Spacer(),
        widget.controller.position != null
            ? Container(
                margin: const EdgeInsets.all(5),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor),
                child: InkWell(
                    onTap: widget.controller.goToPosition,
                    child: const Icon(Icons.my_location_outlined)))
            : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          buildMap(),
          Column(
            children: [
              widget.input ?? Container(),
              Expanded(
                  child: LayoutBuilder(
                builder: buildBottomLayout,
              )),
            ],
          )
        ],
      ),
    );
  }
}
