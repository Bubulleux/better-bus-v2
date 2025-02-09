import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';

class GTFSLineDirection extends LineDirection {
  final int directionId;
  GTFSLineDirection(super.line, super.destination, this.directionId);

  factory GTFSLineDirection.fromCSV(Map<String, String> row, GTFSData data) {
    final line = data.routes[row["route_id"]]!;
    return GTFSLineDirection(line as BusLine, row["trip_headsign"]!, int.parse(row["direction_id"]!));
  }
}