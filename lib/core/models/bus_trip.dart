import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';

class BusTrip {
  const BusTrip({
    required this.line,
    required this.headsign,
    required this.departure,
    required this.arrivalTimestamp,
});

  final BusLine line;
  final String headsign;
  final DateTime departure;
  final Map<Duration, Station> arrivalTimestamp;
}