import 'package:better_bus_v2/model/clean/bus_line.dart';

class NextPassage {
  NextPassage(this.line, this.destination, this.realTime, this.aimedTime,
      this.expectedTime);

  NextPassage.fromJson(Map<String, dynamic> json)
      : line = BusLine.fromJson(json["line"]),
        destination = json["destinationName"],
        realTime = json["realtime"],
        aimedTime = DateTime.parse(json["aimedDepartureTime"]),
        expectedTime = DateTime.parse(json["expectedDepartureTime"]);

  final BusLine line;
  final String destination;
  final bool realTime;
  final DateTime aimedTime;
  final DateTime expectedTime;
}
