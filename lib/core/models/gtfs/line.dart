
// TODO: Change this to another function
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/helper.dart';

class GTFSLine extends BusLine {
  final int gtfsId;

  // TODO: Add directions
  GTFSLine(super.id, super.name, super.color, this.gtfsId,
  {required Iterable<Direction> directions}) : super(directions: directions.toSet());

  GTFSLine.fromCSV(Map<String, String> row, Iterable<Direction> directions)
      : this(
    row["route_short_name"]!,
    row["route_long_name"]!,
    colorFromHex("#${row["route_color"]!}"),
    int.parse(row["route_id"]!),
    directions: directions
  );
}
