import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/timetable.dart';

class LineTimetable extends Timetable {
  // TODO : Maybe not needed but their is this to do here
  LineTimetable(super.station, this.line, super.data, {
    required super.stopTimes
  });

  final BusLine line;
}