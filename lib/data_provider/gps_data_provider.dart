import 'dart:io';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../model/app_config.dart';

class GpsDataProvider {
  bool askAndDecine = false;
  static late GpsDataProvider instance;
  bool isReady = false;
  static bool _available = false;

  final LatLng cityLocation;

  GpsDataProvider(this.cityLocation);

  static Future initGps(AppConfig config) async {
    instance = GpsDataProvider(config.cityLocation);
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

  static double calculateDistancePos(LatLng posA, LatLng posB) {
    return calculateDistance(posA.latitude, posA.longitude, posB.latitude, posB.longitude);
  }

  static Future<bool> askForGPSPermission() async {
    if (Platform.isLinux) return true;
    LocationPermission permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied;

  }

  static Future<bool> available() async{
		if (Platform.isLinux)
			return (true);
    if (!_available) {
      final perm = await Geolocator.checkPermission();
      _available = (perm == LocationPermission.always || perm == LocationPermission.whileInUse);
    }
    if (!_available) return false;
    _available &= (await Geolocator.isLocationServiceEnabled());
    return _available;
  }

  static Future<LatLng?> getLocation({bool askEnableGPS = false}) async {
    if (!(await available())) {
      return null;
    }
    if (Platform.isLinux) {
			return Future.value(instance.cityLocation);
		}
    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }
}
