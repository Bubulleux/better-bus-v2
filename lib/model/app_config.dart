import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'app_paths.dart';

abstract class AppConfig {
  final String cityName;
  final String networkName;
  final LatLng cityLocation;
  final MaterialColor primaryColor;

  AppConfig({required this.cityName, required this.networkName, required this.cityLocation,
  required this.primaryColor});

  FullProvider createProvider();
}

class VitalisAppConfig extends AppConfig {

  VitalisAppConfig() : super(
    cityName: "Poitiers",
    networkName: "Vitalis",
    cityLocation: LatLng(46.58150366398437, 0.3413034114105826),
    primaryColor: Colors.lightGreen
  );

  @override
  FullProvider createProvider() {
    return FullProvider(
      api: ApiProvider.vitalis(),
      gtfs: GTFSProvider.vitalis(AppPaths()),
    );
  }

}