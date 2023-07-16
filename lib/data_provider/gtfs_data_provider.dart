import 'dart:convert';
import 'dart:io';

import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:better_bus_v2/model/cvs_parser.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class GTFSDataProvider {
  static final dataSetAPI = Uri.parse(
      "https://transport.data.gouv.fr/api/datasets/58ef2cefa3a7293d49c4e178");
  static const String gtfsFilePath = "/gtfs.zip";
  static const String gtfsDirPath = "/gtfs";

  static GTFSData? gtfsData;

  static Future loadFile() async {
    await downloadFile();
    Directory appSupportDir = await getApplicationSupportDirectory();
    Directory gtfsDir = Directory(appSupportDir.path + gtfsDirPath);

    Map<String, CSVTable> files = loadFiles(gtfsDir);
    gtfsData = GTFSData(files);
  }

  static Map<String, CSVTable> loadFiles(Directory dir) {
    Map<String, CSVTable> files = {};
    for (FileSystemEntity e in dir.listSync()) {
      if (e is! File) continue;

      File file = e;
      files[basename(file.path)] = CSVTable.fromFile(file);
    }
    return files;
  }

  static Future<bool> downloadFile() async {
    if (!await ConnectivityChecker.isConnected()) {
      return false;
    }

    Uri fileUri = await getFileMetaData();

    HttpClient client = HttpClient();
    var request = await client.getUrl(fileUri);
    var response = await request.close();

    if (response.statusCode != 200) return false;

    Directory appTempDir = await getTemporaryDirectory();
    var bytes = await consolidateHttpClientResponseBytes(response);
    await File(appTempDir.path + gtfsFilePath).writeAsBytes(bytes);

    await extractZipFile();
    return true;
  }

  static Future<Uri> getFileMetaData() async {
    http.Response res = await http.get(dataSetAPI);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
    var uri = Uri.parse(json["resources"][0]["original_url"]);
    return uri;
  }

  static Future extractZipFile() async {
    Directory appTempDir = await getTemporaryDirectory();
    Directory appSupportDir = await getApplicationSupportDirectory();
    await ZipFile.extractToDirectory(
        zipFile: File(appTempDir.path + gtfsFilePath),
        destinationDir: Directory(appSupportDir.path + gtfsDirPath));
  }

  static List<BusStop> getStops() {
    print("Get Stops");
    return gtfsData!.stops.values
        .map((e) => BusStop(
              e.stopName,
              e.stopID,
              latitude: e.latitude,
              longitude: e.longitude,
            ))
        .toList();
  }

  static List<BusLine> getStopLines(int stopId) {
    List<String> stopTrips = [];
    GTFSStop stop = gtfsData!.stops[stopId.toString()]!;
    Set<int> validIDs = {stop.stopID};
    validIDs.addAll(stop.child.map((e) => e.id));

    for (List<GTFSStopTime> stopTimes in gtfsData!.stopTime.values) {
      for (var stopTime in stopTimes) {
        if (!validIDs.contains(int.parse(stopTime.stopID))) continue;
        stopTrips.add(stopTime.tripID);
      }
    }

    stopTrips.sort(
      (a, b) => gtfsData!.stopTime[a]!.length
          .compareTo(gtfsData!.stopTime[b]!.length),
    );

    stopTrips = stopTrips.reversed.toList();

    print(validIDs);
    print(stopTrips.length);

    Map<String, List<String>> routeDirectionsA = {};
    Map<String, List<String>> routeDirectionsB = {};

    for (var tripID in stopTrips) {
      GTFSTrip trip = gtfsData!.trips[tripID]!;
      Map<String, List<String>> routeDirection =
          trip.direction ? routeDirectionsA : routeDirectionsB;
      if (!routeDirection.containsKey(trip.routeID)) {
        routeDirectionsA[trip.routeID] = [];
        routeDirectionsB[trip.routeID] = [];
      }
      if (!routeDirection[trip.routeID]!.contains(trip.headSign)) {
        routeDirection[trip.routeID]!.add(trip.headSign);
      }
    }

    List<BusLine> lines = [];

    for (var key in routeDirectionsA.keys) {
      GTFSRoute route = gtfsData!.routes[key]!;
      var line = BusLine(
        route.shortName,
        route.longName,
        route.color,
        goDirection: routeDirectionsA[key]!,
        backDirection: routeDirectionsB[key]!,
      );
      if (route.shortName == "3") {
        print(line.goDirection);
        print(line.backDirection);
      }

      lines.add(line);
    }
    return lines;
  }

  static Timetable getTimetable(
    String stopID,
    String lineID,
    bool direction,
    DateTime date,
  ) {
    DateTime midnightTime = DateTime(date.year, date.month, date.day);
    Set<String> validServices =
        gtfsData!.calendar.getEnablesServices(midnightTime);
    Map<String, List<GTFSStopTime>> schredules = {};

    String routeID = gtfsData!.routes.entries
        .firstWhere((e) => e.value.shortName == lineID)
        .key;

    GTFSStop stop = gtfsData!.stops[stopID]!;
    Set<int> validStopId = stop.child.map((e) => e.id).toSet();

    for (var trip in gtfsData!.trips.entries) {
      if (trip.value.direction != direction) continue;
      if (trip.value.routeID != routeID) continue;
      if (!validServices.contains(trip.value.serviceID)) continue;

      String key = trip.value.headSign;
      if (!schredules.containsKey(key)) {
        schredules[key] = [];
      }

      schredules[key]!.add(gtfsData!.stopTime[trip.key]!
          .firstWhere((e) => validStopId.contains(int.parse(e.stopID))));
    }

    String labels = "abcdefghijk";
    Map<String, String> terminalLabel = {};
    for (var terminal in schredules.keys) {
      terminalLabel[terminal] = labels[terminalLabel.length];
    }

    List<BusSchedule> sortedSchredules = [];

    for (var entrie in schredules.entries) {
      for (var schredule in entrie.value) {
        sortedSchredules.add(BusSchedule(
            midnightTime.add(schredule.arival), terminalLabel[entrie.key]!));
      }
    }
    sortedSchredules.sort((a, b) => a.time.compareTo(b.time));
    return Timetable(sortedSchredules, terminalLabel);
  }
}
