import 'dart:convert';
import 'dart:math';

class BusStop {
  BusStop(this.name, {this.id = -1, this.latitude = 0, this.longitude = 0});
  BusStop.example() : this("Bus Stop Name");
  BusStop.fromJson(Map<String, dynamic> json):
      this(
        json["name"],
        latitude: json["lat"],
        longitude: json["lng"],
        // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
        id: int.parse(utf8.decode(base64.decode(json["stop_id"])).substring(2, 7)),
      );

  final String name;
  final double latitude;
  final double longitude;
  final int id;
}