import 'package:better_bus_core/src/helper.dart';

import '../stop_time.dart';
import '../timetable.dart';
import 'trip.dart';

class GTFSTimeTable extends Timetable {
  late final List<GTFSTrip> _trips;

  get trips => _trips;

  GTFSTimeTable(super.station, super.date, Iterable<GTFSTrip> trips) {
    _trips = trips.where((e) => e.stopTimes.containsKey(station)).toList();
    _trips.sort((a, b) =>
        a.stopTimes[station]!.arrival.compareTo(b.stopTimes[station]!.arrival));
  }

  @override
  Iterable<StopTime> getNext({DateTime? from}) {
    from ??= DateTime.now();
    Duration fromDuration = from.difference(DateTime.now().atMidnight());
    return _trips
        .where((e) => e.stopTimes[station]!.arrival >= fromDuration)
        .map((e) => StopTime(
            station, e.direction, date.add(e.stopTimes[station]!.arrival),
            trip: e.at(date)));
  }

  StopTime matchTime(StopTime time) {
    assert(time.station == station);
    List<GTFSTrip> validTrip =
        trips.where((e) => e.direction == time.direction).toList();

    Duration testDuration = time.time.difference(date);

    int i = validTrip
        .lastIndexWhere((e) => testDuration >= e.stopTimes[station]!.arrival);

    assert(i >= 0);

    Duration curDiff = testDuration - validTrip[i].stopTimes[station]!.arrival;
    if (validTrip.length != i + 1 &&
        curDiff > validTrip[i + 1].stopTimes[station]!.arrival - testDuration) {
      i += 1;
    }
    DateTime aimedTime = date.add(validTrip[i].stopTimes[station]!.arrival);

    return StopTime(station, time.direction, aimedTime,
        realTime: time.time, trip: validTrip[i].at(date));
  }
}