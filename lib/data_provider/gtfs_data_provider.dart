import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

// import 'package:archive/archive_io.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/next_passage.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:better_bus_v2/model/cvs_parser.dart';
import 'package:better_bus_v2/model/gtfs_data.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatasetMetadata {
  Uri ressourceUri;
  DateTime updateTime;

  DatasetMetadata(this.ressourceUri, this.updateTime);
}

class GTFSDataProvider {
  static final dataSetAPI = Uri.parse(
      "https://data.grandpoitiers.fr/data-fair/api/v1/datasets/offre-de-transport-du-reseau-vitalis");
  static final gtfsFileURL = Uri.parse("https://data.grandpoitiers.fr/data-fair/api/v1/datasets/2gwvlq16siyb7d9m3rqt1pb1/metadata-attachments/gtfs.zip");
  static const String gtfsFilePath = "/gtfs.zip";
  static const String gtfsDirPath = "/gtfs";

  static GTFSData? gtfsData;

  static Future loadFile({bool forceDownload = false}) async {
    if (gtfsData != null && !forceDownload) return;

    await downloadFile(forceDownload: forceDownload);


    Directory appSupportDir = await getApplicationSupportDirectory();
    Directory gtfsDir = Directory(appSupportDir.path + gtfsDirPath);

    Map<String, CSVTable> files = loadFiles(gtfsDir);

    if (files.isEmpty) {
      throw CustomErrors.noGTFS;
    }
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

  static Future<bool> downloadFile({bool forceDownload = false}) async {
    return false;
    if (!await ConnectivityChecker.isConnected()) {
      return false;
    }

    bool downloadWhenWifi = await LocalDataHandler.getDownloadWhenWifi();
    bool isWifiConnected = await ConnectivityChecker.isWifiConnected();
    if (downloadWhenWifi && !isWifiConnected && !forceDownload) {
      return false;
    }

    late HttpClientResponse? response;
    try {

      DatasetMetadata metadata = await getFileMetaData();
      DateTime? lastUpdate = await LocalDataHandler.getGTFSDownloadDate();

      if (lastUpdate != null &&
          metadata.updateTime.isBefore(lastUpdate) &&
          !forceDownload) {
        return false;
      }

      HttpClient client = HttpClient();
      var request = await client.getUrl(metadata.ressourceUri);
      response = await request.close();
      if (response.statusCode != 200) return false;

    } on Exception {
      return false;
    }

    Directory appTempDir = await getTemporaryDirectory();
    var bytes = await consolidateHttpClientResponseBytes(response);
    await File(appTempDir.path + gtfsFilePath).writeAsBytes(bytes);

    await extractZipFile();
    await LocalDataHandler.setGTFSDownloadDate(DateTime.now());

    return true;
  }

  static Future<DatasetMetadata> getFileMetaData() async {
    http.Response res = await http.get(dataSetAPI);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    var ressource = json["attachments"].firstWhere((e) => e["title"] == "gtfs.zip");

    var uri = Uri.parse(ressource["url"]);
    DateTime updateTime = DateTime.parse(ressource["updatedAt"]);

    return DatasetMetadata(uri, updateTime);
  }

  static Future extractZipFile() async {
    Directory appTempDir = await getTemporaryDirectory();
    Directory appSupportDir = await getApplicationSupportDirectory();
    // await extractFileToDisk(appTempDir.path + gtfsFilePath,
    //   appSupportDir.path + gtfsDirPath);
    // await ZipFile.extractToDirectory(
    //     zipFile: File(appTempDir.path + gtfsFilePath),
    //     destinationDir: Directory(appSupportDir.path + gtfsDirPath));
  }

  static List<BusStop> getStops() {
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

      lines.add(line);
    }
    return lines;
  }

  static Future deleteGTFSData() async {
    await LocalDataHandler.setGTFSDownloadDate(null);
    var appSupportDir = await getApplicationSupportDirectory();
    var dir = Directory(appSupportDir.path + gtfsDirPath);
    for (FileSystemEntity e in dir.listSync()) {
      if (e is! File) continue;
      File file = e;
      await file.delete();
    }
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

      List<GTFSStopTime> stopTime = gtfsData!.stopTime[trip.key]!
          .where((e) => validStopId.contains(int.parse(e.stopID)))
          .toList();
      if (stopTime.isEmpty) continue;

      String key = trip.value.headSign;

      if (!schredules.containsKey(key)) {
        schredules[key] = [];
      }
      schredules[key]!.add(stopTime[0]);
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

  static List<NextPassage> getNextPassage(String stopID, {int max = 100}) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    Set<String> validServices = gtfsData!.calendar.getEnablesServices(today);
    Map<String, Duration> tripPassage = {};

    Set<int> validStopId =
        gtfsData!.stops[stopID]!.child.map((e) => e.id).toSet();

    for (var entrie in gtfsData!.stopTime.entries) {
      GTFSTrip trip = gtfsData!.trips[entrie.key]!;
      if (!validServices.contains(trip.serviceID)) continue;

      for (var stopTime in entrie.value) {
        if (!validStopId.contains(int.parse(stopTime.stopID))) continue;
        DateTime arivalTime = today.add(stopTime.arival);
        if (arivalTime.isBefore(now)) continue;

        tripPassage[entrie.key] = stopTime.arival;
      }
    }

    List<NextPassage> nextPassages = [];

    for (var entrie in tripPassage.entries) {
      GTFSTrip trip = gtfsData!.trips[entrie.key]!;
      GTFSRoute route = gtfsData!.routes[trip.routeID]!;

      BusLine line = BusLine(route.shortName, route.longName, route.color);
      List<ArrivingTime> arrivalTimes = gtfsData!.stopTime[entrie.key]!
        .where((element) => element.arival > entrie.value).map((e) => 
        ArrivingTime(gtfsData!.allStops[e.stopID]!.stopName, e.arival)).toList();
      DateTime arrivalTime = today.add(entrie.value);
      NextPassage nextPassage = NextPassage(
        line,
        trip.headSign,
        false,
        arrivalTime,
        arrivalTime,
        arrivalTimes,
      );
      nextPassages.add(nextPassage);
    }

    nextPassages.sort((a, b) => a.expectedTime.compareTo(b.expectedTime));
    if (nextPassages.length > max) {
      nextPassages = nextPassages.sublist(0, max);
    }

    return nextPassages;
  }
}
