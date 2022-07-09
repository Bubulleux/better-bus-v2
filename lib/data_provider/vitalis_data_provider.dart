import 'dart:convert';
import 'dart:ffi';
import 'dart:developer';

import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        // String transformation: WyIxMDA3NyIsMV0= -> (base 64) ["10077",1] -> (sub string) 10077
        int id = int.parse(
            utf8.decode(base64.decode(rawStop["stop_id"])).substring(2, 7));

        output.add(BusStop(
          rawStop["name"],
          latitude: rawStop["lat"],
          longitude: rawStop["lng"],
          id: id,
        ));
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
          output.add(BusLine(
            rawLine["line_id"],
            rawLine["name"],
            Color(int.parse(rawLine["color"].replaceAll("#", "0xff"))),
            goDirection: rawLine["direction"]["aller"].cast<String>(),
            backDirection: rawLine["direction"]["retour"].cast<String>(),
          ));
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