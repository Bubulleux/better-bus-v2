import 'package:better_bus_core/src/models/api_status.dart';
import 'package:better_bus_core/src/models/report.dart';
import 'package:better_bus_core/src/models/station.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:better_bus_v2/data_provider/radar_provider.dart';

const radarUnavailable = "Radar is not available";

// TODO: Their is a better way to do that...

class BrokenRadar implements  AppRadarProvider {
  BrokenRadar();

  @override
  DateTime? lastSent = DateTime.now();

  @override
  Future<List<Report>> getReports() {
    return Future.value([]);
  }

  @override
  Future<ApiStatus> getStatus() {
    return Future.value(ApiStatus(false));
  }

  @override
  Future<bool> init() {
    return Future.value(false);
  }

  @override
  void preventSpam() {
    throw radarUnavailable;
  }

  @override
  Future<Report?> sendReport(Station station) {
    return Future.value(null);
  }

  @override
  // TODO: implement sentAvailable
  bool get sentAvailable => false;

  @override
  Future<Report?> updateReport(Report report, bool stillThere) {
    return Future.value(null);
  }

  @override
  AppProvider get provider => throw radarUnavailable;

  @override
  set provider(AppProvider _provider) => throw radarUnavailable;

}