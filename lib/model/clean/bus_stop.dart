import 'dart:convert';

import 'package:latlong2/latlong.dart';

class SubBusStop {
  const SubBusStop(this.id, this.pos, {this.stopCode});

  final LatLng pos;
  final int id;
  final String? stopCode;
}

class BusStop extends SubBusStop{
  const BusStop(this.name, super.id, super.pos, {this.children = const [], super.stopCode});

  @override
  int? get parent_id => null;

  BusStop.example() : this("Bus Stop Name", 10, const LatLng(0, 0));

  final String name;
  final List<SubBusStop> children;

  double get latitude => pos.latitude;
  double get longitude => pos.longitude;

  BusStop.fromJson(Map<String, dynamic> json) :
        this(
          json["name"],
          getIdFromApi(json["stop_id"]),
          LatLng(json["lat"], json["lng"])
      );

  BusStop.fromCleanJson(Map<String, dynamic> json)
      : this(
          json["name"],
          // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
          json["id"],
          LatLng(json["lat"], json["long"])
        );

  BusStop.fromCSV(Map<String, String> row)
      : this(
          row["stop_name"]!,
          int.parse(row["stop_id"]!),
          LatLng(
              double.parse(row["stop_lat"]!),
              double.parse(row["stop_lon"]!))
        );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "lat": pos.latitude,
      "long": pos.longitude,
      "id": id,
    };
  }

  static int getIdFromApi(String base64Id) {
    // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
    String parsedId = utf8.decode(base64.decode(base64Id));
    return int.parse(parsedId.substring(2, parsedId.length - 4));
  }

  Set<String> get ids => {id.toString(), ...children.map((e) => e.id.toString())};


  @override
  bool operator ==(Object other) {
    return other is BusStop && id == other.id && name == other.name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}


