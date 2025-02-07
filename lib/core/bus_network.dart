import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/core/models/traffic_info.dart';


abstract class BusNetwork {

  // Initiate and return true if is available
  Future<bool> init();

  // Return if available
  bool isAvailable();

  // Return a list of all bus station on the network
  Future<List<Station>> getStations();

  // Return a list of all the Line in the network
  Future<List<BusLine>> getAllLines();

  // Return all the line passing at the bus station
  Future<List<BusLine>> getPassingLines(Station station);

  // Return the timetable of the station
  Future<Timetable> getTimetable(Station station);

  // Return a list of all available Traffic info
  Future<List<TrafficInfo>> getTrafficInfos();
}