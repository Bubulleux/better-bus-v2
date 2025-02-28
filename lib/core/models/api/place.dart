import 'package:better_bus_v2/core/models/place.dart';
import 'package:latlong2/latlong.dart';

class JsonPlace extends Place {
  JsonPlace(Map<String, dynamic> json)
      : super(json["title"],
            LatLng(json["position"]["lat"], json["position"]["lng"]),
            address: json["address"]["label"]);
}
