
import 'package:better_bus_v2/model/clean/bus_line.dart';

@Deprecated("User Core")
class ArrivingTime {
  final Duration duration;
  final String stop;

  const ArrivingTime(this.stop, this.duration);
}

@Deprecated("User Core")
class NextPassage {
  const NextPassage(this.line, this.destination, this.aimedTime,
      {this.expectedTime, this.arrivingTimes});

  final BusLine line;
  final String destination;
  final DateTime aimedTime;
  final DateTime? expectedTime;
  final List<ArrivingTime>? arrivingTimes;

  DateTime get betterTime => expectedTime ?? aimedTime;
  bool get realTime => expectedTime != null;

  NextPassage copyWith({DateTime? aimedTime, DateTime? expectedTime, List<ArrivingTime>? arrivingTimes}) {
    return NextPassage(
        line, destination, aimedTime ?? this.aimedTime,
        expectedTime: expectedTime ?? this.expectedTime, arrivingTimes:
    arrivingTimes ?? this.arrivingTimes);
  }

  @override
  int get hashCode =>
      Object.hash(aimedTime.hashCode, line.hashCode,
          destination);


  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}


class ApiNextPassage extends NextPassage {
  ApiNextPassage(super.line, super.destination, super.aimedTime,
  {super.expectedTime, super.arrivingTimes});

  ApiNextPassage.fromJson(Map<String, dynamic> json)
      : this (
    BusLine.fromJson(json["line"]),
    json["destinationName"],
    DateTime.parse(json["expectedDepartureTime"]),
    expectedTime: json["realtime"] ? DateTime.parse(json["expectedDepartureTime"]) : null,
  );
}
