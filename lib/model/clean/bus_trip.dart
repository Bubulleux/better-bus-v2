import 'package:better_bus_v2/model/clean/bus_line.dart';

@Deprecated("User Core")
class BusTrip {

}

@Deprecated("User Core")
class TripPassage {
  TripPassage(this.line, this.direction, this.time, this.tripId);

  final BusLine line;
  final String direction;
  final DateTime time;
  final String tripId;
}
