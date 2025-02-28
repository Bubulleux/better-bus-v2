import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_provider.dart';
import 'bus_network.dart';
import 'gtfs_provider.dart';
import 'models/bus_line.dart';
import 'models/gtfs/timetable.dart';
import 'models/line_timetable.dart';
import 'models/matching_timetable.dart';
import 'models/station.dart';
import 'models/timetable.dart';
import 'models/traffic_info.dart';

class FullProvider extends BusNetwork {
  final ApiProvider api;
  final GTFSProvider gtfs;

  BusNetwork get preferApi => api.isAvailable() ? api : gtfs;
  BusNetwork get preferGtfs => gtfs.isAvailable() ? gtfs : api;

  FullProvider({required this.api, required this.gtfs});

  factory FullProvider.of(BuildContext context) {
    return context.read<FullProvider>();
  }

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
  Future<LineTimetable> getLineTimetable(Station station, BusLine line, int direction, DateTime date)
    => gtfs.getLineTimetable(station, line, direction, date);

  @override
  Future<List<BusLine>> getPassingLines(Station station) => preferGtfs.getPassingLines(station);

  @override
  Future<List<Station>> getStations() => preferGtfs.getStations();


  @override
  Future<Timetable> getTimetable(Station station) async {
    if (!gtfs.isAvailable() || !api.isAvailable()) {
      return preferApi.getTimetable(station);
    }
    GTFSTimeTable gtfsTimes = await gtfs.getTimetable(station);
    final apiTimes = await api.getTimetable(station);

    return MatchingTimetable(apiTimes, gtfsTimes);

  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() => api.getTrafficInfos();


}