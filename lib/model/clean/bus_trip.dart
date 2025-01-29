import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/next_passage.dart';

class BusTrip {

}

class TripPassage {
  TripPassage(this.line, this.direction, this.time, this.tripId);

  final BusLine line;
  final String direction;
  final DateTime time;
  final String tripId;
}
