import 'package:better_bus_core/src/api_provider.dart';
import 'package:better_bus_core/src/bus_network.dart';
import 'package:better_bus_core/src/full_provider.dart';
import 'package:better_bus_core/src/gtfs_downloader.dart';
import 'package:better_bus_core/src/gtfs_provider.dart';
import 'package:better_bus_core/src/models/bus_line.dart';
import 'package:better_bus_core/src/models/gtfs/gtfs_path.dart';
import 'package:better_bus_core/src/models/station.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() async {

  final downloader = GTFSDataDownloader.vitalis(
      GTFSPaths.broken()
  );

  final gtfs = GTFSProvider(provider: downloader);
  ApiProvider api = ApiProvider.vitalis();

  setUp(() async {
    await d.dir("gtfs", [
      d.dir("download"),
      d.dir("extract"),
    ]).create();
    downloader.paths = GTFSPaths("${d.sandbox}/gtfs/download/gtfs.zip", "${d.sandbox}/gtfs/extract/");
  });
  const stationName = "Northampton";
  const lineId = "2B";
  const directionId = 0;

  // TODO: Need to be tested
  group("Test Vitalis Api reponse", () {
    testNetwork(api, stationName, lineId, directionId);
  });

  group("Test Vitalis GTFS", () {

    testGTFSDownloader(downloader);
    testNetwork(gtfs, stationName, lineId, directionId);
  });

  group("Test Networks Equality", () {
    testProviderEquality(api, gtfs);
  });

  group("Test Full Provider", () {
    final provider = FullProvider(api: api, gtfs: gtfs);
    testNetwork(provider, stationName, lineId, directionId);
  });

  group("Faild Test", () {
    failTest();
  });
}

void testNetwork(BusNetwork network, String testStationName, String lineTestName, int directionId) {
  List<Station>? stations;
  Station? station;
  BusLine? line;
  test("Test init", () async {
    expect(await network.init(), true);
    expect(network.isAvailable(), true);
  });

  test("Test getStations", () async {
    stations = await network.getStations();
    expect(stations, isNotEmpty);
    station = stations!.firstWhere((e) => e.name.startsWith(testStationName));
    expect(station, isNotNull);
  });

  test("Test getAllLines", () async {
    final lines = await network.getAllLines();
    expect(lines, isNotEmpty);

    line = lines[lineTestName];
    expect(line, isNotNull);

    // Check that all line have 1 or 2 directions.
    for (var curLine in lines.values) {
      final dirIds = curLine.directions.map((e) => e.directionId).toSet();
      expect(dirIds, isNotEmpty);
      expect(dirIds.length, lessThanOrEqualTo(2));
    }
  });

  test("Test getLine from stop", () async {
    expect(station, isNotNull);
    expect(await network.getPassingLines(station!), isNotEmpty);
  });

  test("Test getTimetable", () async {
    expect(station, isNotNull);
    final timetable = await network.getTimetable(station!);
    // TODO: Make it more robust
    expect(timetable, isNotNull);
    expect(timetable.getNext(), isNotEmpty);
  });

  test("Get Line Timetable", () async {
    expect(station, isNotNull);
    expect(line, isNotNull);
    final timetable = await network.getLineTimetable(station!, line!, directionId,
    DateTime.now(), );

    expect(timetable, isNotNull);
    expect(timetable.passingTimes, isNotEmpty);
    expect(timetable.destinations, isNotEmpty);
  });

  test("Test Info Traffic", () async {
    expect(network.isAvailable(), true);
    final infos = await network.getTrafficInfos();
    expect(infos, isNotEmpty);
  });
}


void testGTFSDownloader(GTFSDataDownloader downloader) {
  test("Test downloader getData()", () async {
    var downloadDate = await downloader.getDownloadDate();
    expect(downloadDate, isNull);

    var sucess = await downloader.downloadFile();
    expect(sucess, isTrue);

    downloadDate = await downloader.getDownloadDate();
    expect(downloadDate, isNotNull);

    final data = await downloader.loadFile();
    expect(data, isNotNull);

    sucess = await downloader.downloadFile();
    expect(sucess, isFalse);

    if (data == null) return;

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
