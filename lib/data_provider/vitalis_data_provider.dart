import 'dart:convert';

import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/model/clean/line_boarding.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/clean/next_passage.dart';
import 'connectivity_checker.dart';

class VitalisDataProvider {
  static String? token;

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
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/stops");

    List<dynamic> body = await sendRequest(uri);
    List<BusStop> output = [];
    for (Map<String, dynamic> rawStop in body) {

      output.add(BusStop.fromJson(rawStop));
    }
    return output;
  }

  static Future<List<BusLine>?> getLines(BusStop stop) async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Line/getStationLines.json");
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

  static Future<List<NextPassage>> getNextPassage(BusStop stop, {int max = 40}) async {
    if (stop.id == -1) {
      throw "Bus Stop need id";
    }

    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/SIRI/getSIRIWithErrors.json");
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

    return output;
  }

  static Future<LineBoarding> getLineBoarding(BusStop stop, BusLine line) async {

    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Station/getBoardingIDs.json");
    uri = uri.replace(queryParameters: {
      "station": stop.name,
      "line": line.id.toString(),
      "networks": "[1]",
    });

    Map<String, dynamic> body = await sendRequest(uri);
    return LineBoarding.fromJson(body, line);
  }

  static Future<Timetable> getTimetable(BusStop stop, BusLine line, int direction, LineBoarding boarding, DateTime date) async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Horaire/getHoraire.json");
    uri = uri.replace(queryParameters: {
      "boarding_id": stop.id.toString(),
      "date": DateFormat("yyyy-MM-dd").format(date),
      "direction" : direction.toString(),
      "line": line.id,
      "stop_id": jsonEncode((direction == 0 ? boarding.back : boarding.go).values.map((k) => k.toString()).toList()),
      "networks": "[1]",
    });

    Map<String, dynamic> body = await sendRequest(uri);
    Timetable output = Timetable.fromJson(body);
    return output;
  }

  static Future<List<InfoTraffic>> getTrafficInfo() async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/traffics");

    List<dynamic> json = await sendRequest(uri);
    return json.map((e) => InfoTraffic.fromJson(e)).toList();
  }

  static Future<Map<String, BusLine>> getAllLines() async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/lines");

    List<dynamic> json = await sendRequest(uri);
    return { for (Map<String, dynamic>  e in json) e["slug"]: BusLine.fromSimpleJson(e)};
  }

  static Future<List<MapPlace>> getPlaceAutocomplet(String input) async{
    Uri uri = Uri.parse("https://autosuggest.search.hereapi.com/v1/autosuggest");
    uri = uri.replace(queryParameters: {
      // "types": "address,place",
      "q": input.replaceAll(" ", "+"),
      "in": "circle:46.56690062723211,0.34005607254464293;r=50000",
      "apiKey": "ESWcIHAoVm5EPLoAva-cz0lnaH_NnUZGv4WhmoneSRI",
    });

    Map<String, dynamic> json = await sendRequest(uri, needToken: false);
    List<MapPlace> output = [];
    for (Map<String, dynamic> e in json["items"]){
      if (e.containsKey("position")){
        output.add(MapPlace.fromJson(e));
      }
    }
    return output;
  }

  static Future<List<VitalisRoute>> getVitalisRoute(MapPlace start, MapPlace end, DateTime date, String timeType, {int count = 5}) async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Itinerary/getItineraries.json");
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

    print(date.millisecondsSinceEpoch / 1000);

    dynamic rawJson = await sendRequest(uri);
    if (rawJson is Map<String, dynamic>){
      return [];
    }
    List<dynamic> json = rawJson;
    return json.map((e) => VitalisRoute.fromJson(e)).toList().cast<VitalisRoute>();
  }

  static Future<dynamic> sendRequest(Uri uri, {needToken = true}) async {
    int status = -1;
    int countTry = 0;
    http.Response? response;

    if (!await ConnectivityChecker.isConnected()) {
      throw CustomErrors.noInternet;
    }

    while (status != 200 && countTry < 3) {
      countTry += 1;
      response = await http.get(uri, headers: needToken ? await getAutHeader() : null);
      status = response.statusCode;
      if (response.statusCode == 200) {
        dynamic output = jsonDecode(response.body);
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