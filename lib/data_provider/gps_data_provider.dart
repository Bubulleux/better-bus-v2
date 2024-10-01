import 'dart:math';

//import 'package:location/location.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class GpsDataProvider {
  static bool askAndDecine = false;

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

    bool isGranted = await askForGPSPermission();
    if (!isGranted) {
      return null;
    }

    bool isEnable = await askForEnableGPS(askEnableGPS);
    if (!isEnable) {
      return null;
    }
    var controleur = MapController();
    GeoPoint myPos = await controleur.myLocation();
    return myPos;
  }
}
