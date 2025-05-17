import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/broken_radar.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../app_constant/root_load.dart';
import '../views/stops_search_page/stops_search_page.dart';
import 'radar_provider.dart';

class AppProvider extends GTFSProvider {
  final RootLoad loader = RootLoad();
  final ConnectivityStatus connStatus = ConnectivityStatus();
  late final AppRadarProvider radar;

  bool get online => connStatus.connected ?? false;

  bool get offline => !online;

  AppProvider({
    AppRadarProvider? radar,
    required super.downloader,
  }) {
    this.radar = radar ?? BrokenRadar();
  }

  factory AppProvider.of(BuildContext context) {
    return context.read<AppProvider>();
  }

  Future<bool> fastInit() async {
    return await loader.gtfsLoad.complete(downloader.loadIfExist());
  }

  @override
  Future<bool> init({OnProgress? onProgress}) async {
    await loader.internet.complete(connStatus.isConnected());

    if (offline) {
      print("No Internet connected only GTFS DATA");
      connStatus.onConnected(() async {
        print("Internet connection found Gtfs Data will get fetch is needed");
        // await api.init();
        super.init();
        // print("Api inited: ${api.isAvailable()}");
      });

      await downloader.paths.init();
      await downloader.loadIfExist();
      return isAvailable();
    }

    final futures = [
      loader.gtfsDownloadLoad
          .completWithProgress((p) => downloader.downloadAndLoad(onProgress: p)),
      // loader.api.complete(api.init()),
      // loader.radar.complete(radar.init())
    ];

    final success = await Future.wait(futures);

    print("App Provider full init $success");

    return success.every((e) => e);
  }

  Future awaitInit() async {
    while (!isAvailable()) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() {
    print("Connec status ${connStatus.connected}, ${connStatus.disconnected}");
    if (connStatus.disconnected == true) {
      throw CustomErrors.noInternet;
    }
    return super.getTrafficInfos();
  }

  Future<List<Station>> getClosestStation(LatLng origin, {int max = -1, double maxDist = double.infinity}) async {
    var stations = await getStations();
    if (maxDist != double.infinity) {
      stations = stations.where((s) => getDistanceInKMeter(s, origin) < maxDist).toList();
    }
    stations.sort((a, b) => getDistanceInKMeter(a, origin)
        .compareTo(getDistanceInKMeter(b, origin)));
    if (max > 0) {
      stations = stations.take(max).toList();
    }
    return stations;
  }
}
