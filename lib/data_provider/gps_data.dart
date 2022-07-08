import 'package:location/location.dart';

class GpsDataProvider {
  static Future<LocationData?> getLocation() async {
    Location location = Location();

    // Check if location service is enable
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    // Check if permission is granted
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    final LocationData _locationData = await location.getLocation();
    return _locationData;
  }


}
