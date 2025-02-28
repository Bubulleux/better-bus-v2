import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';

class GTFSLineDirection extends LineDirection {
  GTFSLineDirection(super.line, super.destination, super.directionId);

  factory GTFSLineDirection.fromTripRow(Map<String, String> row, BusLine line) {
    return GTFSLineDirection(
        line, row["trip_headsign"]!, int.parse(row["direction_id"]!));
  }
}
