import 'package:better_bus_core/core.dart';

import 'models/report.dart';

class ReportsHandler {
  GTFSProvider provider;
  List<Report> reports = [];
  Map<int, Station> stationsMap = {};


  ReportsHandler(this.provider);

  Future<bool> init() async {
    final success = await provider.init();
    if (!success) return false;
    stationsMap.addEntries(
        (await provider.getStations()).map((e) => MapEntry(e.id, e))
    );
    return true;
  }

  Future<bool> sendReport(int stationId) async {
    if (!stationsMap.containsKey(stationId)) return false;

    reports.add(Report(stationsMap[stationId]!));
    return true;
  }

  int countReports() {
    return reports.length;
  }
}