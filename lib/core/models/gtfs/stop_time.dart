import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/trip.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/helper.dart';

class GTFSStopTime  {
  late final Duration arival;
  late final int _stopId;
  final Station station;
  late final double distanceTravel;

  GTFSStopTime(Map<String, String> row, this.station) {

    arival = parseDuration(row["arrival_time"]!);
    distanceTravel = double.parse(row["shape_dist_traveled"]!);
    _stopId = int.parse(row["stop_id"]!);
  }

  StopTime toStopTime(GTFSTrip trip, DateTime date) {
    return StopTime(trip.line, trip.direction.destination, 
      date.atMidnight().add(arival));
  }

}
