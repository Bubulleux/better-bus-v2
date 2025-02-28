
// TODO: Change this to another function
import 'package:better_bus_core/src/models/gtfs/trip.dart';

import '../../helper.dart';
import '../bus_line.dart';
import '../line_direction.dart';

class GTFSLine extends BusLine {
  final int gtfsId;

  // TODO: Add directions
  GTFSLine(super.id, super.name, super.color, this.gtfsId) : super(directions: {});

  GTFSLine.fromCSV(Map<String, String> row)
      : this(
    row["route_short_name"]!,
    row["route_long_name"]!,
    colorFromHex("#${row["route_color"]!}"),
    int.parse(row["route_id"]!),
  );

  void addDirection(GTFSTrip trip) {
    assert(trip.line == this);
    assert(trip.line.id == id);
    super.directions.add(trip.direction as Direction);
  }
}
