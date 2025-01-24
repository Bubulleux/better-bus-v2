import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';

class LineDirection {
  LineDirection(this.line, this.tripId, this.destination);

  final BusLine line;
  final String tripId;
  final String destination;

  @override
  int get hashCode => line.hashCode ^ destination.hashCode ^ tripId.hashCode;
}