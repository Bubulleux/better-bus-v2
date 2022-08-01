import 'dart:convert';

import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/model/clean/line_boarding.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/clean/next_passage.dart';

class VitalisDataProvider {
  static String? token;

  static Future<void> getToken() async {
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

    http.Response res = await http.get(uri, headers: await getAutHeader());

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<BusStop> output = [];
      for (Map<String, dynamic> rawStop in body) {

        output.add(BusStop.fromJson(rawStop));
      }
      return output;
    } else {
      throw ApiProviderException(res);
    }
  }

  static Future<List<BusLine>?> getLines(BusStop stop) async {
    Uri uri = Uri.parse("https://releases-uxb3m2jh5q-ew.a.run.app/gtfs/Line/getStationLines.json");
    uri = uri.replace(queryParameters: {
      "station": stop.name,
      "networks": "[1]",
    });

    http.Response res = await http.get(uri, headers: await getAutHeader());

    if (res.statusCode == 200) {
      try {
        Map<String, dynamic> body = jsonDecode(res.body);
        List<dynamic> rawLines = body["lines"];
        List<BusLine> output = [];
        for (Map<String, dynamic> rawLine in rawLines) {
          output.add(BusLine.fromJson(rawLine));
        }
        return output;
      } on Exception catch(e) {
        throw ApiProviderException(res, parentException: e);
      }
    } else {
      throw ApiProviderException(res);
    }
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

    http.Response res = await http.get(uri, headers: await getAutHeader());

    if (res.statusCode == 200) {
      try {
        Map<String, dynamic> body = jsonDecode(res.body);
        return LineBoarding.fromJson(body, line);
      } on Exception catch(e) {
        throw ApiProviderException(res, parentException: e);
      }
    } else {
      throw ApiProviderException(res);
    }
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

    http.Response res = await http.get(uri, headers: await getAutHeader());

    if (res.statusCode == 200) {
      try {
        Map<String, dynamic> body = jsonDecode(res.body);
        Timetable output = Timetable.fromJson(body);
        return output;
      } on Exception catch(e) {
        throw ApiProviderException(res, parentException: e);
      }
    } else {
      throw ApiProviderException(res);
    }
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

  static Future<dynamic> sendRequest(Uri uri) async {
    int status = -1;
    int countTry = 0;
    http.Response? response;
    while (status != 200 && countTry < 3) {
      response = await http.get(uri, headers: await getAutHeader());
      status = response.statusCode;
      if (response.statusCode == 200) {
        dynamic output = jsonDecode(response.body);
        return output;
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