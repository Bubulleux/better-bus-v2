import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';

class Direction {
  final String destination;
  final int directionId;

  const Direction(this.destination, this.directionId);

  @override
  int get hashCode => destination.hashCode ^ directionId.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Direction && hashCode == other.hashCode;
  }
}

class Directed implements Direction {
  String get destination => throw UnimplementedError();

  int get directionId => throw UnimplementedError();

}

class LineDirection extends Direction {
  const LineDirection(this.line, super.destination, super.directionId);

  final BusLine line;

  @override
  int get hashCode => line.hashCode ^ super.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LineDirection && hashCode == other.hashCode;
  }

  @override
  String toString() {
    return '{${line.id}, $destination, $directionId}';
  }
}

class LineDirected implements LineDirection {
  final LineDirection direction;

  LineDirected(this.direction);

  @override
  String get destination => direction.destination;

  @override
  int get directionId => direction.directionId;

  @override
  BusLine get line => direction.line;

}