import 'dart:convert';

class BusStop {
  BusStop(this.name, this.id, {this.latitude = 0, this.longitude = 0});

  BusStop.example() : this("Bus Stop Name", 10);

  final String name;
  final double latitude;
  final double longitude;
  final int id;

  BusStop.fromJson(Map<String, dynamic> json)
      : this(
          json["name"],
          // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
          int.parse(
              utf8.decode(base64.decode(json["stop_id"])).substring(2, 7)),
          latitude: json["lat"],
          longitude: json["lng"],
        );

  BusStop.fromCleanJson(Map<String, dynamic> json)
      : this(
    json["name"],
    // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
    json["id"],
    latitude: json["lat"],
    longitude: json["long"],
  );

  Map<String, dynamic> toJson() {
    return {
      "name" : name,
      "lat" : latitude,
      "long": longitude,
      "id": id,
    };
  }



  @override
  bool operator ==(Object other) {
    return other is BusStop && id == other.id && name == other.name;
  }

  @override
  int get hashCode => Object.hash(id, name);

}
