import 'package:better_bus_v2/core/models/place.dart';
import 'package:latlong2/latlong.dart';

class Station extends Place {
  const Station(super.name, this.id, super.postion, {required this.stops});

  final int id;
  final Map<int, LatLng> stops;

  @override
  bool operator ==(Object other) {
    return other is Station && other.hashCode == hashCode;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() {
    return "$name ($id: ${stops.length})";
  }

  // TODO: Old Json function
  Station.fromCleanJson(Map<String, dynamic> json)
      : this(
          json["name"],
          int.parse(json["id"]),
          LatLng(json["lat"], json["long"]),
          stops: {},
        );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "lat": position.latitude,
      "long": position.longitude,
      "id": id,
    };
  }
}
