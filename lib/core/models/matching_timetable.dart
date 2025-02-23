import 'package:better_bus_v2/core/models/bus_trip.dart';
import 'package:better_bus_v2/core/models/gtfs/timetable.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/helper.dart';

class MatchingTimetable extends Timetable {
  Timetable realTime;
  GTFSTimeTable gtfsTimeTable;

  MatchingTimetable(this.realTime, this.gtfsTimeTable): super.copy(realTime) {
    assert(realTime == gtfsTimeTable);
  }

  @override
  Iterable<StopTime> getNext({DateTime? from}) {
    from ??= DateTime.now();
    List<StopTime> apiTimes = realTime.getNext(from: from).toList();
    final result = apiTimes.map((e) => gtfsTimeTable.matchTime(e)).toList();
    final Set<int> matchedTrips = result.map((e) => e.trip!.id).toSet();
    
    result.addAll(gtfsTimeTable.getNext(from: from)
        .where((e) => !matchedTrips.contains(e.trip?.id))
    );

    result.sort();
    return result;
  }

}