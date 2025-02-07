import 'dart:convert';

import 'package:better_bus_v2/core/models/station.dart';
import 'package:latlong2/latlong.dart';

class JsonStation extends Station {

  JsonStation(Map<String, dynamic> json) :
        super(
          json["name"],
          getIdFromApi(json["stop_id"]),
          LatLng(json["lat"], json["lng"]),
        stops: {}
      );

  static int getIdFromApi(String base64Id) {
    // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
    String parsedId = utf8.decode(base64.decode(base64Id));
    return int.parse(parsedId.substring(2, parsedId.length - 4));
  }
}