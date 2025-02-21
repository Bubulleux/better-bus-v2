import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';

class BusTrip extends LineDirected {
  BusTrip({
    required LineDirection direction,
    this.stopTimes,
  }) : super(direction);

  final Map<DateTime, Station>? stopTimes;
}
