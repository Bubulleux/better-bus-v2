import 'dart:async';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/map_pages/easter_eggs_layer.dart';
import 'package:better_bus_v2/views/map_pages/focus_place.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:better_bus_v2/views/map_pages/place_layer.dart';
import 'package:better_bus_v2/views/map_pages/position_layer.dart';
import 'package:better_bus_v2/views/map_pages/stop_layer.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPageArg {
  const MapPageArg({this.station, this.stop});

  final BusStop? station;
  final SubBusStop? stop;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  static const String routeName = "/map_test";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late MapController controller;
  late Map<LatLng, BusStop> stopsPos;
  BusStop? focusStation;
  SubBusStop? focusedStop;
  MapPlace? focusedPlace;
  LatLng? position;
  LatLng? needFocus;
  StreamSubscription<Position>? _posStream;

  @override
  void initState() {
    super.initState();
    controller = MapController();
    controller.mapEventStream.listen((data) {
      if (needFocus != null) {
        focusOnLatLng(needFocus!, 18);
        needFocus = null;
      }
    });

    _posStream = Geolocator.getPositionStream().listen((Position newPos) {
      setState(() {
        position = LatLng(newPos.latitude, newPos.longitude);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as MapPageArg?;
    if (arg != null && focusStation == null) {
      setState(() {
        focusStation = arg.station;
        focusedStop = arg.stop;
        needFocus = focusStation?.pos;
      });
    }
  }

  @override
  void dispose() {
    _posStream?.cancel();
    controller.dispose();
    super.dispose();
  }

  void test() async {
    position = await GpsDataProvider.getLocation();
    setState(() {
      position = position;
    });
  }

  void LatLngClicked(LatLng point) {
    setState(() {
      focusStation = stopsPos[point];
    });
  }

  MarkerLayer getStopsLayer() {
    List<Marker> markers = [];
    stopsPos = {
      for (var e in GTFSDataProvider.getStops())
        LatLng(e.latitude, e.longitude): e
    };
    for (var stop in stopsPos.keys) {
      markers.add(Marker(
        point: stop,
        child: ElevatedButton(
            onPressed: () => setState(() {
                  focusStation = stopsPos[stop];
                }),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(0)),
            child: const Icon(
              Icons.directions_bus,
              size: 20,
            )),
      ));
    }

    return MarkerLayer(markers: markers);
  }

  Future goToSearch() async {
    MapPlace? place = await (Navigator.of(context)
        .pushNamed(PlaceSearcherPage.routeName) as Future<dynamic>);
    if (place == null) return;
    setState(() {
      if (place.type == "busStop") {
        final stop = GTFSDataProvider.getStops()
            .firstWhere((e) => e.name == place.title);
        focusStation = stop;
        focusedStop = stop;
      } else {
        focusStation = null;
        focusedStop = null;
        focusedPlace = place;
      }
    });
    focusOnLatLng(LatLng(place.latitude, place.longitude), 18);
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

    final Tween<double> zoomTween =
        Tween(begin: controller.camera.zoom, end: 18);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final Animation<double> animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastLinearToSlowEaseIn);

    animationController.addListener(() {
      controller.move(tween.evaluate(animation), zoomTween.evaluate(animation));
    });

    animationController.forward();
  }

  void onFocusOpen() {
    if (focusStation == null) return;
    Navigator.of(context)
        .pushNamed(StopInfoPage.routeName,
            arguments: StopInfoPageArgument(focusStation!, null, fromMap: true))
        .then((value) {
      setState(() {
        focusStation = value as BusStop?;
        if (focusStation != null) focusOnLatLng(focusStation!.pos, 18);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: FlutterMap(
                mapController: controller,
                options: const MapOptions(
                  initialCenter: GpsDataProvider.cityLocation,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    // Plenty of other options available!
                  ),
                  StopsMapLayer(
                    stops: GTFSDataProvider.getStops(),
                    onStationClick: (BusStop v) => setState(() {
                      focusStation = v;
                      focusedStop = null;
                    }),
                    onStopClick: (SubBusStop v) => setState(() {
                      focusedStop = v;
                    }),
                    focusedStation: focusStation,
                    focusedStop: focusedStop,
                  ),
                  const EasterEggsLayer(),
                  const PositionLayer(),
                  focusedPlace != null ?
                      PlaceLayer(focusedPlace!) :
                      Container()
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FakeTextField(
                          onPress: goToSearch,
                          icon: Icons.search,
                          value: focusStation?.name ?? focusedPlace?.title,
                          hint: AppString.searchLabel,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    //ElevatedButton(onPressed: test, child: const Text("OUI")),
                    const Spacer(),
                    Container(
                        margin: const EdgeInsets.all(5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor),
                        child: InkWell(
                            onTap: goToMyLocation,
                            child: const Icon(Icons.my_location_outlined)))
                  ],
                ),
                StopFocusWidget(
                  station: focusStation,
                  stop: focusedStop,
                  position: position,
                  openFocus: onFocusOpen,
                ),
                focusedPlace != null ?
                    FocusPlace(focusedPlace!, pos: position,):
                    Container()
              ],
            )
          ],
        ),
      ),
    );
  }
}
