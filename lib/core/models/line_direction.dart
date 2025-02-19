import 'package:better_bus_v2/core/models/bus_line.dart';

class Direction {
  final String destination;
  final int directionId;

  const Direction(this.destination, this.directionId);
}

class LineDirection extends Direction {
  const LineDirection(this.line, super.destination, super.directionId);

  final BusLine line;

  @override
  int get hashCode => line.hashCode ^ destination.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LineDirection && hashCode == other.hashCode;
  }
}