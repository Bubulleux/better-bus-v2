import 'models/bus_line.dart';
import 'models/line_timetable.dart';
import 'models/station.dart';
import 'models/timetable.dart';
import 'models/traffic_info.dart';

abstract class BusNetwork {

  // Initiate and return true if is available
  Future<bool> init();

  // Return if available
  bool isAvailable();

  // Return a list of all bus station on the network
  Future<List<Station>> getStations();

  // Return a map of all the Line in the network
  // Key is the short name of the line
  Future<Map<String,BusLine>> getAllLines();

  // Return all the line passing at the bus station
  Future<List<BusLine>> getPassingLines(Station station);

  // Return the timetable of the station
  Future<Timetable> getTimetable(Station station);

  // Return the timetable of the Line in the Station Only
  Future<LineTimetable> getLineTimetable(Station station, BusLine line,int direction, DateTime date);

  // Return a list of all available Traffic info
  Future<List<InfoTraffic>> getTrafficInfos();
}
