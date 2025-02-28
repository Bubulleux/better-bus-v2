import 'package:better_bus_core/src/models/line_timetable.dart';
import 'package:intl/intl.dart';

class JsonLineTimetable extends LineTimetable {
  JsonLineTimetable(
      Map<String, dynamic> json, super.station, super.line, super.date)
      : super(
          destinations: {
            for (var e in json["terminus"]) e["label"]: e["direction"]
          },
          passingTimes: {
            for (var e in json["horaire"])
              DateFormat("HH:mm:ss").parse(e["time"]): e["label"]
          },
        );
}
