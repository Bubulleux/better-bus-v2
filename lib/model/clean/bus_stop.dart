import 'dart:math';

class BusStop {
  BusStop(this.name, {this.id = -1, this.latitude = 0, this.longitude = 0});
  BusStop.example() : this("Bus Stop Name");

  final String name;
  final double latitude;
  final double longitude;
  final int id;
}