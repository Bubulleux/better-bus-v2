import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:better_bus_v2/core/models/gtfs/stop_time.dart';
import 'package:better_bus_v2/core/models/gtfs/timetable.dart';
import 'package:better_bus_v2/core/models/gtfs/trip.dart';
import 'package:better_bus_v2/core/models/line_timetable.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/core/models/traffic_info.dart';
import 'package:better_bus_v2/helper.dart';

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
      throw Exception("Station has no stops");
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

    final trips = data.trips.values.where((e) => validServices.contains(e.serviceID));

    return Future.value(GTFSTimeTable(station, now, trips));
  }

  @override
  Future<LineTimetable> getLineTimetable(
      Station station, BusLine line, int direction, DateTime date) {
    DateTime today = date.atMidnight();
    Set<String> validServices = data.calendar.getEnablesServices(today);

    Map<String, String> ends = {};
    Map<DateTime, String> stopTimes = {};

    const labels = "abcdefghijk";

    for (var trip in data.trips.values) {
      if (!validServices.contains(trip.serviceID) ||
          !trip.stopTimes.containsKey(station)) {
        continue;
      }
      if (!ends.containsKey(trip.direction.destination)) {
        ends[trip.direction.destination] = labels[ends.length];
      }
      final stopTime = trip.stopTimes[station]!;
      stopTimes[today.add(stopTime.arrival)] = ends[trip.direction.destination]!;

    }

    final result = LineTimetable(
      station,
      line,
      today,
      destinations: {for (var e in ends.entries) e.value: e.key},
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
