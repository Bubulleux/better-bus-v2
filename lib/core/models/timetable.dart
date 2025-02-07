import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/helper.dart';

class Timetable {
  Timetable(this.station, DateTime date, {required this.stopTimes}) {
    this.date = date.atMidnight();
    updateTime = DateTime.now();
  }

  final Station station;
  late final DateTime date;
  late DateTime updateTime;
  List<StopTime> stopTimes;

  Iterable<StopTime> getNext({DateTime? from}) {
    DateTime start = from ?? DateTime.now();
    return stopTimes.where((stopTime) =>
      stopTime.time.isAfter(start));
  }
}