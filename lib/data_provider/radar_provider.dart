import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

const sendThreshold = Duration(minutes: 2);

class AppRadarProvider extends RadarClient {
  @override
  FullProvider provider;
  static DateTime? lastSent;

  AppRadarProvider({required this.provider})
      : super(
          provider: provider,
          apiUrl: kDebugMode && false
              ? RadarClient.localhostEndPoint
              : RadarClient.productionEndpoint,
        );

  // TODO: Make it not static

  // TODO: Watch out
  bool get sentAvailable =>
      lastSent == null ||
      DateTime.now().difference(lastSent!) >= sendThreshold ||
      kDebugMode; // Retrun alayse true if debug

  factory AppRadarProvider.of(BuildContext context) {
    return AppRadarProvider(provider: FullProvider.of(context));
  }

  void preventSpam() {
    if (!sentAvailable) throw "Not available wait pls";
    lastSent = DateTime.now();
  }

  @override
  Future<Report?> sendReport(Station station) {
    preventSpam();
    return super.sendReport(station);
  }

  @override
  Future<Report?> updateReport(Report report, bool stillThere) {
    preventSpam();
    return super.updateReport(report, stillThere);
  }

  @override
  Future<List<Report>> getReports() async {
    // TODO: Do this calculation in server too
    if (provider.offline) {
      return [];
    }

    const timeLimit = Duration(hours: 1);
    final reports = await super.getReports();
    return reports.where((e) => e.lastSee < timeLimit).toList();
  }
}
