
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/gtfs/line.dart';
import 'package:better_bus_v2/core/models/gtfs/stop_time.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';

class GTFSTrip {
  late final LineDirection direction;
  late final String serviceID;
  late final int _routeID;
  // final String _headSign;
  late final int directionId;
  late final List<GTFSStopTime> stopTimes;

  BusLine get line => direction.line;


  GTFSTrip(Map<String, String> row, this.stopTimes, GTFSLine line){
    _routeID = int.parse(row["route_id"]!);
    serviceID = row["service_id"]!;
    direction = LineDirection(line, row["trip_headsign"]!);
    directionId = int.parse(row["direction_id"]!);
  }

  // BusTrip toTrip() {
  //
  // }
}