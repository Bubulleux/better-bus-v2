import 'dart:convert';
import 'dart:ffi';
import 'dart:developer';

import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      "max": max,
      "stopPoint": stop.id,
      "networks": "[1]",
    });

    http.Response res = await http.get(uri, headers: await getAutHeader());

    if (res.statusCode == 200) {
      try {
        Map<String, dynamic> body = jsonDecode(res.body);
        List<dynamic> rawPassages = body["realtime"];
        List<NextPassage> output = [];
        for (Map<String, dynamic> rawPassage in rawPassages) {
          output.add(NextPassage.fromJson(rawPassage));
        }
        return output;
      } on Exception catch(e) {
        throw ApiProviderException(res, parentException: e);
      }
    } else {
      throw ApiProviderException(res);
    }
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