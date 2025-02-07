import 'dart:io';

import 'package:better_bus_v2/core/api_provider.dart';
import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/gtfs_provider.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() async {
  // TODO: Need to be tested
  group("Test Vitalis Api reponse", () {
    ApiProvider api = ApiProvider.vitalis();
    testNetwork(api);
    testInfoTrafficProvider(api);
  });

  group("Test Vitalis GTFS", () {
    final downloader = GTFSDataDownloader.vitalis(
        GTFSPaths.broken()
    );

    final network = GTFSProvider(provider: downloader);

    setUp(() async{
      await d.dir("gtfs", [
        d.dir("download"),
        d.dir("extract"),
      ]).create();
      downloader.paths = GTFSPaths("${d.sandbox}/gtfs/download/gtfs.zip", "${d.sandbox}/gtfs/extract/");
    });

    testGTFSDownloader(downloader);
    testNetwork(network);
  });
}

void testNetwork(BusNetwork network) {
  test("Test init", () async {
    expect(await network.init(), true);
    expect(network.isAvailable(), true);
  });

  test("Test getStations", () async {
    expect(await network.getStations(), isNotEmpty);
  });

  test("Test getAllLines", () async {
    expect(await network.getAllLines(), isNotEmpty);
  });

  test("Test getLine from stop", () async {
    final stations = await network.getStations();
    stations.shuffle();
    // TODO: Move to Vitalis Specific Test
    final nd = stations.firstWhere((e) => e.name.startsWith("Notre-"));
    expect(nd, isNotNull);
    expect(await network.getPassingLines(stations.first), isNotEmpty);
    expect(await network.getPassingLines(nd), isNotEmpty);
  });

  test("Test getTimetable", () async {
    final stations = await network.getStations();
    // TODO: Move to Vitalis Specific Test
    final nd = stations.firstWhere((e) => e.name.startsWith("Notre-"));
    expect(nd, isNotNull);
    final timetable = await network.getTimetable(nd);
    // TODO: Make it more robust
    expect(timetable, isNotNull);
    expect(timetable.stopTimes, isNotEmpty);
  });
}

void testInfoTrafficProvider(BusNetworkWithInfo provider) {
  test("Test Info Traffic", () async {
    expect(provider.isAvailable(), true);
    final infos = await provider.getTrafficInfos();
    expect(infos, isNotEmpty);
  });
}

void testGTFSDownloader(GTFSDataDownloader downloader) {
  test("Test downloader getData()", () async {
    final data = await downloader.getData();
    expect(data, isNotNull);
    if (data == null) {
      return;
    }
    expect(data.stations, isNotEmpty);
    //expect(data.stops, isNotEmpty);
    expect(data.stopTime, isNotEmpty);
    expect(data.routes, isNotEmpty);
    expect(data.calendar, isNotNull);
    expect(data.trips, isNotEmpty);
  });
}
