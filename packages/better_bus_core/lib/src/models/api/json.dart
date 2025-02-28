import 'dart:convert';
import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '../../helper.dart';
import '../bus_line.dart';
import '../line_direction.dart';
import '../station.dart';
import '../stop_time.dart';

// Old Api Json parser
// TODO: Clean it up

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

class JsonBusLine extends BusLine {
  JsonBusLine.fromSimpleJson(Map<String, dynamic> json)
      : super(
    json["slug"],
    json["name"],
    Color(int.parse(json["color"].replaceAll("#", "0xff"))),
    directions: {}
  );

  JsonBusLine.fromJson(Map<String, dynamic> json)
      : super(
    json["line_id"],
    json["name"],
    // TODO: Get a better function, not from helper.dart
    colorFromHex(json["color"]),
    // TODO: Probably needs to be reimplemented
      directions: {
        ...(json["direction"]["aller"].map((e) => Direction(e, 0)).toSet()),
        ...(json["direction"]["retour"].map((e) => Direction(e, 1)).toSet()),
      }
  );
}

class JsonStopTime extends StopTime {

  JsonStopTime(Map<String, dynamic> json, int directionId, Station station)
      : super (station,
    LineDirection(JsonBusLine.fromJson(json["line"]), json["destinationName"], directionId),
    DateTime.parse(json["expectedDepartureTime"]).toLocal(),
    realTime: json["realtime"] ? DateTime.parse(json["expectedDepartureTime"]).toLocal() : null,
  );
}