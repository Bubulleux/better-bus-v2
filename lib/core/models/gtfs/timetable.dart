import 'package:better_bus_v2/core/models/gtfs/trip.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';

class GTFSTimeTable extends Timetable {
  late final List<GTFSTrip> _trips;

  get trips => _trips;

  GTFSTimeTable(super.station, super.date, Iterable<GTFSTrip> trips) {
    _trips = trips.where((e) => e.stopTimes.containsKey(station)).toList();
  }

  @override
  Iterable<StopTime> getNext({DateTime? from}) {
    return _trips.map((e) => StopTime(
        station, e.direction, date.add(e.stopTimes[station]!.arrival),
        trip: e.at(date)));
  }
}
