import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:better_bus_v2/views/map/bus_layer.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data_provider/gps_data_provider.dart';
import '../../data_provider/radar_provider.dart';
import 'easter_eggs_layer.dart';
import 'place_layer.dart';
import 'position_layer.dart';
import 'stop_layer.dart';
import 'trip_layer.dart';

class NetworkMap extends StatefulWidget {
  const NetworkMap({
    this.width = double.infinity,
    this.height = double.infinity,
    required this.controller,
    this.showStation = true,
    super.key,
  });

  final double width;
  final double height;
  final NetworkMapController controller;
  final bool showStation;

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

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Build ${rootController.focusedStopTime}");
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FlutterMap(
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
          ...(rootController.focusedStopTime != null
              ? [
                TripLayer(stopTime: rootController.focusedStopTime!),
            BusLayer(
              key: Key(rootController.focusedStopTime!.hashCode.toString()),
              stopTime: rootController.focusedStopTime!,
            controller: rootController,
            )
          ]
              : []),
          const EasterEggsLayer(),
          PositionLayer(
            positionUpdate: (v) => rootController.position = v,
          ),
          rootController.focusedPlace != null
              ? PlaceLayer(rootController.focusedPlace!)
              : Container(),
        ],
      ),
    );
  }
}
