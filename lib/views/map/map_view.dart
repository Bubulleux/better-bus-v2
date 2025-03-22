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
    print("Deps changed");
    update();
  }

  void update() {
    setState(() {
      // print("Update");
      // if (!(widget.overlayAsDrawer ?? false)) {
      //   _overlayHeight = double.nan;
      //   print("Set Nan");
      // }
      // if (widget.overlay != null && (widget.overlayAsDrawer ?? false) && _overlayHeight.isNaN) {
      //   print("Height set");
      //   _overlayHeight = 200;
      // }
      // print("Fuck");
    });
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
          // Column(
          //   children: [
          //     widget.input ?? Container(),
          //     Expanded(
          //         child: LayoutBuilder(
          //       builder: buildBottomLayout,
          //     )),
          //   ],
          // )
        ],
      ),
    );
  }
}
