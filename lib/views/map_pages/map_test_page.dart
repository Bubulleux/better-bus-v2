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
  static GeoPoint poitiersGPS = GeoPoint(latitude: 46.5807437, longitude: 0.3367311);

  @override
  void initState() {
    super.initState();
    controller = MapController(initPosition: poitiersGPS);
    controller.init();
    options = OSMOption(
      userTrackingOption: UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
         userLocationMarker : UserLocationMaker(
            personMarker: MarkerIcon(icon: Icon(Icons.person_pin_circle, size: 48,),),
           directionArrowMarker: MarkerIcon(icon: Icon(Icons.circle, size: 60,),)
          )
    );

  }

  void test() async {
    await controller.moveTo(poitiersGPS);
    await controller.setZoom(zoomLevel: 14);
    print((await controller.myLocation()).latitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              
              Expanded(child: OSMFlutter(controller: controller, osmOption: options)),
              ElevatedButton(onPressed: test, child: const Text("OUI"))
            ],
          ),
        ),
      ),
    );
  }
}
