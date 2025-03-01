import 'package:better_bus_core/core.dart';
class Report {
  final Station station;
  late final DateTime time;

  Report(this.station) {
    time = DateTime.now();
  }


}