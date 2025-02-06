import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/core/models/traffic_info.dart';


abstract class BusNetwork {

  bool isAvailable();
  List<Station> getStations();
  List<BusLine> getAllLines();
  List<BusLine> getPassingLines(Station station);
  Timetable getTimetable(Station station);
  List<TrafficInfo> getTrafficInfos();
}