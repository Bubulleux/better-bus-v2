
import 'gtfs_data.dart';

class GTFSStopTime  {
  late final Duration arrival;
  late final int stopId;
  late final double distanceTravel;
  late final int tripId;
  late final int stopIndex;

  GTFSStopTime(Map<String, String> row) {

    arrival = parseDuration(row["arrival_time"]!);
    distanceTravel = double.parse(row["shape_dist_traveled"]!);
    stopId = int.parse(row["stop_id"]!);
    tripId = int.parse(row["trip_id"]!);
    stopIndex = int.parse(row["stop_sequence"]!);
  }

  // StopTime toStopTime(GTFSTrip trip, DateTime date) {
  //   return StopTime.fromTrip(trip.at(date),
  //     date.atMidnight().add(arival));
  // }

  @override
  int get hashCode => stopId ^ tripId ^ stopIndex;

  @override
  bool operator ==(Object other) {
    return other is GTFSStopTime && hashCode == other.hashCode;
  }

}
