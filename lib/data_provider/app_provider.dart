import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../views/stops_search_page/stops_search_page.dart';
import 'radar_provider.dart';

class FullProvider extends NetworkProvider {
  final ConnectivityStatus connStatus = ConnectivityStatus();
  late final AppRadarProvider radar;
  bool get online => connStatus.connected ?? false;
  bool get offline => !online;

  FullProvider({
    required super.api,
    required super.gtfs,
  }) {
    radar = AppRadarProvider(provider: this);
  }


  factory FullProvider.of(BuildContext context) {
    return context.read<FullProvider>();
  }

  @override
  Future<bool> init() async {
    print("Starting full init");
    await connStatus.isConnected();
    print("Conn $online");
    if (offline) {
      print("No Internet connected only GTFS DATA");
      connStatus.onConnected(() async {
        print("Internet connection found Api'll get inited");
        await api.init();
        gtfs.init();
        print("Api inited: ${api.isAvailable()}");

      });

      await gtfs.init(offline: true);
      return gtfs.isAvailable();
    }
    bool success = await super.init();
    success &= await radar.init();

    print("App Provider full init sucess $success");

    return success;
  }

  Future awaitInit() async {
    while(!isAvailable()) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }


  @override
  bool isAvailable() {
    return api.isAvailable() || gtfs.isAvailable();
  }



  @override
  Future<List<InfoTraffic>> getTrafficInfos() {
    print("Connec status ${connStatus.connected}, ${connStatus.disconnected}");
    if (connStatus.disconnected == true) {
      throw CustomErrors.noInternet;
    }
    return super.getTrafficInfos();
  }

  Future<List<Station>> getClosestStation(LatLng origin, {int max = -1}) async {
    var stations = await getStations();
    stations.sort((a, b) =>
        getDistanceInKMeter(a, origin).compareTo(getDistanceInKMeter(b, origin)));
    if (max > 0) {
      stations = stations.take(max).toList();
    }
    return stations;
  }

}
