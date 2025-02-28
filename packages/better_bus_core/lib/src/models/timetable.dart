import 'package:better_bus_core/src/helper.dart';

import 'station.dart';
import 'stop_time.dart';

abstract class Timetable {
  Timetable(this.station, DateTime date) {
    this.date = date.atMidnight();
    updateTime = DateTime.now();
  }

  Timetable.copy(Timetable from) : this(from.station, from.date);

  final Station station;
  late final DateTime date;
  late DateTime updateTime;

  Iterable<StopTime> getNext({DateTime? from});

  @override
  int get hashCode => station.hashCode ^ date.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Timetable && hashCode == other.hashCode;
  }
}

class ConstTimetable  extends Timetable{
  ConstTimetable(super.station, super.date, {required this.stopTimes});

  List<StopTime> stopTimes;

  @override
  Iterable<StopTime> getNext({DateTime? from}) {
    DateTime start = from ?? DateTime.now();
    var output =  stopTimes.where((stopTime) =>
      stopTime.time.isAfter(start)).toList();

    output.sort();
    return output;
  }
}