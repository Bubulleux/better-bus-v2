import 'dart:io';

import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/timetable.dart';

class GTFSProvider extends BusNetwork {
  GTFSProvider({required this.provider});

  GTFSProvider.vitalis(GTFSPaths paths) : this(
    provider: GTFSDataDownloader.vitalis(paths)
  );

  final GTFSDataDownloader provider;
  GTFSData? _data;
  GTFSData get data => _data!;

  @override
  Future<bool> init() async{
    final providerData = await provider.getData();
    if (providerData == null) {
      return false;
    }
    _data = providerData;
    return true;
  }

  @override
  bool isAvailable() {
    return _data != null;
  }

  @override
  Future<List<Station>> getStations() {
    // TODO: implement getStations
    throw UnimplementedError();
  }

  @override
  Future<Map<String, BusLine>> getAllLines() {
    // TODO: implement getAllLines
    throw UnimplementedError();
  }

  @override
  Future<Timetable> getLineTimetable(Station station, BusLine line) {
    // TODO: implement getLineTimetable
    throw UnimplementedError();
  }

  @override
  Future<List<BusLine>> getPassingLines(Station station) {
    // TODO: implement getPassingLines
    throw UnimplementedError();
  }

  @override
  Future<Timetable> getTimetable(Station station) {
    // TODO: implement getTimetable
    throw UnimplementedError();
  }



}