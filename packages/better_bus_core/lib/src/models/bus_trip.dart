
import 'package:better_bus_core/src/models/station.dart';

import 'line_direction.dart';

class BusTrip extends LineDirected {
  BusTrip(super.direction, {required this.stopTimes, required this.id});


  final int id;
  final List<TripStop> stopTimes;

  Iterable<TripStop> from(Station station) {
    return stopTimes.skipWhile((e) => e.station != station);
  }

  @override
  String toString() {
    return 'BusTrip{direction: $direction, stopLength: ${stopTimes.length}';
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is BusTrip && hashCode == other.hashCode;
  }
}

class TripStop {
  TripStop(this.time, this.station);

  TripStop.fromMapEntry(MapEntry<DateTime, Station> entry)
      : this(entry.key, entry.value);

  final DateTime time;
  final Station station;
}
