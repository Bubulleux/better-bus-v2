import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_buttons.dart';
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
    super.key,
  });

  final double width;
  final double height;
  final NetworkMapController controller;
  final VitalisRoute? route;
  final bool showStation;

  final List<Widget> layers;

  @override
  State<NetworkMap> createState() => NetworkMapState();
}

class NetworkMapState extends State<NetworkMap> with TickerProviderStateMixin {
  late MapController controller;

  NetworkMapController get rootController => widget.controller;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: GpsDataProvider.instance.cityLocation,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.bubulle',
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
              onStationClick: (station) => setState(() {
                rootController.focused = station;
              }),
              onStopClick: rootController.setStop,
              focusedStation: rootController.focusedStation,
              focusedStop: rootController.focusedStop,
            ),
            widget.route != null
                ? RouteLayer(route: widget.route!)
                : Container(),
            ...widget.layers,
            const EasterEggsLayer(),
            PositionLayer(
              positionUpdate: (v) => rootController.position = v,
            ),
            rootController.focusedPlace != null
                ? PlaceLayer(rootController.focusedPlace!)
                : Container(),
          ],
        ),
        Positioned.fill(
          child: Padding(
            padding: rootController.camPadding,
            child: MapButtons(rootController),
          ),
        ),
      ],
    );
  }
}
