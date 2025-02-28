import 'package:better_bus_core/src/helper.dart';

import 'bus_network.dart';
import 'gtfs_downloader.dart';
import 'models/bus_line.dart';
import 'models/gtfs/gtfs_data.dart';
import 'models/gtfs/gtfs_path.dart';
import 'models/gtfs/timetable.dart';
import 'models/line_direction.dart';
import 'models/line_timetable.dart';
import 'models/station.dart';
import 'models/traffic_info.dart';

class GTFSProvider extends BusNetwork {
  GTFSProvider({required this.provider});

  GTFSProvider.vitalis(GTFSPaths paths)
      : this(provider: GTFSDataDownloader.vitalis(paths));

  final GTFSDataDownloader provider;
  GTFSData? _data;

  GTFSData get data => _data!;

  @override
  Future<bool> init() async {
    bool pathInit = await provider.paths.init();
    if (!pathInit) {
      // TODO: Make it better, test it
      print("Path provider failded to init");
      return false;
    }
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
    return Future.value(
        {for (var e in _data!.routes.entries) e.value.id: e.value});
  }

  @override
  Future<List<BusLine>> getPassingLines(Station station) {
    if (station.stops.isEmpty) {
      station = data.stations[station.id]!;
    }

    List<BusLine> result = data.trips.entries
        .where((e) => e.value.stopTimes.containsKey(station))
        .map((e) => e.value.line)
        .toSet()
        .toList(growable: false);

    return Future.value(result);
  }

  @override
  Future<GTFSTimeTable> getTimetable(Station station) {
    DateTime now = DateTime.now();

    Set<String> validServices = data.calendar.getEnablesServices(now);

    final trips =
        data.trips.values.where((e) => validServices.contains(e.serviceID));

    return Future.value(GTFSTimeTable(station, now, trips));
  }

  @override
  Future<LineTimetable> getLineTimetable(
      Station station, BusLine line, int direction, DateTime date) {
    DateTime today = date.atMidnight();
    Set<String> validServices = data.calendar.getEnablesServices(today);

    Map<String, String> ends = {};
    Map<DateTime, String> stopTimes = {};

    const labels = "abcdefghijk............";

    for (var trip in data.trips.values) {
      if (!validServices.contains(trip.serviceID) ||
          !trip.stopTimes.containsKey(station) ||
          trip.line != line ||
          trip.direction.directionId != direction) {
        continue;
      }
      if (!ends.containsKey(trip.direction.destination)) {
        ends[trip.direction.destination] = ends.length < labels.length
            ? labels[ends.length]
            : ends.length.toString();
      }
      final stopTime = trip.stopTimes[station]!;
      stopTimes[today.add(stopTime.arrival)] =
          ends[trip.direction.destination]!;
    }
    stopTimes = Map.fromEntries(
        stopTimes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    final result = LineTimetable(
      station,
      line,
      today,
      destinations: {for (var e in ends.entries) e.value: e.key},
      passingTimes: stopTimes,
    );

    return Future.value(result);
  }

  List<LineDirection> getStopDirections(int stopId) {
    final station = data.stopsParent[stopId]!;
    return data.trips.values
        .where((t) => t.stopTimes.keys.contains(station) && t.stopTimes[station]!.stopId == stopId)
        .map((e) => e.direction)
        .toSet()
        .toList();
  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() {
    // TODO: implement getTrafficInfos
    throw UnimplementedError();
  }
}
