import 'package:latlong2/latlong.dart';
class Place {
  const Place(this.name, this.position, {this.address});

  final String name;
  final String? address;
  final LatLng position;
}