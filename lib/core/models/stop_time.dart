import 'package:better_bus_v2/core/models/line_direction.dart';

class StopTime extends LineDirection {
  StopTime(super.line, super.direction, this.aimedTime, {this.realTime});

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
}
