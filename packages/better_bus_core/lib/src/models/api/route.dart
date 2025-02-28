
import 'package:flutter/material.dart';

import '../../helper.dart';
import '../bus_line.dart';

class VitalisRoute {
  VitalisRoute({required this.id, required this.itinerary, required this.polyLines});

  VitalisRoute.fromJson(Map<String, dynamic> json): this(
    id: json["id"],
    itinerary: json["itinerary"].map((e) => RoutePassage.fromJson(e)).toList().cast<RoutePassage>(),
    polyLines: json["polylines"].map((e) => PolyLine.fromJson(e)).toList().cast<PolyLine>(),
  );

  String id;
  List<RoutePassage> itinerary;
  List<PolyLine> polyLines;

  Duration get timeTravel  {
    Duration sum = const Duration();
    for(RoutePassage passage in itinerary) {
      sum += passage.travelTime;
    }
    return sum;
  }

  int get busDistanceTravel  {
    int sum = 0;
    for(RoutePassage passage in itinerary) {
      if (passage.lines == null){
        continue;
      }
      sum += passage.travelDistance;
    }
    return sum;
  }

  int get walkDistanceTravel  {
    int sum = 0;
    for(RoutePassage passage in itinerary) {
      if (passage.lines != null){
        continue;
      }
      sum += passage.travelDistance;
    }
    return sum;
  }
}


class RoutePassage {
  RoutePassage({
    required this.startPlace,
    required this.endPlace,
    required this.startTime,
    required this.endTime,
    this.lines,
    required this.instruction,
    required this.type,
    required this.travelTime,
    required this.travelDistance,
  });

  RoutePassage.fromJson(Map<String, dynamic> json): this(
    startPlace: json["start"],
    endPlace: json["end"],

    startTime: DateTime.parse(json["startTime"]),
    endTime: DateTime.parse(json["endTime"]),

    lines: json["line"] != null ? RouteLine.fromJson(json["line"]) : null,

    instruction: json["instruction"],

    travelDistance: json["travelDistance"],
    travelTime: Duration(seconds: json["travelTime"]),

    type: json["type"],
  );

  String startPlace;
  String endPlace;

  DateTime startTime;
  DateTime endTime;

  RouteLine? lines;

  String instruction;

  Duration travelTime;
  int travelDistance;

  String type;
}

class PolyLine {
  PolyLine({required this.lineString, required this.lineColor, required this.lineWidth});

  PolyLine.fromJson(Map<String, dynamic> json): this(
    lineString: json["lineString"].cast<double>(),
    lineColor: json["style"]["strokeColor"] == "gray" ? Colors.grey : colorFromHex(json["style"]["strokeColor"]),
    lineWidth: json["style"]["lineWidth"],
  );

  List<double> lineString;
  Color lineColor;
  int lineWidth;
}

class RouteLine  extends BusLine {
  RouteLine({required this.name, required this.destination, required this.color}):
        super(name, destination, color, directions: {});

  RouteLine.fromJson(Map<String, dynamic> json): this(
    name: json["lineName"],
    destination: json["destination"],
    color: colorFromHex(json["lineBackground"]),
  );

  String name;
  String destination;
  Color color;
}
