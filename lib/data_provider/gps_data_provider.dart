import 'dart:math';

import 'package:location/location.dart';

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
    Location location = Location();

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  static Future<bool> askForEnableGPS(bool forceAsk) async {
    Location location = Location();

    bool _serviceEnabled = await location.serviceEnabled();


    if (!_serviceEnabled) {
      if (!forceAsk && askAndDecine) return false;

      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        askAndDecine = true;
        return false;
      }
    }

    return true;
  }

  static Future<LocationData?> getLocation({bool askEnableGPS = false}) async {
    Location location = Location();

    bool isGranted = await askForGPSPermission();
    if (!isGranted) {
      return null;
    }

    bool isEnable = await askForEnableGPS(askEnableGPS);
    if (!isEnable) {
      return null;
    }

    final LocationData _locationData = await location.getLocation();
    return _locationData;
  }
}
