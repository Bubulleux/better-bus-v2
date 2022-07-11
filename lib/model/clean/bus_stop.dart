import 'dart:convert';
import 'dart:math';

class BusStop {
  BusStop(this.name, this.id, {this.latitude = 0, this.longitude = 0});

  BusStop.example() : this("Bus Stop Name", 10);

  BusStop.fromJson(Map<String, dynamic> json)
      : this(
          json["name"],
          // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
          int.parse(
              utf8.decode(base64.decode(json["stop_id"])).substring(2, 7)),
          latitude: json["lat"],
          longitude: json["lng"],
        );

  final String name;
  final double latitude;
  final double longitude;
  final int id;
}
