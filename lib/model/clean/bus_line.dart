import 'package:better_bus_v2/model/clean/terminal.dart';
import 'package:flutter/material.dart';

class BusLine {
  BusLine(this.id, this.fullName, this.color, {this.goDirection, this.backDirection});
  BusLine.example() : this("X", "Some Line name", Colors.red);
  BusLine.fromJson(Map<String, dynamic> json):
      this(
        json["line_id"],
        json["name"],
        Color(int.parse(json["color"].replaceAll("#", "0xff"))),
        goDirection: json["direction"]["aller"].cast<String>(),
        backDirection: json["direction"]["retour"].cast<String>(),
      );

  String id;
  String fullName;
  Color color;
  List<String>? goDirection;
  List<String>? backDirection;

  @override
  bool operator ==(Object other) {
    return other is BusLine && id == other.id;
  }
}