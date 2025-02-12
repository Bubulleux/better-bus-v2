@Deprecated("User Core")
class MapPlace{
  MapPlace({
    required this.title,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  MapPlace.fromJson(Map<String, dynamic> json): this(
    title: json["title"],
    address: json["address"]["label"],
    type: json["resultType"],
    latitude: json["position"]["lat"],
    longitude: json["position"]["lng"],
  );

  MapPlace.fromCleanJson(Map<String, dynamic> json): this(
    title: json["title"],
    address: json["address"],
    type: json["type"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  final String title;
  final String address;
  final String type;
  final double longitude;
  final double latitude;

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "address": address,
      "type": type,
      "longitude": longitude,
      "latitude": latitude,
    };
  }

  @override
  int get hashCode => Object.hash(title, longitude, latitude);

  @override
  bool operator ==(Object other) {
    return other is MapPlace ? other.hashCode == hashCode : false;
  }

  @override
  String toString() {
    return "$title, $address, $longitude, $latitude";
  }
}