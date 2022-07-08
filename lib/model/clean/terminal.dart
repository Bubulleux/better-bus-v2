import 'package:better_bus_v2/model/clean/bus_stop.dart';

import 'bus_line.dart';

class Terminal {
  Terminal(this.endStop, this.line, {this.oneWay = true});
  Terminal.example(): this(BusStop.example(), BusLine.example());

  BusStop endStop;
  BusLine line;
  bool oneWay;
}