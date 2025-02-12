import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:intl/intl.dart';

class JsonTimetable extends Timetable {
  factory JsonTimetable(Map<String, dynamic> json, Station station, DateTime date) {
    final ends = Map<String, String>.fromIterable(
      json["terminus"],
        key: (e) => e["label"],
      value: (e) => e["direction"]
    );

  }

  List<BusSchedule> schedule;
  Map<String, String> terminalLabel;

}

class BusSchedule extends StopTime {

  BusSchedule(Map<String, dynamic> json)
      : super(
    DateFormat("HH:mm:ss").parse(json["time"]),
    json["label"],
  );

  DateTime time;
  String label;
}