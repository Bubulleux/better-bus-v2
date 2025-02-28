import 'package:latlong2/latlong.dart';

class Place {
  const Place(this.name, this.position, {this.address});

  final String name;
  final String? address;
  final LatLng position;

  Place.fromJson(Map<String, dynamic> json)
      : this(json['name'], LatLng(json['lat'], json['long']),
            address: json['address']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'lat': position.latitude,
        'long': position.longitude,
      };
}
