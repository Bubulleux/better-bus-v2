import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTestPage extends StatefulWidget {
  const MapTestPage({Key? key}) : super(key: key);
  static const String routeName = "/map_test";

  @override
  State<MapTestPage> createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage> {
  late MapController controller;
  late Map<LatLng, BusStop> stopsPos;
  BusStop? focusStop = null;

  @override
  void initState() {
    super.initState();
    controller = MapController();

  }

  void test() async {
  }

  Future renderBusPaths() async {
    if (GTFSDataProvider.gtfsData == null) {
      return ;
    }
    GTFSData data = GTFSDataProvider.gtfsData!;

    for (var e in data.routes.entries) {

    }


  }

  Future renderStops() async {
  }

  void LatLngClicked(LatLng point) {
    print(point);
    print(stopsPos[point]?.name);
    setState(() {
      focusStop = stopsPos[point];
    });
  }

  MarkerLayer getStopsLayer() {
    List<Marker> markers = [];
    stopsPos = {
      for (var e in GTFSDataProvider.getStops() ?? [])
    LatLng(e.latitude, e.longitude) : e
    };
    for (var stop in stopsPos.keys) {
      markers.add(Marker(
        point: stop,
        child: ElevatedButton(onPressed: () => setState(() {
          focusStop = stopsPos[stop];
        }),
            child: Icon(Icons.directions_bus))
        )
      );
    }

    return MarkerLayer(markers: markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FlutterMap(
                  mapController: controller,
                  options: MapOptions(
                    initialCenter: GpsDataProvider.CityLocation,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      // Plenty of other options available!
                    ),
                    getStopsLayer()
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      ElevatedButton(onPressed: test, child: const Text("OUI")),
                      ElevatedButton(onPressed: renderStops, child: const Text("Stops")),
                    ],
                  ),
                  focusStop != null ?
                  SizedBox(height: 200, child: StopFocusWidget(focusStop)) :
                  Container(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
