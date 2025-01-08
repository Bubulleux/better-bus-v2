import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapTestPage extends StatefulWidget {
  const MapTestPage({Key? key}) : super(key: key);
  static const String routeName = "/map_test";

  @override
  State<MapTestPage> createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage>
  with TickerProviderStateMixin {
  late MapController controller;
  late Map<LatLng, BusStop> stopsPos;
  BusStop? focusStop = null;
  LatLng? position = null;

  @override
  void initState() {
    super.initState();
    controller = MapController();

  }

  void test() async {
    position = await GpsDataProvider.getLocation();
    setState(() {
    });
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

  MarkerLayer renderLocationLayer() {
    return MarkerLayer(markers: position != null ?
      [Marker(
        point: position!,
        child: Icon(Icons.arrow_upward)

      )] : []
    );
  }

  Future goToSearch() async {
    print("Go to Search");
    MapPlace? place = await (Navigator.of(context).pushNamed(PlaceSearcherPage.routeName) as Future<dynamic>);
    if (place == null) return;

  }

  void goToMyLocation() async {
    if (position == null) {
      return;
    }
    focusOnLatLng(position!, 18);

  }
  void focusOnLatLng(LatLng dst, double dstZoom) {
    final LatLngTween tween = LatLngTween(
      begin: controller.camera.center,
      end: dst,
    );

    final Tween<double> zoomTween = Tween(
      begin: controller.camera.zoom,
      end: 18
    );

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final Animation<double> animation =
      CurvedAnimation(parent: animationController,
          curve: Curves.fastLinearToSlowEaseIn);
    
    animationController.addListener(() {
      controller.move(tween.evaluate(animation), 
      zoomTween.evaluate(animation));
    });

    animationController.forward();
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
                    getStopsLayer(),
                    renderLocationLayer(),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FakeTextField(
                      onPress: goToSearch,
                      icon: Icons.search,
                      value: focusStop?.name,
                      hint: AppString.searchLabel,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ElevatedButton(onPressed: test, child: const Text("OUI")),
                      ElevatedButton(onPressed: renderStops, child: const Text("Stops")),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: goToMyLocation,
                        child: Icon(Icons.my_location_outlined),
                      )
                    ],
                  ),
                  focusStop != null ?
                  SizedBox(child: StopFocusWidget(focusStop)) :
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
