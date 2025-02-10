import 'dart:io';

import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:better_bus_v2/core/models/gtfs/line.dart';
import 'package:better_bus_v2/core/models/gtfs/stop_time.dart';
import 'package:better_bus_v2/core/models/gtfs/trip.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
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
    if (data != null) {
      return true;
    }
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
    return Future.value(_data!.stations.values.toList());
  }

  @override
  Future<Map<String, BusLine>> getAllLines() {
    return Future.value({for (var e in _data!.routes.entries) e.value.id: e.value});
  }

  @override
  Future<Timetable> getLineTimetable(Station station, BusLine line) {
    // TODO: implement getLineTimetable
    throw UnimplementedError();
  }

  @override
  Future<List<BusLine>> getPassingLines(Station station) {
    if (station.stops.isEmpty) {
      throw Exception("Station has no stops");
    }
    List<int> stopTrips = [];

    Set<int> validIDs = {station.id};
    validIDs.addAll(station.stops.keys);

    for (var e in data.stopTime.entries) {
      final stopTimes = e.value;
      for (var stopTime in stopTimes) {
        if (stopTime.station != station) continue;
        stopTrips.add(e.key);
      }
    }

    // stopTrips.sort(
    //       (a, b) => data.stopTime[a]!.length
    //       .compareTo(data.stopTime[b]!.length),
    // );
    //
    // stopTrips = stopTrips.reversed.toList();

    List<BusLine> result = [];

    for (var key in stopTrips) {
      GTFSTrip trip = data.trips[key]!;

      result.add(trip.line);
    }
    return Future.value(result);
  }

  @override
  Future<Timetable> getTimetable(Station station) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    Set<String> validServices = data.calendar.getEnablesServices(today);

    List<StopTime> stopTimes = [];


    for (var entrie in data.stopTime.entries) {
      GTFSTrip trip = data.trips[entrie.key]!;
      if (!validServices.contains(trip.serviceID)) continue;

      for (var stopTime in entrie.value) {
        if (station != stopTime.station) continue;
        stopTimes.add(stopTime.toStopTime(trip, today));

      }
    }


    return Future.value(Timetable(station, today, stopTimes: stopTimes));
  }
}