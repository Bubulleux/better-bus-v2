
import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:better_bus_v2/core/models/gtfs/trip.dart';
import 'package:better_bus_v2/core/models/line_timetable.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/core/models/traffic_info.dart';
import 'package:better_bus_v2/helper.dart';

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
    if (_data != null) {
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

  @override
  Future<LineTimetable> getLineTimetable(Station station, BusLine line, int direction, DateTime date) {
    DateTime today = date.atMidnight();
    Set<String> validServices = data.calendar.getEnablesServices(today);

    Map<String, String> ends = {};
    Map<DateTime, String> stopTimes = {};

    const labels = "abcdefghijk";

    for (var entry in data.stopTime.entries) {
      GTFSTrip trip = data.trips[entry.key]!;
      if (!validServices.contains(trip.serviceID) ||
        trip.directionId != direction) {
        continue;
      }

      for (var stopTime in entry.value) {
        if (station != stopTime.station) continue;
        if (!ends.containsKey(trip.direction.destination)) {
          ends[trip.direction.destination] = labels[ends.length];
        }
        stopTimes[today.add(stopTime.arival)] = ends[trip.direction.destination]!;

      }
    }


    final result = LineTimetable(station, line, today,
      destinations: { for (var e in ends.entries) e.value: e.key},
      passingTimes: stopTimes,
    );
    
    return Future.value(result);
  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() {
    // TODO: implement getTrafficInfos
    throw UnimplementedError();
  }
}