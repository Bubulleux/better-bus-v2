import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';

class BusTrip extends LineDirected {
  BusTrip(LineDirection direction, {required this.stopTimes})
      : super(direction);

  BusTrip.fromMap({
    required LineDirection direction,
    required Map<DateTime, Station> stopTimes,
  }) : this(direction,
            stopTimes: stopTimes.entries
                .map((e) => TripStop.fromMapEntry(e))
                .toList());

  final List<TripStop> stopTimes;

  Iterable<TripStop> from(Station station) {
    return stopTimes.skipWhile((e) => e.station != station);
  }

  @override
  String toString() {
    return 'BusTrip{direction: $direction, stopLength: ${stopTimes.length}';
  }
}

class TripStop {
  TripStop(this.time, this.station);

  TripStop.fromMapEntry(MapEntry<DateTime, Station> entry)
      : this(entry.key, entry.value);

  final DateTime time;
  final Station station;
}
