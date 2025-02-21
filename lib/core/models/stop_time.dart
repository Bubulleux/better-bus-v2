import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/bus_trip.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';

class StopTime extends LineDirected implements Comparable<StopTime>{
  StopTime(this.station, super.direction, this.aimedTime, {this.trip, this.realTime});

  StopTime.fromDirection(this.station, super.direction, this.aimedTime, {this.realTime});

  StopTime.fromTrip(this.station, BusTrip this.trip, this.aimedTime, {this.realTime}) :
        super(trip);


  Station station;
  BusTrip? trip;
  final DateTime aimedTime;
  DateTime? realTime;

  DateTime get time => realTime ?? aimedTime;

  bool get isRealTime => realTime != null;

  Duration get delay =>
      isRealTime ? realTime!.difference(aimedTime) : Duration.zero;

  @override
  int get hashCode => aimedTime.hashCode ^ super.hashCode;


  @override
  bool operator ==(Object other) {
    return other is StopTime && hashCode == other.hashCode;
  }

  @override
  int compareTo(StopTime other) {
    return time.compareTo(other.time);
  }

}
