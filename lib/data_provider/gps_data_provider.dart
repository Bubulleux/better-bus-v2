import 'dart:math';

//import 'package:location/location.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class GpsDataProvider  implements OSMMixinObserver {
  bool askAndDecine = false;
  late MapController controller;
  static late GpsDataProvider instance;
  bool isReady = false;

  static Future initGps() async {
    instance = GpsDataProvider();
  }

  GpsDataProvider() {
    controller = MapController(initPosition: GeoPoint(latitude: 0, longitude: 0));
    controller.addObserver(this);
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double result = 12742 * asin(sqrt(a));
    return result;
  }

  static Future<bool> askForGPSPermission() async {

    return true;
  }

  static Future<bool> askForEnableGPS(bool forceAsk) async {

    return true;
  }

  static Future<GeoPoint?> getLocation({bool askEnableGPS = false}) async {
    return null;
    bool isGranted = await askForGPSPermission();
    if (!isGranted) {
      return null;
    }

    bool isEnable = await askForEnableGPS(askEnableGPS);
    if (!isEnable) {
      return null;
    }
    GeoPoint myPos = await instance.controller.myLocation();
    return myPos;
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    print("Map Ready");
    isReady = true;
  }

  @override
  Future<void> mapRestored() async {
  }

  @override
  void onLocationChanged(UserLocation userLocation) {
    // TODO: implement onLocationChanged
  }

  @override
  void onLongTap(GeoPoint position) {
    // TODO: implement onLongTap
  }

  @override
  void onRegionChanged(Region region) {
    // TODO: implement onRegionChanged
  }

  @override
  void onRoadTap(RoadInfo road) {
    // TODO: implement onRoadTap
  }

  @override
  void onSingleTap(GeoPoint position) {
    // TODO: implement onSingleTap
  }
}
