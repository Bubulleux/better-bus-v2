import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullProvider extends NetworkProvider {
  final ConnectivityStatus connStatus = ConnectivityStatus();
  bool get online => connStatus.connected ?? false;
  bool get offline => !online;

  FullProvider({
    required super.api,
    required super.gtfs,
  });


  factory FullProvider.of(BuildContext context) {
    return context.read<FullProvider>();
  }

  @override
  Future<bool> init() async {
    await connStatus.isConnected();
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
    return super.init();
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

}
