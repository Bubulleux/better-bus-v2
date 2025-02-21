import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/bus_trip.dart';
import 'package:better_bus_v2/core/models/gtfs/direction.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/line.dart';
import 'package:better_bus_v2/core/models/gtfs/stop_time.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/helper.dart';

class GTFSTrip {
  late final LineDirection direction;
  late final String serviceID;
  late final int _routeID;
  late final Map<Station, GTFSStopTime> _stopTimes;

  Map<Station, GTFSStopTime> get stopTimes => _stopTimes;

  BusLine get line => direction.line;

  GTFSTrip(Map<String, String> row, List<GTFSStopTime> stopTimes, GTFSData data) {
    _stopTimes = { for (var e in stopTimes) data.stopsParent[e.stopId]! : e};
    _routeID = int.parse(row["route_id"]!);
    serviceID = row["service_id"]!;
    direction = GTFSLineDirection.fromTripRow(row, data.routes[_routeID]!);
  }

  BusTrip at(DateTime from) {
    final date = from.atMidnight();
    return BusTrip(direction,
        stopTimes: stopTimes.entries
            .map((e) => TripStop(date.add(e.value.arrival), e.key))
            .toList());
  }
}
