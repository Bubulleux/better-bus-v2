import 'package:better_bus_v2/core/api_provider.dart';
import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_provider.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:flutter/foundation.dart';

class FullProvider extends BusNetwork {
  final ApiProvider api;
  final GTFSProvider gtfs;

  BusNetwork get preferApi => api.isAvailable() ? api : gtfs;
  BusNetwork get preferGtfs => gtfs.isAvailable() ? gtfs : api;

  FullProvider({required this.api, required this.gtfs});

  @override
  Future<bool> init() async {
    final result = await Future.wait([api.init(), gtfs.init()]);
    return result[0] && result[1];
  }

  @override
  bool isAvailable() {
    return api.isAvailable() && gtfs.isAvailable();
  }

  @override
  Future<Map<String, BusLine>> getAllLines() {
    return preferGtfs.getAllLines();
  }

  @override
  Future<Timetable> getLineTimetable(Station station, BusLine line) {
    // TODO: implement getLineTimetable
    throw UnimplementedError();
  }

  @override
  Future<List<BusLine>> getPassingLines(Station station) => preferGtfs.getPassingLines(station);

  @override
  Future<List<Station>> getStations() => preferGtfs.getStations();

  @override
  Future<Timetable> getTimetable(Station station) {
    // TODO: implement getTimetable
    throw UnimplementedError();
  }


}