import 'dart:convert';

import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:better_bus_v2/model/clean/line_boarding.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:http/http.dart' as http;

import '../model/clean/next_passage.dart';
import 'cache_data_provider.dart';
import 'connectivity_checker.dart';

class VitalisDataProvider {
  static String? token;
  static CacheDataProvider stopsCache =
      const CacheDataProvider(key: "stops", expiration: Duration(hours: 5));
  static CacheDataProvider linesCache =
      const CacheDataProvider(key: "lines", expiration: Duration(hours: 5));
  static CacheDataProvider trafficInfoCache = const CacheDataProvider(
      key: "trafficInfo", expiration: Duration(minutes: 14));

  static Future<void> getToken() async {
    if (!await ConnectivityChecker.isConnected()) {
      return;
    }

    Uri uri = Uri.parse("https://www.vitalis-poitiers.fr/horaires/");
    http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      int startIndex = res.body.indexOf("token:") + 8;
      int endIndex = res.body.indexOf("'", startIndex);
      token = "Bearer " + res.body.substring(startIndex, endIndex);
    }
  }

  static Future<Map<String, String>> getAutHeader() async {
    if (token == null) {
      await getToken();
    }

    return {"Authorization": token!};
  }

  static Future<List<BusStop>?> getStops() async {
    if (GTFSDataProvider.gtfsData != null) {
      return GTFSDataProvider.getStops();
    }

    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/stops");

    List<dynamic> body = await sendRequest(uri, cache: stopsCache);
    List<BusStop> output = [];
    for (Map<String, dynamic> rawStop in body) {
      output.add(BusStop.fromJson(rawStop));
    }
    return output;
  }

  static Future<List<BusLine>?> getLines(BusStop stop) async {
    if (GTFSDataProvider.gtfsData != null) {
      return GTFSDataProvider.getStopLines(stop.id);
    }
    Uri uri = Uri.parse(
        "https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Line/getStationLines.json");
    uri = uri.replace(queryParameters: {
      "station": stop.name,
      "networks": "[1]",
    });

    Map<String, dynamic> body = await sendRequest(uri);
    List<dynamic> rawLines = body["lines"];
    List<BusLine> output = [];
    for (Map<String, dynamic> rawLine in rawLines) {
      output.add(BusLine.fromJson(rawLine));
    }
    return output;
  }

  static Future<List<NextPassage>> getNextPassage(BusStop stop,
      {int max = 40}) async {
    List<NextPassage>? gtfsNextPassage;
    if (GTFSDataProvider.gtfsData != null) {
      gtfsNextPassage = GTFSDataProvider.getNextPassage(stop.id.toString());
      if (!await ConnectivityChecker.isConnected()) {
        return gtfsNextPassage;
      }
    }

    if (stop.id == -1) {
      throw "Bus Stop need id";
    }

    Uri uri = Uri.parse(
        "https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/SIRI/getSIRIWithErrors.json");
    uri = uri.replace(queryParameters: {
      "max": max.toString(),
      "stopPoint": stop.id.toString(),
      "networks": "[1]",
    });

    Map<String, dynamic> body = await sendRequest(uri);
    List<dynamic> rawPassages = body["realtime"];
    List<NextPassage> output = [];
    for (Map<String, dynamic> rawPassage in rawPassages) {
      output.add(NextPassage.fromJson(rawPassage));
    }

    if (gtfsNextPassage == null) return output;

    for (var nextPassage in output) {
      gtfsNextPassage.removeWhere((e) =>
          e.aimedTime.toUtc().isAtSameMomentAs(nextPassage.realTime
              ? nextPassage.aimedTime
              : nextPassage.expectedTime) &&
          e.line.id == nextPassage.line.id);
    }
    output += gtfsNextPassage;
    output.sort((a, b) => a.expectedTime.compareTo(b.expectedTime));

    return output;
  }

  static Future<LineBoarding> getLineBoarding(
      BusStop stop, BusLine line) async {
    Uri uri = Uri.parse(
        "https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Station/getBoardingIDs.json");
    uri = uri.replace(queryParameters: {
      "station": stop.name,
      "line": line.id.toString(),
      "networks": "[1]",
    });

    Map<String, dynamic> body = await sendRequest(uri);
    return LineBoarding.fromJson(body, line);
  }

  static Future<Timetable> getTimetable(
      BusStop stop, BusLine line, int direction, DateTime date) async {
    if (GTFSDataProvider.gtfsData == null) {
      throw CustomErrors.noGTFS;
    }

    return GTFSDataProvider.getTimetable(
        stop.id.toString(), line.id, direction == 1, date);
  }

  static Future<List<InfoTraffic>> getTrafficInfo() async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/traffics");
    uri = uri.replace(queryParameters: {
      "displayable": "",
    });

    List<dynamic> json = await sendRequest(uri, cache: trafficInfoCache);
    return json.map((e) => InfoTraffic.fromJson(e)).toList();
  }

  static Future<Map<String, BusLine>> getAllLines() async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/lines");

    List<dynamic> json = await sendRequest(uri, cache: linesCache);
    return {
      for (Map<String, dynamic> e in json) e["slug"]: BusLine.fromSimpleJson(e)
    };
  }

  static Future<List<MapPlace>> getPlaceAutoComplete(String input) async {
    Uri uri =
        Uri.parse("https://autosuggest.search.hereapi.com/v1/autosuggest");
    uri = uri.replace(queryParameters: {
      // "types": "address,place",
      "q": input.replaceAll(" ", "+"),
      "in": "circle:46.56690062723211,0.34005607254464293;r=50000",
      "apiKey": "ESWcIHAoVm5EPLoAva-cz0lnaH_NnUZGv4WhmoneSRI",
    });

    Map<String, dynamic> json = await sendRequest(uri, needToken: false);
    List<MapPlace> output = [];
    for (Map<String, dynamic> e in json["items"]) {
      if (e.containsKey("position")) {
        output.add(MapPlace.fromJson(e));
      }
    }
    return output;
  }

  static Future<List<VitalisRoute>> getVitalisRoute(
      MapPlace start, MapPlace end, DateTime date, String timeType,
      {int count = 5}) async {
    Uri uri = Uri.parse(
        "https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Itinerary/getItineraries.json");
    uri = uri.replace(queryParameters: {
      "start": "[${start.latitude},${start.longitude}]",
      "end": "[${end.latitude},${end.longitude}]",
      "start_name": start.title,
      "end_name": end.title,
      "count": count.toString(),
      "date": (date.millisecondsSinceEpoch / 1000).round().toString(),
      "date_type": timeType,
      "networks": "[1]",
    });

    dynamic rawJson = await sendRequest(uri);
    if (rawJson is Map<String, dynamic>) {
      return [];
    }
    List<dynamic> json = rawJson;
    return json
        .map((e) => VitalisRoute.fromJson(e))
        .toList()
        .cast<VitalisRoute>();
  }

  static Future<dynamic> sendRequest(Uri uri,
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

    if (!await ConnectivityChecker.isConnected()) {
      throw CustomErrors.noInternet;
    }

    while (status != 200 && countTry < 3) {
      countTry += 1;
      response =
          await http.get(uri, headers: needToken ? await getAutHeader() : null);
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
        await getToken();
      }
    }
    throw ApiProviderException(response!);
  }
}

class ApiProviderException implements Exception {
  ApiProviderException(this.response, {this.parentException});

  http.Response response;
  Exception? parentException;

  @override
  String toString() {
    return "Http Request exception\nStatus: ${response.statusCode}\nBody:\n${response.body}"
        "${parentException != null ? '\nParent Exception:\n' + parentException.toString() : ""}";
  }
}
