import 'dart:convert';

import 'package:better_bus_v2/core/bus_network.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/json.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/core/models/traffic_info.dart';
import 'package:better_bus_v2/data_provider/cache_data_provider.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiProvider extends BusNetworkWithInfo {
  String? token;
  Uri tokenUrl;
  Uri apiUrl;

  ApiProvider({required this.tokenUrl, required this.apiUrl, this.token});

  ApiProvider.vitalis()
      : this(
          tokenUrl: Uri.parse("https://www.vitalis-poitiers.fr/horaires/"),
          apiUrl: Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app"),
        );

  // Old Api caches function, Not really needed if gtfs data is downloaded
  // TODO: Remove cache
  // final stopsCache =
  //     const CacheDataProvider(key: "stops", expiration: Duration(hours: 5));
  // final linesCache =
  //     const CacheDataProvider(key: "lines", expiration: Duration(hours: 5));
  // final trafficInfoCache = const CacheDataProvider(
  //     key: "trafficInfo", expiration: Duration(minutes: 14));

  @override
  Future<bool> init() async {
    if (token != null) {
      return true;
    }
    return _getToken();
  }

  @override
  bool isAvailable() {
    return token != null;
  }

  @override
  Future<List<Station>> getStations() async {
    Uri uri = Uri.parse("$apiUrl/stops");

    // TODO: Add Cache
    List<dynamic> body = await _sendRequest(uri, cache: null);
    List<Station> output = [];
    for (Map<String, dynamic> rawStop in body) {
      output.add(JsonStation(rawStop));
    }
    return output;
  }

  @override
  Future<Map<String, BusLine>> getAllLines() async {
    Uri uri = Uri.parse("$apiUrl/lines");
    List<dynamic> json = await _sendRequest(uri);
    return {
      for (Map<String, dynamic> e in json)
        e["slug"]: JsonBusLine.fromSimpleJson(e)
    };
  }

  @override
  Future<List<BusLine>> getPassingLines(Station station) async {
    Uri uri = Uri.parse("$apiUrl/gtfs/Line/getStationLines.json");
    uri = uri.replace(queryParameters: {
      "station": station.name,
      "networks": "[1]",
    });

    Map<String, dynamic> body = await _sendRequest(uri);
    List<dynamic> rawLines = body["lines"];
    List<BusLine> output = [];
    for (Map<String, dynamic> rawLine in rawLines) {
      output.add(JsonBusLine.fromJson(rawLine));
    }
    return output;
  }

  @override
  Future<Timetable> getTimetable(Station station, {int max = 40}) async {
    Uri uri = Uri.parse("$apiUrl/gtfs/SIRI/getSIRIWithErrors.json");
    uri = uri.replace(queryParameters: {
      "max": max.toString(),
      "stopPoint": station.id.toString(),
      "networks": "[1]",
    });

    Map<String, dynamic> body = await _sendRequest(uri);
    List<dynamic> rawPassages = body["realtime"];
    List<StopTime> realTime = [];
    for (Map<String, dynamic> rawPassage in rawPassages) {
      realTime.add(JsonStopTime(rawPassage));
    }
    return Timetable(station, DateTime.now(), stopTimes: realTime);

    // TODO: Move the match realtime Gtfs algorithm
    // List<NextPassage> output = [];
    // Map<LineDirection, DateTime> directionAccuracy = {};
    // final now = DateTime.now();
    // for (var realNextTime in realTime) {
    //   TripPassage? bestMatch;
    //   final testingTime = realNextTime.betterTime;
    //   final destinationTimes = fullTimetable.entries.firstWhere((e) =>
    //       e.key.line.id == realNextTime.line.id &&
    //       e.key.destination == realNextTime.destination);
    //
    //   for (var curTrip in destinationTimes.value) {
    //     final curTime = curTrip.time;
    //     bestMatch ??= curTrip;
    //     final curTimeDiff = testingTime.difference(curTime);
    //
    //     if (curTimeDiff.abs() < testingTime.difference(bestMatch.time).abs() &&
    //         curTimeDiff > const Duration(minutes: -10)) {
    //       bestMatch = curTrip;
    //     }
    //   }
    //
    //   output.add(realNextTime.copyWith(
    //       aimedTime: bestMatch?.time,
    //       arrivingTimes: GTFSDataProvider.getArrivingTime(
    //           stop.id.toString(), bestMatch?.tripId ?? "")));
    //   if (bestMatch == null) continue;
    //
    //   if (!directionAccuracy.containsKey(destinationTimes.key) ||
    //       bestMatch.time.isAfter(directionAccuracy[destinationTimes.key]!)) {
    //     directionAccuracy[destinationTimes.key] = bestMatch.time;
    //   }
    // }
    // for (var curDirection in fullTimetable.entries) {
    //   DateTime start = directionAccuracy[curDirection.key] ?? now;
    //   output.addAll(curDirection.value.where((e) => e.time.isAfter(start)).map(
    //       (e) => NextPassage(
    //           curDirection.key.line, curDirection.key.destination, e.time,
    //           arrivingTimes: GTFSDataProvider.getArrivingTime(
    //               stop.id.toString(), e.tripId))));
    // }
    // output.sort((a, b) => a.betterTime.compareTo(b.betterTime));
    //
    // return output;
  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() async{
    Uri uri = Uri.parse("$apiUrl/traffics");
    uri = uri.replace(queryParameters: {
      "displayable": "",
    });

    List<dynamic> json = await _sendRequest(uri);
    return json.map((e) => InfoTraffic.fromJson(e)).toList();
  }

  // pull the api Token and return true if found
  // TODO: Make it more robust
  Future<bool> _getToken() async {
    http.Response res = await http.get(tokenUrl);

    if (res.statusCode == 200) {
      int startIndex = res.body.indexOf("token:") + 8;
      int endIndex = res.body.indexOf("'", startIndex);
      token = "Bearer ${res.body.substring(startIndex, endIndex)}";
      return true;
    }
    return false;
  }

  Future<Map<String, String>> _getAutHeader() async {
    if (token == null) {
      await _getToken();
    }

    return {"Authorization": token!};
  }

  // Old send request function, it'll work
  // TODO: Make it Better
  Future<dynamic> _sendRequest(Uri uri,
      {needToken = true, CacheDataProvider? cache}) async {
    int status = -1;
    int countTry = 0;
    http.Response? response;
    if (cache != null) {
      String? cacheData = await cache.getData();
      if (cacheData != null) {
        return jsonDecode(cacheData);
      }
    }

    // TODO: Check Connectivity
    // if (!await ConnectivityChecker.isConnected()) {
    //   throw CustomErrors.noInternet;
    // }

    while (status != 200 && countTry < 3) {
      countTry += 1;
      response = await http.get(uri,
          headers: needToken ? await _getAutHeader() : null);
      status = response.statusCode;
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        dynamic output = jsonDecode(body);
        if (cache != null) {
          await cache.setData(body);
        }
        return output;
      }

      if (response.statusCode == 401 && needToken) {
        await _getToken();
      }
    }
    throw ApiProviderException(response!);
  }

  @override
  Future<Timetable> getLineTimetable(Station station, BusLine line) {
    // TODO: implement getLineTimetable check previous commit
    throw UnimplementedError();
  }
}
