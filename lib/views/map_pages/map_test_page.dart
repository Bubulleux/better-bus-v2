import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapTestPage extends StatefulWidget {
  const MapTestPage({Key? key}) : super(key: key);
  static const String routeName = "/map_test";

  @override
  State<MapTestPage> createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage> {
  late MapController controller;
  late OSMOption options;
  late Map<GeoPoint, BusStop> stopsPos;
  BusStop? focusStop = null;
  static GeoPoint poitiersGPS = GeoPoint(latitude: 46.5807437, longitude: 0.3367311);

  @override
  void initState() {
    super.initState();
    controller = MapController.customLayer(
        initPosition: poitiersGPS,
      customTile: CustomTile(
        sourceName: "openstreetmap",
        urlsServers: [
          TileURLs(url:"https://c.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png")
        ],
          tileExtension: ".png",
      )
    );
    controller.init();
    options = OSMOption(
      userTrackingOption: UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
         userLocationMarker : UserLocationMaker(
            personMarker: MarkerIcon(icon: Icon(Icons.person_pin_circle, size: 100,),),
           directionArrowMarker: MarkerIcon(icon: Icon(Icons.arrow_upward, size: 100,),)
          ),
    );

  }

  void test() async {
    await controller.setZoom(zoomLevel: 18);
    //await controller.moveTo(await controller.myLocation());
    await controller.currentLocation();
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
    stopsPos = {
      for (var e in await VitalisDataProvider.getStops() ?? [])
        GeoPoint(latitude: e.latitude, longitude: e.longitude) : e
    };
    for (var stop in stopsPos.keys) {
      MarkerIcon icon = MarkerIcon(
        icon: Icon(Icons.directions_bus_filled),
      );
      controller.addMarker(stop, markerIcon: icon);
    }
  }

  void geoPointClicked(GeoPoint point) {
    print(point);
    print(stopsPos[point]?.name);
    setState(() {
      focusStop = stopsPos[point];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(child: OSMFlutter(controller: controller, osmOption: options,
              onGeoPointClicked: geoPointClicked)),
              focusStop != null ?
                SizedBox(height: 200, child: StopFocusWidget(focusStop)) :
                Container(),
              Row(
                children: [
                  ElevatedButton(onPressed: test, child: const Text("OUI")),
                  ElevatedButton(onPressed: renderStops, child: const Text("Stops")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
