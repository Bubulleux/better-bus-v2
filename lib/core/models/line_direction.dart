import 'package:better_bus_v2/core/models/bus_line.dart';

class LineDirection {
  const LineDirection(this.line, this.destination);

  final BusLine line;
  final String destination;

  @override
  int get hashCode => line.hashCode ^ destination.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LineDirection && hashCode == other.hashCode;
  }
}