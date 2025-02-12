import 'package:better_bus_v2/model/clean/bus_line.dart';

@Deprecated("User Core")
class LineDirection {
  LineDirection(this.line, this.destination);

  final BusLine line;
  final String destination;

  @override
  int get hashCode => line.hashCode ^ destination.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}