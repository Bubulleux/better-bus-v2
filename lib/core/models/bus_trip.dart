import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';

class BusTrip {
  const BusTrip({
    required this.direction,
    required this.stopTimes,
});

  final LineDirection direction;
  final Map<DateTime, Station> stopTimes;
}