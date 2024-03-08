import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';

class ArrivingTime {
  final Duration duration;
  final String stop;

  ArrivingTime(this.stop, this.duration);
}

class NextPassage {
  NextPassage(this.line, this.destination, this.realTime, this.aimedTime,
      this.expectedTime, this.arrivingTimes);

  NextPassage.fromJson(Map<String, dynamic> json)
      : line = BusLine.fromJson(json["line"]),
        destination = json["destinationName"],
        realTime = json["realtime"],
        aimedTime = DateTime.parse(json["aimedDepartureTime"]),
        expectedTime = DateTime.parse(json["expectedDepartureTime"]),
        arrivingTimes = [];

  NextPassage witchArrival(List<ArrivingTime> newArriving) {
    return NextPassage(line, destination, realTime, aimedTime, expectedTime, newArriving);
  }

  final BusLine line;
  final String destination;
  final bool realTime;
  final DateTime aimedTime;
  final DateTime expectedTime;
  final List<ArrivingTime> arrivingTimes;
}
