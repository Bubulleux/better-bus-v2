import 'dart:io';
import 'dart:math';

//import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class GpsDataProvider {
  bool askAndDecine = false;
  static late GpsDataProvider instance;
  bool isReady = false;

  static const LatLng CityLocation = LatLng(46.58150366398437, 0.3413034114105826);

  static Future initGps() async {
    instance = GpsDataProvider();
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
    if (Platform.isLinux) return true;
    LocationPermission permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied;

  }

  static Future<bool> askForEnableGPS(bool forceAsk) async {
    return true;
  }

  static Future<LatLng?> getLocation({bool askEnableGPS = false}) async {
    if (Platform.isLinux) return LatLng(46.58306570646413, 0.34316815224968406);
    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }
}
