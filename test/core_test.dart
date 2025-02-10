import 'dart:io';

import 'package:better_bus_v2/core/api_provider.dart';
import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/gtfs_downloader.dart';
import 'package:better_bus_v2/core/gtfs_provider.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() async {

  final downloader = GTFSDataDownloader.vitalis(
      GTFSPaths.broken()
  );

  final gtfs = GTFSProvider(provider: downloader);
  ApiProvider api = ApiProvider.vitalis();

  setUp(() async{
    await d.dir("gtfs", [
      d.dir("download"),
      d.dir("extract"),
    ]).create();
    downloader.paths = GTFSPaths("${d.sandbox}/gtfs/download/gtfs.zip", "${d.sandbox}/gtfs/extract/");
  });

  // // TODO: Need to be tested
  group("Test Vitalis Api reponse", () {
    testNetwork(api);
    testInfoTrafficProvider(api);
  });

  group("Test Vitalis GTFS", () {

    testGTFSDownloader(downloader);
    testNetwork(gtfs);
  });

  group("Test Networks Equality", () {
    testProviderEquality(api, gtfs);
  });

  group("Test Full Provider", () {
    final provider = FullProvider(api: api, gtfs: gtfs);
    testNetwork(provider);
  });

  group("Faild Test", () {
    failTest();
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
    expect(data.stopTime, isNotEmpty);
    expect(data.routes, isNotEmpty);
    expect(data.calendar, isNotNull);
    expect(data.trips, isNotEmpty);
  });
}

void testProviderEquality(ApiProvider api, GTFSProvider gtfs) {

  test("Test Available", () {
    expect(api.isAvailable(), isTrue);
    expect(gtfs.isAvailable(), isTrue);
  });

  test("Test Station equality", () async {
    final apiStations = await api.getStations();
    final gtfsStations = await gtfs.getStations();

    print("Api Missing Station");
    for (var curStation in gtfsStations) {
      if (apiStations.contains(curStation)) continue;
      print(curStation);
    }
    expect(apiStations.length, (gtfsStations.length));
    expect(apiStations, same(gtfsStations));
  });

  test("Test Line equality", () async {
    final apiLines = await api.getAllLines();
    final gtfsLines = await gtfs.getAllLines();

    print("Api Missing Lines");
    for (var curLine in gtfsLines.entries) {
      if (apiLines.containsKey(curLine.key)) continue;
      print(curLine.value);
    }
    expect(apiLines.length, (gtfsLines.length));
    expect(apiLines, same(gtfsLines));
  });

  test("Station equality", () {
    // final apiResponce = aw
  });

}

void failTest() {
  test("Need To Fail", () {
    print("HAHAH");
    expect(4, 20);
    //expect(actual, matcher)
  });
  test("Need To Fail More", () {
    print("HAHAH");
    expect(false, isTrue);
    //expect(actual, matcher)
  });
  test("Need To Fail too", () {
    print("HAHAH");
    expect([1, 2, 3], isEmpty);
    //expect(actual, matcher)
  });
}
