import 'dart:io';

import 'package:better_bus_core/core.dart';
import 'package:path_provider/path_provider.dart';

class AppPaths extends GTFSPaths {
  AppPaths() : super.broken();

  @override
  Future<bool> init() async {
    if (extractDir.isNotEmpty && gtfsFilePath.isEmpty) {
      return true;
    }
    Directory appSupportDir = await getApplicationSupportDirectory();
    super.extractDir = "${appSupportDir.path}/gtfs/";

    Directory appTempDir = await getTemporaryDirectory();
    super.gtfsFilePath = "${appTempDir.path}/gtfs.zip";
    return true;
  }
}
