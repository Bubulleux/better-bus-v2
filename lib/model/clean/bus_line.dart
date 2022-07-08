import 'package:better_bus_v2/model/clean/terminal.dart';
import 'package:flutter/material.dart';

class BusLine {
  BusLine(this.id, this.fullName, this.color, {this.goDirection, this.backDirection});
  BusLine.example() : this("X", "Some Line name", Colors.red);

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